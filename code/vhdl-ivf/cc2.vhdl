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

--  Title: 	Cross-Coupled Random Logic
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
    port (inp : in  bit_vector(2 downto 0);
	  outp: out bit_vector(1 downto 0));
end random;
--
architecture str of random is
--  
    signal and1 : bit;
--
--
begin
--
    outp(0) <= and1 or inp(0);
    outp(1) <= inp(2) or and1;
    and1 <= outp(0) and inp(1);

end str;
