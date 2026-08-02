# ☁️ Azure Modular Infrastructure as Code (Terraform)

This repository contains a clean, modular **Terraform (Infrastructure as Code)** project designed to deploy a complete, production-ready Azure environment. It demonstrates industry best practices such as **reusable modules**, **dependency management**, and **environment separation**.

---

## 🏗️ Project Overview

The project deploys an Azure infrastructure architecture in the **Japan West** (`japanwest`) region. It provisions a Virtual Network with specialized subnets, secure remote access via **Azure Bastion**, web traffic routing via **Application Gateway**, outbound internet connectivity via **NAT Gateways**, and backend **Linux Virtual Machines**.

### **High-Level Architecture**
```text
+-----------------------------------------------------------------------------------+
| RESOURCE GROUP: demo_rg (japanwest)                                               |
|                                                                                   |
|  +-----------------------------------------------------------------------------+  |
|  | VIRTUAL NETWORK: alpha_vnet (10.20.0.0/16)                                  |  |
|  |                                                                             |  |
|  |  +--------------------+  +--------------------+  +-----------------------+  |  |
|  |  | Subnet: alpha_snet |  | Subnet: beta_snet  |  | Subnet: agw_snet      |  |  |
|  |  | (10.20.1.0/24)     |  | (10.20.2.0/24)     |  | (10.20.4.0/24)        |  |  |
|  |  |                    |  |                    |  |                       |  |  |
|  |  |  [ Linux VM 1 ]    |  |  [ Linux VM 2 ]    |  | [ Application Gateway]|  |  |
|  |  |  + NAT Gateway     |  |  + NAT Gateway     |  |   + NAT Gateway       |  |  |
|  |  +--------------------+  +--------------------+  +-----------------------+  |  |
|  |                                                                             |  |
|  |  +-----------------------------------------------------------------------+  |  |
|  |  | Subnet: AzureBastionSubnet (10.20.3.0/26)                             |  |  |
|  |  |  [ Azure Bastion Host ] + NAT Gateway + Public IP                     |  |  |
|  |  |  (Provides secure, browser-based SSH access to VMs without open RDP/SSH)|  |  |
|  |  +-----------------------------------------------------------------------+  |  |
|  +-----------------------------------------------------------------------------+  |
+-----------------------------------------------------------------------------------+
```

---

## 📂 File & Folder Structure

The codebase is organized into two main sections: **Modules** (reusable building blocks) and **Environments** (where the building blocks are assembled and configured).

```text
practice 19-7-26/
├── modules/                               # 📦 Reusable Terraform Modules
│   ├── azurerm_resource_group/            # Creates Azure Resource Groups
│   ├── azurerm_virtual_network/           # Creates Virtual Networks (VNets)
│   ├── azurerm_subnet/                    # Creates Subnets within VNets
│   ├── azurerm_pip/                       # Creates Public IP Addresses (PIPs)
│   ├── azurerm_virtual_machine/           # Creates Linux Virtual Machines & NICs
│   ├── azurerm_bastion_host/              # Creates Azure Bastion for secure access
│   ├── azurerm_application_gateway/       # Creates L7 Application Gateways
│   └── azurerm_nat_gateway/               # Creates NAT Gateways & Subnet associations
│
└── environment/                           # 🚀 Deployment Environments
    ├── config.yaml                        # Secret scanning rules for Gitleaks
    ├── .gitleaks.toml                     # Gitleaks configuration to prevent exposed credentials
    └── prod/                              # 🌐 Production Environment Configuration
        ├── provider.tf                    # Azure provider (azurerm v4.80.0) configuration
        ├── variable.tf                    # Input variable definitions
        ├── terraform.tfvars               # Actual values & parameters for resources
        └── main.tf                        # Connects and executes all modules in order
```

---

## 🧩 Detailed Explanation of the Code

### 1. The Modules (`/modules`)
Instead of writing all code in a single massive file, each resource type lives in its own folder under `modules/`.
* **Dynamic & Scalable:** Every module uses Terraform's `for_each` loop. This means a single module can create **1 or 100 resources** dynamically based on the map of objects passed into it.
* **Separation of Concerns:** For example, `azurerm_nat_gateway` handles creating the NAT Gateway *and* associating it with its respective subnet automatically.

