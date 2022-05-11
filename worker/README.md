# worker

This folder holds various Dockerfiles for worker nodes images

fnal-wn-sl6, fnal-wn-sl7 and fnal-wn-el8 are containers that provide an environment similar to the one on FermiGrid (actual FermiGrid nodes have only SL7).
It includes a base Scientific Linux with the xrootd client from OSG.

These three continers are made available on DockerHub and as expanded Singularity images on OSG's CVMFS.
To add a container to the OSG images it shold be added to the docker_images.txt file in the [OSG CVMFS Singularly Image Repository](https://github.com/opensciencegrid/cvmfs-singularity-sync). 

[Here](https://support.opensciencegrid.org/support/solutions/articles/12000024676-docker-and-singularity-containers) are more information about adding your image to CVMFS and on using Singularity images on CVMFS.

