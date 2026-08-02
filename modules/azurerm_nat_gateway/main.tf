data "azurerm_subnet" "data_snet" {
  for_each             = var.nat_gateways
  name                 = each.value.name_data_snet
  virtual_network_name = each.value.virtual_network_name
  resource_group_name  = each.value.resource_group_name
}

resource "azurerm_nat_gateway" "nat_gateways" {
  for_each            = var.nat_gateways
  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  sku_name            = "Standard"
}

resource "azurerm_subnet_nat_gateway_association" "nat_associations" {
  for_each       = var.nat_gateways
  subnet_id      = data.azurerm_subnet.data_snet[each.key].id
  nat_gateway_id = azurerm_nat_gateway.nat_gateways[each.key].id
}
