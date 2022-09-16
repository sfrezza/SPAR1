#
#
# Makefile for SPAR, a schematics place-and-route tool. 
#
# SPAR works by parsing an IVF (Intermediate VHDL Format) text file, and
# successively partitioning modules, placing them, and then performing
# highly-specialized schematics global and local routing.  The default output
# is to generate Type-1 Post-Script output that depicts the logic schematic.
#

# IVF-generation is available with the Keystone VHDL compiler,
# available for a small fee and license agreement from the University of
# Pittsburgh. send email to "vhdl@ee.pitt.edu". Sample IVF files are included.

# The optional -s flag is used to generate SCED-compatible output, a 
# schematics-editing tool once available from the University of Pittsburgh.

# The location of icon library for sced (not sure if ~ expansion will work)
# must be defined. SCEDLIB is a path to the compilation directory, and is 
# necessary to compile file "sced.c".
SCEDLIB = \"./\"


CC = gcc
# CFLAGS = -g
CFLAGS = -O2
LIBS = -lm -lm


#
OBJ = parse.o place.o global_route.o local_route.o terminals.o utility.o list.o cstitch.o  var.o psfigs.o debug.o sced.o hand_place.o
#
spar:	n2a.c parse.o place.o global_route.o local_route.o \
	terminals.o utility.o list.o cstitch.o var.o debug.o \
	sced.o hand_place.o \
	cstitch.h network.h externs.h Makefile
	$(CC) $(CFLAGS) -o spar n2a.c ${OBJ} ${LIBS}
#
sced.o:	sced.c utility.o list.o var.h network.h externs.h cstitch.h
	$(CC) -c $(CFLAGS) -DSCEDLIB=${SCEDLIB} sced.c
#
#
local_route.o:	local_route.c utility.o list.o var.o network.h externs.h cstitch.o route.h
	cc -c $(CFLAGS) local_route.c
#	
global_route.o:	global_route.c utility.o list.o var.o network.h externs.h cstitch.o route.h
	cc -c $(CFLAGS) global_route.c
#	
place.o:	place.c utility.o list.o cstitch.o var.h network.h externs.h cstitch.h
	$(CC) -c $(CFLAGS) place.c
#
hand_place.o: hand_place.c utility.o list.o var.o network.h externs.h cstitch.o 
	$(CC) -c $(CFLAGS) hand_place.c
#
terminals.o: terminals.c global_route.c utility.o list.o var.o network.h externs.h cstitch.o route.h terminals.h
	$(CC) -c $(CFLAGS) terminals.c
#
parse.o:	parse.c utility.o list.o var.h network.h externs.h cstitch.h 
	$(CC) -c $(CFLAGS) parse.c
#
utility.o :	utility.c list.o var.h network.h externs.h cstitch.h
	$(CC) -c $(CFLAGS) utility.c
#
cstitch.o:	cstitch.c cstitch.h list.h
	$(CC) -c $(CFLAGS) cstitch.c
#
list.o:	list.h
	$(CC) -c $(CFLAGS) list.c
#
var.o: 		var.h network.h externs.h
	$(CC) -c $(CFLAGS) var.c
#
debug.o:	debug.c psfigs.o var.h network.h externs.h 
	$(CC) -c $(CFLAGS) debug.c
#
psfigs.o: 	var.h network.h externs.h 
	$(CC) -c $(CFLAGS) psfigs.c
#
listing:	n2a.c parse.c place.c local_route.c global_route.c utility.c debug.c\
		sced.c psfigs.c network.h externs.h README
	enscript -2rG n2a.c parse.c place.c local_route.c global_route.c utility.c\
	          debug.c sced.c psfigs.c network.h externs.h README
#
clean:
	rm spar *.o
#
example:	spar test1.ivf
	spar test1.ivf | lpr
#
