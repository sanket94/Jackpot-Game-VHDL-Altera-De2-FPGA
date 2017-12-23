library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity bigclock is
	
	port(clk,srst,pause,pause1,pause2,pause3,increase,decrease,rst: in std_logic;
		ledr,ledg: out std_logic_vector(5 downto 0);
		--lcd	
      lcd_rs             : OUT    std_logic;
      lcd_e              : OUT    std_logic;
      lcd_rw             : OUT    std_logic;
      lcd_on             : OUT    std_logic;
      lcd_blon           : OUT    std_logic;
     lcd_out: inout std_logic_vector(7 downto 0);
     --end lcd
     --bet
     bet_result : out std_logic_vector(6 downto 0);
	display0,display1,display2,display3,display4,close4,close5: out std_logic_vector(6 downto 0));
end bigclock;

architecture arch of bigclock is 
	type character_string is array ( 0 to 31 ) of STD_LOGIC_VECTOR( 7 downto 0 );
  
    type state_type is (func_set, display_on, mode_set, print_string, line2, return_home, drop_lcd_e, reset1, reset2,
                       reset3, display_off, display_clear );
  --lcd signals
  signal state, next_command         : state_type;
  signal string_01       : character_string;
  signal string_02       : character_string;
  signal string_03       : character_string;
  signal string_04       : character_string;
  signal data_bus_signal, next_char   : STD_LOGIC_VECTOR(7 downto 0);
  signal clk_count_400hz             : STD_LOGIC_VECTOR(23 downto 0);
  signal char_count                  : STD_LOGIC_VECTOR(4 downto 0);
  signal clk_enable,lcd_rw_int : std_logic;
  signal data_bus                    : STD_LOGIC_VECTOR(7 downto 0);	
  signal string_control              : STD_LOGIC_VECTOR(1 DOWNTO 0);
  signal freq_ctr: integer range 0 to 2**27-1:=0;
constant period: integer range 0 to 2**27-1:=50000000;
--end of lcd signals
---------------------------------
--start of hex display signals
	signal counter1 : std_logic := '0';
	signal counter3 : std_logic := '0';
	signal counter4 : std_logic := '0';
	signal counter5 : std_logic := '0';
	signal counter6 : std_logic := '0';
	signal counter2_1 : std_logic_vector(3 downto 0) := (others => '0');
	signal counter2_2 : std_logic_vector(3 downto 0) := (others => '0');
	signal counter2_3 : std_logic_vector(3 downto 0) := (others => '0');
	signal counter2_4 : std_logic_vector(3 downto 0) := (others => '0');
	signal counter2_5 : std_logic_vector(3 downto 0) := (others => '0');
	signal not_reset : std_logic := '1';
	signal not_pause : std_logic := '1';
	signal not_pause1 : std_logic := '1';
	signal not_pause2 : std_logic := '1';
	signal not_increase : std_logic := '1';
	signal not_decrease : std_logic := '1';
	signal not_rst : std_logic := '1';
	signal disp0: std_logic_vector(6 downto 0) := (others => '0');
	signal disp1 : std_logic_vector(6 downto 0) := (others => '0');
	signal disp2 : std_logic_vector(6 downto 0) := (others => '0');
	signal disp3 : std_logic_vector(6 downto 0) := (others => '0');
	signal disp4 : std_logic_vector(6 downto 0) := (others => '0');
	signal disp5 : std_logic_vector(6 downto 0);
-- end of hex display signals
----------------------------------
--start of bet signal
begin
--process for led lights on results
close4 <= "1111111";--keeps the unused seven segment display off
close5 <= "1111111";
not_pause <= not pause;-- this to reverse logic as the buttons are active low
not_pause1 <= not pause1;
not_pause2 <= not pause2;
not_reset <= not srst;
display0 <= not disp0;
display1 <= not disp1;
display2 <= not disp2;
display3 <= not disp3;
display4 <= not disp4;

not_increase <= not increase;
not_decrease <= not decrease;
not_rst <= not rst;
--start of process for led lights on result
process(disp0,disp1,disp2)
begin
if (disp0=disp1) then
	if (disp0=disp2) then
		ledr <= "000000";
		ledg <= "111111";
	else
		ledg <= "000000";
		ledr <= "111111";
	end if;
