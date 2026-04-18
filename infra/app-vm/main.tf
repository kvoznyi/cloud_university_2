resource "azurerm_public_ip" "app" {
  name                = "pip-${var.project_name}-app"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags = merge(var.tags, {
    component = "app-vm"
  })
}
resource "azurerm_network_interface" "app" {
  name                = "nic-${var.project_name}-app"
  location            = var.location
  resource_group_name = var.resource_group_name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.app.id
  }
  tags = merge(var.tags, {
    component = "app-vm"
  })
}
resource "azurerm_linux_virtual_machine" "app" {
  name                            = "vm-${var.project_name}-app"
  location                        = var.location
  resource_group_name             = var.resource_group_name
  size                            = var.vm_size
  admin_username                  = var.admin_username
  disable_password_authentication = true
  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_public_key_path)
  }
  network_interface_ids = [
    azurerm_network_interface.app.id
  ]
  os_disk {
    name                 = "osdisk-${var.project_name}-app"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 30
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  custom_data = base64encode(templatefile("${path.module}/cloud-init.yaml", {
    acr_login_server = var.acr_login_server
    acr_username     = var.acr_username
    acr_password     = var.acr_password
    docker_image     = var.docker_image
  }))
  tags = merge(var.tags, {
    component = "app-vm"
    lab       = "LR2"
  })
}