# GlideinWMS Frontend docker image repository
This image is intended to be used by either docker or within a Kubernetes cluster. Please refer
to the respective sections below depending on the use you intend to give to this image.

For either case the following is needed. Please refer to: https://opensciencegrid.org/docs/other/install-gwms-frontend/#proxy-configuration for more info.

1. proxies.ini file. This file will tell the `renew proxy` cron job where are the certs and where to create the proxies 
1. Pilot certs. You have to mount the pilot cert and key in the path you have specified in `proxies.ini` within the "PILOT" section
1. Frontend certs. You have to mount the frontend cert and key in the path you have specified in `proxies.ini` within the "PILOT section".
in that case, make sure that the path were the certs are generated coincide with the paths specified in `proxies.ini`
1. Voms certs (Only If you need a fake voms server). You will need to mount a voms cert and key in the path specified in `proxies.ini` within the "PILOT" section

## Using with Kubernetes

## Using with Docker
