#!/bin/bash
#############################################################################
# file: 			makeFindit. sh - remove and recreate findit and
#					symbolic links to findit in /usr/bin
#                   This builds and deploys or removes the findit
#                   application and all of its symbolic links.
# author:			John Schwartzman, Forte Systems, Inc.
# last revision:	05/06/2019
#############################################################################

set -o errexit			# exit if any statement returns non-true value

declare DEVDIR
declare findCmd='find'
declare regexPrefix
declare dspCmd
declare -i nCount=0;
declare -r BINDIR="/usr/bin"
declare -r buildDate=$(date)
declare -r SHSCRIPT="findit"
declare -r TEMPLATE_FILE="${SHSCRIPT}-template.sh"
declare -r USAGE_FILE="${SHSCRIPT}-usage.sh"
declare -r GETSCRIPT_FILE="${SHSCRIPT}-getScript.sh"
declare -r GETOPTIONS_FILE="${SHSCRIPT}-getOptions.sh"
declare -r FILES="finda findasm findawk findc findh findch 			\
				  findblock findchar findjsp findgo					\
				  findcpp findhpp findchpp findcall					\
				  findcomp findzip findcfg findx finddtd			\
				  findaudio findimg	findsocket findpipe				\
				  findhfile findhtml findcss findjs					\
				  findinc findjava findjar findfile					\
				  findmake findMake	findlink finddir				\
				  findmp3 findwav findogg findhdir					\
				  findnoext	findlst findlog	findobj	findodt	        \
				  findpdf findphp findrdme findrpm					\
				  findsh findpl findpy findrb findshell				\
				  finda findso findlib findspace					\
				  findsvn findgit findbak findtmp					\
				  findtar findtxt findxml findxslt"

######################## CHECK FOR ROOT USER ################################
function checkForRoot()
{
	if [[ $(whoami) != 'root' ]]; then
		printf "\nERROR: You must have root privileges to write to $BINDIR.\n"
		usage
		exit 192
	fi
}

################# CHECK for a known operating system ########################
function checkOS()
{
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
}

################################## buildFindit ##############################
function buildFindit()
{
	# we assume that findit.sh is in the same directory as this script
	# CD to this directory to get the location of findit.sh
	cd $(dirname $0)
	DEVDIR=$PWD

	###### CREATE a local copy of findit.sh by combining TEMPLATE_FILE ######
	###### with a few $OSTYPE determined declarations #######################
	###### and inserting some other scripts into $DEVDIR/$SHSCRIPT.sh #######

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
}

################################## removeFindit #############################
function removeFindit()
{
	### DELETE all old find* symbolic link files in this directory ##########
	echo "--Deleting old symbolic links to findit in $BINDIR"
	find $BINDIR -type l -lname findit -exec rm {} +
	echo "--Deleting old $BINDIR/$SHSCRIPT"
	rm -f $BINDIR/$SHSCRIPT    # REMOVE the old findit in BINDIR
}

################################## copyFindit ###############################
function copyFindit()
{
	# COPY findit.sh to $BINDIR and make it readable and executable ##
	echo "--Copying $DEVDIR/$SHSCRIPT.sh to $BINDIR/$SHSCRIPT"
	cp -f $DEVDIR/$SHSCRIPT.sh $BINDIR/$SHSCRIPT
	echo "--Making $BINDIR/$SHSCRIPT readable and executable for everyone"
	chmod +rx $BINDIR/$SHSCRIPT
}

########################### CREATE the symbolic links #######################
function createSymlinks()
{
	cd $BINDIR
	nCount=0
	echo "--Creating symbolic links..."
	for file in $FILES; do
		ln -fs $SHSCRIPT $file
		nCount+=1
	done

	echo "--$nCount symbolic links to $SHSCRIPT were created."
}

##################################### usage #################################
function usage()
{
	echo -e "\nUSAGE: sudo ./makeFindit.sh [-h || --help] build || clean"
	echo -e "-or-   sudo make [clean]\n\n"
}

##################################### main ##################################

if [[ "$1" == "build" ]]; then
	checkForRoot
	checkOS
	buildFindit
	removeFindit
	copyFindit
	createSymlinks
	echo -e "--makefindit.sh build completed successfully.\n"
	exit 0

elif [[ "$1" == "clean" ]]; then
	echo
	checkForRoot
	removeFindit
	echo -e "--makefindit.sh clean completed successfully.\n"
	exit 0

elif [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
	usage
	echo -e "\n"
	exit 0

else
	echo -e "\nInvalid command argument\n"
	usage
	echo
	exit 192
fi

############################# end of makeFindit.sh ##########################

