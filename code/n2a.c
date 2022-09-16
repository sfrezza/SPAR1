/************************************************************
**
**       COPYRIGHT (C) 1993 UNIVERSITY OF PITTSBURGH
**       COPYRIGHT (C) 1996 GANNON UNIVERSITY
**                  ALL RIGHTS RESERVED
**
**        This software is distributed on an as-is basis
**        with no warranty implied or intended.  No author
**        or distributor takes responsibility to anyone 
**        regarding its use of or suitability.
**
**        The software may be distributed and modified 
**        freely for academic and other non-commercial
**        use but may NOT be utilized or included in whole
**        or part within any commercial product.
**
**        This copyright notice must remain on all copies 
**        and modified versions of this software.
**
************************************************************/


/* file n2a.c */
/* ------------------------------------------------------------------------
 * main file manipulation routines                         spl 7/89
 *
 * ------------------------------------------------------------------------
 */
#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <sys/time.h>	
#include <sys/resource.h>

#include "network.h"

/*---------------------------------------------------------------
 * External functions
 *---------------------------------------------------------------
 */

#include "externs.h"

/*---------------------------------------------------------------
 * Global Variable Definitions
 *---------------------------------------------------------------
 */

#define USEC 1000000

mlist *modules;		/* M the set of all modules */
nlist *nets;		/* N the set of all nets */
tlist *ext_terms;	/* ST the set of all system terminals */
mlist *ext_mods;	/* the modules associated with each element of ST */

/* NOT USED*/
tlist *int_terms;	/* T the set of all inter-module terminals */

/* FOR THE ROUTER (only) */
int currentPartition;
tile **routingRoot[2];	  

/* NOT USED MUCH */
mlist **boxes;		/* the sets of boxes */
mlist **strings;	/* the set of strings */
ctree **parti_stats;	/* partition statistics */
int *str_length;	/* the length of each string */
int *str_height;	/* the height of each string */
int *x_sizes;		/* the max x size of each partition */
int *y_sizes;		/* the max y size of each partition */
int *x_positions;	/* and their postions, after placement */
int *y_positions;
int xfloor, yfloor;	/* the origin for the current partition */

mlist **partitions;	/* the set of PARTITIONS (lists) of modules */
tile **rootTiles;	/* The tile spaces that correspond to the partitions */
int partition_count;	/* the total number of partitions created */


/* NOT USED ENOUGH */
int lcount = 0;			   /* number of input lines read */
int module_count = 0;		   /* number of modules/objects read in */
int node_count = 0;		   /* number of nodes/signals read in */
int terminal_count = 0;		   /* number of terminals read in */
int connected[MAX_MOD][MAX_MOD];   /* BIG array of connection counts */
info_type module_info[MAX_MOD];/* re-used array of inter module connections */

/* command-line parameters: */
int compute_aspect_ratios = FALSE;		/* -a flag, in parsing - compute aspect ratios*/
int Xcanvas_scaling = FALSE;	   		/* -b flag (use XCanvas scaling) */
int max_partition_conn =  MAX_PARTITION_CONN; 	/* -c qualifier, used for clustering */
int debug_level = 0;			      	/* -d qualifier, sets the debug level */
int stopAtFirstCut = FALSE;			/* -f flag; terminates GR early */
int congestion_rule = 2; 			/* -g qualifier, used for conGestion */
int do_hand_placement = FALSE;			/* -h flag */
int includeSysterms = TRUE;			/* -i flag; excludes system terminals */
int collapseNullModules = TRUE;			/* -k flag;denies kollapse of NL_GATES */
int cc_search_level = CC_SEARCH_LEVEL;		/* -l qualifier, limits cc search */
int matrix_type = UNSIGNED;			/* -m qualifier, sets signal-flow style*/
int do_routing = TRUE;				/* -n qualifier, inhibits routing */
FILE *outputFile = stdout;			/* -o qualifier, opens an Output file */
int partition_rule =  DEF_PARTITION_RULE; 	/* -p qualifier, used for clustering */
int recordStats = FALSE;			/* -q flag; quality stats collection on*/
float partition_ratio =  DEF_PARTITION_RATIO; 	/* -r qualifier, used for clustering */
int max_partition_size =  MAX_PARTITION_SIZE; 	/* -s qualifier, used for clustering */
int turn_mode = TIGHT;			        /* Used to choose the cornering alg */
int useBlockPartitioning = FALSE;		/* -u flag; skips automatic partitioning */
int useSlivering = TRUE;			/* -v flag; removes sliVer corrections */
int useAveraging = FALSE;			/* -w flag; turns Weighted averaging on*/
int latex = FALSE;				/* -x flag; modified PostScript header */
int recordTiming = FALSE;			/* -y flag; turns time collection on */

