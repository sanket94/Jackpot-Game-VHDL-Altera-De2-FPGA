library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity counter_bet is
	generic(tcount : natural := 60;
			N_bits : natural := 6);
	port(clk,en,rst,increase,decrease: in std_logic;
		 tc : out std_logic;
		output : out std_logic_vector(N_bits-1 downto 0));
end counter_bet;

architecture arch of counter_bet is 
	signal count_out : std_logic_vector(N_bits-1 downto 0) := (others => '0');
begin
output <= count_out;
process(clk)
begin
	if rising_edge(clk) then
		tc <= '0';
		if rst ='1' then 
			count_out <= (others => '0');
		elsif count_out = (tcount - 1) then 
			count_out <= 	(others => '0');
			tc <='1';
		elsif en='1' then
			if increase ='1' then
				count_out <= count_out + '1';
			elsif decrease ='1' then
				count_out <= count_out - '1';
			end if;
		end if;
	end if;
end process;
end arch;