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

-- Author: Chun-lung Tsai (VLSI 91-1)
--        Model for Signal PLUS2 Used in Multiply Decoder MLYDEC
-- ------------------------------------------------------------------------

entity plus2 is
     port (y2,y1,y0:in bit;  plus2:out bit);
end plus2;

architecture structure of plus2 is
begin
     plus2 <= not(y2) and y1 and y0;
end structure;



-- ------------------------------------------------------------------------
--        Model for Signal MINUS2 Used in Multiply Decoder MLYDEC
-- ------------------------------------------------------------------------

entity minus2 is
     port (y2,y1,y0:in bit;  minus2:out bit);
end minus2;

architecture structure of minus2 is
begin
     minus2  <= y2 and not(y1) and not(y0);
end structure;



-- ------------------------------------------------------------------------
--        Model for Signal PLUS1 Used in Multiply Decoder MLYDEC
-- ------------------------------------------------------------------------

entity plus1 is
     port (y2,y1,y0:in bit;  plus1:out bit);
end plus1;

architecture structure of plus1 is
begin
     plus1  <= (not(y0) and y1 and not(y2)) or (not(y2) and not(y1) and
y0);
end structure;



-- ------------------------------------------------------------------------
--        Model for Signal MINUS1 Used in Multiply Decoder MLYDEC
-- ------------------------------------------------------------------------

entity minus1 is
     port (y2,y1,y0:in bit;  minus1:out bit);
end minus1;

architecture structure of minus1 is
begin
     minus1  <= (y0 and not(y1) and y2) or (y2 and y1 and not(y0));
end structure;



-- ------------------------------------------------------------------------
--                       Multiply Decoder Model
-- ------------------------------------------------------------------------

entity mlydec is
     port (y2,y1,y0:in bit;  plus2,minus2,plus1,minus1:out bit);
end mlydec;

architecture structure of mlydec is
label lplus2,lminus2,lplus1,lminus1;

component plus2
     port (y2,y1,y0:in bit;  plus2:out bit);
end component;
     for lplus2:plus2 use entity plus2(structure);

component minus2
     port (y2,y1,y0:in bit;  minus2:out bit);
end component;
     for lminus2:minus2 use entity minus2(structure);

component plus1
     port (y2,y1,y0:in bit;  plus1:out bit);
end component;
     for lplus1:plus1 use entity plus1(structure);

component minus1
     port (y2,y1,y0:in bit;  minus1:out bit);
end component;
     for lminus1:minus1 use entity minus1(structure);

begin

lplus2: plus2 port map(y2,y1,y0,plus2);
lminus2: minus2 port map(y2,y1,y0,minus2);
lplus1: plus1 port map(y2,y1,y0,plus1);
lminus1: minus1 port map(y2,y1,y0,minus1);

end structure;



-- ------------------------------------------------------------------------
--                                 PPL Model
-- ------------------------------------------------------------------------

entity ppl is
     port (one,minus2,plus1,minus1:in bit;  ppl:out bit);
end ppl;

architecture structure of ppl is
begin
     ppl <= (one and plus1) or minus2 or (not(one) and minus1);
end structure;



-- ------------------------------------------------------------------------
--                                 PPM Model
-- ------------------------------------------------------------------------

entity ppm is
     port (one,two,plus2,minus2,plus1,minus1:in bit;  ppm:out bit);
end ppm;

architecture structure of ppm is
begin
     ppm <= (two and plus2) or (not(two) and minus2) or (one and plus1) or
(not(one) and minus1);
end structure;



-- ------------------------------------------------------------------------
--                                 PPH Model
-- ------------------------------------------------------------------------

entity pph is
     port (one,plus2,minus2,plus1,minus1:in bit;  pph:out bit);
end pph;

architecture structure of pph is
begin
     pph <= not((one and plus2) or (one and plus1) or (not(one) and minus2)
or (not(one) and minus1));
end structure;



-- ------------------------------------------------------------------------
--                                 R Model
-- ------------------------------------------------------------------------

