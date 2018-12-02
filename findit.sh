#!/bin/bash
###############################################################################
# file:					findit.sh
# author: 			 	John Schwartzman, Forte Systems, Inc.
# last revision:		12/01/2018
#
# search for presence of files / content in files with specific file types
# findc, findh, findch, findcpp, findhpp, findchpp, findjava, etc.
# are symbolic links to findit
#
# See case statement (findit-getScript) for a list of symlinks and the 
# file patterns they match.
# Change --dir=$PWD (default) to --dir=. to show partial paths
# (i.e., ./xxx/xx instead of /xxx/xxx/xx )
#
# Built on Sun Dec  2 00:40:00 EST 2018 for OSTYPE = linux-gnu.
# The variables findCmd, regexPrefix and displayCmd have been customized 
# for this OS.
#
# USAGE, GETSCRIPT and GETOPTION (in findit-template.sh are placeholders for
# other shell scripts.  They will be replaced in findit.sh at build time.
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
declare findCmd='find'
declare -r regexPrefix='-regextype posix-egrep'
declare -r dspCmd='-exec ls -lhF --color {} +'
declare -r BUILD_DATE='Sun Dec  2 00:40:00 EST 2018'
declare -r OSTYPE='linux-gnu'

##############################################################################
# doExit(errorNumber = 0): display usage and exit with errorNumber
##############################################################################
function doExit()
{
	errmsg=$1
	usage "$errmsg"
	exit  $(($2 + 0))	# make this an integer
}


##############################################################################
# usage: display findit usage, version and alias information
#
##############################################################################
##############################################################################
# function saveAndClearScreen()
##############################################################################
function saveAndClearScreen()
{
	tput smcup	# save screen
	clear		# clear screen
}

##############################################################################
# function restoreScreen()
##############################################################################
function restoreScreen()
{
	tput rev		# reverse video
	read -n1 -p "Press any key to continue..."
	tput sgr0		# restore terminal defaults
	tput rmcup		# restore screen
}

##############################################################################
# usage(): display script usage
##############################################################################
function usage()
{
	saveAndClearScreen

	if [[ ! -z $1 ]]; then
		echo $1
	fi

	cat <<-EOF

USAGE: $script [OPTIONS] ['text to find']
  The '$script' alias to 'findit' finds $fdesc.
  -c|--count            - show count of matching files/directories
  -d|--directory <dir> 	- use starting directory dir (default: $PWD)
  -e|--extended         - display filespecs in 'ls -lFh' format
  -g|--group <id>       - show files owned by group id or name
  -h|--help             - display help
  -i|--ignore-case-grep	- case-insensitive grep
  -I|--ignore-case-find	- case-Insensitive find
  -k|--context          - show 3 context lines for each match (1 before and 1 after)
  -l|--level <maxdepth> - level must be an integer >= 1
  -m|--match            - display matches within files (1 context line)
  -M|--no-match         - display files without matches
  -n|--name <filename>  - specify part of a filename to match
  -N|--NAME <filename>	- specify an exact filename to match
  -p|--permission       - specify permission to match (e.g., 640 or 777 or -777)
  -q|--query            - show query without execution
  -s|--size <[+]size>   - find files with size = [+|-]n [b|c|k|M|G]
  -t|--type <type>     	- type = f(ile)|l(ink)|d(irectory)|p(ipe)|s(ocket)|b(lock)|c(har)
  -u|--user <id>        - show files owned by user id or name
  -v|--version          - display version information
  -w|--whole-words      - match whole words
  -x|--executable       - find executable files
  --writable            - find writable files / directories
  --notwritable         - find non-writable files / directories
  --nopermission        - negate the permission to match (e.g., ! -perm /-a=r)
  --linkto <filename>   - use with findlinks to specify what your symlinks link to
  --minutes <[+|-]nMin> - find files with modification time of [+|-]nMin ago
  --days <[+|-]nDays>   - find files with modification time of [+|-]nDays days ago (0=today)
  --today               - find files that were modified in the last 24 hours (--days 0)
  --nouser              - find files not owned by a known user
  --nogroup             - find files not owned by a known group
  --empty               - find empty files or directories

	EOF

	restoreScreen
}

