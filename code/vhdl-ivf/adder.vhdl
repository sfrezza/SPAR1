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

--  Title: 	adder.vhdl
--  Created:	Fri Apr 21 14:17:55 1989
--  Author: 	Dr. Steven Levitan vlsi	<steve@europa>
--  Modified:   Stephen Frezza <frezza@ee.pitt.edu>
--  Description:
--  This is a collection of different 8-bit & 4-bit
--  unsigned binary adders for use in benchmarking.
--  These were developed by Levitan and Martello.
--  
--  Modification History:
--  4/89 collection of all our adders into one file -- spl
--  2/91 modifications to create 4-bit adders -- stf
--
-- ************************************************************************
--
--
entity half_adder is -- for one bit
    port (x, y: in bit; s, c: out bit);
end half_adder;
--
entity full_adder is -- for one bit
    port (x, y, c_in: in bit; sum, c_out: out bit);
end full_adder;
--
entity adder is
	port (arg1	:in bit_vector(7 downto 0);
	      arg2	:in bit_vector(7 downto 0);
	      carry_in	:in bit;
	      result	:out bit_vector(7 downto 0);
	      carry_out	:out bit);
end adder;
--
entity adder4 is
	port (arg1	:in bit_vector(3 downto 0);
	      arg2	:in bit_vector(3 downto 0);
	      carry_in	:in bit;
	      result	:out bit_vector(3 downto 0);
	      carry_out	:out bit);
end adder4;
--
------------------------------------------------------------------------
--
architecture test0 of adder is
	signal cw, cx	:bit_vector(7 downto 0);
begin
	cw(0) <= carry_in;
	cw(7 downto 1) <= cx(6 downto 0);
	cx <= (arg1 and arg2) or (arg1 and cw) or (arg2 and cw);
	result <= arg1 xor arg2 xor cw;
	carry_out <= cx(7);
end test0;
--
------------------------------------------------------------------------
--
architecture test0b4 of adder4 is
	signal cw, cx	:bit_vector(3 downto 0);
begin
	cw(0) <= carry_in;
	cw(3 downto 1) <= cx(2 downto 0);
	cx <= (arg1 and arg2) or (arg1 and cw) or (arg2 and cw);
	result <= arg1 xor arg2 xor cw;
	carry_out <= cx(3);
end test0b4;
--
------------------------------------------------------------------------
--
architecture test1 of adder is
                signal G,P,CO,CI,T:  Bitvec;
begin
    	-- generate terms
        G(7 downto 0) <= Arg1(7 downto 0) and Arg2(7 downto 0);
	-- propagate terms
        P(7 downto 0) <= Arg1(7 downto 0) or Arg2(7 downto 0);

	CI(7 downto 0) <= CO(6 downto 0) & carry_in;
        CO(7 downto 0) <= G(7 downto 0) or (P(7 downto 0) and CI(7 downto 0));
        T(7 downto 0) <= ((Arg1(7 downto 0) and not Arg2(7 downto 0)) or
			  (not Arg1(7 downto 0) and Arg2(7 downto 0)));
        Result(7 downto 0) <= ((T(7 downto 0) and not CI(7 downto 0)) or
			  (not T(7 downto 0) and CI(7 downto 0)));
	carry_out <= co(7);
end test1;
--
------------------------------------------------------------------------
------------------------------------------------------------------------
--
architecture test1b4 of adder4 is
                signal G,P,CO,CI,T:  Bitvec;
begin
    	-- generate terms
        G(3 downto 0) <= Arg1(3 downto 0) and Arg2(3 downto 0);
	-- propagate terms
        P(3 downto 0) <= Arg1(3 downto 0) or Arg2(3 downto 0);

	CI(3 downto 0) <= CO(2 downto 0) & carry_in;
        CO(3 downto 0) <= G(3 downto 0) or (P(3 downto 0) and CI(3 downto 0));
        T(3 downto 0) <= ((Arg1(3 downto 0) and not Arg2(3 downto 0)) or
			  (not Arg1(3 downto 0) and Arg2(3 downto 0)));
        Result(3 downto 0) <= ((T(3 downto 0) and not CI(3 downto 0)) or
			  (not T(3 downto 0) and CI(3 downto 0)));
	carry_out <= co(3);
