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

------------------------------------------------------------------------
-- 74189 RAM VHDL
-- 11/17/88 
-- David George
-- EE 295
-- Department of Electrical Engineering
-- University of Pittsburgh

------------------------------------------------------------------------
--      RS FLIP-FLOP                                                  --
--      S. Levitan -- 10/88 Picalab Univ. Pittsburgh                  --
------------------------------------------------------------------------
entity RS is
        port (reset, set: in bit; q, qbar: out bit);
end RS;


------------------------------------------------------------------------
--      PURE STRUCTURE MODEL OF RS FLIP-FLOP                          --
--      S. Levitan -- 10/88 Picalab Univ. Pittsburgh                  --
------------------------------------------------------------------------
architecture rs_struct of RS is
begin
	q <= reset nor qbar after 3ns;
	qbar <= set nor q after 3ns;
end rs_struct;


------------------------------------------------------------------------
--      MASTER SLAVE FLIP-FLOP                                        --
--      S. Levitan -- 10/88 Picalab Univ. Pittsburgh                  --
------------------------------------------------------------------------

entity MS is
    port (clear, reset, set, clock: in bit; q, qbar: out bit);
end MS;

------------------------------------------------------------------------
--      MODEL OF MASTER SLAVE FLIP-FLOP USING STRUCTURE COMPONENTS    --
--      S. Levitan -- 10/88 Picalab Univ. Pittsburgh                  --
------------------------------------------------------------------------
architecture ms_struct of MS is
	signal clrbar, x0, y0, r0, s0, q0, qbar0, x1, y1, r1, s1, cbar: bit;
	label rs0, rs1;
	component rs_ff
		port (r, s: in bit; q, qbar: out bit);
	end component;
	for rs0, rs1: rs_ff
		use entity RS(rs_struct);
begin
	clrbar <= not clear;
	x0 <= reset and clock;
	y0 <= set and clock;
	r0 <= x0 or clear;
	s0 <= y0 and clrbar;
	rs0: rs_ff port map (r0, s0, q0, qbar0);
	cbar <= not clock;
	x1 <= qbar0 and cbar;
	y1 <= q0 and cbar;
	r1 <= x1 or clear;
	s1 <= y1 and clrbar;
	rs1: rs_ff port map (r1, s1, q, qbar);
end ms_struct;
------------------------------------------------------------------------


------------------------------------------------------------------------
--      TRANSPARENT LOW D-LATCH                                       --
--      D. GEORGE --  10/88 Picalab Univ. Pittsburgh                  --
------------------------------------------------------------------------
entity DLATCH is
        port (d, clock: in bit; q, qbar: out bit);
end DLATCH;
------------------------------------------------------------------------

------------------------------------------------------------------------
-- MODEL OF DLATCH USING STRUCTURE COMPONENTS                         --
--      D. GEORGE -- 11/88 Picalab Univ. Pittsburgh                   --
------------------------------------------------------------------------
architecture dlatch_struct of DLATCH is
	signal notd, r0, s0: bit;
	label rs0;
	component rs_ff
		port (r, s: in bit; q, qbar: out bit);
	end component;
	for rs0: rs_ff
		use entity RS(rs_struct);
begin
        notd <= not d;
	r0 <= notd nor clock;
	s0 <=    d nor clock;
	rs0: rs_ff port map (r0, s0, q, qbar);
end dlatch_struct;

------------------------------------------------------------------------
--      DECODER                                                       --
--      D. GEORGE --  10/88 Picalab Univ. Pittsburgh                  --
------------------------------------------------------------------------
entity DECODER4TO16 is
 port (sin: in bit_vector(3 downto 0); sout: out bit_vector(15 downto 0));
end DECODER4TO16;

