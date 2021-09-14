
data "azurerm_subnet" "addsubnet" {
  name                 = "shs-prd-us-northcentral-ADD-SUBNET_10.205.0.0_26"
  virtual_network_name = "shs-prd-us-northcentral-vnet_10.205.0.0_22"
  resource_group_name  = "shs-prd-northcentralus-connectivity-rg"
}

resource "azurerm_network_interface" "nic_vm" {
  name                = "${local.settings.dnsnicname}${format("%02d", count.index + 1)}"
  location            = azurerm_resource_group.ADDS.location
  resource_group_name = azurerm_resource_group.ADDS.name
  count = 2
  

  ip_configuration {
    name                          = "${local.settings.ipname}${format("%02d", count.index + 1)}-nic"
    subnet_id                     = data.azurerm_subnet.addsubnet.id
    private_ip_address_allocation = local.settings.ipallocationtype
    private_ip_address            = local.settings.dcip[count.index]
  }

  tags = local.settings.tags

}



/*resource "azurerm_availability_set" "avail" {
  name                = local.settings.name
  location            = local.settings.location
  resource_group_name = azurerm_resource_group.ADDS.name
  managed             = local.settings.managed
  tags                =  local.settings.tags
}*/

### Commented out line 33-60


resource "azurerm_virtual_machine" "virtual_machine" {
  name                             = "${local.settings.dnsname}-${format("%02d", count.index + 1)}"
  location                         = azurerm_resource_group.ADDS.location
  resource_group_name              = azurerm_resource_group.ADDS.name
  network_interface_ids            = ["${azurerm_network_interface.nic_vm[count.index].id}"]
  vm_size                          = local.settings.dnsvmsize
  #availability_set_id             =  azurerm_availability_set.avail.id
  delete_data_disks_on_termination = local.settings.deletedatadisk
  count = 2
  #zones =[2]

  storage_image_reference {
    publisher = local.settings.publisher
    offer     = local.settings.offer
    sku       = local.settings.skuwindows
    version   = local.settings.version
  }
  os_profile {
    computer_name  = "seihub-dns"
    admin_username = "seihubdns001"
    admin_password = "Clientxyz789!"
  }
  storage_os_disk {
    name              = "${local.settings.storagediskname}-${format("%02d", count.index + 1)}"
    create_option     = local.settings.create_option
    managed_disk_type = local.settings.managed_disk_type
  }
  

  /*storage_data_disk {
    name              = "${local.settings.dnsname}-${format("%02d", count.index + 1)}-data-disk1"
    caching           = "None"
    create_option     = "Empty"
    disk_size_gb      = 120
    lun               = 1
  } */

##Commnented out line 73 -79


  os_profile_windows_config {
    provision_vm_agent        = local.settings.provision_vm_agent
    enable_automatic_upgrades = local.settings.enable_automatic_upgrades
  }

  tags = local.settings.tags
}


##Commented out line 86-107


resource "azurerm_virtual_machine_extension" "vm_vme" {

  name                 = "${element(azurerm_virtual_machine.virtual_machine.*.name, count.index)}"
  virtual_machine_id   = azurerm_virtual_machine.virtual_machine[count.index].id
  publisher            = local.settings.mmapublisher
  type                 = local.settings.mmatype
  type_handler_version = local.settings.type_handler_version
  count = 2

  settings = <<SETTINGS
        {
           "workspaceId": "33880c3f-7dc9-475c-9e69-d7d60706e5a0"
        }
        SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
        {
          "workspaceKey": "G91s1y6x/jp8fceeedcCteW5e6j+cNksx8NTOyOCSx/g8vlrl9ocxLeOmEBMBEXBi07u0GepV294lsmPjXW87A=="
        }
        PROTECTED_SETTINGS
}



