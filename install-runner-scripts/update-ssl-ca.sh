#!/bin/bash
set -x -e -o pipefail
echo "# RUNNING: $(dirname $0)/$(basename $0)"

script="update-ssl-ca.sh"
cat <<'EOF_SCRIPT' > /home/ubuntu/${script}
#!/bin/bash

set -e -o pipefail

function clean() {
    ret=$?
    if [ "$ret" -gt 0 ] ;then
        echo "FAILURE $0: $ret"
    else
        echo "SUCCESS $0: $ret"
    fi
    exit $ret
}

trap clean EXIT QUIT KILL

[ -f /home/ubuntu/config.cfg ] && source /home/ubuntu/config.cfg

if [ -n "$UPDATE_SSL_CA_URL" ] ; then
	cd /usr/local/share/ca-certificates/
	curl --insecure ${UPDATE_SSL_CA_URL}/ac-machines-2020.crt -o ac-machines-2020.crt
	openssl x509 -inform DER -outform PEM -in ac-machines-2020.crt -out ac-machines-2020.crt -text
	/usr/sbin/update-ca-certificates --fresh
fi
EOF_SCRIPT

echo "# run /home/ubuntu/${script}"
chmod +x /home/ubuntu/${script}
/bin/bash -c /home/ubuntu/${script}
echo "# end /home/ubuntu/${script}"
