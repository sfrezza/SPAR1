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

--  Title: 	test file for frezza's place and route
--  Created:	Wed Mar 13 15:18:18 1991
--  Author: 	Dr. Steven Levitan	<steve@europa.ee.pitt.edu>
--
--  Description: 1 of 16 boolean function generator
--               application example for SN74AS850 from p 2-198
--               from the "LSI Logic Data Book" by Texas Instruments, 1986
--  
--  Modification History:
--
-- ************************************************************************

entity as850 is  --  
    port(d : in bit_vector(15 downto 0);
    	    s	: in bit_vector(3 downto 0);
    	    g, gy, gw, clock	: in bit;
    	    y,w : out bit);
end as850;
architecture beh of as850 is
begin
 process
  begin
 end process;
end beh;

entity als138 is  --  
    port (g1,g2a,g2b,a,b,c	: in bit;
	      dout	: out bit_vector (7 downto 0));
end als138;
architecture beh of als138 is
begin
    process
     begin
    end process;
end beh;
--

entity as163 is  --  
    port(clr,m1,m2,g3,g4,clock,a,b,c,d	: in bit;
	      rc0	: out bit;
	      q : out bit_vector(3 downto 0));
end as163;
architecture beh of as163 is
begin
 process
 begin
 end process;
end beh;
------------------------------------------------------------------
entity fngen is  --  
--
    port (g2a,g2b,enable,disable,clear,load,count,clock,a,b,c,d	: in bit;
	  y,w	: out bit);
end fngen;
--
architecture try1 of fngen is
--  junk
--  
    signal d1  : bit_vector (15 downto 0);
    signal oct  : bit_vector ( 7 downto 0);
    signal q: bit_vector(3 downto 0);
    signal g,gy,gw,aa,bb,cc,dd,rco : bit;
    signal nenable, ndisable : bit;
--
    component mux
    	port (d	: in bit_vector(15 downto 0);
	      s	: in bit_vector(3 downto 0);
	      g, gy, gw, clock	: in bit;
	      y,w : out bit);
    end component;
    label l1;
    for l1: mux use entity AS850(beh);
--
    component bin_oct
    	port (g1,g2a,g2b,a,b,c	: in bit;
	      dout	: out bit_vector (7 downto 0));
    end component;
    label l2;
    for l2: bin_oct use entity ALS138(beh);
--
--
    component ctr_div
    	port (clr,m1,m2,g3,g4,clock,a,b,c,d	: in bit;
	      rc0 : out bit;
	      q: out bit_vector(3 downto 0));
    end component;
    label l3;
    for l3: ctr_div use entity AS163(beh);
--
--
begin
--
    ndisable <= not(disable);
    nenable <= not(enable);
    l1: mux port map (d1,q,ndisable,enable,nenable,clock,y,w);
    l2: bin_oct port map (disable,g2a,g2b,q(0),q(1),q(2),oct);
    l3: ctr_div port map (clear,load,load,count,disable,clock,a,b,c,d,rco,q);
--
	d1(0) <= oct(0) and oct(2) and oct(5);
	d1(1) <= not(oct(1) and oct(6) and oct(3));
	d1(2) <= oct(3) or oct(4) or oct(5);
	d1(3) <= not(oct(6) or oct(7) or rco);
	d1(4) <= oct(7) or q(2) or q(3);
	d1(5) <= d1(1);
	d1(6) <= d1(0);
	d1(7) <= d1(11);
	d1(8) <= oct(7);
	d1(9) <= d1(6) and d1(5) and rco;
	d1(10) <= q(2);
	d1(11) <= q(0) and q(1) and q(3) and cc;
	d1(12) <= not(aa and q(1) and cc and dd);
	d1(13) <= q(0) or q(1) or q(2) or q(3);
	d1(14) <= not(aa or bb or q(2) or dd);
	d1(15) <= rco;
--
	aa <= not(q(0));
	bb <= not(q(1));
	cc <= not(q(2));
	dd <= not(q(3));
--      	
end try1;

