findit is a bash shell script that is useful for finding files, directories, sockets, pipes, links, block and character devices and contents of files.
findit consists of a main script, /usr/local/bin/findit and 61 symbolic links to findit (also located in /usr/local/bin).  
Each symbolic link is an alias to findit.  The findcpp alias finds *.cpp files while the findlink alias finds symbolic links.
The program can be build by copying the files included here to a local directory and running sudo ./makefindit.sh.  Type any
alias name with --help to see the program's aliases and options.