int generate_sced = FALSE;  			/* Old -g flag */
char *ivffilename; 			      	/* input file name */
FILE *stats;					/* quality statistics file */

/*------------------------------------------------------------------------------------
 * main: parse command line, open files, parse, place internal terminals, global route, 
 *       lay system terminals, global route, local route.
 *-------------------------------------------------------------------------------------
 */

main(argc, argv)
    int argc;
    char *argv[];
{
    FILE *ivffile, *timingFile, *fopen();
    
    int c,  errflg = 0, x1, y1, x2, y2;
    double atof();
    nlist *nl = NULL, *systermNets = NULL;
    mlist *modulesJustPlaced, *ml;
    mlist *systerms = NULL, *internalModules = NULL;
    /* for date and time */
    long starTime, diffTime;
    extern long int time();
    tile *r;

    extern int optind;
    extern char *optarg;

    /* 
     * Parse command line inputs
     */
    
    while ((c = getopt(argc, argv, "d:s:t:c:r:o:p:l:m:g:abfhiknquvwxy")) != EOF)
    switch (c) {
	case 'a':	/* Have the parser compute aspect ratios for blocks */
	{
	    compute_aspect_ratios = TRUE;
	    break;
	}
	case 'b':	/* Have the parser do scaling for Xcanvas icon info */
	{
	    Xcanvas_scaling = TRUE;
	    break;
	}
	case 'c':	/* Set the number of connections that make a partition */
	{
	    max_partition_conn = atoi(optarg);
	    break;
	}
	case 'd':	/* Set the debug level (amount of junk spewed to stderr) */
	{
	    debug_level = atoi(optarg);
	    break;
	}
	case 'f':	/* Only complete the first-cut at the Global Route  */
	{
	    stopAtFirstCut = TRUE;
	    break;
	}
	case 'g':	/* Generate SCED file */
	{
	    congestion_rule = atoi(optarg);
	    break;
	}
	case 'h':	/* Enter hand-placement mode */
	{
	    do_hand_placement = TRUE;
	    partition_rule = 0;
	    max_partition_size = 0;
	    max_partition_conn = 0;
	    break;
	}
	case 'i':	/* do not display the output terminals */
	{
	    includeSysterms = FALSE;
	    break;
	}
	case 'k':	/* do not (K)ollapse null modules */
	{
	    collapseNullModules = FALSE;
	    break;
	}
	case 'l':	/* Set the Cross-Coupled Search level */
	{
	    cc_search_level = atoi(optarg);
	    break;
	}
	case 'm':	/* Determine the Matrix Type (default = 0) */
	{
	    matrix_type = atoi(optarg);
	    if ((matrix_type < -1) ||	/* these are <m>'s limits: {m|-1..1} */
                (matrix_type > 1 ))
	    {
		matrix_type = UNSIGNED;
		fprintf(stderr,"Bad choice for -m option (%d)\n", matrix_type);
		exit(1);
	    }		
	    break;
	}
	case 'n':	/* Placement Only */
	{
	    do_routing = FALSE;
	    break;
	}
	case 'o':	/* open an output file: */
	{
	    if ((outputFile = fopen(optarg, "w")) == NULL) {
		fprintf(stderr,"can't open %s\n", optarg);
		exit(1);
	    }
	    break;
	}
	case 'p':	/* Set the partition Rule */
	{
	    partition_rule = atoi(optarg);
	    if ((partition_rule < 1) ||	/* these are <p>'s limits: {p|1..3} */
                (partition_rule > 4))
	    {
		partition_rule = DEF_PARTITION_RULE;
		fprintf(stderr,"Bad choice for -p option(%d)\n", partition_rule);
		exit(1);
	    }		
	    break;
	}
	case 'q':	/* Create a quality statistics file */
	{
	    recordStats = TRUE;
	    break;
	}
	case 'r':	/* Set the ratio for the -d2 paritioning scheme */
	{
	    partition_ratio = atof(optarg);
	    break;
	}
	case 's':	/* set the number of modules that make a partition */
	{
	    max_partition_size = atoi(optarg);
	    break;
	}
	case 't':	/* Global route only? (Use -d1 instead) */
	{
	    turn_mode = atoi(optarg);
	    break;
	}
	case 'u':	/* Use block partitioning, if provided */
	{
	    useBlockPartitioning = TRUE;
	    break;
	}
	case 'v':	/* do not use sliVer corrections */
	{
	    useSlivering = FALSE;
	    break;
	}
	case 'w':	/* use Weighted averaging in placement */
	{
	    useAveraging = TRUE;
	    break;
	}
	case 'x':	/* Create a latex-readable PostScript file */
	{
	    latex = TRUE;
	    break;
	}
	case 'y':	/* Create a timing file */
	{
	    recordTiming = TRUE;
	    break;
	}
	
	case '?':
	errflg++;
	break;
	default: 	errflg++;
    }

    if ((errflg) || (argv[optind] == NULL))
    {
	fprintf(stderr,
		"usage: %s [-a][-b][-c#][-d#][-g][-m#][-n][-o<filename>][-p#][-r#][-s#][-t#][-u][-v][-w][-x][-y] <ivffile> \n", 
		argv[0]);
	fprintf(stderr,"where:\n");
	fprintf(stderr,"\t a => Compute aspect ratios for block icons.\n");
	fprintf(stderr,"\t b => Use Xcanvas scaling factors.\n");
	fprintf(stderr,"\t c# => max # Connections out of a partition (p=1)\n");
	fprintf(stderr,"\t d# is Debug level\n");
	fprintf(stderr,"\t f => First cut at global route (no rip-up & reroute)\n");
	fprintf(stderr,"\t g# => ConGestion Style to use:\n");
	fprintf(stderr,"\t\t 1 => Only count corner density.\n");
	fprintf(stderr,"\t\t 2 => Count corner density and max crossover. [default]\n");
	fprintf(stderr,"\t h => Hand place all modules in the diagram.\n");
	fprintf(stderr,"\t i => do not Include system terminals\n");	
	fprintf(stderr,"\t k => do not Kollapse NL_GATEs\n");	
	fprintf(stderr,"\t l# => max level to identify cross-coupled modules\n");
	fprintf(stderr,"\t m# => type of connections considered (-1, 0, 1)\n");
	fprintf(stderr,"\t o <filename>  => open <filename> as the output file.\n");
	fprintf(stderr,"\t n  => No routing is to be performed\n");
	fprintf(stderr,"\t p# => Partitioning style (rule) to be employed, where:\n");
	fprintf(stderr,"\t\t 1 => partition OK if <= s && <= c(size)\n");
	fprintf(stderr,"\t\t 2 => partition OK if c/s > r (ratio)\n");
	fprintf(stderr,"\t\t 3 => partition OK if c(n) > c(n-1) (find local maxima) [default]\n");
	fprintf(stderr,"\t\t 4 => experimental (combines -p2 & -p3 notions)\n");
	fprintf(stderr,"\t q => produce datafile with quality statistics.\n");
	fprintf(stderr,"\t r# => partitioning ratio used in rule (p=2)\n");
	fprintf(stderr,"\t s# => max size of each partition (p=1)\n");
	fprintf(stderr,"\t t# => -1 = Global route only (broken! use -d1 instead)\n");
	fprintf(stderr,"\t u => Use block clues in .ivf file for partitioning\n");
	fprintf(stderr,"\t v => ignore sliVering corrections in the local route\n");
	fprintf(stderr,"\t w => use Weighted averaging to merge strings & partitions\n");
	fprintf(stderr,"\t x => produce lateX compatible PostScript output\n");
	fprintf(stderr,"\t y => produce datafile with runtime info.\n");	
	exit(1);
    }
    
    /*
     * Open the ivf file
     */
    
    ivffilename = strdup(argv[optind]);
    
    if ((ivffile = fopen(argv[optind], "r")) == NULL) {
	fprintf(stderr,"can't open %s\n", argv[optind]);
	exit(1);
    }
    else fprintf(stderr,"%s, used for ivffile\n", argv[optind]);
    
    /*
     * main body
     */

    /* parse input */

    if (recordTiming == TRUE) 
    {
	if ((timingFile = fopen("run-time", "w")) == NULL) 
	{
	    fprintf(stderr,"can't open file for timing results\n");
	    exit(1);
	}
	fprintf(timingFile,"Timing results for %s with flags -p%d -s%d -c%d -m%d -l%d -d%d %s %s %s %s\n\n",
		ivffilename, partition_rule, max_partition_size, max_partition_conn, 
		matrix_type, cc_search_level, debug_level,
		(do_routing == FALSE) ? "-n" : (stopAtFirstCut == TRUE) ? "-f" : " ",
		(useSlivering == FALSE) ? "-v" : " ",
		(useAveraging == TRUE) ? "-w":" ",
		(includeSysterms == FALSE) ? "-i" : " ");

	diffTime = 0;
	mark_time(timingFile, "startup", &diffTime);
    }

    read_ivf(ivffile);  
    if(recordTiming == TRUE) mark_time(timingFile, "parse", &diffTime);

    /* place */
    if (do_hand_placement == FALSE)
    {
	fprintf(stderr,"Placing internal modules...");
	if (useBlockPartitioning == FALSE) partition_count = partition();
	else partition_count = blockPartition();

	if (collapseNullModules == TRUE) clip_null_gates();
	
	if(recordTiming == TRUE) mark_time(timingFile, "partition", &diffTime);
	
	erase_systerms();
	place_first_strings();
	box_placement();
	placement_prep();
	modulesJustPlaced = partition_placement();
	/* Setup the bounding box */
	systerms = make_room_for_systerm_placement(&systermNets, &x1, &y1, &x2, &y2);

	fprintf(stderr,"\nAutomatic placement ");
    }

    else	/* Do the placement by hand, query the user for all modules. */
    {
	fprintf(stderr,"Querying for placement of internal modules...");	
	/* Separate the systerms from the internal modules: */
	separate_systerms(&internalModules, &systerms, &systermNets, 0);

	/* Do the hand placement: */
	modulesJustPlaced = hand_placement(internalModules, &r);
	/* Setup the Bounding Box: */
	determine_bounding_box(r, &x1, &y1, &x2, &y2);
	x1 -= 20;  y1 -= 20;  				/* Add some padding... */
	x2 += 20;  y2 += 20;

	rootTiles[0] = r;
	x_sizes[0] = MAX(x1, x2) + 20;			/* Add a bit more */
	y_sizes[0] = MAX(y1, y2) + 20; 
	xfloor = MIN(x1, x2);
	yfloor = MIN(y1, y2);
	
	fprintf(stderr,"\nHand placement ");
    }
    fprintf(stderr,"completed.\n");

    if(recordTiming == TRUE) mark_time(timingFile, "central placement", 
				       &diffTime);    


    if (includeSysterms == TRUE)
    {
	/* routing */
	if (do_routing == TRUE) 
	{
	    currentPartition = 0;
	    for(ml = systerms; ml != NULL; ml = ml->next) pull_terms_from_nets(ml->this);
	    routingRoot[VERT] = (tile **)calloc(partition_count + 2, sizeof(tile *));
	    routingRoot[HORZ] = (tile **)calloc(partition_count + 2, sizeof(tile *));
	    
	    fprintf(stderr,"Routing for Systerm Placement...");
	    create_routing_space(modulesJustPlaced, currentPartition, 
				 x_sizes[currentPartition], y_sizes[currentPartition], 
				 xfloor, yfloor);

	    nl = first_global_route(modulesJustPlaced, currentPartition, 
				    TRUE, congestion_rule);
	    if(recordTiming == TRUE) mark_time(timingFile, "central global route", 
					       &diffTime);    

	    /* Create a local route to use to locate the system terminals */
	    local_route(systermNets, currentPartition, FALSE);
	    if(recordTiming == TRUE) mark_time(timingFile, "central local route", 
					       &diffTime);    
	    fprintf(stderr,"placing systerms...");

	    /* Add the system terminals (systerms) to the diagram: */
	    modulesJustPlaced = fine_systerm_placement(&x1, &y1, &x2, &y2); 
	    if(recordTiming == TRUE) mark_time(timingFile, "systerm placement", 
					       &diffTime);    
	    fprintf(stderr,"completed. \n");
	}

	if (do_routing != TRUE) 
	{
	    gross_systerm_placement(&x1, &y1, &x2, &y2);
	    if(recordTiming == TRUE) mark_time(timingFile, "gross systerm placement", 
					       &diffTime);    
	}

	/* Add the system terminals back to their respective nets: */
	for(ml = systerms; ml != NULL; ml = ml->next) add_terms_to_nets(ml->this); 
	fprintf(stderr,"System Terminals being added to diagram...\n");

	/* finish the routing */
	if (do_routing == TRUE)
	{
	    fprintf(stderr,"Adding systerms to routing space, Global Routing commenced...");
	    /* Deal with resetting the boundaries to include the system terminals: */
	    reset_boundaries(routingRoot[HORZ][currentPartition], x1, y1, x2, y2);
	    reset_boundaries(routingRoot[VERT][currentPartition], y1, x1, y2, x2);
	    xfloor = x1;		x_sizes[currentPartition] = x2 - x1;
	    yfloor = y1;		y_sizes[currentPartition] = y2 - y1;	    
	    
	    nl = incremental_global_route(modulesJustPlaced, modules, nl, currentPartition);
	    if(recordTiming == TRUE) mark_time(timingFile, "complete global route", 
					       &diffTime);    

	    fprintf(stderr,"completed...Local Routing commenced...");
	    local_route(nets, currentPartition, TRUE);
	    if(recordTiming == TRUE) mark_time(timingFile, "complete local route", 
					       &diffTime);    
	    fprintf(stderr,"completed.\n");
	}
    }
    else if (do_routing == TRUE)
    {
	/* No terminals are to be placed, hence no incremental routing. */
	routingRoot[VERT] = (tile **)calloc(partition_count + 3, sizeof(tile *));
	routingRoot[HORZ] = (tile **)calloc(partition_count + 3, sizeof(tile *));
	
	fprintf(stderr,"Adding modules to routing space, Global Routing commenced...");
	create_routing_space(modulesJustPlaced, currentPartition,
			     x_sizes[currentPartition], y_sizes[currentPartition], 
			     xfloor, yfloor);

	nl = first_global_route(modulesJustPlaced, currentPartition, 
				FALSE, congestion_rule);  
	if(recordTiming == TRUE) mark_time(timingFile, "complete global route", 
					   &diffTime);    

	fprintf(stderr,"completed...Local Routing commenced...");
	local_route(nets, currentPartition, TRUE);
	fprintf(stderr,"completed.\n");      
	if(recordTiming == TRUE) mark_time(timingFile, "complete local route", 
					   &diffTime);    
    }

    if (recordStats == TRUE) print_distance_matricies();

    /*
     * finish up
     */

    if (debug_level > 20) /* debug */
    {
       print_modules(stderr);
       print_nets(stderr);

       if (debug_level > 20) /* debug */
       {
       }
       print_info(stderr);
       print_strings(stderr);
       
    }

    if (generate_sced == TRUE)
    {
/*	print_sced(outputFile);   		broken ...*/
    }
    if (do_routing != TRUE) 
    {
	draft_statistics();
	print_module_placement(currentPartition, outputFile);
    }
    else
    {
	if (turn_mode != TIGHT) print_global_route(outputFile);
	else print_local_route(outputFile, nets);
    }
    if (recordStats == TRUE)
    {
	draft_statistics();
	collect_congestion_stats(currentPartition);
    }
    
    
    fprintf(stderr,"\n %d Lines read, %d Modules, %d Nodes, %d Partitions\n",
	    lcount, module_count, node_count, partition_count);
    fprintf(stderr,"\nMax partition size: %d Max Connections: %d Ratio: %-5.3f Rule #%d\n",
	    max_partition_size, max_partition_conn, partition_ratio, partition_rule);
    fclose(ivffile);

    if(recordTiming == TRUE) 
    {
	mark_time(timingFile, "PostScript Generation time", &diffTime);    
	fprintf(timingFile,"%d Modules, %d Nets, %d Terminals, %d partitions\n\n",
		list_length(modules), list_length(nets), 
		count_terminals(modules), partition_count);
	fclose(timingFile);
    }
}
/* ------------------------------------------------------------------- */
mark_time(tf, name, dTime)
    FILE *tf;
    char *name;
    long *dTime;
{
   /*  record the time, and mark it in the <timingFile>: */
    double t;
    int cTime, maxMemory = 0;
    struct rusage ru;

    getrusage(RUSAGE_SELF, &ru);
    cTime = USEC * ru.ru_utime.tv_sec + ru.ru_utime.tv_usec; 
    maxMemory = MAX(ru.ru_maxrss, maxMemory);
    t = (double)(cTime - *dTime)/(double)USEC;
    *dTime = cTime;

    fprintf(tf, "%s time = %f, time elapsed = %f\n", 
	    name, t, (double)cTime/(double)USEC);
}
/* ------------------------------------------------------------------- */
int count_terminals(mods)
    mlist *mods;
{
    /* Given a list of modules, count the number of terminals contained */
    int c = 0;
    mlist *ml;
    for (ml = mods; ml != NULL; ml = ml->next)
    {
	c += list_length(ml->this->terms);
    }
    return(c);
}

