#!/usr/bin/env sh

# Options.
DATADIR="/data"
LEGO_BIN="/usr/bin/lego"
COMMON_PARAMS="--http $HTTP_PORT --tls $TLS_PORT --path $DATADIR -m $NOTIF_MAIL -a"

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
    $LEGO_BIN $COMMON_PARAMS -d $1 -a run
}

renew_cert() {
    $LEGO_BIN $COMMON_PARAMS --days $DAYS -d $1 renew
}

for cert in $@; do
    check_cert "$cert"
    test $? -gt 0 && create_cert $cert || renew_cert $cert
done
