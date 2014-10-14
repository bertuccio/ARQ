library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Hazard is

    Port (  PC_Write : out  STD_LOGIC;
           IFID_Write : out  STD_LOGIC;
           IDEX_Memread : in  STD_LOGIC;
           MUX_sel : out  STD_LOGIC;
           IDEX_Rt : in  STD_LOGIC_VECTOR (4 downto 0);
           IFID_Rs : in  STD_LOGIC_VECTOR (4 downto 0);
           IFID_Rt : in  STD_LOGIC_VECTOR (4 downto 0));
			  
end Hazard;

architecture Behavioral of HAZARD is

begin

process(IDEX_Memread,IFID_Rs,IFID_Rt,IDEX_Rt) 
begin

	if IDEX_Memread='1' AND (IDEX_Rt=IFID_Rs OR IDEX_Rt=IFID_Rt) then 
			PC_Write<='0';
			IFID_Write<='0';
			Mux_sel<='1';
	else 
		PC_Write<='1';
		IFID_Write<='1';
		Mux_sel<='0';
	end if;


end process;

end Behavioral;