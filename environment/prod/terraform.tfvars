rgs = {
  rg1 = {
    name     = "demo_rg"
    location = "japanwest"
  }
   rg2 = {
    name     = "demo_rg2"
    location = "japanwest"
  }
}

vnets = {
  vnet1 = {
    name                = "alpha_vnet"
    location            = "japanwest"
    resource_group_name = "demo_rg"
    address_space       = ["10.20.0.0/16"]
  }
}

snets = {
  snet1 = {
    name                 = "alpha_snet"
    virtual_network_name = "alpha_vnet"
    resource_group_name  = "demo_rg"
    address_prefixes     = ["10.20.1.0/24"]

  }
  snet2 = {
    name                 = "beta_snet"
    virtual_network_name = "alpha_vnet"
    resource_group_name  = "demo_rg"
    address_prefixes     = ["10.20.2.0/24"]

  }
  bastion_snet = {
    name                 = "AzureBastionSubnet"
    virtual_network_name = "alpha_vnet"
    resource_group_name  = "demo_rg"
    address_prefixes     = ["10.20.3.0/26"]
  }
  agw_snet = {
    name                 = "agw_snet"
    virtual_network_name = "alpha_vnet"
    resource_group_name  = "demo_rg"
    address_prefixes     = ["10.20.4.0/24"]
  }
}

pips = {
  pip1 = {
    name                = "alpha_pip"
    resource_group_name = "demo_rg"
    location            = "japanwest"
  }
  pip2 = {
    name                = "beta_pip"
    resource_group_name = "demo_rg"
    location            = "japanwest"
  }
  bastion_pip = {
    name                = "bastion_pip"
    resource_group_name = "demo_rg"
    location            = "japanwest"
  }
  agw_pip = {
    name                = "agw_pip"
    resource_group_name = "demo_rg"
    location            = "japanwest"
  }
}

vms = {
  vm1 = {
    nic_name             = "alpha_nic"
    location             = "japanwest"
    resource_group_name  = "demo_rg"
    ip_config_name       = "alpha_config"
    name_data_snet       = "alpha_snet"
    virtual_network_name = "alpha_vnet"
    name_data_pip        = "alpha_pip"
    vm_name              = "alphavm"
    vm_size              = "Standard_B1s"
    admin_username       = "devops_admin"
    admin_password       = "linux@2011"
  }

  vm2 = {
    nic_name             = "beta_nic"
    location             = "japanwest"
    resource_group_name  = "demo_rg"
    ip_config_name       = "beta_config"
    name_data_snet       = "beta_snet"
    virtual_network_name = "alpha_vnet"
    name_data_pip        = "beta_pip"
    vm_name              = "betavm"
    vm_size              = "Standard_B1s"
    admin_username       = "devops_admin"
    admin_password       = "Linux@2011"
  }
}

bastions = {
  bastion1 = {
    name                 = "demo_bastion"
    location             = "japanwest"
    resource_group_name  = "demo_rg"
    ip_config_name       = "bastion_config"
    name_data_snet       = "AzureBastionSubnet"
    virtual_network_name = "alpha_vnet"
    name_data_pip        = "bastion_pip"
  }
}

app_gateways = {
  agw1 = {
    name                 = "demo_agw"
    resource_group_name  = "demo_rg"
    location             = "japanwest"
    name_data_snet       = "agw_snet"
    virtual_network_name = "alpha_vnet"
    name_data_pip        = "agw_pip"
    name_data_vm         = "alphavm"
  }
}

nat_gateways = {
  nat1 = {
    name                 = "alpha_nat"
    resource_group_name  = "demo_rg"
    location             = "japanwest"
    name_data_snet       = "alpha_snet"
    virtual_network_name = "alpha_vnet"
  }
  nat2 = {
    name                 = "beta_nat"
    resource_group_name  = "demo_rg"
    location             = "japanwest"
    name_data_snet       = "beta_snet"
    virtual_network_name = "alpha_vnet"
  }
  bastion_nat = {
    name                 = "bastion_nat"
    resource_group_name  = "demo_rg"
    location             = "japanwest"
    name_data_snet       = "AzureBastionSubnet"
    virtual_network_name = "alpha_vnet"
  }
  agw_nat = {
    name                 = "agw_nat"
    resource_group_name  = "demo_rg"
    location             = "japanwest"
    name_data_snet       = "agw_snet"
    virtual_network_name = "alpha_vnet"
  }
}