------------------------------------------------------------------------
-- Behavioral MODEL of DECODER4TO16                                   --
-- S.Frezza -- 2/91 Picalab Univ. Pittsburgh                          --
------------------------------------------------------------------------
architecture decoder_beh of DECODER4TO16 is
begin
    process
    begin
    sout(0) <= not(sin(3) or sin(2) or sin(1) or sin(0));
    sout(1) <= not(not sin(0)) and (not(sin(3) or sin(2) or sin(1)));
    sout(2) <= not(not sin(1)) and (not(sin(3) or sin(2) or sin(0)));
    sout(3) <= (sin(1) and sin(0)) and (not (sin(3) or sin(2)));
    sout(4) <= not(not sin(2)) and (not(sin(3) or sin(1) or sin(0)));
    sout(5) <= (sin(2) and sin(0)) and (not(sin(3) or sin(1)));
    sout(6) <= (sin(2) and sin(1)) and (not(sin(3) or sin(0)));
    sout(7) <= (sin(2) and sin(1) and sin(0)) and (not sin(3));
    sout(8) <= not(not sin(3)) and (not(sin(2) or sin(1) or sin(0)));
    sout(9) <= (sin(3) and sin(0)) and (not(sin(2) or sin(1)));
    sout(10) <= (sin(3) and sin(1)) and (not(sin(2) or sin(0)));
    sout(11) <= (sin(3) and sin(1) and sin(0)) and (not sin(2));
    sout(12) <= (sin(3) and sin(2)) and (not(sin(1) or sin(0)));
    sout(13) <= (sin(3) and sin(2) and sin(0)) and (not sin(1));
    sout(14) <= (sin(3) and sin(2) and sin(1)) and (not sin(0));
    sout(15) <= not(not sin(3)) and sin(2) and sin(1) and sin(0);
    end process;
end decoder_beh;

------------------------------------------------------------------------
-- MODEL DECODER4TO16 USING STRUCTURE COMPONENTS                      --
--      D. GEORGE -- 11/88 Picalab Univ. Pittsburgh                   --
------------------------------------------------------------------------
architecture decoder_struct of DECODER4TO16 is
begin
  sout(0) <= not(sin(3) or sin(2) or sin(1) or sin(0));
  sout(1) <= sin(0) and (not(sin(3) or sin(2) or sin(1)));
  sout(2) <= sin(1) and (not(sin(3) or sin(2) or sin(0)));
  sout(3) <= (sin(1) and sin(0)) and (not (sin(3) or sin(2)));
  sout(4) <= sin(2) and (not(sin(3) or sin(1) or sin(0)));
  sout(5) <= (sin(2) and sin(0)) and (not(sin(3) or sin(1)));
  sout(6) <= (sin(2) and sin(1)) and (not(sin(3) or sin(0)));
  sout(7) <= (sin(2) and sin(1) and sin(0)) and (not sin(3));
  sout(8) <= sin(3) and (not(sin(2) or sin(1) or sin(0)));
  sout(9) <= (sin(3) and sin(0)) and (not(sin(2) or sin(1)));
 sout(10) <= (sin(3) and sin(1)) and (not(sin(2) or sin(0)));
 sout(11) <= (sin(3) and sin(1) and sin(0)) and (not sin(2));
 sout(12) <= (sin(3) and sin(2)) and (not(sin(1) or sin(0)));
 sout(13) <= (sin(3) and sin(2) and sin(0)) and (not sin(1));
 sout(14) <= (sin(3) and sin(2) and sin(1)) and (not sin(0));
 sout(15) <= sin(3) and sin(2) and sin(1) and sin(0);
end decoder_struct;

------------------------------------------------------------------------
--      MUX                                                           --
--      D. GEORGE --  10/88 Picalab Univ. Pittsburgh                  --
------------------------------------------------------------------------
entity MUX16TO1 is
 port (ce, rw: in bit; din,sel: in bit_vector(15 downto 0); dout: out bit);
end MUX16TO1;

------------------------------------------------------------------------
-- Behavioral MODEL 16to1 MUX USING STRUCTURE COMPONENTS              --
-- S.Frezza -- 11/88 Picalab Univ. Pittsburgh                         --
------------------------------------------------------------------------
architecture mux_beh of MUX16TO1 is
begin
    process(ce, rw)
        variable tout: bit_vector(15 downto 0);
        variable temp1,temp2,temp3,temp4,hiimp: bit;
    begin
      hiimp := (not rw) or ce;
      tout(0) := din(0) and sel(0);
      tout(1) := din(1) and sel(1);
      tout(2) := din(2) and sel(2);
      tout(3) := din(3) and sel(3);
      tout(4) := din(4) and sel(4);
      tout(5) := din(5) and sel(5);
      tout(6) := din(6) and sel(6);
      tout(7) := din(7) and sel(7);
      tout(8) := din(8) and sel(8);
      tout(9) := din(9) and sel(9);
      tout(10) := din(10) and sel(10);
      tout(11) := din(11) and sel(11);
      tout(12) := din(12) and sel(12);
      tout(13) := din(13) and sel(13);
      tout(14) := din(14) and sel(14);
      tout(15) := din(15) and sel(15);
      temp1 := ((tout(0) or tout(1)) or (tout(2) or tout(3)));
      temp2 := ((tout(4) or tout(5)) or (tout(6) or tout(7)));
      temp3 := ((tout(8) or tout(9)) or (tout(10) or tout(11)));
      temp4 := ((tout(12) or tout(13)) or (tout(14) or tout(15)));
      dout <= (((temp1 or temp2) or (temp3 or temp4)) or hiimp);
    end process;