end test1b4;
--
------------------------------------------------------------------------
--
architecture test2 of adder is
                signal G,P,CI:  Bitvec;
begin
        G(7 downto 0) <= Arg1(7 downto 0) and Arg2(7 downto 0); -- generate terms
        P(7 downto 0) <= Arg1(7 downto 0) or Arg2(7 downto 0);  -- propagate terms
	CI(0) <= carry_in;
	CI(1) <= G(0) or (carry_in and P(0));
	CI(2) <= G(1) or (G(0) and P(1))
	    	      or (carry_in and P(0) and P(1));
	CI(3) <= G(2) or (G(1) and P(2))
		      or (G(0) and P(1) and P(2))
	    	      or (carry_in and P(0) and P(1) and P(2));
        CI(4) <= G(3) or (G(2) and P(3))
		      or (G(1) and P(2) and P(3))
		      or (G(0) and P(1) and P(2) and P(3))
	    	      or (carry_in and P(0) and P(1) and P(2) and P(3));
	CI(5) <= G(4) or (G(3) and P(4))
                      or (G(2) and P(3) and P(4))
		      or (G(1) and P(2) and P(3) and P(4))
		      or (G(0) and P(1) and P(2) and P(3) and P(4))
	    	      or (carry_in and P(0) and P(1) and P(2) and P(3) 
		      	and P(4));
	CI(6) <= G(5) or (G(4) and P(5))
		      or (G(3) and P(4) and P(5))
                      or (G(2) and P(3) and P(4) and P(5))
		      or (G(1) and P(2) and P(3) and P(4) and P(5))
		      or (G(0) and P(1) and P(2) and P(3) and P(4) and P(5))
	    	      or (carry_in and P(0) and P(1) and P(2) and P(3) 
		      	and P(4) and P(5));
	 CI(7) <= G(6) or (G(5) and P(6))
		      or (G(4) and P(5) and P(6))
		      or (G(3) and P(4) and P(5) and P(6))
                      or (G(2) and P(3) and P(4) and P(5) and P(6))
		      or (G(1) and P(2) and P(3) and P(4) and P(5) and P(6))
	              or (G(0) and P(1) and P(2) and P(3) and P(4) and P(5) 
		      	and P(6))
	       	      or (carry_in and P(0) and P(1) and P(2) and P(3) 
		      	and P(4) and P(5) and P(6));
	Carry_out <= G(7) or (G(6) and P(7))
		      or (G(5) and P(6) and P(7))
		      or (G(4) and P(5) and P(6) and P(7))
		      or (G(3) and P(4) and P(5) and P(6) and P(7))
                      or (G(2) and P(3) and P(4) and P(5) and P(6) and P(7))
		      or (G(1) and P(2) and P(3) and P(4) and P(5) and P(6)
		      	and P(7))
	              or (G(0) and P(1) and P(2) and P(3) and P(4) and P(5)
		      	and P(6) and P(7))
	       	      or (carry_in and P(0) and P(1) and P(2) and P(3) 
		      	and P(4) and P(5) and P(6) and P(7));

        Result(7 downto 0) <= Arg1(7 downto 0) xor Arg2(7 downto 0)
	    	    	    	xor CI(7 downto 0); 
end test2;
--
------------------------------------------------------------------------
--
architecture test2b4 of adder4 is
                signal G,P,CI:  Bitvec;
begin
        G(3 downto 0) <= Arg1(3 downto 0) and Arg2(3 downto 0); -- generate terms
        P(3 downto 0) <= Arg1(3 downto 0) or Arg2(3 downto 0);  -- propagate terms
	CI(0) <= carry_in;
	CI(1) <= G(0) or (carry_in and P(0));
	CI(2) <= G(1) or (G(0) and P(1))
	    	      or (carry_in and P(0) and P(1));
	CI(3) <= G(2) or (G(1) and P(2))
		      or (G(0) and P(1) and P(2))
	    	      or (carry_in and P(0) and P(1) and P(2));
	Carry_out <= G(3) or (G(2) and P(3))
		      or (G(1) and P(2) and P(3))
		      or (G(0) and P(1) and P(2) and P(3))
	       	      or (carry_in and P(0) and P(1) and P(2) and P(3));

        Result(3 downto 0) <= Arg1(3 downto 0) xor Arg2(3 downto 0)
	    	    	    	xor CI(3 downto 0); 
