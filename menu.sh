#!/bin/sh
export TERM=linux

arNodeList=
arNodeIpList=
nodeCnt=0;

test -f /etc/bx_cluster/master.node && { masterNodeIp=`cat /etc/bx_cluster/master.node` ; } || { masterNodeIp="" ; }
test -f /etc/bx_cluster/current.node && { currentNodeIp=`cat /etc/bx_cluster/current.node` ; } || { currentNodeIp="" ; }
test -f /etc/bx_cluster/dbName.conf && { dbName=`cat /etc/bx_cluster/dbName.conf` ; } || { dbName="" ; }

masterNode=
currentNode=
mysqlServerID=
isCluster="NO"
isMaster="NO"
nodeCnt=0;
for node in $(ls /etc/bx_cluster/nodes)
do
	isCluster="YES"
	arNodeList[$nodeCnt]=$node;
	arNodeIpList[${nodeCnt}]=`cat /etc/bx_cluster/nodes/${node}`;
	if [ "$arNodeIpList[$nodeCnt]" = "$currentNodeIp" ]; then currentNode=$node; fi
	if [ "$arNodeIpList[$nodeCnt]" = "$masterNodeIp" ]; then masterNode=$node; fi
	let "nodeCnt++";
done

if [ "$isCluster" = "YES" ]; then
	if [ "$masterNodeIp" = "$currentNodeIp" ]; then isMaster="YES"; fi
fi

LOGO="Bitrix virtual appliance"
LOGOV=`set | grep BITRIX_VA_VER | sed 's/BITRIX_VA_VER=//'`

Omenu="0.	Virtual appliance information";
amenu="1.	Mail sending system parameters";
dmenu="3.	Change root password";
emenu="4.	Change bitrix password";
fmenu="5.	Virtual server reboot";
gmenu="6.	Virtual server shutdown";
hmenu="7.	Get a new IP address via DHCP";
imenu="8.	Assign a new IP address (manual)";
jmenu="9.	Set PHP timezone from Operating System setting";
kmenu="10.	Create master node";
rmenu="11.	Add slave node";
tmenu="12.	Make slave node a master node";
ymenu="13.	Add aditional site";
wmenu="14.	Delete aditional site";
nmenu="15.	Ntlm authentication";
mmenu="16.	Start/stop server monitoring";
bmenu="17.	Start/stop site backup";
umenu="18.	Update system"


badchoice () { MSG="Misleading choice ... Please, try again" ; }

Opick () { /root/bitrix-env/info.sh ; echo "Press [ENTER] to continue..." ; read enter_var ; }
apick () { passwd ; }
bpick () { /root/bitrix-env/dhcp_ip.sh ; }
cpick () { /root/bitrix-env/ifcfg_ip.sh ; }
dpick () { /root/bitrix-env/msmtp_conf.sh ; }
npick () { /root/bitrix-env/ntlm_conf.sh ; }
mpick () { /root/bitrix-env/server_monitoring.sh ; }
spick () { /root/bitrix-env/backup_configure.sh ; }
epick () { [ -f /home/bitrix/www/.htsecure ] && { rm -rf /home/bitrix/www/.htsecure ; /etc/init.d/nginx stop >/dev/null 2>&1 ; /etc/init.d/nginx start >/dev/null 2>&1 ; } || { touch /home/bitrix/www/.htsecure ; /etc/init.d/nginx stop >/dev/null 2>&1 ; /etc/init.d/nginx start >/dev/null 2>&1 ; } ; }
gpick () { passwd bitrix; }
hpick () { reboot ; }
ipick () { init 0 ; }

if [ "$isMaster" = "NO" -a "$isCluster" = "NO" ]; then
	kpick () { /root/bitrix-env/create_master_node.sh ; }
	tpick () { /root/bitrix-env/change_master_node.sh ; }
fi

if [ "$isMaster" = "NO" -a "$isCluster" = "YES" ]; then
	tpick () { /root/bitrix-env/change_master_node.sh ; }
