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
# Built on Fri Oct 26 21:06:45 EDT 2018 for OSTYPE = linux-gnu.
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
declare findCmd='find'
declare -r regexPrefix='-regextype posix-egrep'
declare -r dspCmd='-exec ls -lhF --color {} +'
declare -r BUILD_DATE='Fri Oct 26 21:06:45 EDT 2018'
declare -r OSTYPE='linux-gnu'

##############################################################################
# doExit(errorNumber = 0): display usage and exit with errorNumber
##############################################################################
function doExit()
{
	usage
	exit $1
}


##############################################################################
# usage(): display script usage
##############################################################################
function usage()
{
	cat <<-EOF
	USAGE: $script [-h]|[-i][-I][-c]|[-m][-M][-w][-x][-q][-u user][-g group]
	          [-s size][-l <maxdepth>][-t <type>][-l depth]
	          [-n <filename>]|[-N <filename>][-d dir] 'text to find'
  $script alias to findgrep finds $fdesc
  -h|--help             - display help
  -c|--count            - show count of matching files/directories
  -d|--directory <dir> 	- use starting directory dir (default: \$PWD)
  -g|--group <id>       - show files owned by group id or name
  -i|--ignore-case-grep	- case-insensitive grep
  -I|--ignore-case-find	- case-Insensitive find
  -l|--level <maxdepth> - maxDepth must be an integer >= 1
  -m|--match            - display matches within files (1 context line)
  -M|--no-match         - display files without matches
  -n|--name <filename>  - specify part of a filename to match
  -N|--NAME <filename>	- specify an exact filename to match
  -q|--query            - show query without execution
  -s|--size <[+|-]size> - find files with size = [+|-]n [b|c|k]
  -t|--type <type>     	- type = f(ile)|l(ink)|d(irectory)|p(ipe)|s(ocket)
  -u|--user <id>        - show files owned by user id or name
  -w|--whole-words      - match whole words
  -f|--extended-format  - display filespecs in 'ls -l' format
  -k|--context          - show 3 context lines for each match (1 before and 1 after)
  --minutes <[+|-]nMin> - find files with modification time of [+|-]nMin ago
  --days <[+|-]nDays>   - find files with modification time of [+|-]nDays days ago (0=today)
  --today               - find files that were modified today (--days 0)
  --nouser              - find files not owned by a known user
  --nogroup             - find files not owned by a known group

	EOF
}

