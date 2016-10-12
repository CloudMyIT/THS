# Tor Hidden Services Setup Scripts
## About
Setup Scripts for Tor Hidden Services

Installs & Configures Tor and Apache2

Sets Apache2 to only listen to 127.0.0.1 so no public leakage
Sets SSH to only listen to 127.0.0.1 so no public leakage

Creates 2 TOR Services one for each of the above.

## TODO
Update script to add websites/services


## Use
```
git clone https://github.com/CloudMyIT/THS.git
cd THS
chmod +x install.sh
./install.sh
```
When it finishes you will recieve output as such.

```
#########################################
# WARNING THIS IS IMPORTANT INFORMATION #
# WARNING THIS IS IMPORTANT INFROMATION #
# WARNING THIS IS IMPORTANT INFROMATION #
#########################################

SSH SERVICE:
XXXXXXXXXXXXXXXX.onion

WWW SERVICE:
XXXXXXXXXXXXXXXX.onion

NOTE ONCE YOU CONTINUE SSH WILL BE RESTARTED
YOUR CONNECTION WILL DROP
YOU MUST RECONNECT USING THE ONION ADDRESS
SSH ONLY LISTENS TO LOCALHOST NOW

#########################################
# WARNING THIS IS IMPORTANT INFORMATION #
# WARNING THIS IS IMPORTANT INFROMATION #
# WARNING THIS IS IMPORTANT INFROMATION #
#########################################
Press any key to continue...
```

After pressing any key; all future SSH connections must be made though TOR.
