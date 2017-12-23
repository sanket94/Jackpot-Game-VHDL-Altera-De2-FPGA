library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity counter is
	generic(tcount : natural := 60;
			N_bits : natural := 6);
	port(clk,en,srst,pause: in std_logic;
		 tc : out std_logic;
		output : out std_logic_vector(N_bits-1 downto 0));
end counter;

architecture arch of counter is 
	signal count_out : std_logic_vector(N_bits-1 downto 0) := (others => '0');
begin
output <= count_out;
process(clk)
begin
	if rising_edge(clk) then
		tc <= '0';
		if srst ='1' then 
			count_out <= (others => '0');
		elsif pause = '1' then
			count_out <= count_out;
		elsif count_out = (tcount - 1) then 
			count_out <= 	(others => '0');
			tc <='1';
		elsif en='1' then
			count_out <= count_out + '1';
		end if;
	end if;
end process;
end arch;