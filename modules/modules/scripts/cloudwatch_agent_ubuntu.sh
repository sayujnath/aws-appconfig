
sudo aws configure set default.region ${region}
echo "Downloading latest CloudWatch Agent..."
cd /home/ubuntu/downloads

sudo wget https://s3.${region}.amazonaws.com/amazoncloudwatch-agent-${region}/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
echo "Installing latest CloudWatch Agent..."
sudo dpkg -i -E ./amazon-cloudwatch-agent.deb
echo "Downloading latest CloudWatch Agent Configuration file from AppConfig to ${cloud_watch_agent_config_file_name}..."


export APP_CONFIG_APP_ID=$(sudo aws appconfig list-applications | jq '.Items[] | select(.Name=="Example App Configuration")'.Id | tr -d '"')

export APP_CONFIG_ENV_ID=$(sudo aws appconfig list-environments --application-id $APP_CONFIG_APP_ID | jq '.Items[] | select(.Name=="ExampleAppServer")'.Id | tr -d '"')

export APP_CONFIG_PROFILE_ID_CLOUDWATCH=$(sudo aws appconfig list-configuration-profiles --application-id $APP_CONFIG_APP_ID  | jq '.Items[] | select(.Name=="cloudwatch_config")'.Id | tr -d '"')

export APP_CONFIG_CLOUDWATCH_TOKEN=$(sudo aws appconfigdata start-configuration-session     --application-identifier $APP_CONFIG_APP_ID     --environment-identifier $APP_CONFIG_ENV_ID     --configuration-profile-identifier $APP_CONFIG_PROFILE_ID_CLOUDWATCH | jq .InitialConfigurationToken)

sudo touch ${cloud_watch_agent_config_file_name}
sudo chmod 777 ${cloud_watch_agent_config_file_name}
sudo echo "" > ${cloud_watch_agent_config_file_name}

sudo aws appconfigdata get-latest-configuration --configuration-token $APP_CONFIG_CLOUDWATCH_TOKEN ${cloud_watch_agent_config_file_name}

echo "Starting CloudWatch agent..."
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:${cloud_watch_agent_config_file_name} -s

echo "Getting CloudWatch Agent Status.."
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -m ec2 -a status

echo "Restarting CloudWatch agent..."
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:${cloud_watch_agent_config_file_name} -s

echo "Test CloudWatch Agent Config File - /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.toml"
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent -schematest -config /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.toml

echo "Getting CloudWatch Agent Status.."
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -m ec2 -a status