end mux_beh;
------------------------------------------------------------------------
-- MODEL 16to1 MUX USING STRUCTURE COMPONENTS                         --
--      D. GEORGE -- 11/88 Picalab Univ. Pittsburgh                   --
------------------------------------------------------------------------
architecture mux_struct of MUX16TO1 is
  signal tout: bit_vector(15 downto 0);
  signal temp1,temp2,temp3,temp4,hiimp: bit;
begin
  hiimp <= (not rw) or ce;
  tout(0) <= din(0) and sel(0);
  tout(1) <= din(1) and sel(1);
  tout(2) <= din(2) and sel(2);
  tout(3) <= din(3) and sel(3);
  tout(4) <= din(4) and sel(4);
  tout(5) <= din(5) and sel(5);
  tout(6) <= din(6) and sel(6);
  tout(7) <= din(7) and sel(7);
  tout(8) <= din(8) and sel(8);
  tout(9) <= din(9) and sel(9);
 tout(10) <= din(10) and sel(10);
 tout(11) <= din(11) and sel(11);
 tout(12) <= din(12) and sel(12);
 tout(13) <= din(13) and sel(13);
 tout(14) <= din(14) and sel(14);
 tout(15) <= din(15) and sel(15);
    temp1 <= ((tout(0) or tout(1)) or (tout(2) or tout(3)));
    temp2 <= ((tout(4) or tout(5)) or (tout(6) or tout(7)));
    temp3 <= ((tout(8) or tout(9)) or (tout(10) or tout(11)));
    temp4 <= ((tout(12) or tout(13)) or (tout(14) or tout(15)));
     dout <= (((temp1 or temp2) or (temp3 or temp4)) or hiimp);
end mux_struct;



------------------------------------------------------------------------
--      4-BIT REGISTER                                                --
--      D. GEORGE - 11/88 Picalab Univ. Pittsburgh                  --
------------------------------------------------------------------------

entity REG is
    port (din, ce, rw: in bit; enable: in bit_vector(15 downto 0); q, qbar: out bit_vector(15 downto 0));
end REG;

------------------------------------------------------------------------
--      MODEL OF REG  USING DLATCH STRUCTURE COMPONENTS               --
--      D. GEORGE 11/88 Picalab Univ. Pittsburgh                      --
------------------------------------------------------------------------
architecture reg_beh of REG is
begin
    process(ce, rw)
        variable en: bit_vector(15 downto 0);
        variable write: bit;
	
    begin
     write   := ((not rw) and (not ce));
     en(0)   := (enable(0) nand write);
     en(1)   := (enable(1) nand write);
     en(2)   := (enable(2) nand write);
     en(3)   := (enable(3) nand write);
     en(4)   := (enable(4) nand write);
     en(5)   := (enable(5) nand write);
     en(6)   := (enable(6) nand write);
     en(7)   := (enable(7) nand write);
     en(8)   := (enable(8) nand write);
     en(9)   := (enable(9) nand write);
     en(10)   := (enable(10) nand write);
     en(11)   := (enable(11) nand write);
     en(12)   := (enable(12) nand write);
     en(13)   := (enable(13) nand write);
     en(14)   := (enable(14) nand write);
     en(15)   := (enable(15) nand write);

    -- rather incomplete.  Used for a SPAR example
    end process;
end reg_beh;

------------------------------------------------------------------------
--      MODEL OF REG  USING DLATCH STRUCTURE COMPONENTS               --
--      D. GEORGE 11/88 Picalab Univ. Pittsburgh                      --
------------------------------------------------------------------------
architecture reg_struct of REG is
        signal en: bit_vector(15 downto 0);
        signal write: bit;
	label latch0, latch1, latch2, latch3, latch4, latch5, latch6, latch7, latch8, latch9, latch10, latch11, latch12, latch13, latch14, latch15;

	component latch_d
		port (d, clock: in bit; q, qbar: out bit);
	end component;

	for latch0, latch1, latch2, latch3, latch4, latch5, latch6, latch7, latch8, latch9, latch10, latch11, latch12, latch13, latch14, latch15: latch_d use entity DLATCH(dlatch_struct);