fi

if [ "$isMaster" = "YES" -a "$isCluster" = "YES" ]; then
	rpick () { /root/bitrix-env/add_slave_node.sh ; }
fi

ypick () { /root/bitrix-env/add_site.sh ; }
wpick () { /root/bitrix-env/del_site.sh ; }
jpick () { TZname=`cat /etc/sysconfig/clock | grep ZONE |sed "s/ZONE\=//g" | sed "s/\"//g"` ; sed -i".bak" "s#^[ \t]*date\.timezone.*#date\.timezone \= $TZname#g" /etc/php.d/bitrixenv.ini ; service httpd restart > /dev/null 2>&1 ; }
upick () {
	yum update --merge-conf ;
	test -d /usr/share/nagios/html && { chown -R nagios:bitrix /usr/share/nagios/html ; } ;
	test -d /var/log/nagios && { chown -R nagios:bitrix /var/log/nagios ; } ;
	test -d /var/spool/nagios && { chown -R nagios:bitrix /var/spool/nagios ; } ;
}

themenu () {
vaports=`[ -f /home/bitrix/www/.htsecure ] && echo "Enable HTTP access" || echo "Disable HTTP access (HTTPS only)"`

ip_=`ifconfig | grep Bcast | grep -v 127.0.0.1 | awk '{print $2}' | sed 's/addr://'`
clear
echo -e "\t\t" $LOGO " version "$LOGOV
if [ "$isCluster" = "YES" ]; then
	echo ;
	role="slave";
	if [ "$currentNodeIp" = "$masterNodeIp" ]; then role="master"; fi
	echo -e "\t\t"" It's runs as $role cluster node";
	echo -e "\t\t"" Cluster contains from (${arNodeList[*]})"
	echo -e "\t\t"" Master node is $masterNode ($masterNodeIp)"
else
	echo ;
	echo "IP address:" ${ip_} ;
fi

echo "Available actions:"
echo -e "\t\t" $Omenu
echo -e "\t\t" $amenu
echo -e "\t\t" "2. ${vaports}"
echo -e "\t\t" $dmenu
echo -e "\t\t" $emenu
echo -e "\t\t" $fmenu
echo -e "\t\t" $gmenu
echo -e "\t\t" $hmenu
echo -e "\t\t" $imenu
echo -e "\t\t" $jmenu

if [ "$isMaster" = "NO" -a "$isCluster" = "NO" ]; then
	echo -e "\t\t" $kmenu
fi
if [ "$isMaster" = "YES" -a "$isCluster" = "YES" ]; then
	echo -e "\t\t" $rmenu
fi
if [ "$isMaster" = "NO" -a "$isCluster" = "YES" ]; then
	echo -e "\t\t" $tmenu
fi

echo -e "\t\t" $ymenu
echo -e "\t\t" $wmenu
echo -e "\t\t" $nmenu
echo -e "\t\t" $mmenu
echo -e "\t\t" $bmenu
echo -e "\t\t" $umenu
echo
echo $MSG
echo Type a number and press ENTER
echo "(Ctrl-C for exit to shell)" ;
}

if [ `chage -l bitrix | grep "password must be changed" | wc -l` -gt 0 ]; then gpick ; fi

MSG=

while  true
 do
   themenu

   read answer

   MSG=

  case $answer in
	0|O)  Opick;;
	1|A)  dpick;;
	2|B)  epick;;
	3|C)  apick;;
	4|D)  gpick;;
	5|E)  hpick;;
	6|F)  ipick;;
	7|G)  bpick;;
	8|H)  cpick;;
	9|I)  jpick;;
	10|J)  kpick;;
	11|K)  rpick;;
	12|L)  tpick;;
	13|M)  ypick;;
	14|N)  wpick;;
	15|O)  npick;;
	16|P)  mpick;;
	17|Q)  spick;;
	18|U)  upick;;
        *) badchoice;;

   esac
done