entity round is
  port(y: in bit_vector(7 downto 0);r : out bit_vector(3 downto 0));
end round;


architecture structure of round is
begin
    r(0) <= y(1);
    r(1) <= y(3) and ( (not y(2)) or ( not y(1)));
    r(2) <= y(5) and ( (not y(4)) or ( not y(3)));
    r(3) <= y(7) and ( (not y(6)) or ( not y(5)));
end structure;



-- ------------------------------------------------------------------------
--                       Partial Product Tree Model
-- ------------------------------------------------------------------------

entity pptree is
     port (x:in bit_vector (7 downto 0);
           y:in bit_vector (7 downto 0);
           a:out bit_vector (8 downto 0);
           b:out bit_vector (8 downto 0);
           c:out bit_vector (8 downto 0);
           d:out bit_vector (8 downto 0);
           r:out bit_vector (3 downto 0));
end pptree;

architecture structure of pptree is

label mlydeca,ppla,ppma1,ppma2,ppma3,ppma4,ppma5,ppma6,ppma7,ppha;
label mlydecb,pplb,ppmb1,ppmb2,ppmb3,ppmb4,ppmb5,ppmb6,ppmb7,pphb;
label mlydecc,pplc,ppmc1,ppmc2,ppmc3,ppmc4,ppmc5,ppmc6,ppmc7,pphc;
label mlydecd,ppld,ppmd1,ppmd2,ppmd3,ppmd4,ppmd5,ppmd6,ppmd7,pphd,round;
signal p2a,m2a,p1a,m1a,p2b,m2b,p1b,m1b,p2c,m2c,p1c,m1c,p2d,m2d,p1d,m1d:bit;

component mlydec
     port (y2,y1,y0:in bit;  plus2,minus2,plus1,minus1:out bit);
end component;
     for mlydeca,mlydecb,mlydecc,mlydecd:mlydec use entity
	 mlydec(structure);

component ppl
     port (one,minus2,plus1,minus1:in bit;  ppl:out bit);
end component;
     for ppla,pplb,pplc,ppld:ppl use entity ppl(structure);

component ppm
     port (one,two,plus2,minus2,plus1,minus1:in bit;  ppm:out bit);
end component;
     for  ppma1,ppma2,ppma3,ppma4,ppma5,ppma6,ppma7,
          ppmb1,ppmb2,ppmb3,ppmb4,ppmb5,ppmb6,ppmb7,
          ppmc1,ppmc2,ppmc3,ppmc4,ppmc5,ppmc6,ppmc7,
          ppmd1,ppmd2,ppmd3,ppmd4,ppmd5,ppmd6,ppmd7:ppm
     use entity ppm(structure);

component pph
     port (one,plus2,minus2,plus1,minus1:in bit;  pph:out bit);
end component;
     for ppha,pphb,pphc,pphd:pph use entity
	 pph(structure);

component round
     port (y:in bit_vector(7 downto 0); r:out bit_vector(3 downto 0));
end component;
     for round:round use entity round(structure);

begin

round:round port map (y(7 downto 0),r(3 downto 0));

mlydeca:mlydec port map (y(1),y(0),0,p2a,m2a,p1a,m1a);
ppla:ppl port map (x(0),m2a,p1a,m1a,a(0));
ppma1:ppm port map (x(1),x(0),p2a,m2a,p1a,m1a,a(1));
ppma2:ppm port map (x(2),x(1),p2a,m2a,p1a,m1a,a(2));
ppma3:ppm port map (x(3),x(2),p2a,m2a,p1a,m1a,a(3));
ppma4:ppm port map (x(4),x(3),p2a,m2a,p1a,m1a,a(4));
ppma5:ppm port map (x(5),x(4),p2a,m2a,p1a,m1a,a(5));
ppma6:ppm port map (x(6),x(5),p2a,m2a,p1a,m1a,a(6));
ppma7:ppm port map (x(7),x(6),p2a,m2a,p1a,m1a,a(7));
ppha:pph port map (x(7),p2a,m2a,p1a,m1a,a(8));

