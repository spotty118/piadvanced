#!/bin/sh
## DNSCRYPT

## Download
cd /etc/piadvanced/installscripts/dnsproxy
sudo wget https://github.com/jedisct1/dnscrypt-proxy/releases/download/2.0.0/dnscrypt-proxy-linux_x86_64-2.0.0.tar.gz
sudo tar -xf LATEST.tar.bz2
#sudo rm LATEST.tar.bz2

## build
pattern="dnscrypt-proxy-"
for _dir in *"${pattern}"*; do     [ -d "${_dir}" ] && dir="${_dir}" && break; done
cd $dir
sudo ldconfig
sudo bash ./configure --with-systemd
sudo make
sudo make install
sudo useradd -r -d /var/dnscrypt -m -s /usr/sbin/nologin dnscrypt

## install
sudo sed -i '/exit 0/d' /etc/rc.local
sudo sed -i '/dnscrypt-proxy/d' /etc/rc.local
sudo sed -i '$i /usr/local/sbin/dnscrypt-proxy --resolver-name=dnscrypt.eu-dk --user=dnscrypt -a 127.0.0.2:5454 --edns-payload-size=4096 --logfile=/var/log/dnscrypt-proxy.1.log &> /dev/null &' /etc/rc.local
sudo sed -i '$i /usr/local/sbin/dnscrypt-proxy --resolver-name=cs-ch --user=dnscrypt -a 127.0.0.3:5656 --edns-payload-size=4096 --logfile=/var/log/dnscrypt-proxy.2.log &> /dev/null &' /etc/rc.local
sudo sed -i '$i /usr/local/sbin/dnscrypt-proxy --resolver-name=d0wn-is-ns1 --user=dnscrypt -a 127.0.0.4:5757 --edns-payload-size=4096 --logfile=/var/log/dnscrypt-proxy.3.log &> /dev/null &' /etc/rc.local
sudo sed -i '$i exit 0' /etc/rc.local
sudo kill $(ps aux | grep 'dnscrypt-proxy' | awk '{print $2}')
sudo /usr/local/sbin/dnscrypt-proxy --resolver-name=dnscrypt.eu-dk --user=dnscrypt -a 127.0.0.2:5454 --edns-payload-size=4096 --logfile=/var/log/dnscrypt-proxy.1.log &> /dev/null &
sudo /usr/local/sbin/dnscrypt-proxy --resolver-name=cs-ch --user=dnscrypt -a 127.0.0.3:5656 --edns-payload-size=4096 --logfile=/var/log/dnscrypt-proxy.2.log &> /dev/null &
sudo /usr/local/sbin/dnscrypt-proxy --resolver-name=d0wn-is-ns1 --user=dnscrypt -a 127.0.0.4:5757 --edns-payload-size=4096 --logfile=/var/log/dnscrypt-proxy.3.log &> /dev/null &
sudo sed -i '/dnscrypt.eu/d' /etc/hosts
sudo sed -i '/cs-ch/d' /etc/hosts
sudo sed -i '/d0wn-is-ns1/d' /etc/hosts
sudo sed -i '$i 127.0.0.2       dnscrypt.eu-dk' /etc/hosts
sudo sed -i '$i 127.0.0.3       cs-ch' /etc/hosts
sudo sed -i '$i 127.0.0.4       d0wn-is-ns1' /etc/hosts

## dnsmasq
echo "Adding Entries to DNSMasq"
sudo /etc/init.d/dnsmasq stop
sudo sed -i '/server=/d' /etc/dnsmasq.d/01-pihole.conf
sudo cp -n /etc/piadvanced/piholetweaks/dnscrypt/10-dnscrypt.conf /etc/dnsmasq.d/
sudo /etc/init.d/dnsmasq start
ps aux | grep 'dnscrypt-proxy'
echo Done
