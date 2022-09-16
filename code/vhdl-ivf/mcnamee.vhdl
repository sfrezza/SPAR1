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

--  Title: 	McNamme Random Logic
--  Created:	Mon 12 February, 1990
--  Author: 	Steve Frezza vlsi	<frezza@jupiter.ee.pitt.edu>
--
--  Description: Random logic from ICCAD '90 pp. 333, Lee & McNamee "Structure Optimization
--               in Logic Schematic Generation"
--  
--  Modification History:
--
-- ************************************************************************
--
entity random is  --  
    port (inp : in bit_vector(4 downto 0);
	  outp: out bit_vector(1 downto 0));
end random;
--
architecture str of random is
--  
    signal not1, not2, or1, or2, or3, and1, and2 : bit;
--
--
begin
--
    not1 <= not (inp(2));
    and1 <= not1 and inp(1);
    or1 <= and1 or inp(0);
    and2 <= inp(3) and inp(4);
    or2 <= not1 or and2;
    not2 <= not (or2);
    or3 <= inp(3) or inp(4);
    outp(0) <= not2 and or1;
    outp(1) <= or1 and or3;
    
end str;

----------------------------------------------------------------------
-- example used in figures 4 & 5 of Chun, et al. (Orig McNamee paper)
entity synch is  --  
    port (r, s1, s2, c, m: in bit;
	  y, ynot: out bit);
end synch;
--
architecture str of synch is
--  
    signal g1, g2, g3, g4, g5, g6, g8, g9 : bit;
--
--
begin
--
    ynot <= c nand g6;
    g1 <= (g2 nand r);
    g2 <= (g1 and s1 and s2);
    g3 <= not(c);
    g4 <= (g2 and g3 and g9);
    g5 <= (g9 and g2 and g6);
    g6 <= (g4 and g5 and ynot);
    g8 <= (ynot nand g9);
    g9 <= (g8 and g2 and m);
    y <= not(ynot);
end str;

----------------------------------------------------------------------
-- example used in figure 7 of Chun, et al. (Orig McNamee paper)
entity samp is  --  
    port (k1, k2, k4: in bit; f : out bit);
end samp;
--
architecture str of samp is
--  
    signal dev1, dev2, dev3, dev4 : bit;
--
--
begin
--
    dev1 <= not(k1);
    dev2 <= not(k4);
    dev3 <= (dev1 and k2 and k4);
    dev4 <= (dev2 and k1);
    f <= dev3 and dev4;
end str;

----------------------------------------------------------------------
entity cc is  --  
    port (a, b, c, d: in bit;
	  e, f, g: out bit);
end cc;
--
architecture str of cc is
--  
    signal q, qbar, p, pbar, r, rbar, t1, t2 : bit;
--
--
begin
--
	q <= a nor qbar;    
	qbar <= b nor q; 
	t1 <= q after 3ns;
	pbar <= not(p xor c);
	p <= not(t1 xor pbar);
	e <= p after 3ns;
	
	rbar <= (qbar and r);
	r <= (d and rbar);
	f <= r;
	g <= rbar;
end str;

----------------------------------------------------------------------
-- example used in figure 6e of Lee, et al. (2nd McNamee paper)
entity opt is  --  
    port (a, b, c, d, e: in bit; f, g : out bit);
end opt;
--
architecture str of opt is
--  
    signal n1, n2, a1, a2, o1, o2, o3 : bit;
--
--
begin
--
    n1 <= not(c);
    n2 <= not(o2);
    a2 <= d and e;
    a1 <= n1 and b;
    o1 <= a1 or a;
    o2 <= a2 or n1;
    o3 <= d or e;
    f <= n2 and o1;
    g <= o1 and o3;
end str;

----------------------------------------------------------------------
--  also from Chun, et al.
----------------------------------------------------------------------
entity fig8 is  
    port (I, SH, DI, CK1, CK2 : in bit;
	  IO : out bit);
end fig8;
--
architecture str of fig8 is
--  
    signal dev1, dev2, dev3, dev4, dev5, dev6, dev7, dev8 : bit;
--
--
begin
--
    dev1 <= NOT(DI);
    dev2 <= NOT(I);
    dev3 <= dev1 AND CK1;
    dev4 <= DI AND CK1;
    dev5 <= dev2 AND SH;
    dev6 <= I AND SH;
    dev7 <= dev5 NOR dev3;
    dev8 <= dev6 NOR dev4;
    IO   <= (CK2 AND dev7 AND dev8);
end str;

----------------------------------------------------------------------


