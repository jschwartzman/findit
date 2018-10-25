#!/bin/bash
##############################################################################
# file: 			makefgrep. sh - remove and recreate findgrep and
#					symbolic links to findgrep in /usr/local/bin
# author:			John Schwartzman, Forte Systems, Inc.
# last revision:	10/24/2018
##############################################################################

set -o nounset			# use strict (no unset variables)
set -o errexit			# exit if any statement returns non-true value

declare DEVDIR
declare findCmd='find'
declare regexPrefix
declare dspCmd
declare -i nCount=0;
declare -r BINDIR="/usr/local/bin"
declare -r buildDate=$(date)
declare -r SHSCRIPT="findgrep"
declare -r TEMPLATE_FILE="${SHSCRIPT}-template.sh"
declare -r USAGE_FILE="${SHSCRIPT}-usage.sh"
declare -r GETSCRIPT_FILE="${SHSCRIPT}-getScript.sh"
declare -r GETOPTIONS_FILE="${SHSCRIPT}-getOptions.sh"
declare -r FILES="findasm findawk			 		 				\
				  findc findh findch 				 				\
				  findcpp findhpp findchpp 							\
				  findcall											\
				  findcomp findzip									\
				  findcfg											\
				  findaudio findimg									\
				  findhidden										\
				  findhtml findcss findjs							\
				  findinc											\
				  findjava findjar									\
				  findmake findMake									\
				  findmp3 findwav findogg							\
				  findnoext											\
				  findlog											\
				  findobj											\
				  findodt											\
				  findpdf											\
				  findphp											\
				  findrdme											\
				  findrpm											\
				  findsh findpl findpy findrb findshell				\
				  finda findso findlib								\
				  findspace											\
				  findsvn findgit									\
				  findbak findtmp									\
				  findtar											\
				  findtxt											\
				  findxml findxslt"

######################## CHECK FOR ROOT USER #################################

if [ `whoami` != 'root' ] ; then
	printf "\nERROR: You must be root to write to $BINDIR.\n"
	printf "USAGE: sudo ./makefgrep.sh\n\n"
	exit 192
fi

printf "\n--Building findgrep for OSTYPE = $OSTYPE on $buildDate.\n"
# check for a known operating system
if [[ ${OSTYPE:0:5} = 'linux' ]]; then
	regexPrefix="-regextype posix-egrep"
	dspCmd='-exec ls -lhF --color {} +'
elif [[ ${OSTYPE:0:6} = 'darwin' ]]; then
	findCmd+=' -E'
	dspCmd='-exec ls -lhfG {} +'
else
	printf "ERROR: There are no instructions for building with OSTYPE = $OSTYPE.\n"
	exit 192
fi

# we assume that findgrep.sh is in the same directory as this script
# cd to this directory to get the location of findgrep.sh
cd `dirname $0` 
DEVDIR=$PWD

# create a local copy of findgrep.sh by combining TEMPLATE_FILE
# with a few $OSTYPE determined declarations
# and inserting some other scripts into $DEVDIR/$SHSCRIPT.sh

# copy lines 1 through 15 of the template file to findgrep.sh
sed -n '1,15p' $DEVDIR/$TEMPLATE_FILE > $DEVDIR/$SHSCRIPT.sh

# replace the place holder with the build date and OSTYPE
sed -n "16s/<<DATE_AND_OSTYPE>>/$buildDate for OSTYPE = $OSTYPE/p" $DEVDIR/$TEMPLATE_FILE >> $DEVDIR/$SHSCRIPT.sh

# copy lines 17 through 47 of the template file to findgrep.sh
sed -n '17,46p' $DEVDIR/$TEMPLATE_FILE >> $DEVDIR/$SHSCRIPT.sh

# write customized variables to findgrep.sh (these are dependent on OSTYPE)
echo "declare findCmd='$findCmd'" >> $DEVDIR/$SHSCRIPT.sh
echo "declare -r regexPrefix='$regexPrefix'" >> $DEVDIR/$SHSCRIPT.sh
echo "declare -r dspCmd='$dspCmd'" >> $DEVDIR/$SHSCRIPT.sh

# copy lines 47 through 56 of the template file to findgrep.sh
sed -n '47, 56p' $DEVDIR/$TEMPLATE_FILE >> $DEVDIR/$SHSCRIPT.sh

# replace the <<USAGE>> place holder with a newline and write USAGE_FILE to findgrep.sh
sed -n "57s/<<USAGE>>/\n/p" $DEVDIR/$TEMPLATE_FILE >> $DEVDIR/$SHSCRIPT.sh
cat $DEVDIR/$USAGE_FILE >> $DEVDIR/$SHSCRIPT.sh

# replace the <<GETSCRIPT>> place holder with a newline and write GETSCRIPT_FILE to findgrep.sh
sed -n "58s/<<GETSCRIPT>>/\n/p" $DEVDIR/$TEMPLATE_FILE >> $DEVDIR/$SHSCRIPT.sh
cat $DEVDIR/$GETSCRIPT_FILE >> $DEVDIR/$SHSCRIPT.sh

# replace the <<GETOPTIONS>> place holder with a newline and write GETOPTIONS_FILE to findgrep.sh
sed -n "59s/<<GETOPTIONS>>/\n/p" $DEVDIR/$TEMPLATE_FILE >> $DEVDIR/$SHSCRIPT.sh
cat $DEVDIR/$GETOPTIONS_FILE >> $DEVDIR/$SHSCRIPT.sh

# copy lines 60 through 144 of the template file to findgrep.sh
sed -n '60, 144p' $DEVDIR/$TEMPLATE_FILE >> $DEVDIR/$SHSCRIPT.sh

echo "--Finished creating $DEVDIR/$SHSCRIPT.sh"

cd $BINDIR

# delete all old find* symbolic link files (-type l) in this directory
echo "--Deleting old find* symbolic links in $BINDIR"
find . -maxdepth 1 -name "find*" -type l -exec rm {} \;

# copy findgrep.sh to /usr/local/bin and make it readable and executable
echo "--Copying $DEVDIR/$SHSCRIPT.sh to $BINDIR/$SHSCRIPT"
cp -f $DEVDIR/$SHSCRIPT.sh $SHSCRIPT
echo "--Making $SHSCRIPT readable and executable to everyone"
chmod +rx $SHSCRIPT

# remake the symbolic links
echo "--Creating symbolic links..."
for file in $FILES ; do
	ln -fsv $BINDIR/$SHSCRIPT $BINDIR/$file
	nCount+=1
done

echo "--$nCount symbolic links to $SHSCRIPT were created."
echo -e "--makefgrep.sh completed successfully.\n"
