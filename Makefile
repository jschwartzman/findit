#############################################################################
# file:				Makefile - for Findit Project
# author: 			John Schwartzman, Forte Systems, Inc.
# last revision:  	04/09/2019
#############################################################################

MAKE_FILE		=	Makefile
MAKE_CMD		=	makeFindit.sh
BINDIR			=	/usr/bin
SHELL_SCRIPT	=	findit
TEMPLATE_FILE	=	$(SHELL_SCRIPT)-template.sh
USAGE_FILE		=	$(SHELL_SCRIPT)-usage.sh
GETSCRIPT_FILE	=	$(SHELL_SCRIPT)-getScript.sh
GETOPTIONS_FILE	=	$(SHELL_SCRIPT)-getOptions.sh
DEPENDENCIES	=   $(TEMPLATE_FILE) 		\
					$(USAGE_FILE) 			\
					$(GETSCRIPT_FILE) 		\
					$(GETOPTIONS_FILE) 		\
					$(MAKE_CMD) 	\
					$(MAKE_FILE)


$(BINDIR)/$(SHELL_SCRIPT): $(DEPENDENCIES)
	./$(MAKE_CMD) build

clean:
	./$(MAKE_CMD) clean

############################## end of Makefile ##############################

