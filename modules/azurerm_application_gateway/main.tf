data "azurerm_subnet" "data_snet" {
  for_each             = var.app_gateways
  name                 = each.value.name_data_snet
  virtual_network_name = each.value.virtual_network_name
  resource_group_name  = each.value.resource_group_name
}

data "azurerm_public_ip" "data_pip" {
  for_each            = var.app_gateways
  name                = each.value.name_data_pip
  resource_group_name = each.value.resource_group_name
}

data "azurerm_virtual_machine" "data_vm" {
  for_each            = var.app_gateways
  name                = each.value.name_data_vm
  resource_group_name = each.value.resource_group_name
}

resource "azurerm_application_gateway" "app_gateways" {
  for_each            = var.app_gateways
  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  location            = each.value.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "gateway-ip-config"
    subnet_id = data.azurerm_subnet.data_snet[each.key].id
  }

  frontend_port {
    name = "frontend-port-80"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "frontend-ip-config"
    public_ip_address_id = data.azurerm_public_ip.data_pip[each.key].id
  }

  backend_address_pool {
    name         = "backend-pool"
    ip_addresses = [data.azurerm_virtual_machine.data_vm[each.key].private_ip_address]
  }

  backend_http_settings {
    name                  = "http-settings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = "http-listener"
    frontend_ip_configuration_name = "frontend-ip-config"
    frontend_port_name             = "frontend-port-80"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "routing-rule"
    rule_type                  = "Basic"
    http_listener_name         = "http-listener"
    backend_address_pool_name  = "backend-pool"
    backend_http_settings_name = "http-settings"
    priority                   = 1
  }
}
