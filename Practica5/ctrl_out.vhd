----------------------------------------------------------------------------------
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ctrl_out is
    generic(NUM_PERIF: integer:=3);
    Port ( dir : in  STD_LOGIC_VECTOR (31 downto 0);
           data_write : in  STD_LOGIC;
           perif_en : out  STD_LOGIC_VECTOR (NUM_PERIF-1 downto 0));
end ctrl_out;

architecture Behavioral of ctrl_out is

begin

	process (data_write,dir)
	
	begin
		if (data_write='1') then
		
			if dir <= x"0000FFFF" and dir >= x"00000000" then 
				perif_en<="001";
				
			elsif dir <= x"600000FF" and dir >= x"60000000" then 
				perif_en<="010";
				
			elsif dir <= x"600001FF" and dir >= x"60000100" then 
				perif_en<="100";
				
			else 
				perif_en<="000";
				
			end if;
		else 
			perif_en<="000";
			
		end if;
	end process;

end Behavioral;

