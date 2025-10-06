# Data source to get AKS node IPs dynamically
data "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-${var.naming_prefix}"
  resource_group_name = var.resource_group_name
}

# Public IP for Application Gateway
resource "azurerm_public_ip" "appgw" {
  name                = "pip-${var.naming_prefix}-appgw"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.tags
}

# User Assigned Managed Identity for Application Gateway
resource "azurerm_user_assigned_identity" "appgw" {
  name                = "uai-${var.naming_prefix}-appgw"
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}

# Application Gateway
resource "azurerm_application_gateway" "main" {
  name                = "appgw-${var.naming_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  # Managed Identity
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.appgw.id]
  }

  # Gateway IP Configuration
  gateway_ip_configuration {
    name      = "appgw-ip-configuration"
    subnet_id = var.appgw_subnet_id
  }

  # Frontend IP Configuration
  frontend_ip_configuration {
    name                 = "appgw-feip"
    public_ip_address_id = azurerm_public_ip.appgw.id
  }

  # Frontend Port
  frontend_port {
    name = "port_80"
    port = 80
  }

  frontend_port {
    name = "port_443"
    port = 443
  }

  # Backend Address Pool (AKS subnet for auto-discovery)
  backend_address_pool {
    name = "appgw-beap"
    # Application Gateway will auto-discover healthy nodes in AKS subnet
  }

  # Backend HTTP Settings
  backend_http_settings {
    name                  = "appgw-be-htst"
    cookie_based_affinity = "Disabled"
    path                  = "/"
    port                  = 31998  # nginx-ingress NodePort for HTTP
    protocol              = "Http"
    request_timeout       = 60
    pick_host_name_from_backend_address = false
  }

  # HTTP Listener
  http_listener {
    name                           = "appgw-httplstn"
    frontend_ip_configuration_name = "appgw-feip"
    frontend_port_name             = "port_80"
    protocol                       = "Http"
  }

  # Request Routing Rule
  request_routing_rule {
    name                       = "appgw-rqrt"
    priority                   = 9
    rule_type                  = "Basic"
    http_listener_name         = "appgw-httplstn"
    backend_address_pool_name  = "appgw-beap"
    backend_http_settings_name = "appgw-be-htst"
  }

  tags = var.tags
}