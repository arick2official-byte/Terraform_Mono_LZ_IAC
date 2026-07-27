data "azurerm_subnet" "data_snet" {
  for_each             = var.bastions
  name                 = each.value.name_data_snet
  virtual_network_name = each.value.virtual_network_name
  resource_group_name  = each.value.resource_group_name
}

data "azurerm_public_ip" "data_pip" {
  for_each            = var.bastions
  name                = each.value.name_data_pip
  resource_group_name = each.value.resource_group_name
}

resource "azurerm_bastion_host" "bastion_hosts" {
  for_each            = var.bastions
  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name

  ip_configuration {
    name                 = each.value.ip_config_name
    subnet_id            = data.azurerm_subnet.data_snet[each.key].id
    public_ip_address_id = data.azurerm_public_ip.data_pip[each.key].id
  }
}