##############################################################################
# alias(): display program aliases (symbolic links to findgrep)
##############################################################################
function alias()
{
	cat <<-EOF
	ALIASES: (use the --query option to display the exact command)
	   finda, findso, findlib:
	               find in archive/shared object/both
	   findasm:    find in assembly language files (*.asm)
	   findawk:    find in awk/gawk files
	   findbak:    find in backup files (*~ and *.bak)
	   findc, findh, findch:
	               find in c language files (*.c/*.h/both)
	   findcpp, findhpp, findchpp:
	                find in C++ language files (*.cpp/*.hpp/both)
	   findcall:    find in all C and C++ language files
	   findcfg:     find in configuration files (*.cfg/*.conf/*.ini)
	   findcss:     find in cascading style sheet files
	   findgrep:    find all files or use with -n 'filename' or -N 'filename'
	   findhtml:    find in *.htm, *.html, *.css and *.js files
	   findhidden:  find in hidden files (.*)
	   findimg:     find in image files (*.jpg, .tiff, etc.)
	   findinc:     find in include files (*.in and *.inc)
	   findjava, findjar:
	                find in Java/Java archive files
	   findjs:      find in javascript files
	   findlog:     find in *.log files
	   findmake, findMake:
	                find in make files (*.mk, *.mak)/'Makefile or makefile'
	   findmp3, findogg, findwav, findaudio:
	                find in *.mp3/*.ogg/*.wav/all audio files
	   findnoext:   find in files with no filename extension
	   findobj:     find in object files (*.o, *.os and *.og)
	   findpdf:     find in PDF files
	   findphp:     find in PHP files
	   findorig:    find in *.orig files(result of merge)
	   findrdme:    find in files named *README*
	   findrpm:     find in RPM files
	   findsh, findpl, findpy, findrb, findshell:
	                find in sh/Perl/Python/Ruby/all shell script files
	   findspace:   find in files containing space(s) in their filepaths
	   findsvn:     find subversion directories
	   findgit:     find git repositories
	   findtar, findzip, findcomp:
	                find in flavors of *.tar/*.zip/all compressed files
	   findtmp:     find in temporary files (*.tmp)
	   findtxt:     find in text files (*.txt)
	   findxml, findxslt:
	                find in *.xml/*.xsl and *.xslt files

	   return value: success = 0, unrecognized option = 110, invalid option = 192

	EOF
}

##############################################################################
# version(): display program version, build date and os type
##############################################################################
function version()
{
	cat <<-EOF
	
	    $script alias to findgrep finds $fdesc
		    VERSION:  $VERSION
		    Built on: $BUILD_DATE for $OSTYPE

	EOF
}

##############################################################################


##############################################################################
# getScript(): determine file extension(s) or regular expression
#			   and description for files to locate
# This consists of a case statement that associates a file or directory type
# with an extension to search or a complete regex pattern and a description.
##############################################################################
function getScript()
{
	case $script in
		findaudio)	# find in sound files
			ext='\.(mp3|m4a|m4b|wav|aa|ogg|wma)$'
			fdesc='audio files' ;;
		findasm)  	# find in *.asm files
			ext='\.asm$'
			fdesc='assembly language files' ;;
		findawk)  	# find in awk/gawk files
			ext='\.awk$'
			fdesc='awk/gawk files' ;;
		findc)    	# find in *.c files
			ext='\.c$'
			fdesc='c source files' ;;
		findh)		# find in *.h files
			ext='\.h$'
			fdesc='c header files' ;;
		findch)	   	# find in *.c and *.h files
			ext='\.[ch]$'
			fdesc='c language files' ;;
		findcpp)	# find in *.cpp files
			ext='\.(cpp|cc)$'
			fdesc='c++ source files' ;;
		findhpp)	# find in *.hpp files
			ext='\.(hpp|hh)$'
			fdesc='c++ header files' ;;
		findchpp)	# find in *.cpp and *.hpp files
			ext='\.(cpp|cc|hpp|hh)$'
			fdesc='c++ language files' ;;
		findcall)	# find in *.c, *.h, *.cpp and *. hpp files
			ext='\.(c|cpp|cc|h|hpp|hh)$'
			fdesc='c and c++ language files' ;;
		findcomp)	# compressed
			ext='\.(ar|tgz|zip|bz2?|ear|war|tar|tar\..*)$'
			fdesc='compressed archives' ;;
		findcfg)	# configuration
			ext='\.(cfg|conf|ini)$'
			fdesc='configuration files' ;;
		findcss)	# find in *.css files
			ext='\.css$'
			fdesc='cascading style sheet files' ;;
		findgrep)	# find in all files
			regex='^.+$'
			fdesc='matching files' ;;
		findhidden)	# find hidden ('.*') files unless -p(attern) provided
			regex='^.?/([^/]+/)*\.[^/]+$'
			fdesc='hidden files' ;;
		findhtml)	# find in *.htm or *.html files
			ext='\.(html?|css|js)$'
			fdesc='html files' ;;
		findnoext)	# find files without extentsions
			regex='^.?/([^/]+/)*\.?[^\.]+$'
			fdesc='no extension files'	;;
		findimg)	# find in image files
			ext='\.(png|jpe?g|bmp|tiff?|pcx|gif)$'
			fdesc='image files' ;;
		findinc)	# find in *.in or *.inc files
			ext='\.inc?$'
			fdesc='include files' ;;
		findjar)	# find in *.jar files
			ext='\.jar$'
			fdesc='java archive files' ;;
		findjava)	# find in *.java files
			ext='\.java$'
			fdesc='java language files' ;;
		findjs)	# find in javascript files
			ext='\.js$'
			fdesc='javascript files' ;;
		findlib)	# find in *.so, and *.a files
			ext='\.(so|a)$'
			fdesc='libraries' ;;
		findlog)	# find in *.log files
			ext='\.log$'
			fdesc='log files' ;;
		findmake)	# find in *.mk, *.mak, or *.make files
			ext='\.m(k|ake?)$'
			fdesc='make files' ;;
		findMake)	# find in files named Makefile*
			regex='^.*/Makefile.*$|^.*/makefile.*$'
			fdesc='Makefile files' ;;
		findmp3)	# find in *.mp3 files
			ext='\.mp3$'
			fdesc='mp3 files' ;;
		findodt)	# find .odt files
			ext='\.odt$'
			fdesc='OpenOffice (*.odt) files' ;;
		findobj)	# find in object (*.o, *.os and *. og) files
			ext='\.o[sg]?$'
			fdesc='object files' ;;
		findogg)	# find in .ogg files
			ext='\.ogg$'
			fdesc='ogg audio files' ;;
		findpdf)	# find in .pdf files
			ext='\.pdf$'
			fdesc='pdf files' ;;
		findphp)	# find in .php files
			ext='\.php$'
			fdesc='PHP files' ;;
		findpl)		# find in .perl
			ext='\.pl$'
			fdesc='Perl files' ;;
		findpy)		# find in .py files
			ext='\.py$'
			fdesc='Python files' ;;
		findrdme)	# find in files named README*
			regex='^.*README.*$'
			fdesc='README files' ;;
		findrb)		# find in Ruby files
			ext='\.rb$'
			fdesc='Ruby files' ;;
		findrpm)	# find in *.rpm files
			ext='\.rpm$'
			fdesc='RPM files' ;;
		findshell)	# find in *.sh, *.pl, *.py or *.rb files
			ext='\.(sh|pl|py|rb)$'
			fdesc='scripting language files'	;;
		findsh)		# find in *.sh
			ext='\.sh$'
			fdesc='shell script files' ;;
		findso)		# find in shared library (* . so) files
			ext='\.so$'
			fdesc='shared library files' ;;
		findspace)	# find in filenames containing spaces
			regex='^.*/.+ +.+$'
			fdesc='filenames containing spaces' ;;
		findsvn)	# find .svn directories
			regex='^.?/([^/]+/)*\.svn$'
			type='-type d'
			fdesc='subversion directories' ;;
        findgit)    # find .git repositories
            regex='^.?/([^/]+/)*\.git$'
            type='-type d'
            fdesc='git repositories' ;;
		findbak)	# find in backup files
			ext='(~|\.bak)$'
			fdesc='backup files' ;;
		findtmp)	# find in temporary files
			ext='\.tmp$'
			fdesc='temporary files' ;;
		findtar)	# find in *.tar.* and *.tgz
			ext='\.(tgz|tar(\..*)?)$'
			fdesc='tar.* and tgz files' ;;
		findtxt)	# find in *.txt and *.text files
			ext='\.te?xt$'
			fdesc='text files' ;;
		findwav)	# find in *.wav
			ext='\.wav$'
			fdesc='wav files' ;;
		findxml)	# find in *.xml files
			ext='\.xml$'
			fdesc='xml files' ;;
		findxslt)	# find in *.xsl and *.xslt files
			ext='\.xslt?$'
			fdesc='xslt files' ;;
		findzip)	# find in zip files
			ext='\.zip$'
			fdesc='zip files' ;;
		*)		# we should never get here unless unknown link
			printf "Could not find command: $script\n"
				doExit 192 ;;
	esac
}

