#!/bin/bash
##############################################################################
# file: 			makefindit. sh - remove and recreate findit and
#					symbolic links to findit in /usr/local/bin
#                   This builds and deploys the findit application
#                   and all of its symbolic links.
# author:			John Schwartzman, Forte Systems, Inc.
# last revision:	12/01/2018
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
declare -r SHSCRIPT="findit"
declare -r TEMPLATE_FILE="${SHSCRIPT}-template.sh"
declare -r USAGE_FILE="${SHSCRIPT}-usage.sh"
declare -r GETSCRIPT_FILE="${SHSCRIPT}-getScript.sh"
declare -r GETOPTIONS_FILE="${SHSCRIPT}-getOptions.sh"
declare -r FILES="findasm findawk findc findh findch 				\
				  findblock findchar findjsp						\
				  findcpp findhpp findchpp findcall					\
				  findcomp findzip findcfg findx					\
				  findaudio findimg	findsockets findpipes			\
				  findhfiles findhtml findcss findjs				\
				  findinc findjava findjar findfiles				\
				  findmake findMake	findlinks finddirs				\
				  findmp3 findwav findogg findhdirs					\
				  findnoext	findlog	findobj	findodt	                \
				  findpdf findphp findrdme findrpm					\
				  findsh findpl findpy findrb findshell				\
				  finda findso findlib findspace					\
				  findsvn findgit findbak findtmp					\
				  findtar findtxt findxml findxslt"

######################## CHECK FOR ROOT USER #################################
if [[ $(whoami) != 'root' ]]; then
	printf "\nERROR: You must be root to write to $BINDIR.\n"
	printf "USAGE: sudo ./makefindit.sh\n\n"
	exit 192
fi

################# CHECK for a known operating system #########################
printf "\n--Building findit for OSTYPE = $OSTYPE on $buildDate.\n"
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

# we assume that findit.sh is in the same directory as this script
# CD to this directory to get the location of findit.sh
cd $(dirname $0)
DEVDIR=$PWD

######### CREATE a local copy of findit.sh by combining TEMPLATE_FILE ########
######### with a few $OSTYPE determined declarations #########################
######### and inserting some other scripts into $DEVDIR/$SHSCRIPT.sh #########

# COPY lines 1 through 15 of the template file to findit.sh
sed -n '1,15p' $TEMPLATE_FILE > $SHSCRIPT.sh

# REPLACE the place holder with the build date and OSTYPE
sed -n "16s/<<DATE_AND_OSTYPE>>/$buildDate for OSTYPE = $OSTYPE/p" \
    $TEMPLATE_FILE >> $SHSCRIPT.sh

# COPY lines 17 through 33 of the template file to findit.sh
sed -n '17,33p' $TEMPLATE_FILE >> $SHSCRIPT.sh

# WRITE customized variables to findit.sh (these are dependent on OSTYPE)
echo "declare findCmd='$findCmd'" >> $SHSCRIPT.sh
echo "declare -r regexPrefix='$regexPrefix'" >> $SHSCRIPT.sh
echo "declare -r dspCmd='$dspCmd'" >> $SHSCRIPT.sh
echo "declare -r BUILD_DATE='$buildDate'" >> $SHSCRIPT.sh
echo "declare -r OSTYPE='$OSTYPE'" >> $SHSCRIPT.sh

# COPY lines 34 through 44 of the template file to findit.sh
sed -n '34, 44p' $TEMPLATE_FILE >> $SHSCRIPT.sh

# REPLACE the #<<USAGE>> place holder on line 45 of TEMPLATE_FILE 
# with nothing and then cat USAGE_FILE to findit.sh
sed -n "45s/#<<USAGE>>//p" $TEMPLATE_FILE >> $SHSCRIPT.sh
cat $USAGE_FILE >> $SHSCRIPT.sh

# REPLACE the #<<GETSCRIPT>> place holder on line 46 of TEMPLATE_FILE 
# with nothing and then cat GETSCRIPT_FILE to findit.sh
sed -n "46s/#<<GETSCRIPT>>//p" $TEMPLATE_FILE >> $SHSCRIPT.sh
cat $GETSCRIPT_FILE >> $SHSCRIPT.sh

# REPLACE the #<<GETOPTIONS>> place holder on line 47 of TEMPLATE_FILE 
# with nothing and then cat GETOPTIONS_FILE to findit.sh
sed -n "47s/#<<GETOPTIONS>>//p" $TEMPLATE_FILE >> $SHSCRIPT.sh
cat $GETOPTIONS_FILE >> $SHSCRIPT.sh

# COPY lines 48 through the end of the template file to findit.sh
sed -n '48, $p' $TEMPLATE_FILE >> $SHSCRIPT.sh

echo "--Finished creating $DEVDIR/$SHSCRIPT.sh"

######################### CD to /usr/local/bin ###############################
cd $BINDIR

### DELETE all old find* symbolic link files in this directory ###############
echo "--Deleting old find* symbolic links in $BINDIR"
for file in $FILES; do
    rm -f $file
    nCount+=1
done

echo "--$nCount symbolic links to $SHSCRIPT were deleted."

rm -f $SHSCRIPT    # REMOVE the old findit in BINDIR

### COPY findit.sh to /usr/local/bin and make it readable and executable ###
echo "--Copying $DEVDIR/$SHSCRIPT.sh to $BINDIR/$SHSCRIPT"
cp -f $DEVDIR/$SHSCRIPT.sh $SHSCRIPT
echo "--Making $SHSCRIPT readable and executable for everyone"
chmod +rx $SHSCRIPT

########################### RECREATE the symbolic links ######################
nCount=0
echo "--Creating symbolic links..."
for file in $FILES; do
	ln -fs $SHSCRIPT $file
	nCount+=1
done

echo "--$nCount symbolic links to $SHSCRIPT were created."
echo -e "--makefindit.sh completed successfully.\n"
exit 0

############################### end of makefgrep.sh ##########################

