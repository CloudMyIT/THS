sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install tor apache2 libapache2-modsecurity -y

###
# Set HostName
###
sudo hostname darknet
echo "darknet" | sudo tee /etc/hostname
echo "127.0.0.1 darknet" | sudo tee -a /etc/hosts
sleep 2

###
# Enable and Start some services
###
sudo systemctl enable tor
sudo systemctl start tor
sudo systemctl enable apache2
sudo systemctl start apache2
sleep 2

###
# Backup Some Files
###
sudo cp /etc/apache2/conf-enabled/security.conf /etc/apache2/conf-enabled/security.conf.bak
sudo cp /etc/apache2/apache2.conf /etc/apache2/apache2.conf.bak
sudo cp /etc/apache2/ports.conf /etc/apache2/ports.conf.bak
sudo mv /etc/modsecurity/modsecurity.conf-recommended /etc/modsecurity/modsecurity.conf
sudo cp /etc/modsecurity/modsecurity.conf /etc/modsecurity/modsecurity.conf.bak
sudo cp /etc/apache2/sites-enabled/000-default.conf /etc/apache2/sites-enabled/000-default.conf.bak
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

###
# FOR UNFUCKING THINGS
###
sudo cp /etc/modsecurity/modsecurity.conf.bak /etc/modsecurity/modsecurity.conf
sudo cp /etc/apache2/conf-enabled/security.conf.bak /etc/apache2/conf-enabled/security.conf
sudo cp /etc/apache2/apache2.conf.bak /etc/apache2/apache2.conf
sudo cp /etc/apache2/ports.conf.bak /etc/apache2/ports.conf
sudo cp /etc/apache2/sites-enabled/000-default.conf.bak /etc/apache2/sites-enabled/000-default.conf
sudo cp /etc/ssh/sshd_config.bak /etc/ssh/sshd_config

###
# Clean Up Config Files
###
sudo sed -i '/^\#/d' /etc/apache2/conf-enabled/security.conf
sudo sed -i '/^\#/d' /etc/apache2/apache2.conf
sudo sed -i '/^\#/d' /etc/modsecurity/modsecurity.conf
sudo sed -i '/^\#/d' /etc/tor/torrc
sudo sed -i '/^\#/d' /etc/apache2/sites-enabled/000-default.conf
sudo sed -i '/^\#/d' /etc/ssh/sshd_config
sudo rm /var/www/html/index.html

###
# Remove Empty Lines
###
sudo sed -i '/^$/d' /etc/apache2/conf-enabled/security.conf
sudo sed -i '/^$/d' /etc/apache2/apache2.conf
sudo sed -i '/^$/d' /etc/modsecurity/modsecurity.conf
sudo sed -i '/^$/d' /etc/tor/torrc
sudo sed -i '/^$/d' /etc/apache2/sites-enabled/000-default.conf
sudo sed -i '/^$/d' /etc/ssh/sshd_config

###
# Fix The Config
###
#Force apache to hide some info
sudo sed -i 's/ServerSignature On/ServerSignature Off/g' /etc/apache2/conf-enabled/security.conf
sudo sed -i 's/ServerTokens OS/ServerTokens Prod/g' /etc/apache2/conf-enabled/security.conf
sudo sed -i 's/FollowSymLinks/-FollowSymLinks/g' /etc/apache2/apache2.conf
sudo sed -i 's/Indexes/-Indexes/g' /etc/apache2/apache2.conf
#Force apache to listen to localhost only
sudo sed -i 's/Listen 80/Listen 127.0.0.1:80/g' /etc/apache2/ports.conf
sudo sed -i 's/Listen 443/Listen 127.0.0.1:443/g' /etc/apache2/ports.conf
#Force SSH to listen to localhost only
echo "ListenAddress 127.0.0.1" | sudo tee -a /etc/ssh/sshd_config
#IDK...
sudo sed -i 's/SecRuleEngine DetectionOnly/SecRuleEngine On/g' /etc/modsecurity/modsecurity.conf

###
# Disable Some Modules
###
sudo a2dismod autoindex -f
sudo a2dismod status -f
sudo service apache2 restart

###
# Setup Hidden Services Directory
###
#Make direcotry
sudo mkdir /var/lib/tor/hidden_services
sudo chown debian-tor:debian-tor /var/lib/tor/hidden_services
#Make ssh service
echo "HiddenServiceDir /var/lib/tor/hidden_services/ssh" | sudo tee -a /etc/tor/torrc
echo "HiddenServicePort 22 127.0.0.1:22" | sudo tee -a /etc/tor/torrc
#Make www service
echo "HiddenServiceDir /var/lib/tor/hidden_services/www" | sudo tee -a /etc/tor/torrc
echo "HiddenServicePort 80 127.0.0.1:80" | sudo tee -a /etc/tor/torrc
#Restart
sudo systemctl restart tor
echo "WAITING FOR TOR TO GENERATE KEYS AND SUCH PRIOR TO CONTINUING"
sleep 10

#Get onion addreses
SSHONION=$(sudo cat /var/lib/tor/hidden_services/ssh/hostname)
WWWONION=$(sudo cat /var/lib/tor/hidden_services/www/hostname)

#ALERT SOME INFO
echo "#########################################"
echo "# WARNING THIS IS IMPORTANT INFORMATION #"
echo "# WARNING THIS IS IMPORTANT INFROMATION #"
echo "# WARNING THIS IS IMPORTANT INFROMATION #"
echo "#########################################"
echo ""
echo "SSH SERVICE:"
echo $SSHONION
echo ""
echo "WWW SERVICE:"
echo $WWWONION
echo ""
echo "NOTE ONCE YOU CONTINUE SSH WILL BE RESTARTED"
echo "THIS SESSION WILL NOT DIE"
echo ""
echo "YOU MUST CONNECT USING THE ONION ADDRESS"
echo "SSH ONLY LISTENS TO THE ONION NOW"
echo ""
echo "#########################################"
echo "# WARNING THIS IS IMPORTANT INFORMATION #"
echo "# WARNING THIS IS IMPORTANT INFROMATION #"
echo "# WARNING THIS IS IMPORTANT INFROMATION #"
echo "#########################################"
read -rsp $'Press any key to continue...\n' -n 1 key

###
# WARNING
# RESTARTING SSHD
# MUST HAVE ACCESS TO TOR TO REGAIN SSH ACCESS
###
sudo service sshd restart
