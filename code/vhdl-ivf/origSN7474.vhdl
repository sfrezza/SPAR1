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

-- 7474 rising edge triggered D ff
-- S. Levitan - 11/88 picalab
entity SN7474 is
        port (nclr, nset, clock, d : in bit; q, qbar : out bit);
end SN7474;
--
architecture gates of SN7474 is
        signal x, y, z, w : bit;
begin
        x <=    not (d and nclr and y) after 3ns;
        y <=    not (clock and x and z) after 3ns;
        z <=    not (clock and nclr and w) after 3ns;
        w <=    not (z and x and nset) after 3ns;
        q <=    not (nset and z and qbar) after 3ns;
        qbar <= not(y and nclr and q) after 3ns;
end gates;

architecture gates1 of SN7474 is
        signal x, y, z, w : bit;
begin
        x <=    not (d and nclr and y)		after 3ns;
        y <=    not (clock and x and z) 	after 3ns;
        z <=    not (clock and nclr and w)	after 3ns;
        w <=    z nand x 			after 3ns;
        q <=    z nand qbar 			after 3ns;
        qbar <= not(y and nclr and q) 		after 3ns;
end gates;

architecture gates2 of SN7474 is
        signal x, y, z, w : bit;
begin
        x <=    d nand y        ;
        y <=    not (clock and x and z) ;
        z <=    clock nand w    ;
        w <=    z nand x        ;
        q <=    z nand qbar     ;
        qbar <= y nand q        ;
end gates2;

architecture gates3 of SN7474 is
        signal x, y, z, w : bit;
begin
        x <=    d nand y        ;
        y <=    clock nand (not w) ;
        z <=    clock nand w    ;
        w <=    z nand x        ;
        q <=    z nand qbar     ;
        qbar <= y nand q        ;
end gates2;
