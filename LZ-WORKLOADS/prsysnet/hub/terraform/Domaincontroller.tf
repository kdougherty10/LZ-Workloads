
/*resource "azurerm_network_interface" "nic_vm" {
  name                = "${local.settings.nicname}${format("%02d", count.index + 1)}"
  location            = azurerm_resource_group.ADDS.location
  resource_group_name = azurerm_resource_group.ADDS.name
  count = 2

  ip_configuration {
    name                          = "${local.settings.ipname}${format("%02d", count.index + 1)}-nic"
    subnet_id                     = azurerm_subnet.addsubnet.id
    private_ip_address_allocation = local.settings.ipallocationtype
    private_ip_address            = local.settings.dcip[count.index]
  }

  tags = local.settings.tags

}

resource "azurerm_availability_set" "avail" {
  name                = local.settings.name
  location            = local.settings.location
  resource_group_name = azurerm_resource_group.ADDS.name
  managed             = local.settings.managed
  tags                =  local.settings.tags
}

resource "azurerm_virtual_machine" "virtual_machine" {
  name                             = "${local.settings.domaincontroller1}-${format("%02d", count.index + 1)}"
  location                         = azurerm_resource_group.ADDS.location
  resource_group_name              = azurerm_resource_group.ADDS.name
  network_interface_ids            = ["${azurerm_network_interface.nic_vm[count.index].id}"]
  vm_size                          = local.settings.vmsize
  availability_set_id             =  azurerm_availability_set.avail.id
  delete_data_disks_on_termination = local.settings.deletedatadisk
  count = 2

  storage_image_reference {
    publisher = local.settings.publisher
    offer     = local.settings.offer
    sku       = local.settings.skuwindows
    version   = local.settings.version
  }
  os_profile {
    computer_name  = "clientaz-DC"
    admin_username = "clientaz001"
    admin_password = "Clientxyz789!"
  }
  storage_os_disk {
    name              = "${local.settings.storagediskname}-${format("%02d", count.index + 1)}"
    create_option     = local.settings.create_option
    managed_disk_type = local.settings.managed_disk_type
  }

  storage_data_disk {
    name              = "${local.settings.domaincontroller1}-${format("%02d", count.index + 1)}-data-disk1"
    caching           = "None"
    create_option     = "Empty"
    disk_size_gb      = 120
    lun               = 1
  }  

  os_profile_windows_config {
    provision_vm_agent        = local.settings.provision_vm_agent
    enable_automatic_upgrades = local.settings.enable_automatic_upgrades
  }

  tags = local.settings.tags
}

resource "azurerm_virtual_machine_extension" "vm_vme" {

  name                 = "${element(azurerm_virtual_machine.virtual_machine.*.name, count.index)}"
  virtual_machine_id   = azurerm_virtual_machine.virtual_machine[count.index].id
  publisher            = local.settings.mmapublisher
  type                 = local.settings.mmatype
  type_handler_version = local.settings.type_handler_version
  count = 2

  settings = <<SETTINGS
        {
           "workspaceId": "${local.settings.workspaceId}"
        }
        SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
        {
          "workspaceKey": "${local.settings.workspaceKey}"
        }
        PROTECTED_SETTINGS
}

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
    }

resource "azurerm_virtual_machine_extension" "vm_antix" {
  name                       = "${azurerm_virtual_machine.virtual_machine.name}-${local.settings.antiname}"
  location                   = azurerm_resource_group.ADDS.location
  resource_group_name        = azurerm_resource_group.ADDS.name
  virtual_machine_name       = azurerm_virtual_machine.virtual_machine.name
  publisher                  = local.settings.antipublisher
  type                       = local.settings.antitype
  type_handler_version       = local.settings.antihandler_version
  auto_upgrade_minor_version = local.settings.antiupgrade

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
} */
