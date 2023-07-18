#!/bin/bash

TOKEN_DIR=/var/lib/gwms-frontend/.condor/tokens.d

echo Creating IDTOKENS...
condor_store_cred add -c -p $HOSTNAME.$RANDOM
condor_token_create -id vofrontend_service@"$HOSTNAME" -key POOL > "$TOKEN_DIR"/frontend."$HOSTNAME".idtoken
chown frontend:frontend "$TOKEN_DIR"/frontend.*
chmod 600 "$TOKEN_DIR"/frontend.*
ls -lah "$TOKEN_DIR"