### 2. The Production Environment (`/environment/prod`)
This folder is where the infrastructure is actually instantiated and deployed.

* **`provider.tf`**: Configures the official HashiCorp Azure Provider (`hashicorp/azurerm`) locked at version `4.80.0`.
* **`variable.tf`**: Declares variables for each module (`rgs`, `vnets`, `snets`, `pips`, `vms`, `bastions`, `app_gateways`, `nat_gateways`).
* **`terraform.tfvars`**: Contains the **data definitions** for what gets built in `japanwest`:
  * **Resource Group:** `demo_rg`
  * **Virtual Network:** `alpha_vnet` (`10.20.0.0/16`)
  * **4 Subnets:** `alpha_snet`, `beta_snet`, `AzureBastionSubnet` (dedicated for Bastion), and `agw_snet` (dedicated for Application Gateway).
  * **4 Public IPs:** Assigned to VMs, Bastion, and Application Gateway.
  * **2 Linux VMs:** `alphavm` and `betavm` (Size: `Standard_B1s`).
  * **1 Bastion Host:** `demo_bastion` for secure shell access.
  * **1 Application Gateway:** `demo_agw` for reverse proxy web traffic routing.
  * **4 NAT Gateways:** Attached to each subnet for secure outbound internet routing.
* **`main.tf`**: The **orchestrator**. It calls each module from `../../modules/...` and passes the corresponding variable from `terraform.tfvars`. 
  * It uses `depends_on` to ensure resources are created in the exact required order (e.g., VMs won't attempt to deploy until the subnets and public IPs exist).

---

## ⚙️ How It Works (The Execution Flow)

When Terraform runs in `environment/prod`, it builds the infrastructure in a strict, dependency-safe sequence:

1. **Resource Group Creation:** Terraform creates `demo_rg` first.
2. **Network Infrastructure:**
   * Creates `alpha_vnet` inside `demo_rg`.
   * Splits `alpha_vnet` into 4 subnets (`alpha_snet`, `beta_snet`, `AzureBastionSubnet`, `agw_snet`).
   * Provisions Public IP addresses (`alpha_pip`, `beta_pip`, `bastion_pip`, `agw_pip`).
3. **Compute & Security Layer:**
   * Deploys **Linux VMs** into `alpha_snet` and `beta_snet`.
   * Deploys the **Azure Bastion Host** into `AzureBastionSubnet` and attaches its Public IP.
   * Deploys **NAT Gateways** and links them to their respective subnets for outbound internet traffic.
4. **Traffic Management Layer:**
   * Deploys the **Application Gateway** into `agw_snet`, attaching it to `agw_pip` and pointing backend traffic to `alphavm`.

---

## 🔒 Security Features Included

* **No Open SSH Ports:** By deploying **Azure Bastion**, administrators can securely SSH into Linux VMs directly from the Azure Portal browser over SSL (Port 443) without exposing Port 22 to the public internet.
* **Outbound Traffic Control:** **NAT Gateways** provide predictable, secure outbound IP addressing for subnets, preventing IP exhaustion and enhancing network security.
* **Secret Scanning:** The repository includes `environment/config.yaml` and `.gitleaks.toml` to integrate with **Gitleaks**, ensuring passwords or API keys are not accidentally committed to version control.

---

## 🚀 How to Run & Deploy

To deploy or manage this infrastructure, open your terminal and follow these steps:

### 1. Navigate to the Environment Directory
```bash
cd "environment/prod"
```

### 2. Initialize Terraform
Downloads the required Azure provider (`azurerm`) and initializes the local modules:
```bash
terraform init
```

### 3. Review the Execution Plan
Previews what resources Terraform will create, modify, or destroy in Azure:
```bash
terraform plan
```

### 4. Apply / Deploy Infrastructure
Provisions the resources in your Azure subscription (type `yes` when prompted):
```bash
terraform apply
```

### 5. Clean Up / Destroy Resources
When you are done practicing and want to remove all resources to avoid incurring Azure costs:
```bash
terraform destroy
```

---
*Created as part of Terraform Azure Landing Zone & Modular IaC Practice.*
