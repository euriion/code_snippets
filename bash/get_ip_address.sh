ostnames="ftp.jaist.ac.jp
ftp.kddilabs.jp
ftp.neowiz.com
ftp.riken.jp
kartolo.sby.datautama.net.id
mirror.nus.edu.sg
mirror.unej.ac.id
mirror.yourconnect.com
mirror01.idc.hinet.net
mirrors.ispros.com.bd
mirrors.sohu.com
mirrors.ustc.edu.cn
ftp.neowiz.com
mirrors.fedoraproject.org
wildcard.fedoraproject.org"

for host in $hostnames; do
   echo -n "`dig +short $host | head -1` "
   echo "$host"
done