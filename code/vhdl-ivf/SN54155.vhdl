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

--  Title: 	SN54155 2-line to 4-line decoder
--  Created:	Mon 16 October 1989
--  Author: 	Steve Frezza vlsi	<frezza@jupiter.ee.pitt.edu>
--
--  Description: TI decoder/demultiplexer from 
--               "TTL Data Book for Design Engineers," 1st Ed. p 313
--  
--  Modification History:
--
-- ************************************************************************
--
entity SN54155 is  --  
    port (strobe1G, strobe2G, selectA, selectB, data1C, data2C : in bit;
	  out1Y, out2Y: out bit_vector(3 downto 0));
end SN54155;
--
architecture str of SN54155 is
--  
    signal sA_bar, sB_bar, sA_bar_bar, sB_bar_bar, d1C_bar : bit;
    signal t1, t2 : bit;
--
--
begin
--
    d1C_bar <= not data1C;
    sA_bar <= not selectA;
    sB_bar <= not selectB;
    sA_bar_bar <= not sA_bar;
    sB_bar_bar <= not sB_bar;

    t1 <= strobe1G nor d1C_bar;
    t2 <= strobe2G nor data2C;
    out1Y(0) <= not (t1 and sB_bar and sA_bar);
    out1Y(1) <= not (t1 and sB_bar and sA_bar_bar);
    out1Y(2) <= not (t1 and sB_bar_bar and sA_bar);
    out1Y(3) <= not (t1 and sB_bar_bar and sA_bar_bar);
    out2Y(0) <= not (t2 and sB_bar and sA_bar);
    out2Y(1) <= not (t2 and sB_bar and sA_bar_bar);
    out2Y(2) <= not (t2 and sB_bar_bar and sA_bar);
    out2Y(3) <= not (t2 and sB_bar_bar and sA_bar_bar);
    
end str;


