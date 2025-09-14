#!/bin/sh
# Using sh for compatibility

singularity_check() {
    # Check if it is invoked in Singularity and if Singularity is privileged mode or not
    # Return true (0) if in Singularity false (1) otherwise
    # Echo to stdout a string with the status:
    # - EMPTY if not in singularity
    # - yes is SINGULARITY_CONTAINER or GWMS_SINGULARITY_REEXEC are defined
    # - likely if SINGULARITY_NAME is not defined but process 1 is shim-init or sinit
    # - appends _privileged to yes or likely if singularity is running in privileged mode
    # - appends _fakeroot  to yes or likely if singularity is running in unprivileged fake-root mode
    # - appends _nousernamespaces to yes or likely there is no user namespace info (singularity is running in privileged mode)
    # In Singularity SINGULARITY_NAME and SINGULARITY_CONTAINER are defined (in v=2.2.1 only SINGULARITY_CONTAINER)
    # In the default GWMS wrapper GWMS_SINGULARITY_REEXEC=1
    # The process 1 in singularity is called init-shim (v>=2.6), or sinit (v>=3.2), not init
    # If the parent is 1 and is not init could be also Docker or other containers, so the check was removed
    #   even if it could be also Singularity
    in_singularity=
    [ -n "$SINGULARITY_CONTAINER" ] && in_singularity=yes
    if [ -z "$in_singularity" ];then
        [ -n "$GWMS_SINGULARITY_REEXEC" ] && in_singularity=yes
        [ "$(ps -p1 -ocomm=)" = "shim-init" ] && in_singularity=likely
        [ "$(ps -p1 -ocomm=)" = "sinit" ] && in_singularity=likely
        # [[ "x$PPID" = x1 ]] && [[ "x`ps -p1 -ocomm=`" != "xinit" ]] && { true; return; }  This is true also in Docker
        false
        return
    fi
    # It is in Singularity
    # Test for privileged singularity suggested by D.Dykstra
    # singularity exec -c -i -p ~/work/singularity/cvmfs-fuse3 cat /proc/self/uid_map 2>/dev/null|awk '{if ($2 == "0") print "privileged"; else print "unprivileged"; gotone=1;exit} END{if (gotone != 1) print "failed"}'
    if [ -e /proc/self/uid_map ]; then
        check_privileged="$(cat /proc/self/uid_map 2>/dev/null | head -n1 | tr -s '[:blank:]' ','),"
        if echo "$check_privileged" | grep -q '^,0,'; then  # [[ "$check_privileged" = ,0,* ]]; then
            # [[ "$check_privileged" = ,0,0,* ]] && in_singularity=${in_singularity}_privileged || in_singularity=${in_singularity}_fakeroot
            if echo "$check_privileged" | grep -q '^,0,0,'; then
                in_singularity=${in_singularity}_privileged
            else
                in_singularity=${in_singularity}_fakeroot
            fi
        fi
    else
        in_singularity=${in_singularity}_nousernamespaces
    fi
    echo ${in_singularity}
    # echo will not fail, returning 0 (true)
}

echo "####### BEGIN #######"
hostname
if singularity_check; then
	echo "## in Singularity"
else
	echo "## NO Singularity"
fi
pwd
echo "## Env"
env
echo "## File list"
ls -al
echo "######## END ########"
