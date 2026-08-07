# AWS Configuration
variable "project_name" {
  description = "Project name for resource tagging"
  type        = string
  default     = "remote-ssh-vscode"
}

# EC2 Instance Variables
variable "instance_ami" {
  description = "Optional EC2 AMI ID override; defaults to the latest regional Amazon Linux 2023 AMI"
  type        = string
  default     = null
  nullable    = true

  validation {
    condition     = var.instance_ami == null ? true : trimspace(var.instance_ami) != ""
    error_message = "instance_ami must be null or a non-empty AMI ID."
  }
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "root_volume_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 50
}

variable "key_pair_name" {
  description = "Name of the EC2 key pair"
  type        = string
  default     = "aws-remote-ssh-on-vscode"
}

variable "use_spot_instance" {
  description = "Whether to use spot instance"
  type        = bool
  default     = true
}

variable "spot_instance_max_price" {
  description = "Maximum price for spot instance (USD)"
  type        = string
  default     = "0.01"
}

variable "enable_monitoring" {
  description = "Enable EC2 instance monitoring"
  type        = bool
  default     = false
}

# EBS Volume Variables
variable "ebs_volume_type" {
  description = "EBS volume type"
  type        = string
  default     = "gp3"
}

variable "ebs_volume_size" {
  description = "Data EBS volume size in GB"
  type        = number
  default     = 50
}

variable "ebs_volume_iops" {
  description = "IOPS for gp3 volume (optional)"
  type        = number
  default     = 3000
}

variable "ebs_volume_throughput" {
  description = "Throughput for gp3 volume (optional)"
  type        = number
  default     = 125
}

# Backup Variables
variable "enable_daily_backup" {
  description = "Enable daily snapshots"
  type        = bool
  default     = true
}

variable "backup_retention_days" {
  description = "Number of days to retain backups"
  type        = number
  default     = 7
}

# Security Group Variables
variable "allowed_ssh_cidr_blocks" {
  description = "List of CIDR blocks allowed for SSH access"
  type        = list(string)
  default     = [] # Will be populated with your IP via data source
}

# IAM Role Variables
variable "iam_policies_to_attach" {
  description = "IAM policy ARNs attached to the EC2 instance role; override for workload-specific access"
  type        = list(string)
  default = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
  ]
}

# Tagging
variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}
