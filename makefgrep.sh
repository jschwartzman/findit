#!/bin/bash
##############################################################################
# file: 			makefgrep. sh - remove and recreate findgrep and
#					symbolic links to findgrep in /usr/local/bin
#                   This builds and deploys the findgrep application
#                   and all of its symbolic links.
# author:			John Schwartzman, Forte Systems, Inc.
# last revision:	11/13/2018
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
declare -r FILES="findasm findawk findc findh findch 				\
				  findcpp findhpp findchpp findcall					\
				  findcomp findzip findcfg findx					\
				  findaudio findimg	findsockets findpipes			\
				  findhidden findhtml findcss findjs				\
				  findinc findjava findjar findfiles				\
				  findmake findMake	findlinks finddirs				\
				  findmp3 findwav findogg							\
				  findnoext	findlog	findobj	findodt	                \
				  findpdf findphp findrdme findrpm					\
				  findsh findpl findpy findrb findshell				\
				  finda findso findlib findspace					\
				  findsvn findgit findbak findtmp					\
				  findtar findtxt findxml findxslt"

######################## CHECK FOR ROOT USER #################################
if [ $(whoami) != 'root' ]; then
	printf "\nERROR: You must be root to write to $BINDIR.\n"
	printf "USAGE: sudo ./makefgrep.sh\n\n"
	exit 192
fi

################# check for a known operating system #########################
printf "\n--Building findgrep for OSTYPE = $OSTYPE on $buildDate.\n"
if [[ ${OSTYPE:0:5} = 'linux' ]]; then		# linux
	regexPrefix="-regextype posix-egrep"
	dspCmd='-exec ls -lhF --color {} +'
elif [[ ${OSTYPE:0:6} = 'darwin' ]]; then	# MAC OS
	findCmd+=' -E'
	dspCmd='-exec ls -lhfG {} +'
else
	printf "ERROR: There are no instructions \
           for building with OSTYPE = $OSTYPE.\n"
	exit 192
fi

# we assume that findgrep.sh is in the same directory as this script
# cd to this directory to get the location of findgrep.sh
cd $(dirname $0)
DEVDIR=$PWD

######### create a local copy of findgrep.sh by combining TEMPLATE_FILE ######
######### with a few $OSTYPE determined declarations #########################
######### and inserting some other scripts into $DEVDIR/$SHSCRIPT.sh #########

# copy lines 1 through 15 of the template file to findgrep.sh
sed -n '1,15p' $TEMPLATE_FILE > $SHSCRIPT.sh

# replace the place holder with the build date and OSTYPE
sed -n "16s/<<DATE_AND_OSTYPE>>/$buildDate for OSTYPE = $OSTYPE/p" \
    $TEMPLATE_FILE >> $SHSCRIPT.sh

# copy lines 17 through 47 of the template file to findgrep.sh
sed -n '17,47p' $TEMPLATE_FILE >> $SHSCRIPT.sh

# write customized variables to findgrep.sh (these are dependent on OSTYPE)
echo "declare findCmd='$findCmd'" >> $SHSCRIPT.sh
echo "declare -r regexPrefix='$regexPrefix'" >> $SHSCRIPT.sh
echo "declare -r dspCmd='$dspCmd'" >> $SHSCRIPT.sh
echo "declare -r BUILD_DATE='$buildDate'" >> $SHSCRIPT.sh
echo "declare -r OSTYPE='$OSTYPE'" >> $SHSCRIPT.sh

# copy lines 48 through 57 of the template file to findgrep.sh
sed -n '48, 57p' $TEMPLATE_FILE >> $SHSCRIPT.sh

# replace the #<<USAGE>> place holder on line 58 of TEMPLATE_FILE 
# with nothing and then cat USAGE_FILE to findgrep.sh
sed -n "58s/#<<USAGE>>//p" $TEMPLATE_FILE >> $SHSCRIPT.sh
cat $USAGE_FILE >> $SHSCRIPT.sh

# replace the #<<GETSCRIPT>> place holder on line 59 of TEMPLATE_FILE 
# with nothing and then cat GETSCRIPT_FILE to findgrep.sh
sed -n "59s/#<<GETSCRIPT>>//p" $TEMPLATE_FILE >> $SHSCRIPT.sh
cat $GETSCRIPT_FILE >> $SHSCRIPT.sh

# replace the #<<GETOPTIONS>> place holder on line 60 of TEMPLATE_FILE 
# with nothing and then cat GETOPTIONS_FILE to findgrep.sh
sed -n "60s/#<<GETOPTIONS>>//p" $TEMPLATE_FILE >> $SHSCRIPT.sh
cat $GETOPTIONS_FILE >> $SHSCRIPT.sh

# copy lines 61 through the end 
# of the template file to findgrep.sh
sed -n '61, $p' $TEMPLATE_FILE >> $SHSCRIPT.sh

echo "--Finished creating $DEVDIR/$SHSCRIPT.sh"

######################### cd to /usr/local/bin ###############################
cd $BINDIR

### delete all old find* symbolic link files (-type l) in this directory #####
echo "--Deleting old find* symbolic links in $BINDIR"
for file in $FILES; do
    rm -fv $file
    nCount+=1
done

echo "--$nCount symbolic links to $SHSCRIPT were deleted."

rm -fv $SHSCRIPT    # remove the old findgrep

### copy findgrep.sh to /usr/local/bin and make it readable and executable ###
echo "--Copying $DEVDIR/$SHSCRIPT.sh to $BINDIR/$SHSCRIPT"
cp -f $DEVDIR/$SHSCRIPT.sh $SHSCRIPT
echo "--Making $SHSCRIPT readable and executable for everyone"
chmod +rx $SHSCRIPT

########################### remake the symbolic links ########################
nCount=0
echo "--Creating symbolic links..."
for file in $FILES; do
	ln -fsv $SHSCRIPT $file
	nCount+=1
done

echo "--$nCount symbolic links to $SHSCRIPT were created."
echo -e "--makefgrep.sh completed successfully.\n"

############################### end of makefgrep.sh ##########################

