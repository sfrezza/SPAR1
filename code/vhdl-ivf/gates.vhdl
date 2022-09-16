------------------------------------------------------------
--
--       COPYRIGHT (C) 1993 UNIVERSITY OF PITTSBURGH
--                  ALL RIGHTS RESERVED
--
--        This software is distributed on an as-is basis
--        with no warranty implied or intended.  No author
--        or distributor takes responsibility to anyone 
--        regarding its use of or suitability.
--
--        The software may be distributed and modified 
--        freely for academic and other non-commercial
--        use but may NOT be utilized or included in whole
--        or part within any commercial product.
--
--        This copyright notice must remain on all copies 
--        and modified versions of this software.
--
------------------------------------------------------------
 entity g_3 is
	port (rbar, sbar, tbar: in bit; q, qbar: out bit);
 end g_3;

 architecture g3_struct of g_3 is
 begin
	q <= (sbar or tbar) nand qbar;
	qbar <= rbar nand q;
 end g3_struct;



 entity g_4 is
	port (rbar, sbar, tbar, ubar: in bit; q, qbar: out bit);
 end g_4;

 architecture g4_struct of g_4 is
 begin
	q <= (sbar or tbar) nand qbar;
	qbar <= (rbar or ubar)nand q;
 end g4_struct;



 entity g_4i is
	port (rbar, sbar, tbar, ubar: in bit; q: out bit);
 end g_4i;

 architecture g4_fan_in of g_4i is
        signal t : bit;
 begin
        t <= (sbar and rbar and tbar);
	q <= (t xor ubar);
 end g4_fan_in;
 
 
 
 entity g_4o is
	port ( q1, q2: in bit; rbar, sbar, tbar: out bit);
 end g_4o;

 architecture g4_fan_out of g_4o is
    signal t : bit;
 begin
    t <= (q1 xor q2);
    rbar <= (q2 nand t);
    sbar <= (q1 and t);
    tbar <= not(t);
 end g4_fan_out;
