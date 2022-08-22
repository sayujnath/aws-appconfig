

variable "account_number" {
  type        = string
  default     = ""
  description = "This is the number of the account which owns the AMI that will be used"
}

# The following variable are used to create computing instances

variable "region" {
  type        = string
  default     = "ap-southeast-2" # the default is the sandbox region (Ohio)
  description = "Set this to the region to deploy resources. Ensure the region has at least three availiability zones"
  validation {
    condition     = contains(["eu-west-2", "us-east-2", "ap-southeast-2", "eu-west-2"], var.region)
    error_message = "Allowed values for 'region' parameter are 'eu-west-2', 'us-east-2', 'eu-west-2' and 'ap-southeast-2'."
  }
}


variable "account_type" {
  type    = string
  default = ""
  validation {
    condition     = contains(["dev", "test", "stage", "prod", "all"], var.account_type)
    error_message = "Allowed values for 'account_type' parameter are 'dev', 'test', 'stage', 'prod' or 'all'."
  }
}

variable "deploy_type" {
  type = string
  validation {
    condition     = contains(["dev", "test", "prod"], var.deploy_type)
    error_message = "Allowed values for 'account_type' parameter are 'dev', 'test', 'stage', 'prod'."
  }
}


variable "subdomain" {
  type        = string
  description = "The subdomain prefix used to creat the DNS name of this server."
}


variable "vpc_id" {
  type        = string
  description = "This is the id of the vpc created in the network module"
}


variable "ami" {
  type        = string
  description = "AMI of the Application environment."
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type of the App EC2 instance running the app."
}

variable "instance_profile" {
  type        = string
  description = "This is the instance profile of the role used by the Development and Test EC2 servers"
}


variable "subnet_id" {
  type        = string
  description = "The is the subnet where the compute instance will reside in."
}

variable "security_group_id" {
  type        = string
  description = "This is the id of the security group to allow inbound traffic to the app tier."
}

variable "vm_name_pfx" {
  type        = string
  default     = ""
  description = "Prefix of the App EC2 instance running the app."
}


variable "ssh_key_name" {
  type        = string
  description = "SSH Key used for the regions. This need to be preloaded before running Terraform"
}

variable "ssh_port" {
  type        = number
  description = "This is an alternative ssh port number ."
}


variable "banner_title" {
  type        = string
  description = "This is the name of the server as shoud should appear on the Banner."
}

variable "bastionhost_public_ip" {
  type        = string
  default     = "Not set up yet"
  description = "IP of the bastion host instance"
}

variable "alb_target_arn" {
  type        = map
  description = "These are the development server ALB targets that needs to be attached to the development server IP"
}



variable "primary_domain" {
  type        = string
  description = "The root domain name of the format application server"
}

variable "zone_id_primary" {
  type        = string
  description = "This is the zone ID of the hots zone for the primary domain"
}