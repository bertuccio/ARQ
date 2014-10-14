
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity ForwardingUnit is

    Port ( EX_MEM_ESCREG : in  STD_LOGIC;
           MEM_WB_ESCREG : in  STD_LOGIC;
           AnticipaA : out  STD_LOGIC_VECTOR (1 downto 0);
           AnticipaB : out  STD_LOGIC_VECTOR (1 downto 0);
           ID_EX_RS : in  STD_LOGIC_VECTOR (4 downto 0);
           ID_EX_RT : in  STD_LOGIC_VECTOR (4 downto 0);
           EX_MEM_RD : in  STD_LOGIC_VECTOR (4 downto 0);
           MEM_WB_RD : in  STD_LOGIC_VECTOR (4 downto 0));
			  
end ForwardingUnit;

architecture Behavioral of ForwardingUnit is

begin

process (EX_MEM_ESCREG,EX_MEM_RD,ID_EX_RS,MEM_WB_ESCREG,MEM_WB_RD) 

begin

	if EX_MEM_ESCREG='1' and EX_MEM_RD/="00000" and EX_MEM_RD=ID_EX_RS then 
		AnticipaA<="10";
		
	elsif MEM_WB_ESCREG='1' and MEM_WB_RD/="00000" and EX_MEM_RD/=ID_EX_RS and MEM_WB_RD=ID_EX_RS then
		AnticipaA<="01";
		
	else 
		AnticipaA<="00";
		
	end if;
end process;

process (EX_MEM_ESCREG,EX_MEM_RD,ID_EX_RT,MEM_WB_ESCREG,MEM_WB_RD) 

begin

	if EX_MEM_ESCREG='1' and EX_MEM_RD/="00000" and EX_MEM_RD=ID_EX_RT then
			AnticipaB<="10";
			
	elsif MEM_WB_ESCREG='1' and MEM_WB_RD/="00000" and EX_MEM_RD/=ID_EX_RT and MEM_WB_RD=ID_EX_RT then
			AnticipaB<="01";
			
	else 
			AnticipaB<="00";
			
	end if;
end process;

end Behavioral;