end test2b4;
--
------------------------------------------------------------------------
--
architecture test2A of adder is
--  Carry lookahead in two groups of four bits.
--  
    signal G,P,CI	: bit_vector (7 downto 0);
--
begin
--
        G <= Arg1 and Arg2; -- generate terms
        P <= Arg1 or Arg2;  -- propagate terms
	CI(0) <= carry_in;
	CI(1) <= G(0) or (carry_in and P(0));
	CI(2) <= G(1) or (G(0) and P(1))
	    	      or (carry_in and P(0) and P(1));
	CI(3) <= G(2) or (G(1) and P(2))
		      or (G(0) and P(1) and P(2))
		      or (carry_in and P(0) and P(1) and P(2));
	CI(4) <= G(3) or (G(2) and P(3))  -- carry out of first block
		      or (G(1) and P(2) and P(3))
		      or (G(0) and P(1) and P(2) and P(3))
		      or (carry_in and P(0) and P(1) and P(2) and P(3));
      	CI(5) <= G(4) or (CI(4) and P(4));
	CI(6) <= G(5) or (G(4) and P(5))
		      or (CI(4) and P(4) and P(5));
	CI(7) <= G(6) or (G(5) and P(6))
		      or (G(4) and P(5) and P(6))
		      or (CI(4) and P(4) and P(5) and P(6));
	Carry_out <= G(7) or (G(6) and P(7))
		      or (G(5) and P(6) and P(7))
		      or (G(4) and P(5) and P(6) and P(7))
		      or (CI(4) and P(4) and P(5) and P(6) and P(7));

        Result <= Arg1 xor Arg2 xor CI; 
end test2A;
--
------------------------------------------------------------------------
-- Test 3 uses two types of components a full adder based on the ibm adder
-- and a full adder bult from half-adders.
-- Four of each are used in the adder
------------------------------------------------------------------------
--
architecture ibm of full_adder is
    signal yc, xc, xy, xyc: bit;
begin

    --  the four internal and gates
    yc <= y and c_in;
    xc <= x and c_in;
    xy <= x and y;
    xyc <= x and Y and c_in;
    
    -- the 'sum out' generator
    sum <= (x or y or c_in) and (xyc or not(c_out));

    -- the 'carry out' generator
    c_out <= yc or xc or XY;

end ibm;
--
architecture classic of half_adder is
--
--  the internal specification of the half-adder
--  page 196-197 of the text "Digital Computer Fundamentals", 
--  Sixth Edition, by Thomas C. Bartee, published by McGraw-Hill.
--
begin

    --  generate the sum output
    s <= ((not(x) and y) or (x and not(y)));

    --  generate the carry output
    c <= x and y;

end classic;
--
architecture classic of full_adder is
--
--  the internal architecture for a classical
--  full-adder as described in text, pp. 197-199
--
    --  the local, internal signals
    signal int_c1, int_c2, int_s1: bit;

    --  the rest of the information in this 
    --  description is used to uniquely define 
    --  the component instantiations below

    --  define the labels used for the components
    label h1, h2;

    --  define the way the port list appears
    component hlf_add 
        port (x, y: in bit; s, c: out bit);
    end component;

    --  define what entity(architecture) to use
    --  for hlf_add at labels h1 and h2
    for h1, h2: hlf_add 
        use entity half_adder(classic);
begin

    --  the 'top' half-adder in Figure 5.4,
    --  page 199 in the text
    h1: hlf_add port map (x, y, int_s1, int_c1);

    --  the 'bottom' half-adder in Figure 5.4,
    --  page 199 in the text
    h2: hlf_add port map (int_s1, c_in, sum, int_c2);

    --  the generation of the external carry for
    --  the full-adder
    c_out <= int_c1 or int_c2;

