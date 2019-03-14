#############################################################################
# file:				Makefile - for Findit Project
# author: 			John Schwartzman, Forte Systems, Inc.
# last revision:  	03/14/2019
#############################################################################

MAKE_FILE			=	Makefile
MAKE_SCRIPT			=	makeFindit.sh
CLEAN_SCRIPT		=	removeFindit.sh
DEVDIR				=	/HOME/js/Development/findit
BINDIR				=	/usr/local/bin
SHELL_SCRIPT		=	findit
TEMPLATE_FILE		=	$(SHELL_SCRIPT)-template.sh
USAGE_FILE			=	$(SHELL_SCRIPT)-usage.sh
GETSCRIPT_FILE		=	$(SHELL_SCRIPT)-getScript.sh
GETOPTIONS_FILE		=	$(SHELL_SCRIPT)-getOptions.sh
DEPENDENCIES		=   $(TEMPLATE_FILE) 		\
						$(USAGE_FILE) 			\
						$(GETSCRIPT_FILE) 		\
						$(GETOPTIONS_FILE) 		\
						$(MAKE_SCRIPT) 	\
						$(MAKE_FILE)

$(BINDIR)/$(SHELL_SCRIPT): $(DEPENDENCIES)
	./$(MAKE_SCRIPT)

clean:
	./$(CLEAN_SCRIPT)

############################## end of Makefile ##############################

