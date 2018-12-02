##############################################################################
# getOptions()	get findit options and convert to find and grep options
#
##############################################################################

declare displayCmd			# display command
declare grepOpt				# grep options
declare grepCmd				# grep [-$grepOpt]
declare size				# file size n[b|c|k|M|G]
declare time				# file modification time
declare user				# file owner user
declare group				# file owner group
declare empty				# file or directory is empty
declare maxDepth			# maximum depth (-l or --level)
declare permission			# use 777 format (-640 to find files w/o 640)
declare -i gcase=0			# case-insensitive grep
declare -i bCount=0			# just count matching files if -c switch provided
declare -i bShowMatches=0 	# show matching text in files
declare -i bWholeWord=0 	# grep whole words
declare -i bNoMatch=0		# find files without matches
declare -i bQuery=0			# show find statement without executing
declare -i bExtended=0		# use ls -lFh formatting
declare -i bWritable=0		# show files / dir that are writable / not writable
declare returnValue		    # for use in this module only
declare signValue           # for use in this module only
declare tempFile			# for use in this module only

##############################################################################
# function isIntegerEntry()		check that user entered a valid
#								+/- integer value (+/- is optional)
#
# sets returnValue = 1 if true, sets returnValue = 0 if false
##############################################################################
function isIntegerEntry()
{
    if [[ $1 =~ ^[\+-]?[[:digit:]]+$ ]]; then  
        returnValue=1
    else
        returnValue=0
    fi
}

####################################################################################################
# function isValidSize()		check that user entered a valid find file size
#								[+/-]n [b|c|k|M|G]
#								find does not allow a decimal point
# sets returnValue = 1 if true, sets returnValue = 0 if false
##############################################################################
function isValidSize()
{
	if [[ $1 =~ ^[\+-]?[[:digit:]]+[bckMG]?$ ]]; then
		returnValue=1
	else
		returnValue=0
	fi
}

##############################################################################
# function stripSignIfPositive()	    return the digits of the integer in
#                                       numberVariable without the + sign
##############################################################################
function stripSignIfPositive()
{
    declare tempValue=$1
     if [[ ${tempValue:0:1} == '+' ]]; then
        returnValue=${tempValue:1}
        signValue='+'
    elif [[ ${tempValue:0:1} == '-' ]]; then
        returnValue=${tempValue}
        signValue='-'
    else
        returnValue=$tempValue
   		signValue=' '
   fi
}

