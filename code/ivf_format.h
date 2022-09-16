
/************************************************************
**
**       COPYRIGHT (C) 1988 UNIVERSITY OF PITTSBURGH
**       COPYRIGHT (C) 1988-1989 Alan R. Martello
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



#define MOD_START      "M_"     /*  start of a new module  */
#define MOD_START_EXP  "MX"     /*  start of architecure expanded around  */
#define MOD_PORT       "MP"     /*  start of module port declarations  */

#define MOD_VIEW_HIER   "MH"    /*  start of module hierarchy, for PSU  */
#define MOD_VIEW_FLAT   "MF"    /*  start of module flattend, for vsim simulator  */

#define SEP_CHAR  '.'           /*  entity and architecture separator (i.e. entity.architecture)  */

#define HIER_SIG        "HS"    /*  local signals  */
#define HIER_ASSMT      "HA"    /*  assignment statements  */
#define HIER_BLOCK      "HB"    /*  another nested block  */
#define HIER_COMP       "HC"    /*  component instantiations  */
#define HIER_PROC       "HP"    /*  process blocks  */

#define HIER_PROC_SENS  "PN"    /*  process sensitivity list */
#define HIER_PROC_VDEC  "PD"    /*  process variable declaration  */

#define HIER_PROC_SIG   "PS"    /*  process sig. assignment  */
#define HIER_PROC_VAR   "PV"    /*  process var. assignment  */

#define HIER_PROC_IF    "PI"    /*  process if statement     */
#define HIER_PROC_COND  "IC"    /*  conditional statement    */
#define HIER_PROC_ELSE  "IE"    /*  else statement           */

#define HIER_PROC_CASE  "HK"    /*  case statement           */
#define HIER_PROC_C_EXP "KE"    /*  case expression          */
#define HIER_PROC_C_CH  "KC"    /*  case choice              */
#define HIER_PROC_C_OTH "KO"    /*  case others              */

#define HIER_PROC_LOOP  "PL"    /*  looping construct        */
#define HIER_PROC_FOR   "LF"    /*  for loop with condition  */
#define HIER_PROC_WHILE "LW"    /*  while loop with cond.    */
#define HIER_PROC_NEXT  "LN"    /*  loop 'next' statement    */
#define HIER_PROC_EXIT  "LE"    /*  loop 'exit' statement    */

#define HIER_PROC_WAIT_COND "WC" /*  a wait with a contitional  */
#define HIER_PROC_WAIT_UN   "WU" /*  a wait with an until  */

#define FLAT_SIG        "FS"    /*  definition of signals  */
#define FLAT_GATE       "FG"    /*  a 'gate' */
#define FLAT_PROC       "FP"    /*  a process statement  */

#define IVF_OPEN_CHAR   '{'
#define IVF_CLOSE_CHAR  '}'

#define IVF_OPEN_STR    "{"
#define IVF_CLOSE_STR   "}"

/* Added for SPAR, 25-3-92 <stf> see `ivf_proc_def' in "parse.c" */   
#define FLAT_PROC_ICON_SIZE 		"FPIS" 
#define FLAT_PROC_PIN_POSITIONS 	"FPPP"

/*
** VHDL token declarations
*/
#define TOK_AFTER  "AFTER"
#define TOK_ELSE   "ELSE"
#define TOK_WHEN   "WHEN"
#define TOK_NOT    "NOT"
#define TOK_ASSMT  "<="
#define TOK_VAR_ASSMT ":="
#define TOK_IN     "IN"
#define TOK_OUT    "OUT"
#define TOK_NULL   ""
#define TOK_SELECT "SELECT"
#define TOK_WITH   "WITH"
#define TOK_COMMA  ","
#define TOK_BAR    "|"
#define TOK_TO     "TO"
#define TOK_DOWNTO "DOWNTO"
#define TOK_GUARDED "GUARDED"
#define TOK_RISING  "RISING"
#define TOK_FALLING "FALLING"

/* 'gate' type definitions 
** 
**  ADDITIONS TO THIS LIST MUST BE REFLECTED IN vcomp/proc.h !!
 */
#define GATE_AND        0x01
#define GATE_OR         0x02
#define GATE_NAND       0x03
#define GATE_NOR        0x04
#define GATE_XOR        0x05
#define GATE_NOT        0x06
#define GATE_NULL       0x07
#define GATE_COND       0x08
#define GATE_SEL        0x09
#define GATE_PLUS       0x0a
#define GATE_MINUS      0x0b
#define GATE_CONCAT     0x0c
#define GATE_EQ         0x0d
#define GATE_NE         0x0e
#define GATE_LT         0x0f
#define GATE_LE         0x10
#define GATE_GT         0x11
#define GATE_GE         0x12
#define GATE_FOR_UP     0x13
#define GATE_FOR_DOWN   0x14
#define GATE_WHILE      0x15
#define GATE_BAG        0x16
#define GATE_RISING     0x17
#define GATE_FALLING    0x18

#define GATE_AND_STR    "AND"
#define GATE_OR_STR     "OR"
#define GATE_NAND_STR   "NAND"
#define GATE_NOR_STR    "NOR"
#define GATE_XOR_STR    "XOR"
#define GATE_NOT_STR    "NOT"
#define GATE_INVNOT_STR "INVNOT"
#define GATE_NULL_STR   "NL_GATE"
#define GATE_COND_STR   "COND"
#define GATE_SEL_STR    "SELECT"
#define GATE_CONCAT_STR "CONCAT"
#define GATE_PLUS_STR   "PLUS"
#define GATE_MINUS_STR  "MINUS"
#define GATE_EQ_STR     "EQ"
#define GATE_NE_STR     "NE"
#define GATE_LT_STR     "LT"
#define GATE_LE_STR     "LE"
#define GATE_GT_STR     "GT"
#define GATE_GE_STR     "GE"
#define GATE_FOR_UP_STR    "TO"
#define GATE_FOR_DOWN_STR  "DOWNTO"
#define GATE_WHILE_STR  "WHILE"
#define GATE_BAG_STR    ";"     /*  a bag is just a list of items  */
#define GATE_RISE_STR   "RISING"
#define GATE_FALL_STR   "FALLING"

/*  gate delay/guard definitions  */
#define NO_DELAY 0

