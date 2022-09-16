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


/* file sced.c */
/* ------------------------------------------------------------------------
 * sced particular routines for place and route                 spl 9/89
 *
 * ------------------------------------------------------------------------
 */
#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include "net.h"
/*     #include "network.h"   */
/*     #include "externs.h"   */

#include "route.h"

#define NAMESIZE 16
static char         *scedlib = SCEDLIB; /* directory of sced part icons */

/* in case rotation conventions are different */

#define SIDE_CONVERT(n) ((n==0)?0:(n==1)?1:(n==2)?2:(n==3)?3:0)
#define ISSEP(x) (isspace(x) || ispunct(x))

static int targc;	/* for parse line */
static char *targv[LSIZE]; /* worst case is really LSIZE/2 */

/*---------------------------------------------------------------
 * Forward References
 *---------------------------------------------------------------
 */

rlist *input_positions();


/*---------------------------------------------------------------
 * print_sced
 * Generate the file for the schematics editor sced.
 * Note the part names are built simplisticaly, we just
 * append the number of inputs, to the string name of the type of module.
 * Otherwise we need a new field in the ivf format to specify an icon name.
 * This would make them incompatable with the "old" ~cad parts wich have 
 * different naming conventions.
 *---------------------------------------------------------------
 */

print_sced(f)
FILE *f;
{
    char            temp[NAMESIZE];

    mlist *ml;
    tlist *t;
    int i, c;
    int tempx;
    

    nlist *nl;
    expnlist *exl;
    trail *besTrail;
    trlist *trl;
    crnlist *cl;
    int x1, y1, x2, y2;

    llist *head, *hhead;
    olist *ol, *ool;

    /* put down the objects == modules 
     * LOTS of caveats:
     * 1) must be a name we already have an icon for
     * 2) must fit in sced's fixed window of 0,0 to 218,168
     * or sced will ignore it.
     */

    for (ml = partitions[0]; ml != NULL; ml = ml->next)
    {
	fprintf(f, "[P][%d %d %d ", ml->this->x_pos, ml->this->y_pos,
		SIDE_CONVERT(ml->this->rot));

	for(i = 0, t = ml->this->terms; t != NULL; t = t->next)
	{
	    if (t->this->type == IN) i++;
	}
	
	fprintf(f, "%s/%s%1d.icon ]\n", scedlib, ml->this->type, i);
    }

    /* try to put down the obstacles of type net == wires
     * sced is VERY finiky about wires.
     * also we do not know aprioi the full extent of the picture
     * since wires might run outside the bbox of the final partition.
     * (do you get the feeling that all this is a hack...)
     */

    for (nl = nets; nl != NULL; nl = nl->next)
    {
	/* Print as much of each net as possible: */
	exl = (expnlist *)nl->this->expns;

	for (trl = exl->this->connections; trl != NULL; trl = trl->next)
	{
	    besTrail = trl->this;
	    for (cl = besTrail->used; cl != NULL; cl = cl->next)
	    {
		if (cl->next != NULL)
		{
		    x1 = cl->this->cx->sr->q1;
		    y1 = cl->this->cy->sr->q1;
		    x2 = cl->next->this->cy->sr->q1;
		    y2 = cl->next->this->cy->sr->q1;
		    fprintf(f, "[W][%d,%d][%d,%d][-1,-1]\n", x1, y1, x2, y2);
		}
	    }
	}
    }

    /* we just do the horz ones first, whichever we do first, 
     * the problem comes from the other one. Sced will not let you
     * cross the top of a "T" with a wire. This is because it thinks
     * you do not know if you want a connection or not. In fact we always
     * DO want a connection. but its easier to hack this than fix sced....
     */

    for(head = NULL; head != NULL; head = head->next)
    {
	for(ol = (olist *)head->values; ol != NULL; ol = ol->next)
	{
	    if(ol->this->type == NET)
	    {
		tempx = ol->this->x;

		/* check to see if it makes a "T" with a horiz wire */

		for(hhead = NULL; hhead != NULL; hhead = hhead->next)
		{
		    if ((hhead->index > ol->this->x) &&
			(hhead->index < ol->this->y))
		    {
			/* there are some which span the same range */

			for(ool = (olist *)hhead->values;
			    ool != NULL; ool = ool->next)
			{
			    if((ool->this->type == NET) &&
			       ((ool->this->x == ol->this->i)||
				(ool->this->y == ol->this->i)))
			    {
				/* we found one, put out a segment
				 * from our bottom end, to their index
				 * and keep looking
				 */
				fprintf(stdout, "[W][%d,%d][%d,%d][-1,-1]\n", 
					ol->this->i, tempx,
					ol->this->i, ool->this->i);

				tempx = ool->this->i;
			    }
			}
		    }
		}
		/* finish up the wire */
		fprintf(stdout, "[W][%d,%d][%d,%d][-1,-1]\n", 
			ol->this->i, tempx,
			ol->this->i, ol->this->y);
	    }
	}
    }


    /* We do this last to make sure we only put down labels after
     * modules and wires, so that if they collide this text is what is lost.
     * This is because sced does not support text on top of wires or 
     * objects.
     * We also do not bother to print long strings.
     */
    
    for (ml = partitions[0]; ml != NULL; ml = ml->next)
    {
	if (strlen(ml->this->name) < NAMESIZE)		/* Change this sometime... */
	    {
		fprintf(f, "[L][%d %d %d %d %s@]\n",
			ml->this->x_pos,
			ml->this->y_pos + 1 + ml->this->y_size,
			ml->this->x_pos,
			ml->this->y_pos + 1 + ml->this->y_size,
			ml->this->name);
	    }
    }

    /* finish the sced file */
    fprintf(f,"[E]\n");
    
}


