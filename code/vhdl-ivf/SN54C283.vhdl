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

------------------------------------------------------------
-- FILE C283.VHDL
-- John C. Evans 11/25/88
-- last revision: 
--     11/28/88
-----------------------------------------------------------
-- SN54C283
-- John C. Evans
-----------------------------------------------------------
entity SN54C283 is
  port (a,b:in bit_vector(3 downto 0); c0: in bit; s: out 
        bit_vector(3 downto 0); c4: out bit);
end sn54c283;
-----------------------------------------------------------
-- STRUCTURE FOR SN54C283
-----------------------------------------------------------
architecture structure of SN54C283 is
        signal d1,d2,d3,d4,d5,d6,d7,d8,d9,d10: bit;
        signal e1,e2,e3,e4: bit;
        signal f1,f2,f3,f4,f5,f6,f7,f8,f9,f10,f11,f12,f13,f14,f15,
               f16,f17,f18,f19: bit;
        signal g1,g2,g3: bit;
        signal f11x1,f16x1,f16x2,g2x1,g2x2,g3x1,g3x2,g3x3: bit;
        signal c4x1,c4x2,c4x3,c4x4: bit;
begin
        d1 <= not c0 after 3ns;
        d2 <= a(0) nor b(0) after 3ns;
        d3 <= a(0) nand b(0) after 3ns;
        d4 <= a(1) nor b(1) after 3ns;
        d5 <= a(1) nand b(1) after 3ns;
        d6 <= a(2) nor b(2) after 3ns;
        d7 <= a(2) nand b(2) after 3ns;
        d8 <= a(3) nor b(3) after 3ns;
        d9 <= a(3) nand b(3) after 3ns;
--
        e1 <= not d2 after 3ns;
        e2 <= not d4 after 3ns;
        e3 <= not d8 after 3ns;
        e4 <= not d6 after 3ns;
--
        f1 <= not d1 after 3ns;
        f2 <= d3 and e1 after 3ns;
        f3 <= d3 and d1 after 3ns;
        f4 <= d2 after 3ns;         -- buffer
        f5 <= d5 and e2 after 3ns;
        f6 <= d5 and f3 after 3ns;  -- uses f3
        f7 <= d2 and d5 after 3ns;
        f8 <= d4 after 3ns;         -- buffer
        f9 <= e4 and d7 after 3ns;
        f10 <= d7 and f6 after 3ns;  -- uses f6
            f11x1 <= d2 and d5 after 3ns;
        f11 <= d7 and f11x1 after 3ns;
        f12 <= d4 and d7 after 3ns;
        f13 <= d6 after 3ns;        -- buffer 
        f14 <= d9 and e3 after 3ns;
        f15 <= d9 and f10 after 3ns; -- uses f10
            f16x1 <= d9 and d7 after 3ns;
            f16x2 <= f16x1 and d5 after 3ns;
        f16 <= d2 and f16x2 after 3ns;
        f17 <= d4 and f16x1 after 3ns;
        f18 <= d6 and d9 after 3ns;
        f19 <= d8 after 3ns;        -- buffer
--
        g1 <= f4 nor f3 after 3ns;
           g2x1 <= f8 or f7 after 3ns;
           g2x2 <= f6 or g2x1 after 3ns;
        g2 <= not g2x2 after 3ns;
           g3x1 <= f13 or f12 after 3ns;
           g3x2 <= g3x1 or f11 after 3ns;
           g3x3 <= g3x2 or f10 after 3ns;
        g3 <= not g3x3 after 3ns;
--
        s(0) <= f1 xor f2 after 3ns;
        s(1) <= g1 xor f5 after 3ns;
        s(2) <= g2 xor f9 after 3ns;
        s(3) <= g3 xor f14 after 3ns;
--
          c4x1 <= f19 or f18 after 3ns;
          c4x2 <= f17 or f16 after 3ns;
          c4x3 <= c4x1 or c4x2 after 3ns;
          c4x4 <= c4x3 or f15 after 3ns;
        c4 <= not c4x4 after 3ns;
end structure;
------------------------------------------------------------
-- BEHAVIORAL MODEL FOR SN54C283
------------------------------------------------------------
architecture behavioral of SN54C283 is
begin 
    process(a,b,c0)
        variable ahold: bit_vector(4 downto 0);
        variable bhold: bit_vector(4 downto 0);
        variable sum: bit_vector(4 downto 0);
        variable carry: bit;
    begin
        ahold(3 downto 0) := a(3 downto 0);
        bhold(3 downto 0) := b(3 downto 0);
        sum := ahold + bhold + c0;
        carry := sum(4);
        c4 <= carry;
        s(3 downto 0) <= sum(3 downto 0);
    end process;
end behavioral;
------------------------------------------------------------
-- END FILE C283.VHDL
-- John C. Evans  11/25/88
------------------------------------------------------------