else
	ledr <= "111111";
	ledg <= "000000";
end if;
end process;
--end of process for led lights on results
-----------------------------------------------------
--start of lcd strings
--string_control <= LCD_CHAR_ARRAY_IN;
lcd_out <=data_bus ;
string_01 <= 
(
x"20",x"2A",x"2A",x"2A",x"57",x"65",x"6C",x"63",x"6F",x"6D",x"65",x"2A",x"2A",x"2A",x"20",x"20",
x"21",x"21", x"4A",x"61",x"63",x"6B",x"70",x"6F",x"74",x"20",x"47",x"61",x"6D",x"65",x"21",x"21"
);
string_02 <=
(
x"43",x"6F",x"6E",x"67",x"72",x"61",x"74",x"75",x"6C",x"61",x"74", x"69",x"6F",x"6E",x"73",x"20",
x"59",x"6F",x"75",x"20",x"57",x"6F",x"6E",x"21",x"21",x"20",x"20",x"20",x"20",x"20",x"20",x"20"
);
string_03 <=
(
x"53",x"6F",x"72",x"72",x"79",x"20",x"59",x"6F",x"75",x"20",x"4C",x"6F",x"73",x"74",x"20",x"20",
x"50",x"72",x"65",x"73",x"73",x"20",x"52",x"65",x"73",x"65",x"74",x"20",x"20",x"20",x"20",x"20"
);
string_04 <=
(
x"50",x"75",x"6C",x"6C",x"20",x"73",x"77",x"69",x"74",x"63",x"68",x"65",x"73",x"20",x"31",x"20",
x"62",x"79",x"20",x"31",x"20",x"66",x"6F",x"72",x"20",x"52",x"65",x"73",x"75",x"6C",x"74",x"20"
);
data_bus <= data_bus_signal when lcd_rw_int = '0' else "ZZZZZZZZ";
lcd_rw <= lcd_rw_int;
-- end of string making
------------------------------
--start of process to deicide which string is to be used
------------------------------------------------------
PROCESS (string_control)
BEGIN

     CASE (string_control) IS
	when "00"=>
next_char<=string_01(CONV_INTEGER(char_count));
when "10"=>
next_char<=string_02(CONV_INTEGER(char_count));
when "11"=>
next_char<=string_03(CONV_INTEGER(char_count));
when "01"=>
next_char<=string_04(CONV_INTEGER(char_count));
when others=>
next_char<=string_04(CONV_INTEGER(char_count));
end case;
end process;
--end of process which string to be used
------------------------------------------
process(pause,pause1,pause2,pause3,disp0,disp1,disp2)
begin
	if (pause='0') then
		if (pause1='0') then
			if (pause2='0') then
				if (pause3='1') then
					if (disp0=disp1) then
							if (disp0=disp2) then
								string_control <= "00";
							end if;
					end if;
				end if;
			end if;
		end if;
	end if;
	if (pause='1') then
		if (pause1='1') then
			if (pause2='1') then
				if (pause3='1') then
					if (disp0 /= disp2) then
							string_control	<="01";
					end if;
				end if;
			end if;
		end if;
	end if;
	if (pause='0') then
		if (pause1='0') then
			if (pause2='0') then
				if (pause3='0') then
						if (disp0=disp1) then
							if (disp0=disp2) then
								string_control <= "10"; 
								else
								string_control <= "11";
							end if;
						end if;
				end if;
			end if;
		end if;
	end if;
	if (pause='0') then
		if (pause1='0') then
			if (pause2='0') then
				if (pause3='0') then
					if (disp0 /= disp1) then
						if (disp1 /= disp2) then
							string_control <= "11"; 
						else
							string_control <= "11";
						end if;
					end if;
						
				end if;
			end if;
		end if;
	end if;
						
			
end process;
---------------------------------------
--clock divider for lcd display
process(clk)
begin
      if (rising_edge(clk)) then
         if (srst = '0') then
            clk_count_400hz <= x"000000";
            clk_enable <= '0';
         else
          if (clk_count_400hz <= x"00F424") then 
		  clk_count_400hz <= clk_count_400hz + 1;                                          
                   clk_enable <= '0';                
           else
                   clk_count_400hz <= x"000000";
                   clk_enable <= '1';
            end if;
         end if;
      end if;
