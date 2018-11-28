#!/bin/bash
###############################################################################
# file:					findgrep.sh
# author: 			 	John Schwartzman, Forte Systems, Inc.
# last revision:		11/28/2018
#
# search for presence of files / content in files with specific file types
# findc, findh, findch, findcpp, findhpp, findchpp, findjava, etc.
# are symbolic links to findgrep
#
# See case statement (getScript) for a list of symlinks and the 
# file patterns they match.
# Change --dir=$PWD (default) to --dir=. to show partial paths
# (i.e., ./xxx/xx instead of /xxx/xxx/xx )
#
# Built on <<DATE_AND_OSTYPE>>.
# The variables findCmd, regexPrefix and displayCmd have been customized 
# for this OS.
#
# USAGE, GETSCRIPT and GETOPTION (in findgrep-template.sh are placeholders for
# other shell scripts.  They will be replaced in findgrep.sh at build time.
###############################################################################

declare -r VERSION="0.2.0"
declare -r script=${0##*/}	# base regex of symbolic link
declare regex 				# regex file pattern we're trying to match
declare params				# string containing parameters (folllowing options)
declare ext					# regex pattern of file extension
declare dir					# will use $PWD unless overridden with -d switch
declare findStyle='-regex'	# use find . -regex or find . -iregex
declare type='-type f'		# -type f(ile) is the default
declare fdesc				# file type description
declare errmsg				# what went wrong

##############################################################################
# doExit(errorNumber = 0): display usage and exit with errorNumber
##############################################################################
function doExit()
{
	errmsg=${1}
	usage "$errmsg"
	exit  $(($2 + 0))	# make this an integer
}

#<<USAGE>>
#<<GETSCRIPT>>
#<<GETOPTION>>

########## begin program execution ##########
getScript
getOptions "$@"

# create regex from extension if it hasn't yet been defined
if [[ -z $regex ]] && [[ ! -z $ext ]]; then
	regex="^.+${ext}"
fi

if [[ ! -z $regex ]]; then
	findCmd+=" $dir $type $maxDepth $regexPrefix $findStyle '$regex'"
else
	findCmd+=" $dir $type $maxDepth"
fi

########## determine whether we are going to use grep ##########
if [[ ${#params} -eq 0 ]]; then			# if no search text was provided do not use grep
	grepCmd=''
	if [[ $bShowMatches -eq 1 ]] || 
	   [[ $gcase -eq 1 ]] || [[ $bWholeWord -eq 1 ]] || [[ $bNoMatch -eq 1 ]]; then
		errmsg="WARNING: The -i, -m, -M and -w options have no meaning without 'text to match'."
		doExit "$errmsg" 192
	fi
else											# use grep
	if [[ $bShowMatches -eq 0 ]] && [[ $bCount -eq 0 ]]; then
		grepOpt+='l'
	fi
	if [[ $bNoMatch -eq 1 ]]; then
		# the grep -L option must come after any other options
		grepOpt+='L'
	fi

	grepCmd='grep '
	if [[ $grepOpt ]]; then
		grepCmd+=" -$grepOpt"
	fi
	grepCmd+=' --color'
fi

########## display matching files ##########
echo

if [[ $bCount -eq 1 ]]; then			##### display count of matches
	if [[ -z "$grepCmd" ]]; then
		if [[ $bQuery -eq 1 ]]; then
			printf "$findCmd 2>/dev/null"
		else
			eval $findCmd $displayCmd 2>/dev/null | \
				printf "Number of ${fdesc}: %d\n" $(wc -l)
		fi
	else
		if [[ $bQuery -eq 1 ]]; then
			printf "$findCmd $displayCmd 2>/dev/null | $grepCmd '$params' 2>/dev/null"
		else
			declare relation="containing"	# "containing" or "not containing"
			if [[ $bNoMatch -eq 1 ]]; then
				relation+="not "
			fi
			eval $findCmd $displayCmd 2>/dev/null | xargs $grepCmd "$params" 2>/dev/null | \
				printf "Number of ${fdesc} $relation $params: %d\n" $(wc -l)
		fi
	fi

elif [[ $bShowMatches -eq 1 ]]; then		# display matching lines
	if [[ $bQuery -eq 1 ]]; then
		printf "$findCmd $displayCmd 2>/dev/null | xargs $grepCmd '$params' 2>/dev/null"
	else
		eval $findCmd $displayCmd 2>/dev/null | xargs $grepCmd "$params" 2>/dev/null
	fi

else									# display filespecs only
 	if [[ -z $grepCmd ]]; then
		if [[ $bQuery -eq 1 ]]; then
			printf "$findCmd $displayCmd 2>/dev/null"
		else
			eval $findCmd $displayCmd 2>/dev/null
		fi
	else
		if [[ $bQuery -eq 1 ]]; then
			printf "$findCmd $displayCmd 2>/dev/null | xargs $grepCmd '$params' 2>/dev/null"
		else
			eval $findCmd $displayCmd 2>/dev/null | xargs $grepCmd "$params" 2>/dev/null
		fi
	fi
fi

echo
exit 0

############################## End of findgrep.sh ############################
