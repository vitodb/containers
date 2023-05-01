#!/bin/bash

# SPDX-FileCopyrightText: 2020 Fermi Research Alliance, LLC
# SPDX-License-Identifier: Apache-2.0

set -e

# Creating the lock for renewal proxy
# what systemctl start gwms-renew-proxies would do
#
LOCK=/var/lock/subsys/gwms-renew-proxies

if [ ! -f $LOCK ]; then
   touch $LOCK
fi

/usr/libexec/gwms_renew_proxies
