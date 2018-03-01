#!/bin/bash
###
# This script is useful for cleaning up the 'project'
# Run the following command to change permissions of
# this 'cleanup' file if needed:
# chmod u+x cleanup.sh
###

# Remove directories and files in bd/platform/ folder
find . -mindepth 1 -maxdepth 5  -path './*.srcs/sources_1/bd/*/*' \
                              ! -path './*.srcs/sources_1/bd/*/ui' \
                              ! -path './*.srcs/sources_1/bd/*/hdl' \
                              ! -path './*.srcs/sources_1/bd/*/*.bd' \
                                -exec rm -rf {} +

# Remove runs directory
find . -mindepth 1 -type d -path './*.runs' -exec rm -rf {} +

# Remove all files and folders in bd/platform/hdl folder except wrapper
find . -mindepth 1 -maxdepth 6   -path './*.srcs/sources_1/bd/*/hdl/*' \
                               ! -path './*.srcs/sources_1/bd/*/hdl/*_wrapper.v' \
                               ! -path './*.srcs/sources_1/bd/*/hdl/*_wrapper.vhd' \
                                 -exec rm -rf {} +
