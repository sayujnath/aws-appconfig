
variable "rds_endpoint" {
    type = string
    description = "This is the private endpoint of the rds instance that was created."
}

variable "rds_username" {
    type = string
    description = "The is the default database username set by the template "
}

variable "rds_password" {
    type = string
    description = "The is the default database password set by the template "
}