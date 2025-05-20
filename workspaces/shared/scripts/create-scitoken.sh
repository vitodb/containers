#!/bin/bash

# SPDX-FileCopyrightText: 2020 Fermi Research Alliance, LLC
# SPDX-License-Identifier: Apache-2.0

# Defaults
VERBOSE=
IS_FRONTEND=
IS_DE=
TOKEN_DIR=
TOKEN_DIR_FRONTEND=/var/lib/gwms-frontend/.condor/tokens.d
TOKEN_DIR_DE=/var/lib/decisionengine/.condor/tokens.d
TOKEN_OWNER=
TOKEN_OWNER_FRONTEND="frontend"
TOKEN_OWNER_DE="decisionengine"
TOKEN_SERVER="htvaultprod.fnal.gov"
TOKEN_VO=fermilab

help_msg() {
    cat << EOF
$0 [options] 
Generate one SciToken with the setting for a specific server or custom ones
  -h       print this message
  -v       verbose mode
  -d DIR   HTCondor tokens directory (default depends on server: $TOKEN_DIR_FRONTEND or $TOKEN_DIR_DE)
  -u USER  user owning the SciToken (default depends on server: $TOKEN_OWNER_FRONTEND or $TOKEN_OWNER_DE)
  -s SRV   SciToken server (default: $TOKEN_SERVER)
  -i VO    token VO (default: $TOKEN_VO)
  -r       set up fRontend server
  -e       set up dEcision Engine server
EOF
}

while getopts "hred:u:s:i:v" option
do
  case "${option}"
    in
    h) help_msg; exit 0;;
    v) VERBOSE=yes;;
    d) TOKEN_DIR=$OPTARG;;
    u) TOKEN_OWNER=$OPTARG;;
    s) TOKEN_SERVER=$OPTARG;;
    i) TOKEN_VO=$OPTARG;;
    r) IS_FRONTEND=yes;;
    e) IS_DE=yes;;
    *) echo "ERROR: wrong option"; help_msg; exit 1;;
  esac
done

if [[ -n "$IS_FRONTEND" ]]; then
    [[ -n "$TOKEN_DIR" ]] || TOKEN_DIR="$TOKEN_DIR_FRONTEND"
    [[ -n "$TOKEN_OWNER" ]] || TOKEN_OWNER="$TOKEN_OWNER_FRONTEND"
    [[ -z "$VERBOSE" ]] || echo "Creating Frontend tokens for $TOKEN_OWNER in $TOKEN_DIR."
fi
if [[ -n "$IS_DE" ]]; then
    [[ -n "$TOKEN_DIR" ]] || TOKEN_DIR="$TOKEN_DIR_DE"
    [[ -n "$TOKEN_OWNER" ]] || TOKEN_OWNER="$TOKEN_OWNER_DE"
    [[ -z "$VERBOSE" ]] || echo "Creating Decision Engine tokens for $TOKEN_OWNER in $TOKEN_DIR."
fi

echo Generating SciToken...
[[ -n "$TOKEN_DIR" && -n "$TOKEN_OWNER" ]] || { echo "Token owner or directory not defined ($TOKEN_OWNER/$TOKEN_DIR). Aborting"; exit 1; } 
htgettoken --minsecs=3580 -i "$TOKEN_VO" -v -a "$TOKEN_SERVER" -o "$TOKEN_DIR"/"$HOSTNAME".scitoken
chown "$TOKEN_OWNER": "$TOKEN_DIR"/"$HOSTNAME".scitoken
chmod 600 "$TOKEN_DIR"/"$HOSTNAME".scitoken
ls -lah "$TOKEN_DIR"
