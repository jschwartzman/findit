#!/bin/bash
#############################################################################
# file: 			removeFindit.sh - remove findit symbolic links 
#					to findit and findit from /usr/local/bin
# author:			John Schwartzman, Forte Systems, Inc.
# last revision:	03/14/2019
#############################################################################

set -o nounset			# use strict (no unset variables)
set -o errexit			# exit if any statement returns non-true value

declare -r SHSCRIPT="findit"
declare -r BINDIR="/usr/local/bin"

######################## CHECK FOR ROOT USER ################################
if [[ $(whoami) != 'root' ]]; then
	printf "\nERROR: You must be root to delete files from $BINDIR.\n"
	printf "USAGE: sudo make clean\n\n"
	exit 192
fi

echo "--Deleting all symbolic links to findit in $BINDIR"
find /usr/local/bin -type l -lname findit -exec rm {} +
echo "--Deleting old $BINDIR/$SHSCRIPT"
rm -f $SHSCRIPT    # REMOVE the old findit in BINDIR
echo -e "--removeFindit.sh completed successfully.\n"
exit 0

########################### end of removeFindit.sh ##########################

