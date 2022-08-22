
#                   This version of the code is incomplete &untested and specially released 
#                   for non-commecial public consumption. 

#                   For a production ready version,
#                   please contact the author at info@canditude.com


####################### CLOUDWATCH VPC  INTERFACE #########################
############################### ENDPOINT ##################################

resource "aws_vpc_endpoint" "cloudwatch_endpoint" {
    vpc_id            = var.vpc_id
    service_name      = "com.amazonaws.${var.region}.monitoring"
    vpc_endpoint_type = "Interface"

    security_group_ids = [
        var.security_group_map.web.id,
        var.security_group_map.app_dev.id,
        var.security_group_map.app_test.id,
        var.security_group_map.app_prod.id
    ]
    
    subnet_ids = [var.subnet_map.app.A.id]

    private_dns_enabled = true
    tags = {
        Name = "cloudwatch-app-interface"
        Environment = var.type
        GeneratedBy = "terraform"
        PreparedBy = "canditude"
    }
}

