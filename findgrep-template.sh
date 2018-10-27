#!/bin/bash
###############################################################################
# file:					findgrep.sh
# author: 			 	John Schwartzman, Forte Systems, Inc.
# last revision:		10/26/2018
#
# search for content in files with specific file types
# findc, findh, findch, findcpp, findhpp, findchpp, findjava, etc.
# are symbolic links to findgrep
#
# See case statement (getScript) for a list of symlinks and the 
# file patterns they match.
# Change --dir=$PWD (default) to --dir=. to show relative paths
# (i.e., ./xxx/xx instead of /xxx/xxx/xx)
#
# Built on <<DATE_AND_OSTYPE>>.
# The variables findCmd, regexPrefix and displayCmd have been customized 
# for this OS.
#
# USAGE, GETSCRIPT and GETOPTION (in findgrep-template.sh are placeholders for
# other shell scripts.  They will be replaced in findgrep.sh at build time.
###############################################################################

declare -r VERSION="1.0.1"
declare -r script=${0##*/}	# base regex of symbolic link
declare regex 				# regex file pattern we're trying to match
declare params				# string containing parameters (folllowing options)
declare ext					# regex pattern of file extension
declare dir					# will use $PWD unless overridden with -d switch
declare findStyle='-regex'	# use find . -regex or find . -iregex
declare type='-type f'		# -type f(ile) is the default
declare displayCmd			# display command
declare grepOpt				# grep options
declare grepCmd				# grep [-$grepOpt]
declare fdesc				# file type description
declare size				# file size n[b|c|k]
declare time				# file modification time
declare user				# file owner user
declare group				# file owner group
declare -i gcase=0			# case-insensitive grep
declare -i bCount=0			# just count matching files if -c switch provided
declare -i bShowMatches=0 	# show matching text in files
declare -i bWholeWord=0 	# grep whole words
declare -i maxDepth=-1 		# maxDepth (must be a positive number if used)
declare -i bNoMatch=0		# find files without matches
declare -i bQuery=0			# show find statement without executing
declare -i bExecutable=0	# find executable files

##############################################################################
# doExit(errorNumber = 0): display usage and exit with errorNumber
##############################################################################
function doExit()
{
	usage
	exit $1
}

#<<USAGE>>
#<<GETSCRIPT>>
#<<GETOPTION>>

########## begin program execution ##########
getScript
getOptions "$@"

# create regex from extension if it hasn't yet been defined
if [[ -z $regex ]]; then
	regex="^.+${ext}"
fi

########## determine whether we are going to use grep ##########
if [ ${#params} -eq 0 ]; then			# if no search text was provided do not use grep
	grepCmd=''
	if [ $bShowMatches -eq 1 -o $gcase -eq 1 -o $bWholeWord -eq 1 -o $bNoMatch -eq 1 ]; then
		echo "WARNING: The -i, -m, -M and -w options have no meaning without 'text to match'."
		doExit 192
	fi
else											# use grep
	if [ $bShowMatches -eq 0 -a $bCount -eq 0 ]; then
		grepOpt+='l'
	fi
	if [ $bNoMatch -eq 1 ]; then
		# the grep -L option must come after any other options
		grepOpt+='L'
	fi

	grepCmd='grep '
	if [[ $grepOpt ]]; then
		grepCmd+="-$grepOpt"
	fi
	grepCmd+=' --color'
fi

########## display matching files ##########
echo

if [ $bCount -eq 1 ]; then			##### display count of matches
	if [ -z "$grepCmd" ]; then
		if [ $bQuery -eq 1 ]; then
			printf "$findCmd '$regex' 2>/dev/null"
		else
			$findCmd "$regex" 2>/dev/null | \
				printf "Number of ${fdesc}: %d\n" $(wc -l)
		fi
	else
		if [ $bQuery -eq 1 ]; then
			printf "$findCmd '$regex' 2>/dev/null | xargs $grepCmd '$params' 2>/dev/null"
		else
			declare relation # "containing" or "not containing"
			if [ $bNoMatch -eq 1 ]; then
				relation="not containing"
			else
				relation="containing"
			fi
			$findCmd "$regex" 2>/dev/null | xargs $grepCmd "$params" 2>/dev/null | \
				printf "Number of ${fdesc} $relation $params: %d\n" $(wc -l)
		fi
	fi

elif [ $bShowMatches -eq 1 ]; then		# display matching lines
	if [ $bQuery -eq 1 ]; then
		echo "$findCmd '$regex' 2>/dev/null | xargs $grepCmd '$params' 2>/dev/null"
	else
		$findCmd "$regex" 2>/dev/null | xargs $grepCmd "$params" 2>/dev/null
	fi

else												# display filespecs only
 	if [[ -z $grepCmd ]]; then
		if [ $bQuery -eq 1 ]; then
			echo "$findCmd '$regex' $displayCmd 2>/dev/null"
		else
			$findCmd "$regex" $displayCmd 2>/dev/null
		fi
	else
		if [ $bQuery -eq 1 ]; then
			echo "$findCmd '$regex' 2>/dev/null | xargs $grepCmd '$params' 2>/dev/null"
		else
			$findCmd "$regex" 2>/dev/null | xargs $grepCmd "$params" 2>/dev/null
		fi
	fi
fi

echo

############################## End of findgrep.sh ############################
