#!/bin/bash
#
# Pulls all PEM certs out of yaml file
# then examines properties using openssl
#
# Fork of https://github.com/fabianlee/blogcode/blob/master/ymlcerts/parse_certs.sh

c2cyaml='/etc/cf-assets/envoy_config/sds-c2c-cert-and-key.yaml'

inputfile=${1:-${c2cyaml}}

# pull out multiline sections, remove leading spaces
sed -ne '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/p' ${inputfile} | sed 's/^\s*//' > allcerts.pem

# count how many certs were pulled
certcount=$(grep -e "-----BEGIN CERTIFICATE-----" allcerts.pem | wc -l)

# pull each cert individually, use openssl to show critical properties
for index in $(seq 1 $certcount); do
  echo "==== cert $index"
  awk "/-----BEGIN CERTIFICATE-----/{i++}i==$index" allcerts.pem > $index.crt
  openssl x509 -in $index.crt -text -noout | grep -E "Subject:|Not After :|DNS:"
  rm $index.crt
done

rm allcerts.pem
