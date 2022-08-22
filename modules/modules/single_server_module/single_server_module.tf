############################################################

#   Title:          Single tenant identity providor Cognito User Pool
#   Author:         Sayuj Nath, Cloud Solutions Architect
#   Company:        Canditude
#   Developed by:   Sayuj Nath
#   Prepared for    Public non-commercial use
#   Description:    Single server compute  module that creates and confugures a single
#                   application server. Loads configuration files for cloudwatch from 
#                   AWS AppConfig
#
#   Design Report:  not published in public domain

###########################################################

locals {

  terraform_scripts_path = "${path.module}/../../scripts"
  security_keys_folder   = "${path.module}/../../.security/keys"

  
  launch_script_file   = "${local.launch_script_folder}/launch_script.sh"
  launch_script_folder = "/tmp"

# these are the central folders where the applications get installed
  applications_folder = "/var/www/"
  web_admin_app_server_folder = "${local.applications_folder}example-app"

  apply_updates = file("${local.terraform_scripts_path}/updates_ubuntu.sh")
  
  # security_measures = templatefile("${path.module}/../scripts/security_measures_ubuntu.sh",{ssh_port = var.ssh_port})
  set_banner = templatefile("${local.terraform_scripts_path}/title_banner_ubuntu.sh", { banner_text = var.banner_title })
  

# configuration files for the cloud watch agent. This agent sends logs foles from the EC2 instance to AWS cloudwatch
  cloud_watch_agent_config_file_name = "/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent.json"


  set_app_config_cloudwatch = templatefile("${local.terraform_scripts_path}/app_config_setup.sh", {region = var.region,
    application = "example App Configuration",
    environment = "exampleAppServer",
    config_name = "cloudwatch_config"
    file_location_with_name = local.cloud_watch_agent_config_file_name
    })

  set_cloudwatch_agent = templatefile("${local.terraform_scripts_path}/cloudwatch_agent_ubuntu.sh",{region = var.region, cloud_watch_agent_config_file_name = local.cloud_watch_agent_config_file_name, cloud_watch_agent_config = local.cloud_watch_agent_config})

  cloud_watch_agent_config = templatefile("${local.terraform_scripts_path}/cloudwatch_agent_config.json",{applications_folder = local.applications_folder, instance_name = var.vm_name_pfx})

    user_data = join("\n", [
      "#!/bin/bash",
      "set -x",
      "mkdir -p /home/ubuntu/web_server_files",
      "mkdir -p /home/ubuntu/downloads",
      "mkdir -p /tmp",
      "sudo mkdir -p /usr/local/share/applications",
      "sudo mkdir -p /var/log/pm2",
      local.apply_updates,
      local.set_banner,

    ])

  launch_script = join("\n", [
    "#!/bin/bash",
    "set -x",
    "mkdir -p /tmp",

    local.set_app_config_cloudwatch,
    local.set_cloudwatch_agent,

    "echo App Server launch complete...!"
  ])
}

############################## DEVELOPMENT VM ##############################

resource "aws_network_interface" "eni_app_vm" {
  subnet_id       = var.subnet_id # places the app instance in the first web AZ
  security_groups = [var.security_group_id]
  tags = {
    Name = "eni-app-vm"
  }
}



resource "aws_instance" "example-app-vm" {
  ami                  = var.ami # ami-07989f839f9699ac3 data.aws_ami.example_app_ami.id
  instance_type        = var.instance_type
  iam_instance_profile = var.instance_profile

  key_name = var.ssh_key_name #default ssh key. An ssh key for each user will also be installed via bootstrap using the keys in .security/keys/dev/pem

  user_data = local.user_data # runs bootstrap script in local.user_data


  connection {
    type                = "ssh"
    user                = "ubuntu"
    agent               = true
    private_key         = file("${local.security_keys_folder}/admin/${var.ssh_key_name}.pem")
    host                = self.private_ip
    bastion_host        = var.bastionhost_public_ip
    bastion_user        = "ubuntu"
    bastion_private_key = file("${local.security_keys_folder}/admin/${var.ssh_key_name}.pem")
    port                = var.ssh_port
    bastion_port        = var.ssh_port
  }
  provisioner "remote-exec" {
    inline = [
      "sudo cloud-init status --wait"
    ]
  }

  credit_specification {

    cpu_credits = "unlimited"
  }

  network_interface {
    network_interface_id = aws_network_interface.eni_app_vm.id
    device_index         = 0
  }

  // lifecycle {
  //     ignore_changes = [tags]
  // }

  # TODO: enable termination protection when going into production
  disable_api_termination = false

  tags = {
    Name = var.deploy_type
    # IncludeInScan = "true"      // used by AWS Inspector vulnerability scan
  }
}


resource "null_resource" "compute_launch_script" {
  triggers = {
    private_ip = aws_instance.example-app-vm.private_ip
  }

  depends_on = [
    aws_instance.example-app-vm
  ]

  connection {
    type                = "ssh"
    user                = "ubuntu"
    agent               = true
    private_key         = file("${local.security_keys_folder}/admin/${var.ssh_key_name}.pem")
    host                = aws_instance.example-app-vm.private_ip
    bastion_user        = "ubuntu"
    bastion_host        = var.bastionhost_public_ip
    bastion_private_key = file("${local.security_keys_folder}/admin/${var.ssh_key_name}.pem")
    port                = var.ssh_port
    bastion_port        = var.ssh_port
  }
  // copy our example script to the server
  provisioner "file" {
    content     = local.launch_script
    destination = local.launch_script_file
  }

  // change permissions to executable and pipe its output into a new file
  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x ${local.launch_script_file}",
      "cd ${local.launch_script_folder}",
      "sudo ${local.launch_script_file} > ${local.launch_script_folder}/script-output.log"
    ]
  }

}

# Attaches the server to the listeners provided by the ALB for each port
  resource "aws_lb_target_group_attachment" "alb-target-attach" {
      for_each = var.alb_target_arn

      target_group_arn = each.value
      target_id        = aws_instance.example-app-vm.private_ip
      
  } 

resource "aws_route53_record" "public_dns_server_record" {
  zone_id = var.zone_id_primary
  name    = "${var.subdomain}${var.primary_domain}"
  type    = "A"
  ttl     = 60
  records = [aws_instance.example-app-vm.private_ip]
}