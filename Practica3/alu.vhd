library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity ALU is
    Port ( A 			: in  STD_LOGIC_VECTOR (31 downto 0);
           B 			: in  STD_LOGIC_VECTOR (31 downto 0);
           resultado : out  STD_LOGIC_VECTOR (31 downto 0);
           control   : in  STD_LOGIC_VECTOR (3 downto 0);
           igual 		: out  STD_LOGIC);
end ALU;


architecture Behavior of ALU is

begin

	process (A,B,control)
		variable rAux: std_logic_vector(31 downto 0);
		variable igualAux : std_logic;
	begin
   
      rAux:= (A) - (B);
		if(rAux=x"00000000") then
			igualAux:='1';
      else
			igualAux:='0';
      end if;

		if (control="0000") then
				rAux:= (A) AND (B);
		elsif(control="0001") then
				rAux:= (A) OR (B);
		elsif(control="0010") then
				rAux:= (A) XOR (B);
		elsif(control="0011") then
				rAux:= (A) + (B);
		elsif(control="1000") then
				rAux:= (A) - (B);
		elsif(control="1001") then
				raux:=B(15 downto 0)&x"0000";
		elsif(control="1010") then
				rAux:= (A) - (B);
				if(rAux(31)='1') then
					rAux:=x"00000001";
				else
					rAux:=x"00000000";
				end if;
		else
			 rAux:=(others=>'0');
			 igualAux:='0';

		end if;

		resultado<=rAux;
		igual<=igualAux;

	end process;

end Behavior; 