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
-- 
-- 2-25-91
-- Steve Frezza
-- MS Thesis work
-- Department of Electrical Engineering
-- University of Pittsburgh

----------------------------------------------------------------------
-- PaoPo's Behavioral Flip-Flop
---------------------------------------------------------------------
entity E is
port (C, D: in bit; 
         Q: out bit); 
end E;
---------------------------------------------------------------------
architecture A of E is
begin
  process
  begin
    while C loop
      wait on C, D;
    end loop;
    while not C loop
      wait on C, D;
    end loop;
    Q <= D;
  end process;
end A;
---------------------------------------------------------------------
----------------------------------------------------------------------
-- My Behavioral Flip-Flop
---------------------------------------------------------------------
entity Clocked_RS is
port (R, S, Clock: in bit; 
      Q, Qbar: out bit); 
end Clocked_RS;
---------------------------------------------------------------------
architecture beh of Clocked_RS is
begin
  process(Clock)
  begin
    if (Clock = '0') then
    	Q <= R nor Qbar;
	Qbar <= S nor Q;
    end if;
  end process;
end beh;
---------------------------------------------------------------------
----------------------------------------------------------------------
-- My SN5491A
---------------------------------------------------------------------
entity sn5491A is
port (A, B, Clock: in bit; 
      Q, Qbar: out bit); 
end sn5491A;
---------------------------------------------------------------------
architecture str of sn5491A is
    signal r, s : bit_vector(7 downto 0);
    signal clk_bar : bit;
    
    label FlipFlop_0,FlipFlop_1,FlipFlop_2,FlipFlop_3,FlipFlop_4,FlipFlop_5,FlipFlop_6,FlipFlop_7,FlipFlop_8;
    
    component FF
    	port (R, S, Clock: in bit; Q, Qbar: out bit); 
    end component;
    
    for FlipFlop_0,FlipFlop_1,FlipFlop_2,FlipFlop_3,FlipFlop_4,FlipFlop_5,FlipFlop_6,FlipFlop_7 : FF use entity Clocked_RS(beh);
    
begin
    r(0) <= A nand B;
    s(0) <= not( r(0) );
    clk_bar <= not(Clock);
    
    FlipFlop_0: FF port map (r(0), s(0), clk_bar, s(1), r(1));
    FlipFlop_1: FF port map (r(1), s(1), clk_bar, s(2), r(2));
    FlipFlop_2: FF port map (r(2), s(2), clk_bar, s(3), r(3));
    FlipFlop_3: FF port map (r(3), s(3), clk_bar, s(4), r(4));
    FlipFlop_4: FF port map (r(4), s(4), clk_bar, s(5), r(5));
    FlipFlop_5: FF port map (r(5), s(5), clk_bar, s(6), r(6));
    FlipFlop_6: FF port map (r(6), s(6), clk_bar, s(7), r(7));
    FlipFlop_7: FF port map (r(7), s(7), clk_bar, Q, Qbar);

end str;
---------------------------------------------------------------------

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


----------------------------------------------------------------------
-- SN74S201 256-bit RAM
---------------------------------------------------------------------
entity sn74s201 is
port (A, B, C, D, E, F, G, H, rw, data : in bit; 
      CE : in bit_vector(3 downto 1);
      Y : out bit_vector(7 downto 0)); 
end sn74s201;
---------------------------------------------------------------------
architecture str of sn74s201 is
    signal rw_bar, t1, t2, t3, t4, en : bit;
    signal AD1, AD2, T : bit_vector(15 downto 0);
    
    label RowDecoder
    component vDecoder
    	port (i : in bit_vector(3 downto 0); o : out bit_vector(15 downto 0)); 
    end component;
    for RowDecoder use v4-16Decoder(beh);
    
    label ColDecoder
    component hDecoder
    	port (i : in bit_vector(3 downto 0); o : out bit_vector(15 downto 0)); 
    end component;
    for ColDecoder use h4-16Decoder(beh);
    
begin
    t1 <= (CE(3) nand CE(2) nand CE(1));
    rw_bar <= not(rw);
    t2 <= t1 nand rw_bar;
    t3 <= data nor t2;
    en <= t3 nor t2;
    t4 <= t1 and t2;
    
    RowDecoder: vDecoder port map (D, E, F, G, AD1(0), AD1(1), AD1(2), AD1(3), AD1(4), AD1(5), AD1(6), AD1(7), AD1(8), AD1(9), AD1(10), AD1(11), AD1(12), AD1(13), AD1(14), AD1(15));   
    ColDecoder: hDecoder port map (H, C, B, A, T(0), T(1), T(2), T(3), T(4), T(5), T(6), T(7), T(8), T(9), T(10), T(11), T(12), T(13), T(14), T(15));   
    
    AD(0) <= en and T(0);
    AD(1) <= en and T(1);
    AD(2) <= en and T(2);
    AD(3) <= en and T(3);
    AD(4) <= en and T(4);
    AD(5) <= en and T(5);
    AD(6) <= en and T(6);
    AD(7) <= en and T(7);
    AD(8) <= en and T(8);
    AD(9) <= en and T(9);
   AD(10) <= en and T(10);
   AD(11) <= en and T(11);
   AD(12) <= en and T(12);
   AD(13) <= en and T(13);
   AD(14) <= en and T(14);
   AD(15) <= en and T(15);


    
    
end str;
---------------------------------------------------------------------