##############################################################################
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
	--options 'cd:hiIl:mMn:N:qt:wxfs:u:g:kv' \
	--longoptions 'count,help,ignore-case-grep,ignore-case-find, \
        match,no-match,query, \
		extended,level:,directory:,name:,NAME:,type:,whole-words,ww, \
		size:minutes:,days:,today,user:,group:,nouser,nogroup, \
		executable, context, version' -- "$@")

	if [ $? != 0 ]; then		# error in getopt
		doExit 110
	fi

	eval set -- "$args"

	while [ $# -gt 0 ]; do
		case "$1" in
			-c | --count) 					# display number of matching files
				grepOpt+='l'
				bCount=1
				shift ;;
			-d | --directory) 			# get (one or more) starting directory
				shift
				if [[ ! -d $1 ]]; then
					echo "invalid directory: $1"
					doExit 192
				fi
				if [[ -n $dir ]]; then
					dir+=' '
				fi
				dir+="$1"
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

				else
					# start with a '/' or a './' followed by 0 or more directories
					# followed by *name* and extension
					regex="^\.?([^/]+/)*[^/]*$1[^/]*${ext}"
				fi
				shift ;;
			-N | --NAME) 	# provide complete filename to match
				shift
				if [ $script = 'findgrep' ]; then
					# match comlete filename (extension included)
					regex="^\.?/([^/]+/)*$1$"
				elif [ $script = 'findhidden' ]; then
					if [ ${1#.} = $1 ]; then
						# argument does not start with a period
						regex="^\.?/([^/]+/)*\.$1$"
					else
						# argument does start with a period
						regex="^\.?/([^/]+/)*\\$1$"
					fi
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
				if [[ $1 = 'f' || ${1%s} = 'file' ]]; then
					type='-type f'
				elif [[  $1 = d || ${1%%ector*} = 'dir' ]]; then
					type='-type d'
					displayCmd=''	# extended display does not work properly with dirs
				elif [[  $1 = 'l' || ${1%s} = 'link' ]]; then
					type='-type l'
				elif [[  $1 = 'p' || ${1%s} = 'pipe' ]]; then
					type='-type p'
				elif [[  $1 = 's' || ${1%s} = 'socket' ]]; then
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
			-f | --extended-format) 	# eXtended output
				if [[ $type != '-type d' ]]; then
					displayCmd=$dspCmd
				fi
				shift ;;
			-x | --executable)	# executable files
				bExecutable=1
				shift ;;
			--minutes)	# match last modification time in minutes
				shift
				time+="-mmin $1"
				if [ -z "$1" ]; then
                    printf "ERROR: %s is not a valid number of minutes.\n" $1
                    doExit 192
                fi
				shift ;;
			--days)		# match last modification time in days
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
				params="$*"
				break ;;
		esac
	done

	########## verify correct options ##########
	if [ $bShowMatches -eq 1 ]; then
		if [ $bCount -eq 1 ]; then
			echo "WARNING: The --match and --count switches cannot be meaningfully combined."
			doExit 192
		fi
		if [ $bNoMatch -eq 1 ]; then
			echo "WARNING: The --match and --no-match switches cannot be meaningfully combined."
			doExit 192
		fi
	fi

	if [[ -z $dir ]]; then 
		dir=$PWD
	fi

	findCmd+=" $dir $regexPrefix $type"

	if [ $bExecutable -eq 1 ]; then		# look for executible files
		findCmd+=" -executable"
	fi
	if [[ $user ]]; then				# set user if requested
		findCmd+=" $user"
	fi
	if [[ $group ]]; then				# set group if requested
		findCmd+=" $group"
	fi
	if [[ $size ]]; then				# set size if requested
		findCmd+=" $size"
	fi
	if [[ $time ]]; then				# set time if requested
		findCmd+=" $time"
	fi
	if [ $maxDepth -ne -1 ]; then	 	# set maxDepth if requested
		findCmd+=" -maxdepth $maxDepth"
	fi

	findCmd+=" $findStyle"
}

##############################################################################

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
