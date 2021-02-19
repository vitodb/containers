# GlideinWMS Frontend docker image repository
This image is intended to be used by either docker or within a Kubernetes cluster. Please refer
to the respective sections below depending on the use you intend to give to this image.

For either case the following is needed. Please refer to: https://opensciencegrid.org/docs/other/install-gwms-frontend/#proxy-configuration for more info.
1. frontend.xml. This is the main configuration file and must be mounted exactly at /etc/gwms-frontend/ and the name has to be "frontend.xml.base". 
1. proxies.ini. file This file will tell the `renew proxy` cron job where are the certs and where to create the proxies 
1. Pilot certs. You have to mount the pilot cert and key in the path you have specified in `proxies.ini` within the "PILOT" section
1. Frontend certs. You have to mount the frontend cert and key in the path you have specified in `proxies.ini` within the "PILOT section".
in that case, make sure that the path were the certs are generated coincide with the paths specified in `proxies.ini`
1. Voms certs (Only If you need a fake voms server). You will need to mount a voms cert and key in the path specified in `proxies.ini` within the "PILOT" section

## Validation scripts
The Validation Scripts are cloned into the /opt/ directory within the image at runtime. To specify which repositories and branches within those repositories
to clone, the ENV VARS `GWMS_FE_VS_REPO_#` and `GWMS_FE_VS_BRANCH_#` are used, e.g.,
```
GWMS_FE_VS_REPO_1="https://github.com/<MY REPO>.git"
GWMS_FE_VS_BRANCH_1="production"
GWMS_FE_VS_REPO_2="https://github.com/<ANOTHER REPO>.git"
```

The above would clone 2 repositories into /opt/. If no branch is specified the "master" branch is used.

## Using with Docker
In the following there is an example on how to use this image with docker.

Considering the following extract of a `proxies.ini` configuration file:
```
[FRONTEND]

# Paths to frontend certificate and key
proxy_cert = /etc/grid-security/gwms-frontend/hostcert.pem
proxy_key = /etc/grid-security/gwms-frontend/hostkey.pem

...

[PILOT MY_PILOT]

# Paths to the pilot certificate and key
proxy_cert = /etc/grid-security/gwms-pilot/pilotcert.pem
proxy_key = /etc/grid-security/gwms-pilot/pilotkey.pem
```

We will run the following docker command:

```
docker run \
    --volume $(pwd)/frontend.xml:/etc/gwms-frontend/frontend.xml.base \
    --volume $(pwd)/proxies.ini:/etc/gwms-frontend/proxies.ini \
    --volume $(pwd)/hostcert.pem:/etc/grid-security/gwms-frontend/hostcert.pem \
    --volume $(pwd)/hostkey.pem:/etc/grid-security/gwms-frontend/hostkey.pem \
    --volume $(pwd)/pilotcert.pem:/etc/grid-security/gwms-frontend/pilotcert.pem \
    --volume $(pwd)/pilotkey.pem:/etc/grid-security/gwms-frontend/pilotkey.pem \
    --env GWMS_FE_VS_REPO_1="https://github.com/<MY VALIDATION SCRIPTS REPO>.git" \
    --env GWMS_FE_VS_REPO_2="https://github.com/<ANOTHER VALIDATION SCRIPTS REPO>.git" \
    --env GWMS_FE_VS_BRANCH_2="production" \
    glideinwms/gwms-frontend:stable
```

Notice how the paths for `proxy_cert` and `proxy_key` in the `proxies.ini` file match the paths were we
mount the respective certificates within the image.

## Using with Kubernetes



