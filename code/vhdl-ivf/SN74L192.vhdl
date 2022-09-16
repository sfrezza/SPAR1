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

-- Author: Saverio Fazzari

------------------------------------------------------------------
--    sn74l192_3.vhdl
------------------------------------------------------------------


entity RS is
   port( s, s1, r, r1: in bit; qrs, qbrs: out bit );
end RS;

-------------------------------------------------------------------

architecture rs_struct of RS is
begin
   qrs <= not((s and s1)and qbrs);
   qbrs <= not((r and r1)and qrs);
end rs_struct;
 
------------------------------------------------------------------

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--   t_ff
------------------------------------------------------------------

entity T_FF is
   port( nset, nclr, ck: in bit; q, qb: out bit );
end T_FF;

------------------------------------------------------------------

architecture tff_struct of T_FF is

   label rs1, rs2, rs3;
   signal q1, qb1, q2, qb2, q3, qb3: bit;
   component rs_ff
      port( ss, ss1, rr, rr1: in bit; qq, qqb: out bit );
   end component;
   for rs1, rs2, rs3: rs_ff
      use entity RS(rs_struct); 

begin
   rs1: rs_ff port map( nset, qb2, ck, nclr, q1, qb1 ); 
   rs2: rs_ff port map( qb1, ck, qb, nclr, q2, qb2 ); 
   rs3: rs_ff port map( nset, qb1, q2, nclr, q, qb );

end tff_struct;

------------------------------------------------------------------



entity SN74L192_3 is
   port(di: in bit_vector(3 downto 0);
         do: out bit_vector(3 downto 0);
         dnct, upct, clear, load: in bit;
         brrw, crry: out bit );
end SN74L192_3;
 
-------------------------------------------------------------------

architecture struct of SN74L192_3 is

   label dff0, dff1, dff2, dff3;
   signal ndo, setd, ckd, clrd: bit_vector(3 downto 0);
   signal ndnct, nupct, nclear, nload: bit;
   signal ss0, ss1, ss2, ss3, ss4, ss5, ss6, ss7, ss8, ss9, ss10, ss11: bit;
 
   component dmsff
      port( dst, dclr, dck: in bit; qo, qob: out bit );
   end component;
   for dff0, dff1, dff2, dff3: dmsff
      use entity T_FF(tff_struct);

begin
   ndnct <= not dnct;
   nupct <= not upct;
   nclear <= not clear;
   nload <= not load;

   setd(0) <= not( nclear and nload and di(0)) after 3ns;
   ckd(0) <= ndnct nor nupct after 9ns;
   ss8 <=  nload nand setd(0) after 10ns;
   clrd(0) <= not( clear and ss8 ) after 20ns;
   dff0: dmsff port map( setd(0), clrd(0), ckd(0), do(0), ndo(0));
   
   setd(1) <= not( nclear and nload and di(1)) after 3ns;
   ss0 <= not( ndnct and ndo(0) and ss2) after 3ns;
   ss1 <= not( nupct and do(0) and ndo(3)) after 3ns;
   ckd(1) <= ss0 and ss1 after 3ns;
   ss9 <=  nload nand setd(1) after 10ns;
   clrd(1) <= not( clear and ss9 ) after 20ns;
   dff1: dmsff port map( setd(1), clrd(1), ckd(1), do(1), ndo(1));

   setd(2) <= not( nclear and nload and di(2)) after 3ns;
   ss3 <= not( ndnct and ndo(0) and ndo(1) and ss2) after 3ns;
   ss4 <= not( nupct and do(0) and do(2)) after 3ns;
   ckd(2) <= ss3 and ss4 after 3ns;
   ss10 <=  nload nand setd(2) after 10ns;
   clrd(2) <= not( clear and ss10 ) after 20ns;
   dff2: dmsff port map( setd(2), clrd(2), ckd(2), do(2), ndo(2));

   setd(3) <= not( nclear and nload and di(3)) after 3ns;
   ss5 <= not( ndnct and ndo(0) and ndo(1) and ndo(2) ) after 3ns;
   ss6 <= not( nupct and do(0) and do(3) ) after 3ns;
   ss7 <= not( nupct and do(0) and do(1) and do(2) ) after 3ns;
   ckd(3) <= ss5 and ss6 and ss7 after 6ns;
   ss11 <=  nload nand setd(3) after 10ns;
   clrd(3) <= not( clear and ss11 ) after 20ns;
   dff3: dmsff port map( setd(3), clrd(3), ckd(3), do(3), ndo(3));

   ss2 <= not( ndo(1) and ndo(2) and ndo(3) ) after 3ns;
   brrw <= not(ndo(0) and ndo(1) and ndo(2) and ndo(3) and  ndnct) after 40ns;
   crry <= not( do(0) and do(3) and nupct ) after 40ns;

end struct;
 
---------------------------------------------------------------------------




