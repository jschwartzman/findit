find-grep is a bash shell script that is useful for finding files, directories, sockets, pipes, links, block and character devices and contents of files.
findgrep consists of a main script, /usr/local/bin/findgrep and 60 symbolic links to findgrep (also located in /usr/local/bin).  
Each symbolic link is an alias to findgrep.  The findcpp alias finds *.cpp files while the findlinks alias finds symbolic links.
The program can be build by copying the files included here to a local directory and running sudo ./makefgrep.sh.  Type any
alias name with --help to see the program's aliases and options.
