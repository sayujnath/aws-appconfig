############################################################

#   Title:          Single tenant identity providor Cognito User Pool
#   Author:         Sayuj Nath, Cloud Solutions Architect
#   Company:        Canditude
#   Developed by:   Sayuj Nath
#   Prepared for    Public non-commercial use
#   Description:    Uploads a configuration file into AWS AppConfig
#                   Assigned to a specifiic server applications
#
#   Design Report:  not published in public domain

###########################################################

resource "aws_appconfig_configuration_profile" "this" {
    application_id = var.app_config_app_id
    description    = "${var.config_name} configuration profile for app_config"
    name           = var.config_name
    location_uri   = "hosted"



    tags = {
        Environment = "all"

    }
}

resource "aws_appconfig_hosted_configuration_version" "this" {
    application_id           = var.app_config_app_id
    configuration_profile_id = aws_appconfig_configuration_profile.this.configuration_profile_id
    description              = "${var.config_name} configuration version for app_config"
    content_type             = "text/plain"

    content = var.content # file(var.content_path)
}



resource "aws_appconfig_deployment" "this" {
    application_id           = var.app_config_app_id
    configuration_profile_id = aws_appconfig_configuration_profile.this.configuration_profile_id
    configuration_version    = aws_appconfig_hosted_configuration_version.this.version_number
    deployment_strategy_id   = var.app_config_deploy_strategy_id
    description              = "${var.config_name} configuration deployment for app_config"
    environment_id           = var.app_config_environment_id

    tags = {
        Type = "AppConfig Deployment"
    }
}
