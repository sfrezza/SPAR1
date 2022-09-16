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


/* file hand_place.c */
/* ------------------------------------------------------------------------
 * Hand Placement routines                         		stf 10/91
 * Implemented to enable the testing of routing solutions for SPAR
 * UPittsburgh School of Engineering.
 * ------------------------------------------------------------------------
 */
#include <stdio.h> 
#include "network.h"
#include "externs.h"

#define START_X -5000
#define START_Y -5000

/*===================================================================================*/
int query_for_resizing(m)
    module *m;
{
    char c[20], temp[20];
    int x = START_X, y = START_Y;
    int ins = 0, inouts= 0, outs = 0;

    /* Query to see if the user wants to resize the given module: */
    fprintf(stderr, "Resize module %s?  ", m->name);
    process_comment();
    gets(c);
    
    if (!strncmp(c, "y", 1))
    {
	fprintf(stderr, "New width & height for %s? [Currently %dw x %dh]  -> ", 
		m->name, m->x_size, m->y_size);

	/* Check for a comment line...*/
	process_comment();

	gets(temp);
	sscanf(temp, "%d %d\n", &x, &y);
	if ((x == START_X) && (y == START_Y)) 
	{
	    fprintf(stderr, "Bad string entered;  No changes made.\n");
	}
	else
	{
	    m->x_size = x;
	    m->y_size = y;
	}

	/* Now reposition the terminals so they fall in the right places... */
	get_terminal_counts(m, &ins, &inouts, &outs);
	reposition_all_terminals(m, ins, inouts, outs, pin_spacing(m));
    }
}

/*===================================================================================*/
mlist *hand_placement(modsToPlace, root)
    mlist *modsToPlace;
    tile **root;
{
/* This function runs through the list of modules, and requests positions/sizes for
   all modules.  Some defaults may be available. */

    module *m;
    mlist *ml;
    tile *t = NULL, *tempTile;
    char temp[20];    
    int x = START_X, y = START_Y;


    *root = create_tile(TILE_SPACE_X_LEN, TILE_SPACE_Y_LEN, NULL, 
			TILE_SPACE_X_POS, TILE_SPACE_Y_POS);

    for(ml = modsToPlace; ml != NULL; ml = ml->next)
    {
	query_for_resizing(ml->this);

	while (t == NULL)
	{
	    /* For each interior module, request a placement: */
	    fprintf(stderr, "X & Y Coords for module %s?  [currently (%d %d)] -> ", 
		    ml->this->name, ml->this->x_pos, ml->this->y_pos);

	    /* Check for a comment line...*/
	    process_comment();

     	    gets(temp);
	    sscanf(temp, "%d %d", &x, &y);
	    if ((x == START_X) && (y == START_Y)) 
	    {
		fprintf(stderr, "Bad string entered;  No changes made.\n");
	    }
	    else
	    {
		ml->this->x_pos = x;
		ml->this->y_pos = y;
	    }

	    t = insert_tile(*root, ml->this->x_pos - 1, ml->this->y_pos - 1,
			    ml->this->x_size + 1, ml->this->y_size + 1, ml->this);

	    if (t == NULL) 
	    {
		fprintf(stderr, "Placement for %s failed. Please try again.",
			ml->this->name);	
		tempTile = area_search(*root, ml->this->x_pos - 1, 
				       ml->this->y_pos - 1, ml->this->x_size + 1, 
				       ml->this->y_size + 1);
		m = (module *)tempTile->this;
		fprintf(stderr, "(%s overlaps module %s.)\n", ml->this->name, m->name);
	    }
	}	
	t = NULL;	/* Reset for another go around. */
	x = START_X;	
	y = START_Y;

    }
    return(modsToPlace);
}

/*===================================================================================*/
int process_comment()
{
    /* check to see if the first character given is a '#';  If it is, then
       read in the line and continue looking for comments.
       If it is NOT, then stuff the character back onto the input stream, and
       return. */

    char c;
    char *comment[120];
    
    c = (char)getc(stdin);
    while (c == '#')
    {
	gets(comment);
	c = (char)getc(stdin);
    }
    ungetc(c, stdin);
}
    
/*===================================================================================*/
/* end of file "hand_place.c" */
