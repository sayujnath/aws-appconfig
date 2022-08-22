echo 'Installing figlet..'


sudo apt-get install -y figlet

echo "Creating Banner with text ${banner_text}"
sudo cat > /etc/update-motd.d/40-bastion <<'endmsg'
echo
figlet -c ${banner_text}
echo ###############################################################
echo  Welcome to the ${banner_text}.
echo  All connections are monitored and recorded.
echo  Disconnect IMMEDIATELY if you are not an authorized user! 
echo ###############################################################
endmsg

sudo chmod 777 /etc/update-motd.d/40-bastion
sudo rm /etc/update-motd.d/30-banner
sudo run-parts /etc/update-motd.d/

sudo figlet -c ${banner_text} > /etc/motd

sudo cat >> /etc/motd <<'endmsg'

###############################################################
    Welcome to the ${banner_text}.
    All connections are monitored and recorded.
    Disconnect IMMEDIATELY if you are not an authorized user! 
###############################################################
endmsg