######################################################################
#
#   Title:          CIS Hardened Ubuntu AMI with Node.js
#   Author:         Sayuj Nath, Cloud Solutions Architect
#   Company:        Canditude
#   Prepared for    Public non-commercial use
#   Description:   This file does the following:
#                   1. Creates many AWS Cognito userpools where 
#                   2. Each user pool authenticated by an external SAML or OICD IdP providor 
#                   3. Creates application and authorization server subdomains(both public and private), unique to each IdP. 
#
#                   This version of the code is incomplete &untested and specially released 
#                   for non-commecial public consumption. Runninng this code also requires
#                   additional modules for creating loadbalancers and route53 hostzones

#                   For a production ready version,
#                   please contact the author at info@canditude.com
#
######################################################################

locals {
  dev_ec2_instance_type   = "t3.micro"
  dev_ami_pfx             = "example-dev-image"
}

//upload Cloudwatch configutaion to AWS AppConfig
module "app_config" {

  depends_on = [
    module.database
  ]
  source = "../modules/app_config_module"
}



module "development_server_module" {
  source = "../modules/single_server_module"

  depends_on = [
    module.security_module,
    module.network_module,
    module.loadbalancer
  ]

  vpc_id                      = module.network_module.vpc.id
  instance_type               = local.dev_ec2_instance_type
  subnet_id                   = module.network_module.subnet_map.app.A.id
  security_group_id           = module.security_module.security_group_map.app_dev.id
  ami                         = var.ami
  ssh_key_name                = var.ssh_key_terraform
  banner_title                = "Development Server"
  deploy_type                 = "dev"
  account_type                = "dev"
  instance_profile             = module.iam_module.example_dev_instance_profile.id
  bastionhost_public_ip       = module.bastion_host.bastion_vm_public_ip
  vm_name_pfx                 = var.app_vm_name_pfx
  ssh_port                    = var.ssh_port
  zone_id_primary             = var.primary_domain_host_zone_id
  primary_domain              = var.primary_domain
  subdomain                   = var.dev_subdomain
  alb_target_arn              = module.loadbalancer.dev_alb_target_arn

}


# sets up private endpoints between various AWS and MongoDB ATLAS services
# to keep network traffic isolated from the public internet.
module "endpoints"  {
    source = "../modules/endpoints_module"
    region = var.region
    type = var.type
    vpc_id = module.network_module.vpc.id
    subnet_map = module.network_module.subnet_map
    security_group_map = module.security_module.security_group_map
    private_route_table_id = module.network_module.private_route_table.id

}
