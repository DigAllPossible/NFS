#!/bin/bash
# Onekey install nfs server www.z-dig.com
read -p "Which directory do you want to share (absolute path) :" ShareDir
>/tmp/ShareDir
>/tmp/Exports
for Dir in $(/bin/echo $ShareDir|/usr/bin/tr ";" "\n")
 do
  while [[ `/bin/echo $Dir|/bin/sed -rn 's#^(.).*$#\1#gp'` != "/" ]]
   do read -p "$Dir missing "/" ! Please enter absolute path :" Dir
  done
  if [[ ! -d "$Dir" ]]
   then 
    /bin/mkdir -p $Dir
  fi
  echo $Dir>>/tmp/ShareDir
done
for Dir in $(/bin/cat /tmp/ShareDir)
 do
  read -p "Who can mount \"$Dir\":" Who
  echo "$Dir $Who"|sed -nr 's#(.*)#\1(rw,sync,all_squash)#gp'>>/tmp/Exports
done
echo "Initializing . . ."
SoftWare=rpcbind,nfs-utils

for i in $(echo $SoftWare|tr "," "\n")
 do
  rpm -qa $i|grep $i>/dev/null
  if [[ "$?" != "0" ]]
   then soft=$i;/usr/bin/yum -q -y install $i &>/dev/null
  fi
   if [[ "$?" != "0" ]]
    then /bin/echo "The Network is not available! Software install failed!"
    /bin/rm -f /tmp/ShareDir
    /bin/rm -f /tmp/Exports
    exit 1
    else /bin/cat /tmp/Exports>>/etc/exports&&
    /bin/cat /tmp/ShareDir|/usr/bin/xargs /bin/chown -R nfsnobody.nfsnobody
   fi
done
/etc/init.d/rpcbind restart &>/dev/null&&/etc/init.d/nfs restart &>/dev/null&&
/bin/echo "/etc/init.d/nfs start">>/etc/rc.local
/bin/echo -e '\n* * * * * *'
/usr/sbin/showmount -e localhost
/bin/echo -e '* * * * * *\n'
echo 'Sucess!'
/bin/rm -f /tmp/ShareDir
/bin/rm -f /tmp/Exports
