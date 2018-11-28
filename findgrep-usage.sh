##############################################################################
# usage: display findgrep usage, version and alias information
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
  $script alias to findgrep finds $fdesc
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
# alias(): display program aliases (symbolic links to findgrep)
##############################################################################
function alias()
{
	saveAndClearScreen

	cat <<-EOF

	ALIASES: (use the --query option to display the exact command)
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
	   findcss:     find in cascading style sheet files
	   finddirs:    find directories or use with -n 'dirname' or -N 'dirname'
	   findfiles:   find files or use with -n 'filename' or -N 'filename'
	   findgrep:    find all files or use with -n 'filename' or -N 'filename'
	   findhtml:    find in *.htm, *.html, *.css and *.js files
	   findhfiles, findhdirs:  
	                find hidden files / directories
	   findimg:     find image files (*.jpg, .tiff, etc.)
	   findinc:     find in include files (*.in and *.inc)
	   findjava, findjar:
	                find in Java/Java archive files
	   findjs:      find in javascript files
	   findlinks:	find symbolic links or use with -n 'linkname' or -N 'linkname'
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
	   findpipes:   find pipes or use with -n 'pipename' or -N 'pipename'
	   findspace:   find in files containing space(s) in their filepaths
	   findsockets: find sockets or use with -n 'socketname' or -N 'socketname'
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
	
	    $script alias to findgrep finds $fdesc
	    VERSION: $VERSION
	    Built on: $BUILD_DATE for $OSTYPE

	EOF
}

##############################################################################

