#!/bin/bash
##############################################################################
# file: 			makefgrep. sh - remove and recreate findgrep and
#					symbolic links to findgrep in /usr/local/bin
#                   requires rmlinks
# author:			John Schwartzman, Forte Systems, Inc.
# last revision:	10/19/2018
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
declare -r TARFILE="${SHSCRIPT}.tgz"
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
sed -n '1,13p' $DEVDIR/$TEMPLATE_FILE > $DEVDIR/$SHSCRIPT.sh
sed -n "14s/<<DATE_AND_OSTYPE>>/$buildDate for OSTYPE = $OSTYPE/p" $DEVDIR/$TEMPLATE_FILE >> $DEVDIR/$SHSCRIPT.sh
sed -n '15,42p' $DEVDIR/$TEMPLATE_FILE >> $DEVDIR/$SHSCRIPT.sh
echo "declare findCmd='$findCmd'" >> $DEVDIR/$SHSCRIPT.sh
echo "declare -r regexPrefix='$regexPrefix'" >> $DEVDIR/$SHSCRIPT.sh
echo "declare -r dspCmd='$dspCmd'" >> $DEVDIR/$SHSCRIPT.sh
sed -n '43,$p' $DEVDIR/$TEMPLATE_FILE >> $DEVDIR/$SHSCRIPT.sh

cd $BINDIR

# delete all find* symbolic link files (-type 1) in this directory
echo "--Deleting old find* symbolic links in $BINDIR"
# find . -maxdepth 1 -name "find*" -type l -exec rm {} \;
$BINDIR/rmlinks $BINDIR/$SHSCRIPT

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
# tar all the find* files
echo "--Creating archive file: $TARFILE"
tar -czf $TARFILE $SHSCRIPT $FILES $DEVDIR/$TEMPLATE_FILE $DEVDIR/makefgrep.sh
echo "--Moving $TARFILE to $DEVDIR"
mv -f $TARFILE $DEVDIR
echo -e "--makefgrep.sh completed successfully.\n"