##############################################################################
# function stripTrailingComma()	    returns the string without a trailing
#                                   comma in returnValue
##############################################################################
function stripTrailingComma()
{
    declare tempValue=$1
    declare -i lastCharIndex=${#tempValue}-1
    if [[ ${tempValue:$lastCharIndex} == ',' ]]; then
        returnValue=${tempValue:0:$lastCharIndex}
    else
        returnValue=$tempValue
    fi
}

##############################################################################
# function stripLeadingAndTrailingSpaces()		returns the string without 
#												leading or trailing spaces
#				                               	in returnValue
##############################################################################
function stripLeadingAndTrailingSpaces()
{
    declare tempValue=$1
	# strip leading whitespace
    returnValue="$(echo -e "$tempValue" | sed -e 's/^[[:space:]]*//')"
    tempValue=$returnValue
	# strip trailing whitespace
    returnValue="$(echo -e "$tempValue" | sed -e 's/[[:space:]]*$//')"
 }

###############################################################################
# function stripTrailingSlash()		returns the string without a trailing
#                                   '/' in returnValue
##############################################################################
function stripTrailingSlash()
{
    declare tempValue=$1
    declare -i lastCharIndex=${#tempValue}-1
    if [[ ${tempValue:$lastCharIndex} = '/' ]]; then
        returnValue=${tempValue:0:$lastCharIndex}
    else
        returnValue=$tempValue
    fi
}

#############################################################################
# function isValidPermission()      verify format for find -perm clause
#									use --nopermission -a=w to elicit
#									! - perm -a=w
##############################################################################
function isValidPermission()
{
    stripSignIfPositive $1
     if [[ $returnValue =~ ^-?/?[0-7]+$ ]]; then     # is it an integer?
        :   # integer permission
    elif [[ $returnValue =~ ^-?/?([augo][/+-=]([rwxst]{1,3}){1,3},?){1,3}$ ]]; then  
        :   # symbol permission
    else
		returnValue=''
	fi
    stripTrailingComma $returnValue
}

##############################################################################
# getOptions(): parse command line parameters
#			 - after options are extracted,
#			   command line arguments are placed in $params
# 			 - call as getOptions "$@"
# Get the command line options and see if they make sense together.
# Automated error handling is disabled.
##############################################################################
function getOptions()
{
	args=$(getopt --name $script \
	--options 'cd:ehiIl:mMn:N:p:qt:wxs:u:g:kv' \
	--longoptions 'count,help,ignore-case-grep,ignore-case-find, \
        match,no-match,query,empty,permission:,nopermission:, \
		extended,level:,directory:,name:,NAME:,type:,whole-words,ww, \
		size:,minutes:,days:,today,user:,group:,nouser,nogroup, \
		executable,context,version,writable,notwritable,linkto:' -- "$@")

	if [[ $? != 0 ]]; then		# error in getopt
		errmsg="ERROR: incorect option provided: $1"
		doExit "$errmsg" 110
	fi

	eval set -- "$args"

	while [[ $# -gt 0 ]]; do
		case "$1" in
			-c | --count) 				# display number of matching files
				grepOpt+='l'
				bCount=1
				shift ;;
			-d | --directory) 			# get (one or more) starting directory
				shift
				stripLeadingAndTrailingSpaces "$1"
				if [[ ! -d $returnValue ]]; then
					errmsg="ERROR: $1 is an invalid directory."
					doExit "$errmsg" 192
				fi
				if [[ ! -z $dir ]]; then
					dir+=' '
				fi
				dir+=" $1"
				shift ;;
			-e | --extended) 	# eXtended output ($dspCmd must be at end)
                bExtended=1     # does not work with directories or matches
				shift ;;
			-g | --group)					# group
				shift
				group="-group $1"
				stripLeadingAndTrailingSpaces "$1"
				if [[ -z $returnValue ]]; then
                    errmsg="ERROR: %s is not a valid group. $1"
                    doExit "$errmsg" 192
                fi
				shift ;;
			-h | --help)					# help
				usage "" 0
				alias
				exit ;;
			-i | --ignore-case-grep) 		# case insensitive grep
				grepOpt+='i'
				gcase=1
				shift ;;
			-I | --ignore-case-find)		# case insensitive find
				findStyle='-iregex'
				shift ;;
            -k | --context)
				grepOpt+="C 1"              # show 3 lines of context (1 before and 1 after")
                shift ;;
			-l | --level) 					# search to maxDepth
				shift
				isIntegerEntry $1			# test for integer level
				if [[ returnValue -eq 1 ]] && [[ $1 -ge 1 ]]; then
					maxDepth="$1"
				else
					errmsg="ERROR: invalid level (-maxdepth >= 1): $1"
					doExit "$errmsg" 192
				fi
				shift ;;
			-m | --match)					# display matching lines with line numbers
				bShowMatches=1
				grepOpt+='n'				# always show line numbers for matches
				shift ;;
			-M | --no-match)				# find files without matches
				bNoMatch=1
				shift ;;
			-n | --name) 	# provide partial filename to match
				shift
				if [[ $script = 'findhfiles' ]]; then		# hidden files
					if [[ ${1#.} = ${1} ]]; then
						# argument does not start with a '.'
						regex="^.+/\..*$1.*$"
					else
						# argument does start with a period
						regex="^.+$1.*$"
					fi
				elif [[ $script = 'findhdirs' ]]; then		# hidden dirs
					if [[ ${1#.} = ${1} ]]; then
						# argument does not start with a '.'
						regex="^.+/\..*$1.*$"
					else
						# argument does start with a period
						regex="^.+/$1.*$"
					fi
				else
					regex="^.*$1.*$"
				fi
				shift ;;
			-N | --NAME) 	# provide complete filename to match
				shift
				if [[ $script = 'findhfiles' ]]; then		# hidden files
					if [[ ${1#.} = ${1} ]]; then
						# argument does not start with a period
						regex="^.+/\.$1$"
					else
						# argument does start with a period
						regex="^.+/$1$"
					fi
				elif [[ $script = 'findhdirs' ]]; then		# hidden dirs
					if [[ ${1#.} = ${1} ]]; then
						# argument does not start with a period
						regex="^.+/\.$1$"
					else
						# argument does start with a period
						regex="^.+/$1$"
					fi
				else
					regex="^.*$1$"
				fi
				shift ;;
			-p | --permission)	# permission in -777 format or /u=rwx or u+x
				shift
				isValidPermission $1
				if [[ ! -z $returnValue ]]; then
					permission="-perm $returnValue"
				else
					errmsg="ERROR: illegal permission: $1"
					doExit "$errmsg" 192
				fi
				shift ;;
			--nopermission)	# negate the permission flags
				shift
				isValidPermission $1
				if [[ ! -z $returnValue ]]; then
					permission="! -perm $returnValue"
				else
					errmsg="ERROR: illegal permission: $1"
					doExit "$errmsg" 192
				fi
				shift ;;
			-q | --query) 	# query: display command without execution
				bQuery=1
				shift ;;
			-s | --size)	# file size		[+|-]n [b|c|k|M|G]
				shift
				isValidSize $1
				if [[ ! -z $returnValue ]]; then
					size+="-size $1 "
				else
					errmsg="ERROR: file size is invalid: $1"
					doExit "$errmsg" 192
				fi
				shift ;;
			-t | --type)	# type = (f)ile, (d)irectory, (l)ink, (s)ocket, (p)ipe, (b)lock, (c)haracter
				shift
				if [[ $1 = 'f' ]] || [[ ${1%s} = 'file' ]]; then
					type='-type f'
				elif [[ $1 = d ]] || [[ ${1%%ector*} = 'dir' ]]; then
					type='-type d'
				elif [[ $1 = 'l' ]] || [[ ${1%s} = 'link' ]]; then
					type='-type l'
				elif [[ $1 = 'p' ]] || [[ ${1%s} = 'pipe' ]]; then
					type='-type p'
				elif [[ $1 = 's' ]] || [[ ${1%s} = 'socket' ]]; then
					type='-type s'
				elif [[ $1 = 'b' ]] || [[ ${1%s} = 'block' ]]; then
					type='-type b'
				elif [[ $1 = 'c' ]] || [[ ${1%s} = 'char' ]]; then
					type='-type c'
				else			# unknown type
					errmsg="ERROR: $1 is not a valid type."
					doExit "$errmsg" 192
				fi
				shift ;;
			-u | --user)		# user
				shift
				user="-user $1"
				stripLeadingAndTrailingSpaces "$1"
				if [[ -z "$1" ]]; then
                    errmsg="ERROR: $1 is not a valid user."
                    doExit "$errmsg" 192
                fi
				shift ;;
            -v | --version)     # version
                version
				exit 0 ;;
			-w | --ww | --whole-words) 	# match whole words
				bWholeWord=1
				grepOpt+='w'
				shift ;;
			-x | --executable)	# executable files
				displayCmd+=" -executable"
				shift ;;
			--minutes)	# match last modification time in minutes (use +/-)
				shift
				isIntegerEntry "$1"
				if [[ returnValue -eq 1 ]]; then		# test for integer value
					time="-mmin $1"
				else
                    errmsg="ERROR: $1 is not a valid number of minutes."
                    doExit "$errmsg" 192
                fi
				shift ;;
			--days)		# match last modification time in days (use +/-)
				shift
				isIntegerEntry "$1"
				if [[ $returnValue -eq 1 ]]; then		# test for integer value
					time="-mtime $1"
				else
                    errmsg="ERROR: $1 is not a valid number of days."
                    doExit "$errmsg" 192
                fi
				shift ;;
			--empty)	# return empty files or directories
				empty="-empty"
				shift ;;
			--linkto)	# find symbolic links that link to $1
				shift	# if $1 is not a valid file, try $dir/$1
				stripLeadingAndTrailingSpaces "$1"
				tempFile=$returnValue
				if [[ ! -e $returnValue ]]; then
					stripLeadingAndTrailingSpaces "$dir"
					stripTrailingSlash "$returnValue"
					if [[ ! -e $returnValue/$tempFile ]]; then
						errmsg="ERROR: $tempFile is an invalid linkto file."
						doExit "$errmsg" 192
					fi
				fi
				displayCmd+=" -lname $1"
				shift ;;
			--today)	# match last modification time to today
				time='-mtime 0'
				shift ;;
			--nouser)	# match files without a known user
				user='-nouser'
				shift ;;
			--nogroup)	# match files without a known group
				group='-nogroup'
				shift ;;
			--writable)	# match files / directories that are writable
				bWritable=1
				shift ;;
			--notwritable)	# match Files / directories that are not writable
				bWritable=-1
				shift ;;
			--) 		# end of options
				shift
				stripLeadingAndTrailingSpaces "$*"
				params=$returnValue
				break ;;
		esac
	done

	########## verify correct options ##########
	if [[ $bShowMatches -eq 1 ]]; then
		if [[ $bCount -eq 1 ]]; then
			errmsg="WARNING: The --match and --count switches cannot be meaningfully combined."
			doExit "$errmsg" 192
		fi
		if [[ $bExtended -eq 1 ]]; then
			errmsg="WARNING: The --match and --extended switches cannot be used together."
			doExit "$errmsg" 192
		fi
		if [[ $bNoMatch -eq 1 ]]; then
			errmsg="WARNING: The --match and --no-match switches cannot be meaningfully combined."
			doExit "$errmsg" 192
		fi
	fi

	if [[ $script = 'finddirs' ]] || [[ $script = 'findlinks' ]] 	\
								  || [[ $script = 'findpipes' ]] 	\
								  || [[ $script = 'findsockets' ]]  \
								  || [[ $script = 'findblock' ]]	\
								  || [[ $script = 'findchar' ]]		\
								  || [[ $script = 'findgit' ]]	   	\
								  || [[ $script = 'findsvn' ]]	   	\
								  || [[ $script = 'findhdirs' ]]; then
		if [[ ! -z $params ]]; then	# we can't find matches in these types
			errmsg="WARNING: You cannot search for '$params' in $script."
			doExit "$errmsg" 192
		fi
		if [[ $bShowMatches -eq 1 ]]; then	# we can't find matches in these types
			errmsg="WARNING: The --match switch cannot be used with $script."
			doExit "$errmsg" 192
		fi
	fi

	if [[ $bExtended -eq 1 ]]; then	# bExtended doesn't work with directories
		if [[ $script = 'finddirs' ]] || [[ $script = 'findgit' ]]		\
									  || [[ $script = 'findsvn' ]]		\
									  || [[ $script = 'findhdirs' ]]; then
			errmsg="WARNING: $script cannot use the --extended switch."
			doExit "$errmsg" 192
		fi
		if [[ ! -z $params ]]; then
			errmsg="WARNING: You cannot use the --extended switch with text to match."
			doExit "$errmsg" 192
		fi
	fi

	if [[ -z "$dir" ]]; then 
		dir=$PWD	# change to / to show complete paths
	fi

	if [[ ! -z "$user" ]]; then			    # set user if requested
		displayCmd+=" $user"
	fi
	if [[ ! -z "$group" ]]; then		    # set group if requested
		displayCmd+=" $group"
	fi
	if [[ ! -z "$size" ]]; then				# set size if requested
		displayCmd+=" $size"
	fi
	if [[ ! -z "$time" ]]; then				# set time if requested
		displayCmd+=" $time"
	fi
	if [[ ! -z "$empty" ]]; then			# search emptyness if requested
		displayCmd+=" $empty"
	fi
	if [[ ! -z "$permission" ]]; then		# set permission if requested
		displayCmd+=" $permission"
	fi
	if [[ $bWritable -eq 1 ]]; then			# find writable if requested
		displayCmd+=" -writable"
	elif [[ $bWritable -eq -1 ]]; then		# or not writable
		displayCmd+=" ! -writable"
	fi
	if [[ ! -z $maxDepth ]]; then	 		# set maxDepth if requested
		maxDepth=" -maxdepth $maxDepth"
	fi
	if [[ $bExtended -ne 0 ]]; then       	# this must be at the end
        displayCmd+=" $dspCmd"
    fi
}

##############################################################################
