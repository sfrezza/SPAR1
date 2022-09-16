-- ************************************************************************
--  Copyright (C) 1989 - University of Pittsburgh, Dept. Elect. Engr.
--  PICALAB: Pittsburgh Integrated Circuits Analysis Laboratory
-- ************************************************************************
--  Title: 	SN54155 2-line to 4-line decoder
--  Created:	Mon 16 October 1989
--  Author: 	Steve Frezza vlsi	<frezza@jupiter.ee.pitt.edu>
--
--  Description: TI decoder/demultiplexer from "TTL Data Book for Design Engineers," 1st Ed. p 313
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



-- ************************************************************************
--  Copyright (C) 1989 - University of Pittsburgh, Dept. Elect. Engr.
--  PICALAB: Pittsburgh Integrated Circuits Analysis Laboratory
-- ************************************************************************
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
architecture mux_str of SN54S151 is
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
     
end  mux_str;


--*************************************************************************
entity merged is
    port(InA, InB, InC, strobe : in bit;
    	 OutA, OutB: out bit);
end merged;
--*************************************************************************

------ For Reference -------------------------------------------------------
--entity SN54S151 is  --  
--    port (strobe, A, B, C : in bit;
--    	  D : in bit_vector(7 downto 0);
--	  outY, outW: out bit);
--end SN54S151;

--entity SN54155 is  --  
--    port (strobe1G, strobe2G, selectA, selectB, data1C, data2C : in bit;
--	  out1Y, out2Y: out bit_vector(3 downto 0));
--end SN54155;
-----------------------------------------------------------------------------

architecture combined of merged is
	signal temp : bitvec;
	signal C_bar : bit;
        label mux, demux;
        component s54S151
	    port (strobe, A, B, C : in bit; D : in bit_vector(7 downto 0);
	    	  outY, outW: out bit);
	end component;
	for mux : s54S151 use entity SN54S151(mux_str);

       	component s54155
	    port(strobe1G, strobe2G, selectA, selectB, data1C, data2C : in bit;
	    	  out1Y, out2Y: out bit_vector(3 downto 0));
        end component;
	for demux : s54155 use entity SN54155(str);
begin 
    C_bar <= not InC;
    demux : s54155 port map (strobe, strobe, InA, InB, InC, C_bar, 
    	                      temp(7 downto 4), temp(3 downto 0));
    mux  : s54S151 port map (strobe, InA, InB, InC, temp(7 downto 0), OutA, OutB);
    
end combined;    