begin
     write   <= ((not rw) and (not ce));

     en(0)   <= (enable(0) nand write);
     en(1)   <= (enable(1) nand write);
     en(2)   <= (enable(2) nand write);
     en(3)   <= (enable(3) nand write);
     en(4)   <= (enable(4) nand write);
     en(5)   <= (enable(5) nand write);
     en(6)   <= (enable(6) nand write);
     en(7)   <= (enable(7) nand write);
     en(8)   <= (enable(8) nand write);
     en(9)   <= (enable(9) nand write);
     en(10)   <= (enable(10) nand write);
     en(11)   <= (enable(11) nand write);
     en(12)   <= (enable(12) nand write);
     en(13)   <= (enable(13) nand write);
     en(14)   <= (enable(14) nand write);
     en(15)   <= (enable(15) nand write);

     latch0: latch_d port map (din,  en(0),  q(0), qbar(0));
     latch1: latch_d port map (din,  en(1),  q(1), qbar(1));
     latch2: latch_d port map (din,  en(2),  q(2), qbar(2));
     latch3: latch_d port map (din,  en(2),  q(3), qbar(3));
     latch4: latch_d port map (din,  en(4),  q(4), qbar(4));
     latch5: latch_d port map (din,  en(5),  q(5), qbar(5));
     latch6: latch_d port map (din,  en(6),  q(6), qbar(6));
     latch7: latch_d port map (din,  en(7),  q(7), qbar(7));
     latch8: latch_d port map (din,  en(8),  q(8), qbar(8));
     latch9: latch_d port map (din,  en(9),  q(9), qbar(9));
    latch10: latch_d port map (din, en(10), q(10), qbar(10));
    latch11: latch_d port map (din, en(11), q(11), qbar(11));
    latch12: latch_d port map (din, en(12), q(12), qbar(12));
    latch13: latch_d port map (din, en(13), q(13), qbar(13));
    latch14: latch_d port map (din, en(14), q(14), qbar(14));
    latch15: latch_d port map (din, en(15), q(15), qbar(15));

end reg_struct;


------------------------------------------------------------------------
--      74189                                                        --
--      D. GEORGE -- 11/88 Picalab Univ. Pittsburgh                  --
------------------------------------------------------------------------
entity SN74189 is
port (read_write,ce:in bit;sel,d:in bit_vector(3 downto 0);y:out bit_vector(3 downto 0));
end SN74189;

------------------------------------------------------------------------
--      PURE BEHAVIOR MODEL OF SN74189                            --
--      D. GEORGE -- 11/88 Picalab Univ. Pittsburgh                   --
------------------------------------------------------------------------
architecture ram_beh of SN74189 is
begin
        process(read_write, ce) 
           variable mem1, mem2, mem3, mem4: bit_vector(3 downto 0);
           variable mem5, mem6, mem7, mem8: bit_vector(3 downto 0);
           variable mem9, mem10, mem11, mem12: bit_vector(3 downto 0);
           variable mem13, mem14, mem15, mem16: bit_vector(3 downto 0);
           variable highimp, write, read: bit;

        begin
         highimp := ((not read_write) or ce);
         write   := ((not read_write) and (not ce));
