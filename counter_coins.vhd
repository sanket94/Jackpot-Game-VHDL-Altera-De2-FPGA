library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity counter_coins is
	generic(tcount : natural := 60;
			N_bits : natural := 6);
	port(clk,en,rst: in std_logic;
		 tc : out std_logic;
		output : out std_logic_vector(N_bits-1 downto 0));
end counter_coins;

architecture arch of counter_coins is 
	signal count_out,bet : std_logic_vector(N_bits-1 downto 0) := (others => '0');
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
			count_out <= count_out + bet;
		end if;
	end if;
end process;
end arch;