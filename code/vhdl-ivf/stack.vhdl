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

ENTITY stack IS
    PORT (CP, RST, PUSH, POP: IN BIT;
          STACK_IN: IN BIT_VECTOR(11 DOWNTO 0);
          STACK_OUT: OUT BIT_VECTOR(11 DOWNTO 0));
END Stack;

ARCHITECTURE stack_beh OF stack IS
    SIGNAL PTR: BIT_VECTOR (2 DOWNTO 0);
    SIGNAL memory_0, memory_1, memory_2, memory_3, memory_4, memory_5,
           memory_6, memory_7: BIT_VECTOR(11 DOWNTO 0);
BEGIN
    PROCESS
    BEGIN
        WAIT UNTIL (CP = '1');
            IF (RST = '1') THEN
                PTR <= "111";
            ELSIF (PUSH = '1') THEN
                PTR <= PTR + "001";
            ELSIF (POP = '1') THEN
                PTR <= PTR - "001";
            ELSE
                PTR <= PTR;
            END IF;
    END PROCESS;

    PROCESS
    BEGIN
        WAIT UNTIL (CP = '0');
            IF (PUSH = '1') THEN
                CASE PTR IS
                    WHEN "000" => memory_0 <= STACK_IN;
                    WHEN "001" => memory_1 <= STACK_IN;
                    WHEN "010" => memory_2 <= STACK_IN;
                    WHEN "011" => memory_3 <= STACK_IN;
                    WHEN "100" => memory_4 <= STACK_IN;
                    WHEN "101" => memory_5 <= STACK_IN;
                    WHEN "110" => memory_6 <= STACK_IN;
                    WHEN "111" => memory_7 <= STACK_IN;
                END CASE;
            END IF;
    END PROCESS;

    PROCESS (PTR, memory_0, memory_1, memory_2, memory_3, memory_4,
             memory_5, memory_6, memory_7)
    BEGIN
        CASE PTR IS
            WHEN "000" => STACK_OUT <= memory_0;
            WHEN "001" => STACK_OUT <= memory_1;
            WHEN "010" => STACK_OUT <= memory_2;
            WHEN "011" => STACK_OUT <= memory_3;
            WHEN "100" => STACK_OUT <= memory_4;
            WHEN "101" => STACK_OUT <= memory_5;
            WHEN "110" => STACK_OUT <= memory_6;
            WHEN "111" => STACK_OUT <= memory_7;
        END CASE;
    END PROCESS;
END stack_beh;

