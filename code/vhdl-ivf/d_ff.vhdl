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

 entity rs_ff is
	port (rbar, sbar: in bit; q, qbar: out bit);
 end rs_ff;

 architecture rs_struct of rs_ff is
 begin
	q <= sbar nand qbar;
	qbar <= rbar nand q;
 end rs_struct;


 entity d_ff is
	port (d, c: in bit; q1, qbar1: out bit);
 end d_ff;

 architecture d_struct of d_ff is
	signal dbar, cbar: bit;
	signal rbar0, sbar0, q0, qbar0: bit;
	signal rbar1, sbar1: bit;
	label rs_0, rs_1;
	component rs_ff
		port (rbar, sbar: in bit; q, qbar: out bit);
	end component;
	for rs_0, rs_1: rs_ff
		use entity rs_ff(rs_struct);
 begin
	dbar <= not d;
	rbar0 <= dbar nand c;
	sbar0 <= d nand c;
	cbar <= not c;
	rs_0: rs_ff port map (rbar0, sbar0, q0, qbar0);
	rbar1 <= qbar0 nand cbar;
	sbar1 <= q0 nand cbar;
	rs_1: rs_ff port map (rbar1, sbar1, q1, qbar1);
 end d_struct;





 entity jk_ms_ff is
	port (j, k, c: in bit; q, qbar: out bit);
 end jk_ms_ff;

 architecture jk_struct of jk_ms_ff is
	signal cbar: bit;
        signal int0, int1, int2, int3, int4, int5: bit;
	label rs_0, rs_1;
	component rs_ff
		port (rbar, sbar: in bit; q, qbar: out bit);
	end component;
	for rs_0, rs_1: rs_ff
		use entity rs_ff(rs_struct);
 begin
	cbar <= not c;
	int0 <= not(qbar AND j AND c);
	int3 <= not(q AND k AND c);
	rs_0: rs_ff port map (int0, int3, int1, int4);
	
	rs_1: rs_ff port map (int2, int5, q, qbar);
	int2 <= int1 nand cbar;
	int5 <= int4 nand cbar;

 end jk_struct;