end classic;

------------------------------------------------------------------------------------
architecture test3 of adder is
--  construct an 8-bit adder from the full-
--  adders described above;  note that we
--  utilize two different architectures
--  for the full-adders in the 8-bit adder
--
    --  the internal carry bits which cascade
    --  from one full-adder to the next
    signal carry: bit_vector(7 downto 0);
    --  define the labels for the 
    --  full-adders
    label f1, f2, f3, f4, f5, f6, f7, f8;
    --  define the way the port list appears
    --  NOTE:  this is redundant for us, but MUST
    --         match the port list for the
    --         entity defined above
    component fl_add1
        port (x, y, c_in: in bit; sum, c_out: out bit);
    end component;
    component fl_add2
        port (x, y, c_in: in bit; sum, c_out: out bit);
    end component;
    --  define what entity(architecture) to use
    --  for fl_add at labels f1, f3, f5, and f7
    for f1, f3, f5, f7: 
        fl_add1 use entity full_adder(classic);    
    --  define what entity(architecture) to use
    --  for fl_add2 at labels f2, f4, f6, and f8
    for f2, f4, f6, f8: 
        fl_add2 use entity full_adder(ibm);
begin
    --
    --  create the 8-bit adder by cascading the full-
    --  adders, low order bit to high order bit
    --
    f1: fl_add1 port map 
        (arg1(0), arg2(0), carry_in, result(0), carry(0));
    f2: fl_add2 port map 
        (arg1(1), arg2(1), carry(0), result(1), carry(1));
    f3: fl_add1 port map 
        (arg1(2), arg2(2), carry(1), result(2), carry(2));
    f4: fl_add2 port map 
        (arg1(3), arg2(3), carry(2), result(3), carry(3));
    f5: fl_add1 port map 
        (arg1(4), arg2(4), carry(3), result(4), carry(4));
    f6: fl_add2 port map 
        (arg1(5), arg2(5), carry(4), result(5), carry(5));
    f7: fl_add1 port map 
        (arg1(6), arg2(6), carry(5), result(6), carry(6));
    f8: fl_add2 port map 
        (arg1(7), arg2(7), carry(6), result(7), carry_out);
end test3;
------------------------------------------------------------------------------------
architecture test3b4 of adder4 is
--  construct an 4-bit adder from the full-
--  adders described above;  note that we
--  utilize two different architectures
--  for the full-adders in the 4-bit adder
--
    --  the internal carry bits which cascade
    --  from one full-adder to the next
    signal carry: bit_vector(3 downto 0);
    --  define the labels for the 
    --  full-adders
    label f1, f2, f3, f4, f5, f6, f7, f8;
    --  define the way the port list appears
    --  NOTE:  this is redundant for us, but MUST
    --         match the port list for the
    --         entity defined above
    component fl_add1
        port (x, y, c_in: in bit; sum, c_out: out bit);
    end component;
    component fl_add2 
        port (x, y, c_in: in bit; sum, c_out: out bit);
    end component;
    --  define what entity(architecture) to use
    --  for fl_add1 at labels f1, and f3
    for f1, f3:
        fl_add1 use entity full_adder(classic);    
    --  define what entity(architecture) to use
    --  for fl_add at labels f2, and f4
    for f2, f4:
        fl_add2 use entity full_adder(ibm);
begin
    --
    --  create the 4-bit adder by cascading the full-
    --  adders, low order bit to high order bit
    --
    f1: fl_add1 port map 
        (arg1(0), arg2(0), carry_in, result(0), carry(0));
    f2: fl_add2 port map 
        (arg1(1), arg2(1), carry(0), result(1), carry(1));
    f3: fl_add1 port map 
        (arg1(2), arg2(2), carry(1), result(2), carry(2));
    f4: fl_add2 port map 
        (arg1(3), arg2(3), carry(2), result(3), carry_out);
end test3b4;
-------------------- end of file ----------------------------------------
