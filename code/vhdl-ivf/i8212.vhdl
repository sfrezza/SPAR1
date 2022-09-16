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
-- 
------------------------------------------------------------------------
--      RS FLIP-FLOP                                                  --
--      S. Levitan -- 10/88 Picalab Univ. Pittsburgh                  --
------------------------------------------------------------------------
entity RS is
        port (reset, set: in bit; q, qbar: out bit);
end RS;
--
architecture rs_struct of RS is
begin
	q <= reset nor qbar after 3ns;
	qbar <= set nor q after 3ns;
end rs_struct;
--
------------------------------------------------------------------------
--      D FLIP-FLOP Low edge clock                                    --
--      S. Levitan -- 10/88 Picalab Univ. Pittsburgh                  --
------------------------------------------------------------------------
entity DFF is
	port (NSET, NCLR, D, C: in BIT; Q, QB: out BIT);
end DFF;
------------------------------------------------------------------------
--
------------------------------------------------------------------------
--      MODEL FLIP-FLOP USING STRUCTURE COMPONENTS    --
--      S. Levitan -- 10/88 Picalab Univ. Pittsburgh                  --
------------------------------------------------------------------------
architecture dff_struct of DFF is
	signal ms, mr, mq, mqb, ss, sr: bit;
	label rs0, rs1;
	component rs_ff
		port (r, s: in bit; q, qb: out bit);
	end component;
	for rs0, rs1: rs_ff
		use entity RS(rs_struct);
begin
	ms <= (d nand c) nand nset;
	mr <= (not d nand c) nand nclr;
	rs0: rs_ff port map (mr, ms, mq, mqb);
	sr <= (mqb nand not c) nand nclr;
	ss <= (mq nand not c) nand nset;
	rs1: rs_ff port map (sr, ss, q, qb);
end dff_struct;
------------------------------------------------------------------
--
-- taken from "chip-level modeling with vhdl"
-- james r. armstrong, prentice hall, pp.122
entity I8212 is
        port(DI: in bit_vector(7 downto 0);
                DO: out bit_vector(7 downto 0);
                NDS1, DS2, MD, STB, NCLR: in BIT;
                NINT: out BIT);
end I8212;
------------------------------------------------------------------
architecture beh of I8212 is
        label b, SERVRQ;
        signal S0, S1, S2, S3: BIT;
        signal SRQ: BIT;
        signal Q, Q1, Q2: bit_vector(7 downto 0);
-- GDEL = 30ns
-- FFDEL = 10ns
-- BUFDEL = 20ns
begin
     b: block
     begin -- no guards
        Q1(7 downto 0)  <= DI(7 downto 0) after 10ns when (S1 and NCLR)
                          else Q1(7 downto 0);
        Q2(7 downto 0) <= b"00000000" after 10ns when (not NCLR)
                          else Q2(7 downto 0);
        DO(7 downto 0) <= Q(7 downto 0) after 20ns when (S3) else b"00000000";
     end block b;

     S0 <= not NDS1 and DS2 after 30ns;
     S1 <= (S0 and MD) or (STB and not MD) after 60ns;
     S2 <= S0 nor not NCLR after 30ns;
     S3 <= S0 or MD after 30ns;

     SERVRQ: process(S2, STB)
     variable STB_old: bit := '0';
     begin
        if (S2 = '0') then
                SRQ <= '1' after 10ns;
        elsif (S2 = '1') and (STB /= STB_old) and (STB = '0') then
                SRQ <= '0' after 10ns;
        else SRQ <= SRQ;
        end if;
        STB_old := STB;
     end process SERVRQ;

     NINT <= not SRQ nor S0 after 30ns;
     Q(7 downto 0) <= Q1(7 downto 0) after 11ns when (S1 and NCLR)
                      else Q2(7 downto 0) when (not NCLR)
                      else Q(7 downto 0);
end beh;
------------------------------------------------------------------
--
------------------------------------------------------------------
architecture data of I8212 is
        label SERVRQ;
        component D_FF
		port (NSET, NCLR, D, C: in BIT; Q, QB: out BIT);
	end component;
	for SERVRQ: D_FF
		use entity DFF(dff_struct);
        signal S0, S1, S2, S3: BIT;
        signal SRQ, SRQB: BIT;
        signal Q: bit_vector(7 downto 0);
--
-- GDEL = 30ns
-- FFDEL = 10ns
-- BUFDEL = 20ns
begin
     SERVRQ: D_FF port map(S2, '1', '0', STB, SRQ, SRQB);
     S0 <= not NDS1 and DS2 after 30ns;
     S1 <= (S0 and MD) or (STB and not MD) after 60ns;
     S2 <= S0 nor not NCLR after 30ns;
     S3 <= S0 or MD after 30ns;
     NINT <= not SRQ nor S0 after 30ns;
     Q(7 downto 0) <= b"00000000" after 20ns when (not NCLR)
                          else DI(7 downto 0) after 30ns when (S1)
			  else Q(7 downto 0);
     --- no tristate, so just go low
     DO(7 downto 0) <= Q(7 downto 0) after 20ns when (S3) else b"00000000";
end data;

