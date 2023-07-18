#!/bin/bash

TOKEN_DIR=/var/lib/gwms-frontend/.condor/tokens.d

echo Generating SciToken...
htgettoken --minsecs=3580 -i fermilab -v -a htvaultprod.fnal.gov -o "$TOKEN_DIR"/"$HOSTNAME".scitoken
chown frontend:frontend "$TOKEN_DIR"/"$HOSTNAME".scitoken
chmod 600 "$TOKEN_DIR"/"$HOSTNAME".scitoken
ls -lah "$TOKEN_DIR"