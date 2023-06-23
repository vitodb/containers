#!/bin/bash

TOKEN_DIR=/var/lib/gwms-factory/.condor/tokens.d

echo Creating IDTOKENS...
systemctl start condor
sleep 5
condor_token_create -id gfactory@"$HOSTNAME" > "$TOKEN_DIR"/gfactory."$HOSTNAME".idtoken
chown gfactory:gfactory "$TOKEN_DIR"/gfactory.*
chmod 600 "$TOKEN_DIR"/gfactory.*
condor_token_create -id vofrontend_service@"$HOSTNAME" -key POOL > "$TOKEN_DIR"/frontend."$HOSTNAME".idtoken
ls -lah "$TOKEN_DIR"
systemctl stop condor
