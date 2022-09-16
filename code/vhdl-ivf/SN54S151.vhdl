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

--  Title: 	SN54S151 8x3 Multiplexer
--  Created:	Thur 19 October 1989
--  Author: 	Steve Frezza vlsi	<frezza@jupiter.ee.pitt.edu>
--
--  Description: TI decoder/demultiplexer from "TTL Data Book for Design Engineers," 1st Ed. p 295
--  
--  Modification History:
--
-- ************************************************************************
--
entity SN54S151 is  --  
    port (strobe, A, B, C : in bit;
    	  D : in bit_vector(7 downto 0);
	  outY, outW: out bit);
end SN54S151;
--
architecture str of SN54S151 is
--  
    signal strobe_bar, A_bar, B_bar, C_Bar, A_bar_bar, B_bar_bar, C_bar_bar : bit;
    signal t : bit_vector(7 downto 0);
--
--
begin
--
     strobe_bar <= not strobe;
     A_bar <= not A;
     B_bar <= not B;
     C_bar <= not C;
     A_bar_bar <= not  A_bar;
     B_bar_bar <= not  B_bar;
     C_bar_bar <= not  C_bar;

     t(0) <= (D(0) and A_bar     and B_bar     and C_bar     and strobe_bar);
     t(1) <= (D(1) and A_bar_bar and B_bar     and C_bar     and strobe_bar);
     t(2) <= (D(2) and A_bar     and B_bar_bar and C_bar     and strobe_bar);
     t(3) <= (D(3) and A_bar_bar and B_bar_bar and C_bar     and strobe_bar);
     t(4) <= (D(4) and A_bar     and B_bar     and C_bar_bar and strobe_bar);
     t(5) <= (D(5) and A_bar_bar and B_bar     and C_bar_bar and strobe_bar);
     t(6) <= (D(6) and A_bar     and B_bar_bar and C_bar_bar and strobe_bar);
     t(7) <= (D(7) and A_bar_bar and B_bar_bar and C_bar_bar and strobe_bar);

     outY <= not (t(0) or t(1) or t(2) or t(3) or t(4) or t(5) or t(6) or t(7));
     outW <= not outY;
     
end  str;