end process;  
--end of clock divider for lcd display
--------------------------------------------
--start of lcd display control
------------------------------------
process (clk, srst)
begin
        if srst = '0' then
           state <= reset1;
           data_bus_signal <= x"38"; 
           next_command <= reset2;
           lcd_e <= '1';
           lcd_rs <= '0';
           lcd_rw_int <= '0';  
        elsif rising_edge(clk) then
             if clk_enable = '1' then  
                    case state is
						when reset1 =>
                            lcd_e <= '1';
                            lcd_rs <= '0';
                            lcd_rw_int <= '0';
                            data_bus_signal <= x"38"; 
                            state <= drop_lcd_e;
                            next_command <= reset2;
                            char_count <= "00000";
  
                       when reset2 =>
                            lcd_e <= '1';
                            lcd_rs <= '0';
                            lcd_rw_int <= '0';
                            data_bus_signal <= x"38"; 
                            state <= drop_lcd_e;
                            next_command <= reset3;
                            
                       when reset3 =>
                            lcd_e <= '1';
                            lcd_rs <= '0';
                            lcd_rw_int <= '0';
                            data_bus_signal <= x"38"; 
                            state <= drop_lcd_e;
                            next_command <= func_set;
                    
                       when func_set =>                
                            lcd_e <= '1';
                            lcd_rs <= '0';
                            lcd_rw_int <= '0';
                            data_bus_signal <= x"38"; 
                            state <= drop_lcd_e;
                            next_command <= display_off;
                        
                       when display_off =>
                            lcd_e <= '1';
                            lcd_rs <= '0';
                            lcd_rw_int <= '0';
                            data_bus_signal <= x"08"; 
                            state <= drop_lcd_e;
                            next_command <= display_clear;
                        
                       when display_clear =>
                            lcd_e <= '1';
                            lcd_rs <= '0';
                            lcd_rw_int <= '0';
                            data_bus_signal <= x"01"; -- Clears the Display    
                            state <= drop_lcd_e;
                            next_command <= display_on;
                     
                       when display_on =>
                            lcd_e <= '1';
                            lcd_rs <= '0';
                            lcd_rw_int <= '0';
                            data_bus_signal <= x"0C"; 
                            state <= drop_lcd_e;
                            next_command <= mode_set;
                        
                       when mode_set =>
                            lcd_e <= '1';
                            lcd_rs <= '0';
                            lcd_rw_int <= '0';
                            data_bus_signal <= x"06"; 
                            state <= drop_lcd_e;
                            next_command <= print_string; 
when print_string =>          
                            state <= drop_lcd_e;
                            lcd_e <= '1';
                            lcd_rs <= '1';
                            lcd_rw_int <= '0';
                       if (next_char(7 downto 4) /= x"0") then
                                  data_bus_signal <= next_char;
                               else
                           if next_char(3 downto 0) >9 then
                       else      
                            data_bus_signal <= x"3" & next_char(3 downto 0);
                                    end if;
                               end if;
                         
                               if (char_count < 31) AND (next_char /= x"fe") then
                                   char_count <= char_count +1;                            
                               else
                                   char_count <= "00000";
                               end if;
                  
                           
                               if char_count = 15 then 
                                  next_command <= line2;
                   
                          
                               elsif (char_count = 31) or (next_char = x"fe") then
                                     next_command <= return_home;
                               else 
                                     next_command <= print_string; 
                               end if; 
                     
                       when line2 =>
                            lcd_e <= '1';
                            lcd_rs <= '0';
                            lcd_rw_int <= '0';
                            data_bus_signal <= x"c0";
                            state <= drop_lcd_e;
                            next_command <= print_string;      
                    
                       when return_home =>
                            lcd_e <= '1';
                            lcd_rs <= '0';
                            lcd_rw_int <= '0';
                            data_bus_signal <= x"80";
                            state <= drop_lcd_e;
                            next_command <= print_string; 
                     
						when drop_lcd_e =>
                            state <= next_command;
                            lcd_e <= '0';
                            lcd_blon <= '1';
                            lcd_on   <= '1';
                        end case;
             end if;
      end if;
      