mlydecb:mlydec port map (y(3),y(2),y(1),p2b,m2b,p1b,m1b);
pplb:ppl port map (x(0),m2b,p1b,m1b,b(0));
ppmb1:ppm port map (x(1),x(0),p2b,m2b,p1b,m1b,b(1));
ppmb2:ppm port map (x(2),x(1),p2b,m2b,p1b,m1b,b(2));
ppmb3:ppm port map (x(3),x(2),p2b,m2b,p1b,m1b,b(3));
ppmb4:ppm port map (x(4),x(3),p2b,m2b,p1b,m1b,b(4));
ppmb5:ppm port map (x(5),x(4),p2b,m2b,p1b,m1b,b(5));
ppmb6:ppm port map (x(6),x(5),p2b,m2b,p1b,m1b,b(6));
ppmb7:ppm port map (x(7),x(6),p2b,m2b,p1b,m1b,b(7));
pphb:pph port map (x(7),p2b,m2b,p1b,m1b,b(8));

mlydecc:mlydec port map (y(5),y(4),y(3),p2c,m2c,p1c,m1c);
pplc:ppl port map (x(0),m2c,p1c,m1c,c(0));
ppmc1:ppm port map (x(1),x(0),p2c,m2c,p1c,m1c,c(1));
ppmc2:ppm port map (x(2),x(1),p2c,m2c,p1c,m1c,c(2));
ppmc3:ppm port map (x(3),x(2),p2c,m2c,p1c,m1c,c(3));
ppmc4:ppm port map (x(4),x(3),p2c,m2c,p1c,m1c,c(4));
ppmc5:ppm port map (x(5),x(4),p2c,m2c,p1c,m1c,c(5));
ppmc6:ppm port map (x(6),x(5),p2c,m2c,p1c,m1c,c(6));
ppmc7:ppm port map (x(7),x(6),p2c,m2c,p1c,m1c,c(7));
pphc:pph port map (x(7),p2c,m2c,p1c,m1c,c(8));

mlydecd:mlydec port map (y(7),y(6),y(5),p2d,m2d,p1d,m1d);
ppld:ppl port map (x(0),m2d,p1d,m1d,d(0));
ppmd1:ppm port map (x(1),x(0),p2d,m2d,p1d,m1d,d(1));
ppmd2:ppm port map (x(2),x(1),p2d,m2d,p1d,m1d,d(2));
ppmd3:ppm port map (x(3),x(2),p2d,m2d,p1d,m1d,d(3));
ppmd4:ppm port map (x(4),x(3),p2d,m2d,p1d,m1d,d(4));
ppmd5:ppm port map (x(5),x(4),p2d,m2d,p1d,m1d,d(5));
ppmd6:ppm port map (x(6),x(5),p2d,m2d,p1d,m1d,d(6));
ppmd7:ppm port map (x(7),x(6),p2d,m2d,p1d,m1d,d(7));
pphd:pph port map (x(7),p2d,m2d,p1d,m1d,d(8));

end structure;
-- --------------------------------------------
--                                           --
-- VHDL SIMULATION OF WALLACE TREE ADDER     --
--                                           --
--     input a,b,c,d vectors from PP         --
--   output sum and carry vecors to CPA      --
--                                           --
-----------------------------------------------


-- ---------------------------------------------
-- VHDL FULL ADDER MODEL 
-- ---------------------------------------------

entity full_adder is

   port(x:in bit;
        y:in bit;
        z:in bit;
        sum:out bit;
        car:out bit);

end full_adder;


architecture structure of full_adder is

signal s1,s2,s3,s4,s5,s6,s7,s8,s9,s10:bit;

begin

s1  <= (x and y and z);
s2  <= not y;
s3  <= not z;
s4  <= not x;
s5  <= (x and s2 and s3);
s6  <= (z and s2 and s4);
s7  <= (s4 and y and s3);
s8  <= (x and y);
s9  <= (x or y);
s10 <= (z and s9);
sum <= (s1 or s5 or s6 or s7);
car <= (s8 or s10);

end structure;


