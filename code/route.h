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

/* 
 *      file route.h
 * As part of MS Thesis Work, S T Frezza, UPitt Engineering
 * February, 1990
 *
 * This file contains the global and local routing structures used to perform the routing fns
 * in SPAR.  
 */

#include <math.h>
#include "network.h"
#include "externs.h"

#define RIPPED 1
#define HASH_SIZE 43

#define NO_SIDE -1
#define TERM_MARGIN 1
#define GRAY_MARGIN 0.05

#define TRACK_WEIGHT 30.0
#define LENGTH_WEIGHT 1.0
#define FORWARD_EST_MULTIPLIER 0.80
#define EXPECTED_CORNERS 3
#define CORNER_COST 4

#define TOP_EDGE 1
#define BOT_EDGE 2
#define LEFT_EDGE 4
#define RIGHT_EDGE 8

#define UPWARD_U 1
#define DOWNWARD_U 2
#define HORZ_JOG 3
#define LEFT_U 4
#define UL_CORNER 5
#define LL_CORNER 6
#define VERT_LT 7
#define RIGHT_U 8
#define UR_CORNER 9
#define LR_CORNER 10
#define VERT_RT 11
#define VERT_JOG 12
#define HORZ_UT 13
#define HORZ_DT 14
#define X_CORNER 15

#define EXPAND_BOTH 2
#define EXPAND_MIN 3
#define EXPAND_MAX 4
#define EXPAND_NONE 5

/* Structure Definitions and type definitions: */
//##ModelId=3DA5B06B0225
typedef struct arc_struct 	arc;
//##ModelId=3DA5B06B02A4
typedef struct arc_list_struct 	arclist;
//##ModelId=3DA5B06B02B8
typedef struct expansion_struct expn;
//##ModelId=3DA5B06B02D6
typedef struct expn_list_struct expnlist;
//##ModelId=3DA5B06B02EA
typedef struct trail_struct 	trail;
//##ModelId=3DA5B06B0308
typedef struct trail_ilist_str  trailist;
//##ModelId=3DA5B06B031C
typedef struct trail_list_str   trlist;
//##ModelId=3DA5B06B0330
typedef struct range_struct 	range;
//##ModelId=3DA5B06B034E
typedef struct range_list_str 	rnglist;
//##ModelId=3DA5B06B0362
typedef struct corner_struct    corner;
//##ModelId=3DA5B06B0376
typedef struct corner_list_str	crnlist;

//##ModelId=3DA5B06B03D0
struct arc_struct
/* structure to manage arcs in the global router */
{ 
	//##ModelId=3DA5B06C0056
    nlist *nets;	/* nets that use this arc for their GR */
	//##ModelId=3DA5B06C0075
    crnlist *corners;	/* local routing corners that currently use this arc */
	//##ModelId=3DA5B06C007E
    int congestion;	/* congestion level */
	//##ModelId=3DA5B06C0147
    int page;		/* Indicates which page this tile belongs to. */
    int vcap, hcap;	/* Vertical and Horizontal capacities (# of tracks) */
	//##ModelId=3DA5B06C0152
    tile *t;		/* tile associated with this arc */
	//##ModelId=3DA5B06C0166
    module *mod;        /* Used to hold the original contents of the tile */
	//##ModelId=3DA5B06C0170
    trailist *trails[HASH_SIZE];/* pointers to trails that use this tile */   
    int local, count;		/* used for stats */
};

//##ModelId=3DA5B06C01AB
struct expansion_struct
/* structure to manage multipoint, pseudo-similtaneous expansions within the 
 * arc/edge configuration.  One of these should be used for every terminal in
 * a given net.  */
{
	//##ModelId=3DA5B06C01C0
    net *n;		/* Net to which the terminal belongs */
	//##ModelId=3DA5B06C01D4
    term *t;		/* Terminal from which the expansions began */
	//##ModelId=3DA5B06C01DE
    tilist *seen;       /* list of tiles that this expn has visited */
	//##ModelId=3DA5B06C01E8
    trailist *queue[HASH_SIZE];	/* Hash table of trails, from which the 
				   next move is selected */
	//##ModelId=3DA5B06C01FC
    expnlist *siblings;	/* (shared) list of expns that make up this expansion group */
	//##ModelId=3DA5B06C0210
    trlist *connections;/* (shared) list of trails that form complete paths */
	//##ModelId=3DA5B06C0219
    int eCount;		/* for statistics */
};

//##ModelId=3DA5B06C0255
struct trail_struct
{
    /* This is a possible global route;  Only if *used is set are there 
       ranges associated with the trail. */
	//##ModelId=3DA5B06C0269
    int cost;
	//##ModelId=3DA5B06C0274
    expn *ex;		/* Parent expansion */
	//##ModelId=3DA5B06C0288
    expn *jEx;		/* Who was contacted at termination */
	//##ModelId=3DA5B06C0292
    tilist *tr;		/* ordered list of tiles traversed */
    int page, direction;/* array indecies to the root tile for the next expansion set */
	//##ModelId=3DA5B06C02A6
    crnlist *used;	/* Pointer to the set of corners that 
			   comprise this trail (when constructed) */
};


//##ModelId=3DA5B06C02EB
struct trail_ilist_str	/* Indexed form */
{
	//##ModelId=3DA5B06C02F6
    int index;		/* trail cost */
    trail *this;
	//##ModelId=3DA5B06C0300
    trailist *next;
};

//##ModelId=3DA5B06C0327
struct trail_list_str 	/* Non-indexed form */
{
    trail *this;
	//##ModelId=3DA5B06C033C
    trlist *next;
};


//##ModelId=3DA5B06C034F
struct expn_list_struct
{
    expn *this;
	//##ModelId=3DA5B06C0364
    expnlist *next;
};

//##ModelId=3DA5B06C0381
struct arc_list_struct
{
    arc *this;
	//##ModelId=3DA5B06C0396
    arclist *next;
};


/* The following are used to implement the local router: */
//##ModelId=3DA5B06C03BE
struct range_struct
{
	//##ModelId=3DA5B06C03D3
    srange *sr;		    /* The min/max limits of this range. */
    int use, flag;
	//##ModelId=3DA5B06C03E7
    net *n;		    /* The net that this range is a part of */
	//##ModelId=3DA5B06D0009
    crnlist *corners;	    /* Corners linked by this range */
	//##ModelId=3DA5B06D001D
    crnlist *dep;	    /* Corners who's placement this range is constrained by */
};

//##ModelId=3DA5B06D0030
struct range_list_str
{
    range *this;
	//##ModelId=3DA5B06D0045
    rnglist *next;
};

//##ModelId=3DA5B06D0076
struct corner_struct
{
	//##ModelId=3DA5B06D008B
    range *cx;
	//##ModelId=3DA5B06D0095
    range *cy;
    int vertOrder, horzOrder;
	//##ModelId=3DA5B06D00A9
    arclist *al;
	//##ModelId=3DA5B06D00BD
    term *t;
};

//##ModelId=3DA5B06D00D0
struct corner_list_str
{
    corner *this;
	//##ModelId=3DA5B06D00E5
    crnlist *next;
};



/* Shared info between global and local router: */
/*--------------------------------------------------------------- 
 * Defined in global_route.c
 *---------------------------------------------------------------
 */
extern arc *next_arc();
extern int net_using_edge();
extern int congestion_cost();
extern int decision_box[];
extern tilist *collect_tiles();

/*--------------------------------------------------------------- 
 * Defined in local_route.c
 *---------------------------------------------------------------
 */
extern corner *create_corner();
extern int in_x_order();	
extern int divide_sranges();
extern int overlapped_p();	
