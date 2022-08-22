[[ ! -f /etc/init.d/app_config.sh ]] && echo '#!/bin/bash' > /etc/init.d/app_config.sh

echo "sudo aws configure set default.region ${region}" >> /etc/init.d/app_config.sh

echo "export APP_CONFIG_APP_ID=\$(sudo aws appconfig list-applications | jq '.Items[] | select(.Name==\"${application}\")'.Id | tr -d '\"')" >> /etc/init.d/app_config.sh


echo "export APP_CONFIG_ENV_ID=\$(sudo aws appconfig list-environments --application-id \$APP_CONFIG_APP_ID | jq '.Items[] | select(.Name==\"${environment}\")'.Id | tr -d '\"')" >> /etc/init.d/app_config.sh

echo "export APP_CONFIG_PROFILE_ID_FILE=\$(sudo aws appconfig list-configuration-profiles --application-id \$APP_CONFIG_APP_ID  | jq '.Items[] | select(.Name==\"${config_name}\")'.Id | tr -d '\"')" >> /etc/init.d/app_config.sh

echo "export APP_CONFIG_FILE_TOKEN=\$(sudo aws appconfigdata start-configuration-session     --application-identifier  \$APP_CONFIG_APP_ID     --environment-identifier \$APP_CONFIG_ENV_ID     --configuration-profile-identifier \$APP_CONFIG_PROFILE_ID_FILE | jq .InitialConfigurationToken)" >> /etc/init.d/app_config.sh

echo "sudo aws appconfigdata get-latest-configuration --configuration-token \$APP_CONFIG_FILE_TOKEN ${file_location_with_name}" >> /etc/init.d/app_config.sh