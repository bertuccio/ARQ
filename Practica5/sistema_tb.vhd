--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   10:32:33 11/27/2009
-- Design Name:   
-- Module Name:   D:/practica3/sistema_tb.vhd
-- Project Name:  proyecto
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: sistema
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
 
ENTITY sistema_tb IS
END sistema_tb;
 
ARCHITECTURE behavior OF sistema_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT sistema
    PORT(
         Clk : IN  std_logic;
         Reset : IN  std_logic;
         data_perif_1 : INOUT  std_logic_vector(7 downto 0);
         data_perif_2 : INOUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal Clk : std_logic := '0';
   signal Reset : std_logic := '0';

	--BiDirs
   signal data_perif_1 : std_logic_vector(7 downto 0);
   signal data_perif_2 : std_logic_vector(7 downto 0);
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: sistema PORT MAP (
          Clk => Clk,
          Reset => Reset,
          data_perif_1 => data_perif_1,
          data_perif_2 => data_perif_2
        );
   
 
process
begin

	RESET <= '1';
	wait for 20 ns;
	
	RESET <= '0';
	wait;

end process;

process
begin
	CLK <= '0';
	wait for 5 ns;
	CLK <= '1';
	wait for 5 ns;
end process;
 

process
begin		

data_perif_1 <= x"AA";
wait for 100 ns;	

data_perif_1 <= x"45";
wait for 100 ns;	

data_perif_1 <= x"37";
wait for 100 ns;	


end process;

END;
