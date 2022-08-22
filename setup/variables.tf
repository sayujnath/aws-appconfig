variable "dev_account" {
  type        = string
  default     = ""
  description = "This is the number of the development account which owns the AMI that will be used"
}

variable "default_tags" {
  type        = map(any)
  description = "These are the default tage for all resources deployed with terraform"
}

variable "region" {
  type        = string
  default     = "ap-southeast-2" # the detault is the sandbox region (Ohio)
  description = "Set this to the region to deploy resources. Ensure the region has at least three availiability zones"
  validation {
    condition     = contains(["us-east-1", "us-east-2", "ap-southeast-2"], var.region)
    error_message = "Allowed values for 'region' parameter are 'us-east-1' and 'ap-southeast-2'."
  }
}

variable "type" {
  type = string
  validation {
    condition     = contains(["dev", "test", "prod"], var.type)
    error_message = "Allowed values for 'type' parameter are 'dev', 'test', or 'prod'."
  }
}



variable "primary_domain" {
  type        = string
  description = "The root domain name of the example application server"
}



variable "primary_domain_host_zone_id" {
  type        = string
  description = "The name of the host zone file for the primary domain"
}

variable "dev_subdomain" {
  type        = string
  description = "The subdomain for the app server"
}

variable "test_subdomain" {
  type        = string
  description = "The subdomain of the example test application server"
}

variable "prod_subdomain" {
  type        = string
  description = "The subdomain of the example production application server"
}

variable "applications_folder" {
  type        = string
  description = "The folder where all applications can be found"
}


variable "ssh_key_terraform" {
  type        = string
  description = "This is the ssh key that terraform uses to perform EC2 operations"
}

variable "ami" {
  type        = string
  description = "This is the base ami for all app servers"
}

variable "app_vm_name_pfx" {
  type        = string
  description = "This is the prefix for the example vm"
}


variable "ssh_port" {
  type        = number
  description = "This is an alternative ssh port number ."
}
