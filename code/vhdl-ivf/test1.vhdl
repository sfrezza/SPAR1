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

--  Title: 	test of structures for placement
--  Created:	Wed Aug  9 19:28:16 1989
--  Author: 	Dr. Steven Levitan vlsi	<steve@europa>
--
--  Description:
--  
--  Modification History:
--
-- ************************************************************************
--
entity test1 is  --  just some gates
    port (in1, in2, in3 : in bit;
	  out1, out2: out bit);
end test1;
--
architecture ring of test1 is
--  ring
--  
    signal a, b, c, d, e, f, g	: bit;
--
--
begin
--
--    out1 <= not(a);
    a <= not(b);
    b <= not(c);
    c <= not(d);
    d <= not(e);
    e <= not(f);
    f <= not(g);
    g <= not(a);
end ring;

architecture rs of test1 is
--  ring
--  
    signal a, b, c, d, e, f, g	: bit;
--
--
begin
--
    a <= (in1 and in2) nor b;
    b <= (in1 and in3) nor a;
    out1 <= (in1 or a) nand out2;
    out2 <= (in1 or b) nand out1;
end rs;
