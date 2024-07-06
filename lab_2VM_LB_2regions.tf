###############################################################
# Terraform deployment script for lab purposes.
# Action Items:
## Create vNets
## Create Resource Groups
## Create 2 VMS in two regions
## Create load balancer
## Create NSGs as needed
###############################################################

# Define the provider
provider "azurerm" {
  features {}
}

# Variables for the configurations
variable "location1" {
  default = "Central US"
}

variable "location2" {
  default = "East US 2"
}

variable "vm_size" {
  default = "Standard_B1s"
}

variable "admin_username" {
  default = "azureuser"
}

variable "admin_password" {
  description = "Admin password for the VM"
}

# Resource Group 1
resource "azurerm_resource_group" "rg1" {
  name     = "TerraformIaC-001"
  location = var.location1
}

# Resource Group 2
resource "azurerm_resource_group" "rg2" {
  name     = "TerraformIaC-002"
  location = var.location2
}

# Virtual Network 1
resource "azurerm_virtual_network" "vnet1" {
  name                = "vnet1"
  address_space       = ["10.2.0.0/16"]
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name
}

# Subnet 1
resource "azurerm_subnet" "subnet1" {
  name                 = "subnet1"
  resource_group_name  = azurerm_resource_group.rg1.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = ["10.2.1.0/24"]
}

# Virtual Network 2
resource "azurerm_virtual_network" "vnet2" {
  name                = "vnet2"
  address_space       = ["10.3.0.0/16"]
  location            = azurerm_resource_group.rg2.location
  resource_group_name = azurerm_resource_group.rg2.name
}

# Subnet 2
resource "azurerm_subnet" "subnet2" {
  name                 = "subnet2"
  resource_group_name  = azurerm_resource_group.rg2.name
  virtual_network_name = azurerm_virtual_network.vnet2.name
  address_prefixes     = ["10.3.1.0/24"]
}

# Network Security Group for VM1
resource "azurerm_network_security_group" "nsg1" {
  name                = "nsg1"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name
}

resource "azurerm_network_security_rule" "allow_ssh1" {
  name                        = "allow_ssh1"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg1.name
  network_security_group_name = azurerm_network_security_group.nsg1.name
}

# Network Security Group for VM2
resource "azurerm_network_security_group" "nsg2" {
  name                = "nsg2"
  location            = azurerm_resource_group.rg2.location
  resource_group_name = azurerm_resource_group.rg2.name
}

resource "azurerm_network_security_rule" "allow_ssh2" {
  name                        = "allow_ssh2"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg2.name
  network_security_group_name = azurerm_network_security_group.nsg2.name
}

# Network Interface 1
resource "azurerm_network_interface" "nic1" {
  name                = "nic1"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name
  network_security_group_id = azurerm_network_security_group.nsg1.id

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Network Interface 2
resource "azurerm_network_interface" "nic2" {
  name                = "nic2"
  location            = azurerm_resource_group.rg2.location
  resource_group_name = azurerm_resource_group.rg2.name
  network_security_group_id = azurerm_network_security_group.nsg2.id

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet2.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Virtual Machine 1
resource "azurerm_linux_virtual_machine" "vm1" {
  name                = "vm1"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  network_interface_ids = [azurerm_network_interface.nic1.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "22_04-lts"
    version   = "latest"
  }

  boot_diagnostics {
    enabled = true
  }

  # Auto-shutdown configuration
  scheduled_events {
    time_zone  = "Central Standard Time"
    daily_maintenance_window {
      start_time = "01:00"
      duration   = "01:00"
    }
  }
}

# Virtual Machine 2
resource "azurerm_linux_virtual_machine" "vm2" {
  name                = "vm2"
  resource_group_name = azurerm_resource_group.rg2.name
  location            = azurerm_resource_group.rg2.location
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  network_interface_ids = [azurerm_network_interface.nic2.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "22_04-lts"
    version   = "latest"
  }

  boot_diagnostics {
    enabled = true
  }

  # Auto-shutdown configuration
  scheduled_events {
    time_zone  = "Central Standard Time"
    daily_maintenance_window {
      start_time = "01:00"
      duration   = "01:00"
    }
  }
}

# Public IP for Load Balancer
resource "azurerm_public_ip" "lb_public_ip" {
  name                = "lb_public_ip"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Load Balancer
resource "azurerm_lb" "my_lb" {
  name                = "myLoadBalancer"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "LoadBalancerFrontEnd"
    public_ip_address_id = azurerm_public_ip.lb_public_ip.id
  }
}

# Load Balancer Backend Address Pool
resource "azurerm_lb_backend_address_pool" "bpepool" {
  name                = "BackEndAddressPool"
  loadbalancer_id     = azurerm_lb.my_lb.id
  resource_group_name = azurerm_resource_group.rg1.name
}

# Load Balancer Probe
resource "azurerm_lb_probe" "lbprobe" {
  name                = "http_probe"
  resource_group_name = azurerm_resource_group.rg1.name
  loadbalancer_id     = azurerm_lb.my_lb.id
  protocol            = "Tcp"
  port                = 80
}

# Load Balancer Rule
resource "azurerm_lb_rule" "lbrule" {
  name                           = "http_rule"
  resource_group_name            = azurerm_resource_group.rg1.name
  loadbalancer_id                = azurerm_lb.my_lb.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "LoadBalancerFrontEnd"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.bpepool.id
  probe_id                       = azurerm_lb_probe.lbprobe.id
}

# Adding VM1 to Load Balancer Backend Pool
resource "azurerm_network_interface_backend_address_pool_association" "vm1_lb_association" {
  network_interface_id    = azurerm_network_interface.nic1.id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.bpepool.id
}

# Adding VM2 to Load Balancer Backend Pool
resource "azurerm_network_interface_backend_address_pool_association" "vm2_lb_association" {
  network_interface_id    = azurerm_network_interface.nic2.id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.bpepool.id
}
