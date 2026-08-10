# Project Variables
variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "remote-ssh-vscode"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "chinanorth3"
}

variable "arm_client_id" {
  description = "Azure Service Principal Client ID"
  type        = string
}

variable "arm_client_secret" {
  description = "Azure Service Principal Client Secret"
  type        = string
}

variable "arm_tenant_id" {
  description = "Azure Tenant ID"
  type        = string
}

variable "arm_subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "resource_group_name" {
  description = "Name of resource group for resources"
  type        = string
  default     = "RG-SSH-REMOTE-VSCODE"
}

# Network Variables (Existing Resources)
variable "network_resource_group_name" {
  description = "Name of existing resource group for network resources"
  type        = string
}

variable "vnet_name" {
  description = "Name of existing virtual network"
  type        = string
}

variable "subnet_name" {
  description = "Name of existing subnet"
  type        = string
}

variable "security_group_name" {
  description = "Name of existing security group"
  type        = string
}

# VM Variables
variable "vm_size" {
  description = "Azure VM size"
  type        = string
  default     = "Standard_B2s"
}

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key file"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

# Spot Instance Configuration
variable "spot_instance" {
  description = "Spot instance configuration"
  type = object({
    enabled         = bool
    eviction_policy = string # Deallocate or Delete
    max_price       = string # Use -1 for maximum price
  })
  default = {
    enabled         = true
    eviction_policy = "Deallocate"
    max_price       = "-1"
  }
}

# OS Image Variables
variable "image_publisher" {
  description = "Publisher of the VM image"
  type        = string
  default     = "Canonical"
}

variable "image_offer" {
  description = "Offer of the VM image"
  type        = string
  default     = "0001-com-ubuntu-server-jammy"
}

variable "image_sku" {
  description = "SKU of the VM image"
  type        = string
  default     = "22_04-lts"
}

variable "image_version" {
  description = "Version of the VM image"
  type        = string
  default     = "latest"
}

# Disk Variables
variable "os_disk_type" {
  description = "OS disk type"
  type        = string
  default     = "StandardSSD_LRS"
}

variable "os_disk_size" {
  description = "OS disk size in GB"
  type        = number
  default     = 30
}

variable "data_disk_size" {
  description = "Data disk size in GB"
  type        = number
  default     = 100
}

variable "data_disk_iops" {
  description = "Data disk IOPS (for Premium SSD)"
  type        = number
  default     = 5000
}

variable "data_disk_throughput" {
  description = "Data disk throughput in MB/s (for Premium SSD)"
  type        = number
  default     = 200
}

# Backup Variables
variable "backup_time" {
  description = "Daily backup time (24-hour format)"
  type        = string
  default     = "23:00"
}

variable "backup_timezone" {
  description = "Backup timezone"
  type        = string
  default     = "UTC"
}

variable "backup_retention_days" {
  description = "Number of days to retain backups"
  type        = number
  default     = 7
}

# Tags
variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}
