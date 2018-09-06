#!/bin/bash

# --- configuration -----------------------------------------------------------

RED=`tput setaf 1`
BOLD=`tput bold`
DIM=`tput dim`
RESET=`tput sgr0`
AWK="/^-----BEGIN.*/{flag=1;next}/^-----END.*/{flag=0}flag"

# --- command line arguments --------------------------------------------------

P12_FILE=$1

# --- sanity checks -----------------------------------------------------------

# check the argument was passed
if [[ ! $1 = *[!\ ]* ]]; then
  echo "${BOLD}Usage:${RESET}"
  echo "    p12info.sh path-to-file.p12"
  echo
  exit 1
fi

# check the p12 file is available
if [ ! -f $P12_FILE ]; then
  echo "${RED}'${P12_FILE}' not found.${RESET}"
  exit 1
fi

# --- let's do this -----------------------------------------------------------

# temporary files
CERT_FILE=`mktemp`
KEY_FILE=`mktemp`

# extract the cert & private key
echo
echo "${DIM}---${RESET} ${BOLD}OpenSSL Things${RESET} ${DIM}---------------------------------------------${RESET}"
echo
openssl pkcs12 -in $P12_FILE -nokeys -out $CERT_FILE -nodes -passin pass:
openssl pkcs12 -in $P12_FILE -nocerts -out $KEY_FILE -nodes -passin pass:
openssl rsa -in $KEY_FILE -out $KEY_FILE

# delete the "-passin pass:" above to prompt for a password if you want

# display the certificate
echo
echo "${DIM}---${RESET} ${BOLD}Certificate${RESET} ${DIM}------------------------------------------------${RESET}"
echo
awk $AWK $CERT_FILE

# display the private key
echo
echo "${DIM}---${RESET} ${BOLD}Private Key${RESET} ${DIM}------------------------------------------------${RESET}"
echo
awk $AWK $KEY_FILE

echo

# clean up
rm -f $CERT_FILE $KEY_FILE
