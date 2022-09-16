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

--  Title: 	Swinkels and Hafer example 3
--  Created:	Mon 1 February, 1991
--  Author: 	Steve Frezza vlsi	<frezza@jupiter.ee.pitt.edu>
--
--  Description: Random logic from TCAD Vol 9 no. 12 1990 pp. 1291, 
--  Swinkels & Hafer "Schematic Generation with an Expert System"
--  
--  Modification History:
--
-- ************************************************************************
--
entity iblock is
    port(ainp, binp, cinp: in bit; w, w1: out bit);
end iblock;
--
architecture gates of iblock is
    signal a, b, c, a1, b1, c1, k, l, m, n : bit;
begin
     a <=      not(ainp)    ;
     b <=      not(binp)    ;
     c <=      not(cinp)    ;
    a1 <=      not(a)       ;
    b1 <=      not(b)       ;
    c1 <=      not(c)       ;
     k <= (a1 AND b1 AND c1);
     l <= (a1 AND b AND c)  ;
     m <= (a AND b1 AND c)  ;
     n <= (a AND b AND c1)  ;
     
     w <= (k OR l OR m OR n);
     w1 <= not(w)           ;
     
end gates;



entity example3 is  --  
    port (ainp, binp, cinp, dinp, einp, finp, ginp, hinp, iinp : in bit;
	  Aout, Bout : out bit);
end example3;
--
architecture hierarchical of example3 is
--  
    signal w, w1, x, x1, y, y1 : bit;
    signal aa, bb, cc, dd, ee, ff, gg, hh : bit;
    
    label I1, I2, I3;                           -- labels for input block usage
    
    component in_block                          -- port spec for input blocks
    	port (ainp, binp, cinp: in bit; w, w1: out bit);
    end component;
    
    for I1, I2, I3 : in_block                   -- entity/architecture to use
    	use entity iblock(gates);
begin
--
    I1: in_block port map
    	(ainp, binp, cinp, w, w1);
    I2: in_block port map
    	(dinp, einp, finp, x, x1);
    I3: in_block port map
    	(ainp, binp, cinp, y, y1);
		
    aa <= (w AND y AND x);
    bb <= (y AND y1 AND x1);
    cc <= (y AND w1 AND x1);
    dd <= (w1 AND y1 AND x);
    ee <= (w1 AND y1 AND x1);
    ff <= (w1 AND y AND x);
    gg <= (y AND w1 AND x);
    hh <= (w AND y AND x1);
    
    aout <= (aa OR bb OR cc OR dd);
    bout <= (ee OR ff OR gg OR hh);
end hierarchical;


architecture literal of example3 is
--  
    signal w, w1, x, x1, y, y1 : bit;
    signal aa, bb, cc, dd, ee, ff, gg, hh : bit;
    signal a, b, c, a1, b1, c1, k, l, m, n : bit;
    signal d, e, f, d1, e1, f1, o, p, q, r : bit;
    signal g, h, i, g1, h1, i1, s, t, u, v : bit;
begin
-- First Input Block (Produces w, w1):
     a <=      not(ainp)    ;
     b <=      not(binp)    ;
     c <=      not(cinp)    ;
    a1 <=      not(a)       ;
    b1 <=      not(b)       ;
    c1 <=      not(c)       ;
     k <= (a1 AND b1 AND c1);
     l <= (a1 AND b AND c)  ;
     m <= (a AND b1 AND c)  ;
     n <= (a AND b AND c1)  ;
     
     w <= (k OR l OR m OR n);
     w1 <= not(w)           ;

-- Second Input Block (Produces x, x1):
     d <=      not(dinp)    ;
     e <=      not(einp)    ;
     f <=      not(finp)    ;
    d1 <=      not(d)       ;
    e1 <=      not(e)       ;
    f1 <=      not(f)       ;
     o <= (d1 AND e1 AND f1);
     p <= (d1 AND e AND f)  ;
     q <= (d AND e1 AND f)  ;
     r <= (d AND e AND f1)  ;
     
     x <= (o OR p OR q OR r);
     x1 <= not(x)           ;

-- Third Input Block (Produces y, y1):
     g <=      not(ginp)    ;
     h <=      not(hinp)    ;
     i <=      not(iinp)    ;
    g1 <=      not(g)       ;
    h1 <=      not(h)       ;
    i1 <=      not(i)       ;
     s <= (g1 AND h1 AND i1);
     t <= (g1 AND h AND i)  ;
     u <= (g AND h1 AND i)  ;
     v <= (g AND h AND i1)  ;
     
     y <= (s OR t OR u OR v);
     y1 <= not(y)           ;
		
    aa <= (w AND y AND x);
    bb <= (y AND y1 AND x1);
    cc <= (y AND w1 AND x1);
    dd <= (w1 AND y1 AND x);
    ee <= (w1 AND y1 AND x1);
    ff <= (w1 AND y AND x);
    gg <= (y AND w1 AND x);
    hh <= (w AND y AND x1);
    
    aout <= (aa OR bb OR cc OR dd);
    bout <= (ee OR ff OR gg OR hh);
end literal;
