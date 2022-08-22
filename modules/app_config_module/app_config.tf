############################################################

#   Title:          Single tenant identity providor Cognito User Pool
#   Author:         Sayuj Nath, Cloud Solutions Architect
#   Company:        Canditude
#   Developed by:   Sayuj Nath
#   Prepared for    Public non-commercial use
#   Description:    Uploads a AWS cloudwatch logs configuration file into AWS AppConfig
#                   Assigned to a specifiic environment
#
#   Design Report:  not published in public domain

###########################################################

resource "aws_appconfig_application" "app_config_app_fs" {
    name        = "Example App Configuration"
    description = "Configuration files for Example API Engine"

    tags = {
        Environment = "all"

    }
}


resource "aws_appconfig_environment" "app_config_environment_fs" {
    name           = "ExampleAppServer"
    description    = "Example API Engine Server Environment"
    application_id = aws_appconfig_application.app_config_app_fs.id


    tags = {
        Environment = "all"

    }
}



module app_config_example_cloudwatch_agent_config {
    source = "./app_config_single_hosted"

    app_config_app_id      = aws_appconfig_application.app_config_app_fs.id
    app_config_deploy_strategy_id = aws_appconfig_deployment_strategy.app_config_deploy_strategy_fs.id
    app_config_environment_id = aws_appconfig_environment.app_config_environment_fs.environment_id

    config_name  =  "cloudwatch_config"
    content = file("${path.module}/config_files/cloudwatch_agent_config.json")
}