-- -------------------------------------------
-- STRUCTURE MODEL OF WALLACE TREE
-- -------------------------------------------

entity wallace_twos is

   port (a:in bit_vector (8 downto 0);
         b:in bit_vector (8 downto 0);
         c:in bit_vector (8 downto 0);
         d:in bit_vector (8 downto 0);
         r:in bit_vector (3 downto 0);
         summ: out bit_vector (15 downto 0);
         carry:out bit_vector (15 downto 0));

end wallace_twos;


architecture structure of wallace_twos is
 
  label fa1,fa2,fa3,fa4,fa5,fa6,fa7,fa8,fa9,fa10;
  label fa11,fa12,fa13,fa14,fa15,fa16,fa17,fa18,fa19;
  label fa20,fa21,fa22,fa23,fa24,fa25,fa26,fa27,fa28,fa29;
  label fa30,fa31,fa32,fa33,fa34,fa35;

signal sfas:bit_vector (29 downto 0);
signal sfac:bit_vector (29 downto 0);

--
--

component fa

   port (x:in bit;
         y:in bit;
         z:in bit;
         sum:out bit;
         car:out bit);

end component;


for fa1,fa2,fa3,fa4,fa5,fa6,fa7,fa8,fa9,fa10,
    fa11,fa12,fa13,fa14,fa15,fa16,fa17,fa18,fa19,
    fa20,fa21,fa22,fa23,fa24,fa25,fa26,fa27,fa28,fa29,
    fa30,fa31,fa32,fa33,fa34,fa35:fa
use entity full_adder(structure);

--
--
--

begin

fa1 : fa port map ( a(0),0,r(0),summ(0),carry(1));
fa2 : fa port map ( a(1),0,0,summ(1),carry(2));
fa3 : fa port map ( a(2),b(0),r(1),summ(2),carry(3)); 
fa4 : fa port map ( a(3),b(1),0,summ(3),carry(4));
fa5 : fa port map ( a(4),b(2),c(0),sfas(5),sfac(5));
fa6 : fa port map ( a(5),b(3),c(1),sfas(6),sfac(6));
fa7 : fa port map ( c(2),d(0),sfac(4),sfas(7),sfac(7));
fa8 : fa port map ( a(6),b(4),sfac(6),sfas(8),sfac(8));
fa9 : fa port map ( d(1),sfac(7),sfac(8),sfas(9),sfac(9));
fa10: fa port map ( a(7),b(5),c(3),sfas(10),sfac(10));
fa11: fa port map ( d(2),sfac(9),sfac(10),sfas(11),sfac(11));
fa12: fa port map ( a(8),b(6),c(4),sfas(12),sfac(12));
fa13: fa port map ( sfac(11),sfac(12),1,sfas(13),sfac(13));
fa14: fa port map ( b(7),c(5),d(3),sfas(14),sfac(14));
fa15: fa port map ( sfac(13),sfac(14),0,sfas(15),sfac(15));
fa16: fa port map ( b(8),c(6),d(4),sfas(16),sfac(16));
fa17: fa port map ( sfac(16),sfac(15),0,sfas(17),sfac(17));
fa18: fa port map ( c(7),d(5),1,sfas(18),sfac(18));
fa19: fa port map ( sfac(17),sfac(18),0,sfas(19),sfac(19));
fa20: fa port map ( c(8),d(6),0,sfas(20),sfac(20));
fa21: fa port map ( d(7),sfac(19),sfac(20),sfas(21),sfac(21));
fa22: fa port map ( d(8),sfac(0),sfac(21),summ(14),carry(15));
fa23: fa port map ( sfas(20),sfas(19),0,summ(12),carry(13));
fa24: fa port map ( sfas(18),sfas(17),0,summ(11),carry(12));
fa25: fa port map ( sfas(15),sfas(16),0,summ(10),carry(11));
fa26: fa port map ( sfas(13),sfas(14),0,summ(9),carry(10));
fa27: fa port map ( sfas(11),sfas(12),1,summ(8),carry(9));
fa28: fa port map ( sfas(9),sfas(10),0,summ(7),carry(8));
fa29: fa port map ( sfas(7),sfas(8),r(3),summ(6),carry(7));
fa30: fa port map ( 1,0,0,sfas(0),sfac(0));
fa31: fa port map ( sfas(21),sfas(0),0,summ(13),carry(14));
fa32: fa port map ( r(2),0,0,sfas(2),sfac(2));
fa33: fa port map ( sfas(5),sfas(2),0,summ(4),carry(5));
fa34: fa port map ( sfac(2),sfac(5),0,sfas(4),sfac(4));
fa35: fa port map ( sfas(4),sfas(6),0,summ(5),carry(6));