/*
 *---------------------------------------------------------------
 * read_terms
 * open an icon.term file and read the info into some static space
 * for get_terms to use
 *---------------------------------------------------------------
 */
int read_terms(icon_name, input_count, output_count, m)
    char *icon_name;
    int input_count, output_count;
    module *m;
    
{
    char tfile[LSIZE];
    FILE *tf;
    
    sprintf(tfile, "%s/%s%1d.icon.term", scedlib, icon_name, input_count);
    tf = fopen(tfile,"r");
    if (tf == NULL)
    {
	fprintf(stderr,"Cannot open %s for input\n",tfile);
	return(FALSE);
    }
    if (input_ports(tf, input_count, output_count, m))
    {
	fclose(tf);
	return(TRUE);
    }
    else 
    {
	error("Could not find (or use) icon file: ",tfile);
	
	fclose(tf);
	return(FALSE);
    }
}

/*
 *---------------------------------------------------------------
 * input_ports
 * NOTE: we are assuminng the the icon.term files all have their ports
 * specified in the order: inputs followed by ouputs -- no mater what
 * the position of the pins are.
 *---------------------------------------------------------------------------
 */
int input_ports(in, icount, ocount, m)
    FILE *in;
    int icount, ocount;
    module *m;
    
{
    char line[LSIZE];
    int rcount, count = 0;
    int found = FALSE;
    tlist *tt = m->terms;

    /* NOTE: hack to use range lists for term pos. */
    rlist *rl = NULL, *rrl = NULL ;
    
    while (!found || count > 0)
    {
	if (fgets(line, LSIZE, in) != line)
	{
	    break;
	}
	
	parse_line(line);

	if (targv[0] == NULL)
	{
	    continue;
	}
	else if(!strcmp(targv[0], "COUNT"))
	{
	    /* use this both for a check and as a flag to tell us
	     * we can start parsing the lines for postions
	     */
	    count = atoi(targv[1]);
	    if( count != (icount + ocount))
	    {
		/*  names match but i/o count is wrong */
		return(FALSE);
	    }
	    else
	    {
		found = TRUE;
		rcount = count;
		continue;
	    }
	    
	}
	else if(found && (count > 0))
	{
	    /* put it on a list, generates same reverse order we need */
	    rl = input_positions(rl);
	    count --;
	}
    }/* end of parse loop */


    /* NOTE: here we assume that the order of the terminals in the
     * icon file matches the order of the signals in the
     * ivf file. this is only likely for simple gates.
     * but we can do some checking.
     */
    while ((rcount > 0) && (tt->this != NULL) && (rl->this != NULL))
    {
	if(((tt->this->type == IN) && (rl->this->c == 'i')) ||
	   ((tt->this->type == OUT) && (rl->this->c == 'o')))
	{
	    tt->this->x_pos = rl->this->x;	
	    tt->this->y_pos = rl->this->y;
	    tt = tt->next;
	    rl = rl->next;
	    rcount --;
	    
	}    
	else /* give up */
	{
	    return(FALSE);
	}
    }
    return(TRUE);
}



/*------------------------------------------------------------------
 * parse input line into tokens, filling up targv and setting targc
 * chris terman's code....
 *------------------------------------------------------------------
 */

parse_line(line)
    char *line;
{
    char **carg = targv;
    char ch;

    targc = 0;
    while (ch = *line++) {
	if (ISSEP(ch))
	{
	    continue;
	}
	targc++;
	*carg++ = line-1;
	while ((ch = *line) && !ISSEP(ch))
	{
	    line++;
	}
	if (ch)
	{
	    *line++ = '\0';
	}
	*carg = 0;
    }
}

/*
 *---------------------------------------------------------------
 * input_positions
 *---------------------------------------------------------------
 */
/*---------------------------------------------------------------
 * create_rng (Level 5) create a new range triple on the head of an rlist
 *---------------------------------------------------------------
 */
rlist *create_rng(low, up, cross, rl)
    int low, up, cross;
    rlist *rl;
{
    rng *r;

    r = (rng *)calloc(1, sizeof (rng));
    r->x = low;
    r->y = up;
    r->c = cross;
    
    rl = (rlist *)concat_list(r, rl);
    return(rl);
}

/*---------------------------------------------------------------
 * copy_rng (Level 5) copy a set of ranges (rlist) into a new one
 *---------------------------------------------------------------
 */
rlist *copy_rng(rl)
    rlist *rl;
{
    rlist *retl = NULL;
    
    for(; rl != NULL; rl = rl->next)
    {
	retl = create_rng(rl->this->x, rl->this->y, rl->this->c, retl);
    }
    return(retl);
}

/*----------------------------------------------------------------------*/
rlist *input_positions(tp)
    rlist *tp;
    
{
    return(create_rng(atoi(targv[0]), atoi(targv[1]), targv[2][0], tp));
}


/*---------------------------------------------------------------
 * END OF FILE
 *---------------------------------------------------------------
 */