end process;                                                            
-----------------------------
-- end of lcd display control

----------------------------------------------------------
--start of bet
------------------------
--
process(disp3,disp0,disp2,disp1)
begin
if (disp0=disp1) then
	if (disp0=disp2) then
		case  disp3 is 
			when "0000110"=> disp5 <=  "1111100";
			when "0111111" => disp5 <= "1101101";
			when  "1011011"=> disp5 <= "0000111";
			when  "1001111"=> disp5 <= "1111111";
			when  "1100110"=> disp5 <= "1100111";
			when others => disp5 <= "1111001";
		end case;
	else
		case disp3 is
			when "1100110" => disp5 <= "0000110";
			when "1001111" => disp5 <= "1011011";
			when "1011011" => disp5 <= "1001111";
			when "0000110" => disp5 <= "1100110";
			when "0111111" => disp5 <= "1101101";
			when "1101101" => disp5 <= "0111111";
			when others => disp5 <= "1111001";
		end case;
	end if;
end if;
bet_result <= not  disp5;
end process;
------------------------------
-- start of components for jackpot game and hex display
-------------------------------------------------
counterA : entity work.counter
	generic map(tcount =>5000000,
			N_bits => 26)
	port map (clk => clk,
				srst =>not_reset,
				pause => not_pause,
				en => '1',
				tc => counter1,
				output => open);
counterB : entity work.counter1
	generic map(tcount =>6000000,
			N_bits => 26)
	port map (clk => clk,
				srst =>not_reset,
				pause => not_pause1,
				en => '1',
				tc => counter3,
				output => open);
counterC : entity work.counter2
	generic map(tcount =>7000000,
			N_bits => 26)
	port map (clk => clk,
				srst =>not_reset,
				pause => not_pause2,
				en => '1',
				tc => counter4,
				output => open);
counterD : entity work.counter_bet
	generic map(tcount =>5000000,
			N_bits => 26)
	port map (clk => clk,
				rst =>not_rst,
				increase =>not_increase,
				decrease =>not_decrease,
				en => '1',
				tc => counter5,
				output => open);

CounterA1 : entity work.counter
	generic map(tcount =>11,
			N_bits => 4)
	port map (clk => clk,
				srst => not_reset,
				pause => not_pause,
				en => counter1,
				tc =>open ,
				output => counter2_1 );
CounterB1 : entity work.counter1
	generic map(tcount =>11,
			N_bits => 4)
	port map (clk => clk,
				srst => not_reset,
				pause => not_pause1,
				en => counter3,
				tc => open,
				output => counter2_2  );
CounterC1 : entity work.counter2
	generic map(tcount =>11,
			N_bits => 4)
	port map (clk => clk,
				srst => not_reset,
				pause => not_pause2,
				en => counter4,
				tc => open,
				output => counter2_3  );

CounterD1 : entity work.counter_bet
	generic map(tcount =>6,
			N_bits => 4)
	port map (clk => clk,
				rst => not_rst,
				increase =>not_increase,
				decrease =>not_decrease,
				en => counter5,
				tc =>counter6 ,
				output => counter2_4 );
CounterD2 : entity work.counter_bet
	generic map(tcount =>1,
			N_bits => 4)
	port map (clk => clk,
				rst => not_rst,
				increase =>not_increase,
				decrease =>not_decrease,
				en => counter6,
				tc => open,
				output => counter2_5 );
BCD1: entity work.ssd
	port map (bcd =>  counter2_1,
			seg_out => disp0);
BCD2: entity work.ssd
	port map (bcd =>  counter2_2,
			seg_out => disp1);
BCD3: entity work.ssd
	port map (bcd =>  counter2_3,
			seg_out => disp2);
BCD4: entity work.ssd
	port map (bcd =>  counter2_4,
			seg_out => disp3);
BCD5: entity work.ssd
	port map (bcd =>  counter2_5,
			seg_out => disp4);					
			
				
end arch;