end structure;

-- --------------------------------------------
-- END 
-- --------------------------------------------
-- ---------------------------------------------------------------------------
--  STRUCTURE MODEL OF CARRY LOOK AHEAD
--
------------------------------------------------------------------------------
entity  cla is

  port (a,b: in bit_vector( 3 downto 0);
        c:in bit;
        cc: out bit_vector ( 3 downto 0));
      
end cla;

architecture  structure of cla is 
    signal x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, y0, xy, cbar :bit; 
    signal gbar :bit_vector(3 downto 0);
    signal pbar :bit_vector(3 downto 0); 
  begin
  
     gbar (3 downto 0)  <= a (3 downto 0) nand b (3 downto 0) after 3ns;
     pbar (3 downto 0)  <= a (3 downto 0) nor  b (3 downto 0) after 3ns;
     cbar  <= not c after 2ns  ;

     x0    <= cbar or pbar(0) after 3ns;
     cc(0) <= x0 nand gbar(0) after 3ns;

     x1    <= cbar or pbar(0) or pbar(1) after 5ns;
     x2    <= pbar(1) or gbar(0) after 3ns;
     cc(1) <= not ( x1 and x2 and gbar(1) ) after 5ns;

     x3    <= cbar or pbar(0) or pbar(1) or pbar(2) after 7 ns;
     x4    <= gbar(0) or pbar(1) or pbar(2) after 5ns;
     x5    <= gbar(1) or pbar(2) after 3ns;
     cc(2) <= not ( x3 and x4 and x5 and gbar(2)) after 9ns;

     x6    <= cbar nor pbar(0) after 3ns;
     x7    <=  not ( pbar(1) or pbar(2) or pbar(3)) after 5ns;
     x8    <= not ( gbar(0)  or pbar(1) or pbar(2) or pbar(3)) after 7ns;
     x9    <= not ( gbar(1) or pbar(2) or pbar(3)) after 5ns;
     x10   <=  gbar(2) nor pbar(3) after 3ns;
     y0    <=  x6 and x7 after 3ns;
     xy    <=  not ( y0 or x8 or x9 or x10 ) after 7ns;
     cc(3) <=  xy nand gbar(3) after 3ns;
end structure;

-------------------------------------------------------------------------
--
--   FALF ADDER
-------------------------------------------------------------------------

entity half_adder is
  
  port(
        x:in bit;
        y: in bit;
        ca: in bit;
     sum:out bit);
  end half_adder;

architecture structure of half_adder is
 begin
   sum <=( x xor y) xor ca after 5ns;
 end structure;

---------------------------------------------------------------------------
--
-- prograted delay adder
--
---------------------------------------------------------------------------

entity pda is
 
 port(
       summ: in bit_vector( 15 downto 0 );
       carry: in bit_vector( 15 downto 0);
       result: out bit_vector( 14 downto 0));
 end pda;


architecture structure of pda is

  label cla_0, cla_1, cla_2, cla_3,hf0, hf1, hf2, hf3,hf4;
  label hf5, hf6, hf7, hf8, hf9, hf10, hf11, hf12, hf13, hf14, hf15;