/*
resource "azurerm_virtual_machine_extension" "vme_cs_EXAMPLE" {
  name                 = "CS_DNS"
  virtual_machine_id   = azurerm_virtual_machine.virtual_machine[count.index].id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"
  count = 2

  settings = <<SETTINGS
    {
        "fileUris": [
            "${azurerm_storage_blob.dnsblob.url}"
            ]
                            }
                  SETTINGS



  protected_settings = <<PROTECTED_SETTINGS
        {
          "storageAccountName": "${azurerm_storage_account.storage.name}",
          "storageAccountKey": "${azurerm_storage_account.storage.primary_access_key}",
          "commandToExecute": "powershell -ExecutionPolicy Unrestricted -file ${azurerm_storage_blob.dnsblob.name}"
        }
       PROTECTED_SETTINGS
}
*/

/*resource "azurerm_virtual_machine_extension" "vmextension" {
  count                      = "${lower(var.vm_os_type) == "windows" ? 1 : 0}"
  name                       = "${random_string.password.result}"
  location                   = "${data.azurerm_resource_group.test.location}"
  resource_group_name        = "${data.azurerm_resource_group.test.name}"
  virtual_machine_name       = "${var.vm_name}"
  publisher                  = "Microsoft.Azure.Security"
  type                       = "AzureDiskEncryption"
  type_handler_version       = "${var.type_handler_version == "" ? "2.2" : var.type_handler_version}"
  auto_upgrade_minor_version = true


  settings = <<SETTINGS
    {
        "EncryptionOperation": "${var.encrypt_operation}",
        "KeyVaultURL": "${data.azurerm_key_vault.keyvault.vault_uri}",
        "KeyVaultResourceId": "${data.azurerm_key_vault.keyvault.id}",					
        "KeyEncryptionKeyURL": "${var.encryption_key_url}",
        "KekVaultResourceId": "${data.azurerm_key_vault.keyvault.id}",					
        "KeyEncryptionAlgorithm": "${var.encryption_algorithm}",
        "VolumeType": "${var.volume_type}"
    }*/

/*resource "azurerm_key_vault_key" "encryption_key" {
  name         = local.settings.encryptkvname
  key_vault_id = azurerm_key_vault.keyvault.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
}


resource "azurerm_virtual_machine_extension" "vm_encrypt" {
  name                       = local.settings.encryptname
  virtual_machine_id         = azurerm_virtual_machine.virtual_machine[count.index].id
  #location                   = var.location
  #resource_group_name        = var.rg_name
  #virtual_machine_name       = azurerm_virtual_machine.virtual_machine.name
  publisher                  = "Microsoft.Azure.Security"
  type                       = "AzureDiskEncryption"
  type_handler_version       = "2.2"
  auto_upgrade_minor_version = "true"

  settings = <<SETTINGS
    {
      "EncryptionOperation": "EnableEncryption",
      "KeyVaultURL": "${var.vault_url}",
      "KeyVaultResourceId": "${var.vault_resourceid}",
      "KeyEncryptionKeyURL": "${var.vault_url}/keys/${azurerm_key_vault_key.encryption_key.name}/${azurerm_key_vault_key.encryption_key.version}",
      "KekVaultResourceId":"${var.vault_resourceid}",   
      "KeyEncryptionAlgorithm": "RSA-OAEP",
      "VolumeType": "all"
      }
SETTINGS
} */


/*
resource "azurerm_virtual_machine_extension" "vm_antix" {

  name                       = local.settings.antiname
  virtual_machine_id         = azurerm_virtual_machine.virtual_machine[count.index].id
  publisher                  = local.settings.antipublisher
  type                       = local.settings.antitype
  type_handler_version       = local.settings.antihandler_version
  auto_upgrade_minor_version = local.settings.antiupgrade
  count = 2

  settings = <<SETTINGS
    {
      "AntimalwareEnabled": true,
      "RealtimeProtectionEnabled": "true",
      "ScheduledScanSettings": {
      "isEnabled": "true",
      "day": "1",
      "time": "120",
      "scanType": "Quick"
        },
      "Exclusions": {
      "Extensions": "",
      "Paths": "",
      "Processes": ""
        }
      }
SETTINGS
} 
*/