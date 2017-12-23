library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity ssd is
	
	port(bcd: in std_logic_vector(3 downto 0);
		seg_out : out std_logic_vector(6 downto 0));
end ssd;

architecture arch of ssd is
begin
	with bcd select seg_out <=
			"0111111" when "0000",
			"0000110" when "0001",
			"1011011" when "0010",
			"1001111" when "0011",
			"1100110" when "0100",
			"1101101" when "0101",
			"1111100" when "0110",
			"0000111" when "0111",
			"1111111" when "1000",
			"1100111" when "1001",
			"1111001" when others;
	end arch;
			