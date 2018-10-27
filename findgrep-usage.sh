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