signal car: bit_vector( 15 downto 0);

  component cla_c
      port( a:in bit_vector(3 downto 0);b:in bit_vector(3 downto 0);
             c: in bit;cc:out bit_vector(3 downto 0));
  end component;

   for cla_0,cla_1,cla_2,cla_3: cla_c
                                 use entity cla(structure);
  component hf
     port (x, y,ca : in bit;
           sum  : out bit);
  end component;

  for hf0,hf1,hf2,hf3,hf4,hf5,hf6,hf7,hf8,hf9,hf10,hf11,hf12,hf13,hf14,hf15:hf
   use entity half_adder(structure);


 begin

   cla_0: cla_c port map(summ( 3 downto 0), carry( 3 downto 0),0,
                       car(3 downto 0));
  
   cla_1: cla_c port map(summ( 7 downto 4), carry( 7 downto 4),car(3),
                       car(7 downto 4));

   cla_2: cla_c port map(summ( 11 downto 8), carry( 11 downto 8),car(7),
                       car(11 downto 8));

   cla_3: cla_c port map(summ( 15 downto 12), carry( 15 downto 12),car(11),
                       car(15 downto 12));
   
  
   hf0: hf port map ( summ(0),carry(0),0,result(0));
 
   hf1: hf port map ( summ(1),carry(1),car(0),result(1));

   hf2: hf port map ( summ(2),carry(2),car(1),result(2));

   hf3: hf port map ( summ(3),carry(3),car(2),result(3));

   hf4: hf port map ( summ(4),carry(4),car(3),result(4));

   hf5: hf port map ( summ(5),carry(5),car(4),result(5));

   hf6: hf port map ( summ(6),carry(6),car(5),result(6));

   hf7: hf port map ( summ(7),carry(7),car(6),result(7));

   hf8: hf port map ( summ(8),carry(8),car(7),result(8));

   hf9: hf port map ( summ(9),carry(9),car(8),result(9));

   hf10:hf port map ( summ(10),carry(10),car(9),result(10));

   hf11:hf port map ( summ(11),carry(11),car(10),result(11));

   hf12:hf port map ( summ(12),carry(12),car(11),result(12));

   hf13:hf port map ( summ(13),carry(13),car(12),result(13));

   hf14:hf port map ( summ(14),carry(14),car(13),result(14));

   hf15:hf port map ( summ(15),carry(15),car(14),car(15));
end structure;



entity multiplier is
   port(x:in bit_vector(7 downto 0);
	y:in bit_vector(7 downto 0);
        bit:out bit_vector(14 downto 0));
end multiplier;

architecture structure of multiplier is

label pptree,wtree,pda;
signal a,b,c,d:bit_vector(8 downto 0);
signal r:bit_vector(3 downto 0);
signal sum,carry:bit_vector(15 downto 0);

component pptree
     port (x:in bit_vector (7 downto 0);
           y:in bit_vector (7 downto 0);
           a:out bit_vector (8 downto 0);
           b:out bit_vector (8 downto 0);
           c:out bit_vector (8 downto 0);
           d:out bit_vector (8 downto 0);
           r:out bit_vector (3 downto 0));
end component;
	for pptree:pptree use entity pptree(structure);

component wtree
   port (a:in bit_vector (8 downto 0);
         b:in bit_vector (8 downto 0);
         c:in bit_vector (8 downto 0);
         d:in bit_vector (8 downto 0);
         r:in bit_vector (3 downto 0);
         sum: out bit_vector (15 downto 0);
         carry:out bit_vector (15 downto 0));
end component;
	for wtree:wtree use entity wallace_twos(structure);

component pda
 port (sum:in bit_vector(15 downto 0);
       carry:in bit_vector(15 downto 0);
       result:out bit_vector(14 downto 0));
end component;
	for pda:pda use entity pda(structure);

begin

pptree:pptree port map (x(7 downto 0),y(7 downto 0),a(8 downto 0),b(8 downto 0)
			,c(8 downto 0),d(8 downto 0),r(3 downto 0));

wtree:wtree port map (a(8 downto 0),b(8 downto 0),c(8 downto 0),d(8 downto 0),
		      r(3 downto 0),sum(15 downto 0),carry(15 downto 0));

pda:pda port map (sum(15 downto 0),carry(15 downto 0),bit(14 downto 0));

end structure;




