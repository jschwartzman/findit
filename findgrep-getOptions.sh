##############################################################################
# getOptions(): parse command line parameters
#			 - after options are extracted,
#			   command line arguments are placed in $params
# 			 - call as getOptions "$@"
# Get the command line options and see if they make sense together.
##############################################################################
function getOptions()
{
	args=$(getopt --name $script \
	--options 'cd:ehiIl:mMn:N:qt:wxs:u:g:kv' \
	--longoptions 'count,help,ignore-case-grep,ignore-case-find, \
        match,no-match,query, \
		extended,level:,directory:,name:,NAME:,type:,whole-words,ww, \
		size:,minutes:,days:,today,user:,group:,nouser,nogroup, \
		executable, context, version' -- "$@")

	if [ $? != 0 ]; then		# error in getopt
		doExit 110
	fi

	eval set -- "$args"

	while [ $# -gt 0 ]; do
		case "$1" in
			-c | --count) 				# display number of matching files
				grepOpt+='l'
				bCount=1
				shift ;;
			-d | --directory) 			# get (one or more) starting directory
				shift
				if [ ! -d $1 ]; then
					echo "invalid directory: $1"
					doExit 192
				fi
				if [ $dir ]; then
					dir+=' '
				fi
				dir+=" $1"
				shift ;;
			-g | --group)					# group
				shift
				group="-group $1"
				if [ -z "$1" ]; then
                    printf "ERROR: %s is not a valid group.\n" $1
                    doExit 192
                fi
				shift ;;
			-h | --help)					# help
				usage
				alias
				exit ;;
			-i | --ignore-case-grep) 		# case insensitive grep
				grepOpt+='i'
				gcase=1
				shift ;;
			-I | --ignore-case-find)		# case insensitive find
				findStyle='-iregex'
				shift ;;
			-l | --level) 					# search to maxDepth
				shift
				maxDepth="$1"
				if [[ $maxDepth -lt 1 || -z "$maxDepth" ]]; then
					printf "ERROR: '%s' is not a valid maxdepth (maxDepth >= 1).\n"\
							 $maxDepth
					doExit 192
				fi
				shift ;;
			-m | --match)					# display matching lines with line numbers
				bShowMatches=1
				grepOpt+='n'				# always show line numbers for matches
				shift ;;
            -k | --context)
				grepOpt+="C 1"              # show 3 lines of context (1 before and 1 after")
                shift ;;
			-M | --no-match)				# find files without matches
				bNoMatch=1
				shift ;;
			-n | --name) 	# provide partial filename to match
				shift
				if [ $script = 'findgrep' ]; then
					# match $1 in filename only (not in dirs)
					regex="^\.?/([^/]+/)*[^/]*$1[^/]*$"
				elif [ $script = 'findhidden' ]; then
					if [ ${1#.} = ${1} ]; then
						# argument does not start with a period
						regex="^\.?/([^/]+/)*\.[^/]*$1[^/]*$"
					else
						# argument does start with a period
						regex="^\.?/([^/]+/)*\\$1[^/]*$"
					fi
				elif [ $script = 'findnoext' ]; then
					regex="^\.?/([^/]+/)*[^\.]*$1[^\.]*$"
				elif [ $script = 'findlinks' ]; then
					regex="^.*$1.*$"
				elif [ $script = 'findsockets' ]; then
					regex="^.*$1.*$"
				elif [ $script = 'findpipes' ]; then
					regex="^.*$1.*$"
                elif [ $script = 'finddirs' ]; then
 					regex="^.*$1.*$"
                elif [ $script = 'findfiles' ]; then
 					regex="^.*$1.*$"
				else
					# start with a '/' or a './' followed by 0 or more directories
					# followed by *name* and extension
					regex="^.*$1[^/]*${ext}"
				fi
				shift ;;
			-N | --NAME) 	# provide complete filename to match
				shift
				if [ $script = 'findgrep' ]; then
					# match comlete filename (extension included)
					regex="^.*/([^/]+/)*$1$"
				elif [ $script = 'findhidden' ]; then
					if [ ${1#.} = $1 ]; then
						# argument does not start with a period
						regex="^\.?/([^/]+/)*\.$1$"
					else
						# argument does start with a period
						regex="^\.?/([^/]+/)*\\$1$"
					fi
				elif [ $script = 'findlinks' ]; then
					regex="^.*/$1$"
				elif [ $script = 'findsockets' ]; then
					regex="^.*/$1$"
				elif [ $script = 'findpipes' ]; then
					regex="^.*/$1$"
                elif [ $script = 'finddirs' ]; then
 					regex="^.*/$1.*$"
                elif [ $script = 'findfiles' ]; then
 					regex="^.*/$1.*$"
				else
					# start with a '/' or a './' followed by 0 or more directories
					# followed by name and extension
					regex="^\.?/([^/]+/)*$1${ext}"
				fi
				shift ;;
			-q | --query) 	# query: display command without execution
				bQuery=1
				shift ;;
			-s | --size)	# file size
				shift
				size+="-size $1 "
				shift ;;
			-t | --type)	# type = (f)ile, (d)irectory, (l)ink, (s)ocket, (p)ipe
				shift
				if [ $1 = 'f' ] || [ ${1%s} = 'file' ]; then
					type='-type f'
				elif [ $1 = d ] || [ ${1%%ector*} = 'dir' ]; then
					type='-type d'
					displayCmd=''	# extended display does not work properly with dirs
				elif [ $1 = 'l' ] || [ ${1%s} = 'link' ]; then
					type='-type l'
				elif [ $1 = 'p' ] || [ ${1%s} = 'pipe' ]; then
					type='-type p'
				elif [ $1 = 's' ] || [ ${1%s} = 'socket' ]; then
					type='-type s'
				else			# unknown type
					printf "ERROR: $1 is not a valid type.\n"
					doExit 192
				fi
				shift ;;
			-u | --user)		# user
				shift
				user="-user $1"
				if [ -z "$1" ]; then
                    printf "ERROR: %s is not a valid user.\n" $1
                    doExit 192
                fi
				shift ;;
            -v | --version)     # version
                version
				exit ;;
			-w | --ww | --whole-words) 	# match whole words
				bWholeWord=1
				grepOpt+='w'
				shift ;;
			-e | --extended) 	# eXtended output ($dspCmd must be at end)
                bExtended=1     # does not work with directories or matches
				shift ;;
			-x | --executable)	# executable files
				displayCmd+=" -executable"
				shift ;;
			--minutes)	# match last modification time in minutes (use +/-)
				shift
				time+="-mmin $1"
				if [ -z "$1" ]; then
                    printf "ERROR: %s is not a valid number of minutes.\n" $1
                    doExit 192
                fi
				shift ;;
			--days)		# match last modification time in days (use +/-)
				shift
				time+="-mtime $1"
				if [ -z "$1" ]; then
                    printf "ERROR: %s is not a valid number of days.\n" $1
                    doExit 192
                fi
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
			--) 		# end of options
				shift
				params=$*
				params=${params## }	# remove leading spaces
				params=${params%% }	# remove trailing spaces
				break ;;
		esac
	done

	########## verify correct options ##########
	if [ $bShowMatches -eq 1 ]; then
		if [ $bCount -eq 1 ]; then
			echo "WARNING: The --match and --count switches cannot be meaningfully combined."
			doExit 192
		fi
		if [ $bExtended -eq 1 ]; then
			echo "WARNING: The --match and --extended switches cannot be used together."
			doExit 192
		fi
		if [ $bNoMatch -eq 1 ]; then
			echo "WARNING: The --match and --no-match switches cannot be meaningfully combined."
			doExit 192
		fi
	fi

	if [ $bShowMatches -eq 1 ]; then
		if [ $script = 'finddirs' ] || [ $script = 'findlinks' ] \
									|| [ $script = 'findpipes' ] \
									|| [ $script = 'findsockets' ]; then
			echo "WARNING: The --match switch cannot be used with $script."
			doExit 192
		fi
	fi

	if [ -n "$params" ]; then
		if [ $script = 'finddirs' ] || [ $script = 'findlinks' ] \
									|| [ $script = 'findpipes' ] \
									|| [ $script = 'findsockets' ]; then
			echo "WARNING: You cannot search for '$params' in $script."
			doExit 192
		fi
	fi

	if [ $bExtended -eq 1 ] && [ $script = 'finddirs' ]; then
		echo "WARNING: $script cannot use the --extended switch."
			doExit 192
		fi

	if [ -z "$dir" ]; then 
		dir='.'		# change to $PWD to show complete (from the root) paths
	fi

	if [ -n "$user" ]; then			    # set user if requested
		displayCmd+=" $user"
	fi
	if [ -n "$group" ]; then		    # set group if requested
		displayCmd+=" $group"
	fi
	if [ -n "$size" ]; then				# set size if requested
		displayCmd+=" $size"
	fi
	if [ -n "$time" ]; then				# set time if requested
		displayCmd+=" $time"
	fi
	if [ $maxDepth -ne -1 ]; then	 	# set maxDepth if requested
		displayCmd+=" -maxdepth $maxDepth"
	fi
	if [ $bExtended -ne 0 ]; then       # this must be at the end
        displayCmd+=" $dspCmd"
    fi
}

##############################################################################