/* ------------------------------------------------------------------- */
int allocate_globals(p)
    int p;			/* Number of partitions */
{
    x_sizes = (int *)calloc((p+1), sizeof(int));
    y_sizes = (int *)calloc((p+1), sizeof(int));
    x_positions = (int *)calloc((p+1), sizeof(int));
    y_positions = (int *)calloc((p+1), sizeof(int));
    partitions = (mlist **)calloc((p+3), sizeof(mlist *));
    rootTiles = (tile **)calloc((p+1), sizeof(tile *));
}

/* ------------------------------------------------------------------- */
int separate_systerms(intModules, sysModules, sysNets)	
    mlist **intModules, **sysModules;
    nlist **sysNets;
{
    mlist *ml, *sysMods = NULL;

    /* First, Do some of the background work done in "place.c" */
    allocate_globals(currentPartition);
    partitions[0] = partitions[1] = partitions[2] = NULL;

    for (ml = modules; ml != NULL; ml = ml->next)
    {
	if ((!strcmp(ml->this->type, INOUT_TERM)) ||
	    (!strcmp(ml->this->type, INPUT_TERM)))
	{
	    push(ml->this, sysModules);
	    push(ml->this, &partitions[2]);
	}

	else if (!strcmp(ml->this->type, OUTPUT_TERM)) 
	{
	    push(ml->this, sysModules);
	    push(ml->this, &partitions[1]);
	}
	
	else push(ml->this, intModules);
    }
    partitions[0] = *intModules;


    for (ml = *sysModules; ml != NULL; ml = ml->next)
    {
	/* Collect the nets that connect to the system terminals: */
	/* Assume there is only one terminal for each system terminal: */
	push(ml->this->terms->this->nt, sysNets);
    }
}	



/*---------------------------------------------------------------
 * END OF FILE
 *---------------------------------------------------------------
 */
/* string for printing: ctime(&starTime) */