-- This is the line that screws up:
--       read    := (read_write and (not ce));
-- Whereas this line works.  Why?	 
         read    := (not(not read_write) and (not ce));

         if (highimp = '1') then y(3 downto 0) <= "1111";
         end if;

         if (write = '1') then
           if (sel(3 downto 0) = "0000") then
               mem1(3 downto 0) := d(3 downto 0);
            elsif (sel(3 downto 0) = "0001") then
               mem2(3 downto 0) := d(3 downto 0);
            elsif (sel(3 downto 0) = "0010") then
               mem3(3 downto 0) := d(3 downto 0);
            elsif (sel(3 downto 0) = "0011") then
               mem4(3 downto 0) := d(3 downto 0);
            elsif (sel(3 downto 0) = "0100") then
               mem5(3 downto 0) := d(3 downto 0);
            elsif (sel(3 downto 0) = "0101") then
               mem6(3 downto 0) := d(3 downto 0);
            elsif (sel(3 downto 0) = "0110") then
               mem7(3 downto 0) := d(3 downto 0);
            elsif (sel(3 downto 0) = "0111") then
               mem8(3 downto 0) := d(3 downto 0);
            elsif (sel(3 downto 0) = "1000") then
               mem9(3 downto 0) := d(3 downto 0);
            elsif (sel(3 downto 0) = "1001") then
               mem10(3 downto 0) := d(3 downto 0);
            elsif (sel(3 downto 0) = "1010") then
               mem11(3 downto 0) := d(3 downto 0);
            elsif (sel(3 downto 0) = "1011") then
               mem12(3 downto 0) := d(3 downto 0);
            elsif (sel(3 downto 0) = "1100") then
               mem13(3 downto 0) := d(3 downto 0);
            elsif (sel(3 downto 0) = "1101") then
               mem14(3 downto 0) := d(3 downto 0);
            elsif (sel(3 downto 0) = "1110") then
               mem15(3 downto 0) := d(3 downto 0);
            elsif (sel(3 downto 0) = "1111") then
               mem16(3 downto 0) := d(3 downto 0);
           end if;
         end if;

         if (read = '1') then         
           if (sel(3 downto 0) = "0000") then
               y(3 downto 0) <= mem1(3 downto 0);
            elsif (sel(3 downto 0) = "0001") then
               y(3 downto 0) <= mem2(3 downto 0);
            elsif (sel(3 downto 0) = "0010") then
               y(3 downto 0) <= mem3(3 downto 0);
            elsif (sel(3 downto 0) = "0011") then
               y(3 downto 0) <= mem4(3 downto 0);
            elsif (sel(3 downto 0) = "0100") then
               y(3 downto 0) <= mem5(3 downto 0);
            elsif (sel(3 downto 0) = "0101") then
               y(3 downto 0) <= mem6(3 downto 0);
            elsif (sel(3 downto 0) = "0110") then
               y(3 downto 0) <= mem7(3 downto 0);
            elsif (sel(3 downto 0) = "0111") then
               y(3 downto 0) <= mem8(3 downto 0);
            elsif (sel(3 downto 0) = "1000") then
               y(3 downto 0) <= mem9(3 downto 0);
            elsif (sel(3 downto 0) = "1001") then
               y(3 downto 0) <= mem10(3 downto 0);
            elsif (sel(3 downto 0) = "1010") then
               y(3 downto 0) <= mem11(3 downto 0);
            elsif (sel(3 downto 0) = "1011") then
               y(3 downto 0) <= mem12(3 downto 0);
            elsif (sel(3 downto 0) = "1100") then
               y(3 downto 0) <= mem13(3 downto 0);
            elsif (sel(3 downto 0) = "1101") then
               y(3 downto 0) <= mem14(3 downto 0);
            elsif (sel(3 downto 0) = "1110") then
               y(3 downto 0) <= mem15(3 downto 0);
            elsif (sel(3 downto 0) = "1111") then
               y(3 downto 0) <= mem16(3 downto 0);
           end if;
         end if;
        end process;
end ram_beh;


------------------------------------------------------------------------
--      MODEL OF 64 BIT RAM USING RS STRUCTURE COMPONENTS   --
--      D. GEORGE -- 11/88 Picalab Univ. Pittsburgh         --
------------------------------------------------------------------------
architecture ram_struct of SN74189 is
        signal en,ytemp0,ytemp1,ytemp2,ytemp3: bit_vector(15 downto 0); 
        signal dqbar0,dqbar1,dqbar2,dqbar3: bit_vector(15 downto 0); 
       
        component reg_slice
             port (din, ce, rw: in bit; enable: in bit_vector(15 downto 0); q, qbar: out bit_vector(15 downto 0));
	end component;

	label reg0,reg1,reg2,reg3;

	for reg0,reg1,reg2,reg3: reg_slice use entity REG(reg_struct);


        component mux_16to1
             port (ce, rw: in bit; din,sel: in bit_vector(15 downto 0); dout: out bit);
	end component;

	label mux0, mux1, mux2, mux3;

	for mux0, mux1, mux2, mux3: mux_16to1 use entity MUX16TO1(mux_struct);


        component decoder_4to16
          port (sin: in bit_vector(3 downto 0); sout: out bit_vector(15 downto 0));
	end component;

	label decoder0;
          
	for decoder0: decoder_4to16 use entity DECODER4TO16(decoder_struct);

