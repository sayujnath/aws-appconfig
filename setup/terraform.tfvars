
dev_account = "9XXXXXXXXXXXXXX"

ssh_port = 22


primary_domain_host_zone_id = "Z0XXXXXXXXXXXXXXXXX"

primary_domain = "temp.example.com.au"
dev_subdomain  = "dev."

ssh_key_terraform = "ssh_admin_key" # SSH key to use 

ami = "ami-06XXXXXXXXX4b" # ami with Ubuntu

app_vm_name_pfx = "example-app-vm"

applications_folder = "/var/www/"

# Tags are used to designate ownership of resources
default_tags = {
  Project     = "example-cloud-migration"
  PreparedBy  = "canditude"
  GeneratedBy = "terraform"
}