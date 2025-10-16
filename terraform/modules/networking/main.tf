# Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = "vnet-${var.naming_prefix}"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# AKS Subnet
resource "azurerm_subnet" "aks" {
  name                 = "snet-aks-${var.naming_prefix}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Private Endpoints Subnet
resource "azurerm_subnet" "private_endpoints" {
  name                 = "snet-pe-${var.naming_prefix}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Network Security Group for AKS
resource "azurerm_network_security_group" "aks" {
  name                = "nsg-aks-${var.naming_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  # Allow internal AKS communication
  security_rule {
    name                       = "AllowAKSInternal"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "10.0.1.0/24"
    destination_address_prefix = "10.0.1.0/24"
  }

  # Allow HTTP from Internet for LoadBalancer services
  security_rule {
    name                       = "AllowHTTPFromInternet"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "Internet"
    destination_address_prefix = "10.0.1.0/24"
  }

  # Allow HTTPS from Internet for LoadBalancer services
  security_rule {
    name                       = "AllowHTTPSFromInternet"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "Internet"
    destination_address_prefix = "10.0.1.0/24"
  }

  # Block other direct internet access
  security_rule {
    name                       = "DenyDirectInternet"
    priority                   = 4000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "10.0.1.0/24"
  }
}

# Associate NSG with AKS subnet
resource "azurerm_subnet_network_security_group_association" "aks" {
  subnet_id                 = azurerm_subnet.aks.id
  network_security_group_id = azurerm_network_security_group.aks.id
}

# Route Table for controlled routing
resource "azurerm_route_table" "aks" {
  name                = "rt-aks-${var.naming_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  # Route to force traffic through Azure Firewall (optional)
  route {
    name           = "DefaultRoute"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "Internet"
  }
}

# Associate Route Table with AKS subnet
resource "azurerm_subnet_route_table_association" "aks" {
  subnet_id      = azurerm_subnet.aks.id
  route_table_id = azurerm_route_table.aks.id
}