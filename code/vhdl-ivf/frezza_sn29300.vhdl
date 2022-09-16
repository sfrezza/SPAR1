-- This is vhdl code to specify an SN29300 4-bit parallel-
-- accessed shift register.
-------------------------------------------------------------
-- Author: S.Frezza -- 12/88 Picalab UPitt Engineering
-------------------------------------------------------------

entity D_Latch is
	port(clock, Din, clockbar: in bit; q, qbar: out bit);
end D_Latch;

--------------------------------------------------------------
architecture DL_beh of D_Latch is
begin
    process (clock, Din, clockbar)
    	variable state : bit;
	begin
	if ((clock = '1') and (Din = '0')) then
    	    state := 0;
	 elsif (clock = '1') then
	    state := '1';
	 end if;
         q <= state;
	 qbar <= not state;
     end process;
end DL_beh;
--------------------------------------------------------------
architecture DL_struct of D_Latch is
begin
	q <= Din after 3ns when clock else
		q;
	qbar <= not Din after 3ns when clock else
		qbar;
end DL_struct;

--------------------------------------------------------------
entity SN29300 is
	port(PIn: in bit_vector(3 downto 0);
	     Q: out bit_vector(4 downto 0);
	     Clock, SL, Clear, J, Kbar : in bit);
end SN29300;
--------------------------------------------------------------
architecture beh of SN29300 is

begin
	process(Clock, Clear)
		variable value: bit_vector(3 downto 0);
		variable old_clock: bit;
	begin
		if (clear = '0') then value(3 downto 0) := b"0000";
		elsif ((clock = '1') and (clock /= old_clock)) then
		    if (SL = '0') then
			value(3 downto 0) := PIn(3 downto 0);			
		    else
			case (J & Kbar) is
			    when "00" => value(3 downto 1) := Q(2 downto 0);
					 value(0) := '0';
			    when "01" => value(3 downto 1) := Q(2 downto 0);
				         value(0) := Q(0);
			    when "10" => value(3 downto 1) := Q(2 downto 0);
				         value(0) := not Q(0);
			    when "11" => value(3 downto 1) := Q(2 downto 0);
					 value(0) := '1';
			end case;
		    end if;
		else -- clock is not on a rising edge:
		    value(3 downto 0) := Q(3 downto 0);
		end if;
		old_clock := clock;
		Q(4 downto 0) <= not value(3) & value(3 downto 0);
	end process;
end beh;

--------------------------------------------------------------

--------------------------------------------------------------
architecture str of SN29300 is
	label l0,l1,l2,l3,l4,l5,l6,l7;
	signal Acon, Bcon, Ccon, Dcon: bit;
	signal ClockBar, ClearBar, SLBar, JBar, K, F: bit;
	signal B,C,D,E : bit_vector(3 downto 0);
	component Latch
		port(clock, Din, clockbar: in bit; q, qbar: out bit);
	end component;
	for l0,l1,l2,l3,l4,l5,l6,l7: Latch 
		use entity D_Latch(DL_struct);

begin
	SLBar <= not SL after 3ns;
	ClockBar <= not Clock after 3ns;
	ClearBar <= not Clear after 3ns;
	K <= not KBar after 3ns;
	JBar <= not J after 3ns;

	F<= (J and not Q(0)) or (Q(0) and KBar) after 6ns;

	Acon <= PIn(0) after 3ns when SLBar else
		F;
	Bcon <= PIn(1) after 3ns when SLBar else
		Q(0);
	Ccon <= PIn(2) after 3ns when SLBar else
		Q(1);
	Dcon <= PIn(3) after 3ns when SLBar else
		Q(2);

	L0: Latch port map(Clock, Acon, ClockBar, B(0), C(0));
        L1: Latch port map(Clock, Bcon, ClockBar, B(1), C(1));
	L2: Latch port map(Clock, Ccon, ClockBar, B(2), C(2));
	L3: Latch port map(Clock, Dcon, ClockBar, B(3), C(3));

	L4: Latch port map(ClockBar, B(0), Clock, D(0), E(0));
	L5: Latch port map(ClockBar, B(1), Clock, D(1), E(1));
	L6: Latch port map(ClockBar, B(2), Clock, D(2), E(2));
	L7: Latch port map(ClockBar, B(3), Clock, D(3), E(3));

	Q(3 downto 0) <= b"0000" after 6ns when not Clear else
	    D(3 downto 0) after 3ns;

	Q(4) <= b"1" after 6ns when not Clear else
	       E(3);

end str;
--------------------------------------------------------------
architecture mixed of SN29300 is
	label l0,l1,l2,l3,l4,l5,l6,l7;
	signal Acon, Bcon, Ccon, Dcon: bit;
	signal ClockBar, ClearBar, SLBar, JBar, K, F: bit;
	signal B,C,D,E : bit_vector(3 downto 0);
	component Latch
		port(clock, Din, clockbar: in bit; q, qbar: out bit);
	end component;
	for l0,l1,l2,l3,l4,l5,l6,l7: Latch 
		use entity D_Latch(DL_beh);

begin
	SLBar <= not SL after 3ns;
	ClockBar <= not Clock after 3ns;
	ClearBar <= not Clear after 3ns;
	K <= not KBar after 3ns;
	JBar <= not J after 3ns;

	F<= (J and not Q(0)) or (Q(0) and KBar) after 6ns;

	Acon <= PIn(0) after 3ns when SLBar else
		F;
	Bcon <= PIn(1) after 3ns when SLBar else
		Q(0);
	Ccon <= PIn(2) after 3ns when SLBar else
		Q(1);
	Dcon <= PIn(3) after 3ns when SLBar else
		Q(2);

	L0: Latch port map(Clock, Acon, ClockBar, B(0), C(0));
        L1: Latch port map(Clock, Bcon, ClockBar, B(1), C(1));
	L2: Latch port map(Clock, Ccon, ClockBar, B(2), C(2));
	L3: Latch port map(Clock, Dcon, ClockBar, B(3), C(3));

	L4: Latch port map(ClockBar, B(0), Clock, D(0), E(0));
	L5: Latch port map(ClockBar, B(1), Clock, D(1), E(1));
	L6: Latch port map(ClockBar, B(2), Clock, D(2), E(2));
	L7: Latch port map(ClockBar, B(3), Clock, D(3), E(3));

	Q(3 downto 0) <= b"0000" after 6ns when not Clear else
	    D(3 downto 0) after 3ns;

	Q(4) <= b"1" after 6ns when not Clear else
	       E(3);

end mixed;

--------------------------------------------------------------
