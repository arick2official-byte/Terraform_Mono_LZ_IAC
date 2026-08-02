module "resource_group" {
  source = "../../modules/azurerm_resource_group"
  rgs    = var.rgs
}

module "virtual_networks" {
  depends_on = [module.resource_group]
  source     = "../../modules/azurerm_virtual_network"
  vnets = var.vnets
}

module "subnets" {
  depends_on = [module.virtual_networks]
  source     = "../../modules/azurerm_subnet"
  snets      = var.snets
}

module "public_ips" {
  depends_on = [module.resource_group]
  source     = "../../modules/azurerm_pip"
  pips       = var.pips
}

module "virtual_machines" {
  depends_on = [module.subnets, module.public_ips]
  source     = "../../modules/azurerm_virtual_machine"
  vms        = var.vms
}

module "bastion_hosts" {
  depends_on = [module.subnets, module.public_ips]
  source     = "../../modules/azurerm_bastion_host"
  bastions   = var.bastions
}

module "app_gateways" {
  depends_on   = [module.subnets, module.public_ips, module.virtual_machines]
  source       = "../../modules/azurerm_application_gateway"
  app_gateways = var.app_gateways
}

module "nat_gateways" {
  depends_on   = [module.subnets]
  source       = "../../modules/azurerm_nat_gateway"
  nat_gateways = var.nat_gateways
}