##############################################################################
# alias(): display program aliases (symbolic links to findit)
##############################################################################
function alias()
{
	saveAndClearScreen

	cat <<-EOF

	FINDIT ALIASES: (use the --query option to display the exact command)
	   finda, findso, findlib:
	               find archive/shared object/both
	   findasm:    find in assembly language files (*.asm)
	   findawk:    find in awk/gawk files
	   findbak:    find in backup files (*~ and *.bak)
	   findblock:  find block devices
	   findchar:   find character devices
	   findc, findh, findch:
	               find in c language files (*.c/*.h/both)
	   findcpp, findhpp, findchpp:
	                find in C++ language files (*.cpp/*.hpp/both)
	   findcall:    find in all C and C++ language files
	   findcfg:     find in configuration files (*.cfg/*.conf/*.ini)
	   findcomp:    find compressed files (*.tar/*.gzip/*.bzip2/*.tar.gz...)
	   findcss:     find in cascading style sheet files
	   finddirs:    find directories (use with -n 'dirname' or -N 'dirname')
	   findfiles:   find files (use with -n 'filename' or -N 'filename')
	   findit:      find all files (use with -n 'filename' or -N 'filename')
	   findhtml:    find in *.htm, *.html, *.css and *.js files
	   findhfiles, findhdirs:  
	                find hidden files / directories
	   findimg:     find image files (*.jpg, .tiff, etc.)
	   findinc:     find in include files (*.in and *.inc)
	   findjava, findjar:
	                find in Java/Java archive files
	   findjs:      find in javascript files
	   findjsp:     find in Java Server Page files
	   findlinks:	find symbolic links (use with -n 'linkname' or -N 'linkname')
	   findlog:     find in *.log files
	   findmake, findMake:
	                find in make files (*.mk, *.mak)/'Makefile or makefile'
	   findmp3, findogg, findwav, findaudio:
	                find *.mp3/*.ogg/*.wav/all audio files
	   findnoext:   find in files with no filename extension
	   findobj:     find object files (*.o, *.os and *.og)
	   findpdf:     find PDF files
	   findphp:     find in PHP files
	   findorig:    find in *.orig files(result of merge)
	   findrdme:    find in files named *README*
	   findrpm:     find RPM files
	   findsh, findpl, findpy, findrb, findshell:
	                find in sh/Perl/Python/Ruby/all shell script files
	   findpipes:   find pipes (use with -n 'pipename' or -N 'pipename')
	   findspace:   find in files containing space(s) in their filenames
	   findsockets: find sockets Iuse with -n 'socketname' or -N 'socketname')
	   findsvn:     find subversion directories
	   findgit:     find git repositories
	   findx:       find executable files
	   findtar, findzip, findcomp:
	                find flavors of *.tar/*.zip/all compressed files
	   findtmp:     find in temporary files (*.tmp)
	   findtxt:     find in text files (*.txt)
	   findxml, findxslt:
	                find in *.xml/*.xsl and *.xslt files

	   return value: success = 0, unrecognized option = 110, invalid option = 192

	EOF

	restoreScreen
}

##############################################################################
# version(): display program version, build date and os type
##############################################################################
function version()
{
	cat <<-EOF
	
        The '$script' alias to 'findit' finds $fdesc.
        VERSION: $VERSION
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
		findaudio)	# find audio files
			ext='\.(mp3|m4a|m4b|wav|aa|ogg|wma)$'
			fdesc='audio files' ;;
		findasm)  	# find in *.asm files
			ext='\.asm$'
			fdesc='assembly language files' ;;
		findawk)  	# find in awk/gawk files
			ext='\.awk$'
			fdesc='awk/gawk files' ;;
		findblock)	# find block devices
		    type='-type b'
			dir+=" /"	# root directory
			fdesc='block devices' ;;
		findchar)	# find character devices
		    type='-type c'
			dir+=" /"	# root directory
			fdesc='character devices' ;;
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
		findit)	# find in all files
			regex='^.+$'
			fdesc='matching files' ;;
        findfiles)   # find in files
            fdesc='files' ;;
        finddirs)   # find directories
            type='-type d'
            fdesc='directories' ;;
    	findhfiles)	# find hidden ('.*') files unless -p(attern) provided
			regex='^.+/\..+$'
			fdesc='hidden files' ;;
    	findhdirs)   # find hidden directories
            type='-type d'
			regex='^.+/\..+$'
            fdesc='hidden directories' ;;
		findlinks)	# find links
            type='-type l'
			fdesc='links' ;;
        findsockets) # find sockets
            type='-type s'
            fdesc='sockets' ;;
        findpipes) # find pipes
            type='-type p'
            fdesc='pipes' ;;
		findhtml)	# find in *.htm or *.html files
			ext='\.(html?|css|js)$'
			fdesc='html files' ;;
		findnoext)	# find files without extentsions
			regex='^.?/([^/]+/)*\.?[^\.]+$'
			fdesc='no extension files'	;;
		findimg)	# find image files
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
		findjsp)	# find in java server pages
			ext='\.jsp$'
			fdesc='Java Server Page files' ;;
		findlib)	# find *.so, and *.a files
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
		findwav)	# find *.wav
			ext='\.wav$'
			fdesc='wav files' ;;
		findx)
			displayCmd+=" -executable"
			fdesc='executable files' ;;
		findxml)	# find in *.xml files
			ext='\.xml$'
			fdesc='xml files' ;;
		findxslt)	# find in *.xsl and *.xslt files
			ext='\.xslt?$'
			fdesc='xslt files' ;;
		findzip)	# find zip files
			ext='\.zip$'
			fdesc='zip files' ;;
		*)		# we should never get here unless unknown link
			printf "Could not find command: $script\n"
				doExit 192 ;;
	esac
}

##############################################################################
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

############################## End of findit.sh ##############################
