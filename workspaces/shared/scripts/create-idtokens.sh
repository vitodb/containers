#!/bin/bash

# SPDX-FileCopyrightText: 2020 Fermi Research Alliance, LLC
# SPDX-License-Identifier: Apache-2.0

help_msg() {
    cat << EOF
$0 [options]
Generate multiple idtokens for each of the selected servers
  -h       print this message
  -v       verbose mode
  -a       set up fActory server
  -r       set up fRontend server
  -e       set up dEcision Engine server
EOF
}

# Defaults
VERBOSE=
IS_FACTORY=
IS_FRONTEND=
IS_DE=
        
while getopts "harev" option
do
  case "${option}"
    in
    h) help_msg; exit 0;;
    v) VERBOSE=yes;;
    a) IS_FACTORY=yes;;
    r) IS_FRONTEND=yes;;
    e) IS_DE=yes;;
    *) echo "ERROR: wrong option"; help_msg; exit 1;;
  esac
done

echo Creating IDTOKENS for host $HOSTNAME ...
# Without -lifetime, idtokens have no lifetime restrictions (i.e. no expiration)
condor_store_cred add -c -p "$HOSTNAME".$RANDOM
[[ -n "$IS_FACTORY" || -n "$IS_FRONTEND" || -n "$IS_DE" ]] || echo "WARNING: This host is not identified as Factory, nor Frontend, nor Decision Engine."
if [[ -n "$IS_FACTORY" ]]; then
    TOKEN_DIR=/var/lib/gwms-factory/.condor/tokens.d
    condor_token_create -id vofrontend_service@"$HOSTNAME" -key POOL > "$TOKEN_DIR"/frontend."$HOSTNAME".idtoken
    condor_token_create -id gfactory@"$HOSTNAME" > "$TOKEN_DIR"/gfactory."$HOSTNAME".idtoken
    chown gfactory:gfactory "$TOKEN_DIR"/gfactory.*
    chmod 600 "$TOKEN_DIR"/gfactory.*
    # TODO: check if the frontend.* token should have different owner/permission
    echo Factory:
    ls -lah "$TOKEN_DIR"
fi
if [[ -n "$IS_FRONTEND" ]]; then
    TOKEN_DIR=/var/lib/gwms-frontend/.condor/tokens.d
    condor_token_create -id vofrontend_service@"$HOSTNAME" -key POOL > "$TOKEN_DIR"/frontend."$HOSTNAME".idtoken
    chown frontend:frontend "$TOKEN_DIR"/frontend.*
    chmod 600 "$TOKEN_DIR"/frontend.*
    echo Frontend:
    ls -lah "$TOKEN_DIR"
fi
if [[ -n "$IS_DE" ]]; then
    TOKEN_DIR=/var/lib/decisionengine/.condor/tokens.d
    condor_token_create -id decisionengine_service@"$HOSTNAME" -key POOL > "$TOKEN_DIR"/decisionengine."$HOSTNAME".idtoken
    chown decisionengine:decisionengine "$TOKEN_DIR"/decisionengine.*
    chmod 600 "$TOKEN_DIR"/decisionengine.*
    echo Decision Engine:
    ls -lah "$TOKEN_DIR"
fi
