# GNU make makefile
# This makefile uses GNU make specific conditionals.
#
# make arch=XXX
# where XXX is the architecture type as specified Matlab mex extensions
# examples:
#	mexsg64		64 bit SGI 
#	mexhp7		Helwett Packard
#	mexsol		Sun Solaris
#	dll		Microsoft win32
# These names are subject to change, consult your Matlab external
# interface guide for details.
#
# If you do not have GNU make on your system and do not want to
#	install it, simply remove the ifeq/else/endif directives
#	leaving the appropriate conditional code.
#
# Note - some system administrators install GNU make as gmake.

# Make sure we know what platform to build for.
ifndef arch
$(error ERROR - architecture symbol mandatory - i.e. "make arch=dll")
endif

DEBUG=-g
LIBNAME=hmm$(arch)
LIBFILE=lib$(LIBNAME).a
LIBDIR=lib
LIBFILEPATH=$(LIBDIR)/$(LIBFILE)

ifeq ($(arch),dll)

# Windows
.SUFFIXES: .obj
CC=mex.bat
LIBLINKCMD=$(LIBFILEPATH)
OBJ=obj

else

# UNIX - hooray!
CC=mex
LIBLINKCMD=-L$(LIBDIR) -l$(LIBNAME)
OBJ=o

endif

.SUFFIXES: .$(arch)

.c.$(arch) :
	$(CC) $(CCFLAGS) $(DEBUG) $< $(LIBLINKCMD)

all : gausssel hmm sigproc stat vq

gausssel :
	$(MAKE) -C gausssel 


hmm :
	$(MAKE) -C hmm 

sigproc :
	$(MAKE) -C sigproc 

stat :
	$(MAKE) -C stat 

vq :
	$(MAKE) -C vq 

$(LIBFILEPATH) : $(LIBDIR)

.PHONY : gausssel hmm sigproc stat vq

$(LIBDIR) :
	$(MAKE) -C $(LIBDIR) $(LIBFILE)

clean :
	rm *.$(OBJ) *~