begin
 decoder0: decoder_4to16 port map (sel(3 downto 0), en(15 downto 0));

 reg0: reg_slice port map (d(0), ce, read_write, en(15 downto 0), dqbar0(15 downto 0), ytemp0(15 downto 0));
 reg1: reg_slice port map (d(1), ce, read_write, en(15 downto 0), dqbar1(15 downto 0), ytemp1(15 downto 0));
 reg2: reg_slice port map (d(2), ce, read_write, en(15 downto 0), dqbar2(15 downto 0), ytemp2(15 downto 0));
 reg3: reg_slice port map (d(3), ce, read_write, en(15 downto 0), dqbar3(15 downto 0), ytemp3(15 downto 0));

 mux0: mux_16to1 port map (ce, read_write, ytemp0(15 downto 0), en(15 downto 0), y(0));
 mux1: mux_16to1 port map (ce, read_write, ytemp1(15 downto 0), en(15 downto 0), y(1));
 mux2: mux_16to1 port map (ce, read_write, ytemp2(15 downto 0), en(15 downto 0), y(2));
 mux3: mux_16to1 port map (ce, read_write, ytemp3(15 downto 0), en(15 downto 0), y(3));

end ram_struct;
------------------------------------------------------------------------
--      74189                                                        --
--      D. GEORGE -- 11/88 Picalab Univ. Pittsburgh                  --
------------------------------------------------------------------------
-- entity SN74189 is
-- port (read_write,ce:in bit;sel,d:in bit_vector(3 downto 0);y:out bit_vector(3 downto 0));
-- end SN74189;

------------------------------------------------------------------------
--      MODEL OF 64 BIT RAM USING RS STRUCTURE COMPONENTS   --
--      D. GEORGE -- 11/88 Picalab Univ. Pittsburgh         --
------------------------------------------------------------------------
architecture ram_h of SN74189 is
        signal en,ytemp0,ytemp1,ytemp2,ytemp3: bit_vector(15 downto 0); 
        signal dqbar0,dqbar1,dqbar2,dqbar3: bit_vector(15 downto 0); 
       
        component reg_slice
             port (din, ce, rw: in bit; enable: in bit_vector(15 downto 0); q, qbar: out bit_vector(15 downto 0));
	end component;

	label reg0,reg1,reg2,reg3;

	for reg0,reg1,reg2,reg3: reg_slice use entity REG(reg_beh);


        component mux_16to1
             port (ce, rw: in bit; din,sel: in bit_vector(15 downto 0); dout: out bit);
	end component;

	label mux0, mux1, mux2, mux3;

	for mux0, mux1, mux2, mux3: mux_16to1 use entity MUX16TO1(mux_beh);


        component decoder_4to16
          port (sin: in bit_vector(3 downto 0); sout: out bit_vector(15 downto 0));
	end component;

	label decoder0;
          
	for decoder0: decoder_4to16 use entity DECODER4TO16(decoder_beh);

begin
 decoder0: decoder_4to16 port map (sel(3 downto 0), en(15 downto 0));

 reg0: reg_slice port map (d(0), ce, read_write, en(15 downto 0), dqbar0(15 downto 0), ytemp0(15 downto 0));
 reg1: reg_slice port map (d(1), ce, read_write, en(15 downto 0), dqbar1(15 downto 0), ytemp1(15 downto 0));
 reg2: reg_slice port map (d(2), ce, read_write, en(15 downto 0), dqbar2(15 downto 0), ytemp2(15 downto 0));
 reg3: reg_slice port map (d(3), ce, read_write, en(15 downto 0), dqbar3(15 downto 0), ytemp3(15 downto 0));

 mux0: mux_16to1 port map (ce, read_write, ytemp0(15 downto 0), en(15 downto 0), y(0));
 mux1: mux_16to1 port map (ce, read_write, ytemp1(15 downto 0), en(15 downto 0), y(1));
 mux2: mux_16to1 port map (ce, read_write, ytemp2(15 downto 0), en(15 downto 0), y(2));
 mux3: mux_16to1 port map (ce, read_write, ytemp3(15 downto 0), en(15 downto 0), y(3));

end ram_h;

------------------------------------------------------------------------
-- END OF FILE                                                        --
------------------------------------------------------------------------

