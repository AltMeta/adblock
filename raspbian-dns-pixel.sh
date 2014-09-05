#!/bin/bash

sudo apt-get install -y dnsmasq

pixelscript()
{

        LISTEN_ADDRESS=$(ifconfig eth0 | grep 'inet' | cut -f2 -d':' | cut -f1 -d' ')

        cd /usr/local/bin/
        curl http://proxytunnel.sourceforge.net/files/pixelserv.pl.txt | tee /tmp/pixelserv | sed "s/0\.0\.0\.0/$LISTEN_ADDRESS/" > pixelserv
        chmod 755 pixelserv

        > /etc/init.d/pixelserv

cat << 'EOF' >>  /etc/init.d/pixelserv
#! /bin/sh
# /etc/init.d/pixelserv
#

# Carry out specific functions when asked to by the system
case "$1" in
start)
echo "Starting pixelserv"
/usr/local/bin/pixelserv &
;;
stop)
echo "Stopping script pixelserv"
killall pixelserv
;;
*)
echo "Usage: /etc/init.d/pixelserv {start|stop}"
exit 1
;;
esac

exit 0
EOF


        chmod 755 /etc/init.d/pixelserv
        /etc/init.d/pixelserv start
        update-rc.d pixelserv defaults
}


adblockscript()
{

        > /usr/local/bin/get-ad-block-list.sh

cat << 'EOF' >> /usr/local/bin/get-ad-block-list.sh
#!/bin/sh

LISTEN_ADDRESS=$(ifconfig eth0 | grep 'inet' | cut -f2 -d':' | cut -f1 -d' ')

# Down the DNSmasq formatted ad block list
curl "http://pgl.yoyo.org/adservers/serverlist.php?hostformat=dnsmasq&showintro=0&mimetype=plaintext" | sed "s/127\.0\.0\.1/$LISTEN_ADDRESS/" > /etc/dnsmasq.adblock.conf

# Restart DNSmasq
/etc/init.d/dnsmasq restart
EOF

        chmod 755 /usr/local/bin/get-ad-block-list.sh
        STEN_ADDRESS=$(ifconfig eth0 | grep 'inet' | cut -f2 -d':' | cut -f1 -d' ')
echo 'conf-file=/etc/dnsmasq.adblock.conf' >> /etc/dnsmasq.conf
        /usr/local/bin/get-ad-block-list.sh
        ln -s /usr/local/bin/get-ad-block-list.sh /etc/cron.weekly/get-ad-block-lis
}


pixelscript
adblockscript
