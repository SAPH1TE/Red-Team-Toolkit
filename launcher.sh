#!/bin/bash

#always put this block at the top of the project scripts, it is essential for the script to work!
source core/functions.sh && source core/variables.sh 
trap "echo -e '\n${RED}Interrupted. Logging and exiting.${RESET}'; echo \"$(date '+%Y-%m-%d %H:%M:%S') - User force quit\" >> \"$LOGFILE\"; exit 1" SIGINT

# not much to say about this file, it is just the main entry point for the script
echo "$(date '+%Y-%m-%d %H:%M:%S') - script initialized!" >> "$LOGFILE"

#perform some checks before launching the main menu
check_wifi
check_resolution
sudocheck

# print the ascii art and launch the main menu
print_ascii
bash ${MENUSYSTEM}