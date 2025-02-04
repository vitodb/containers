# preload libc_grantpt_fix.so for SL7 dev container
# to fix pseudoterminal in unpriv. namespace;
# see https://github.com/apptainer/apptainer/issues/297

alias ddd 'env LD_PRELOAD=/usr/lib64/libc_grantpt_fix.so ddd'
