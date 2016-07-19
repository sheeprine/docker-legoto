#!/usr/bin/env sh

# Options.
DATADIR="/data"
WEBROOT="/webroot"
LEGO_BIN="/usr/bin/lego"
COMMON_PARAMS="--path $DATADIR -m $NOTIF_MAIL -a"

if [ -d $WEBROOT ]; then
    COMMON_PARAMS="$COMMON_PARAMS --webroot $WEBROOT"
else
    COMMON_PARAMS="$COMMON_PARAMS --http :$HTTP_PORT --tls :$TLS_PORT"
fi

check_cert() {
    local cert_path="$DATADIR/certificates"
    local cert_file="$cert_path/${1}.crt"
    local check_sec=100
    test -f $cert_file || return 1
    # Check expired certificate
    openssl x509 -checkend $check_sec -noout -in $cert_file || return 1
    return 0
}

create_cert() {
    $LEGO_BIN $COMMON_PARAMS -d $1 run
}

renew_cert() {
    $LEGO_BIN $COMMON_PARAMS -d $1 renew --days $DAYS
}

for cert in $@; do
    check_cert "$cert"
    test $? -gt 0 && create_cert $cert || renew_cert $cert
done
