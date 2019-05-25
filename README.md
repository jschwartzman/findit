findit is a bash shell script that is useful for finding files, directories, sockets, pipes, links, block and character devices and contents of files.

findit consists of a main script, /usr/local/bin/findit and 64 symbolic links to findit (also located in /usr/local/bin).  
Each symbolic link is an alias to findit. The findcpp alias finds *.cpp files while the findlink alias finds symbolic links. 
findgit finds git repositories. findh finds header (*.h) files and will search for specific text specified in the command. findxml will find xml files, etc.

The program can be built by copying the files included here to a local directory and running sudo make.  Type findit 
--help or any alias name with --help to see the program's aliases and options.

Findit is documented in the June 2018 issue of Linux Format Magazine.
