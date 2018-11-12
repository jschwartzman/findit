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
        findfiles)   # find in files
            fdesc='files' ;;
        finddirs)   # find in directories
            type='-type d'
            fdesc='directories' ;;
		findlinks)	# find all links
            type='-type l'
			fdesc='links' ;;
        findsockets) # find all sockets
            type='-type s'
            fdesc='sockets' ;;
        findpipes) # find all pipes
            type='-type p'
            fdesc='pipes' ;;
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
