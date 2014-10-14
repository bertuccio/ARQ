---------------------------------------------------------------------------------------------------
--
-- Title       : Test Bench for procesador
-- Design      : practica_1
-- Author      : alumnoeps
-- Company     : eps
--
---------------------------------------------------------------------------------------------------
--
-- File        : $DSN\src\TestBench\procesador_TB.vhd
-- Generated   : 15/03/2006, 15:43
-- From        : $DSN\src\procesador.vhd
-- By          : Active-HDL Built-in Test Bench Generator ver. 1.2s
--
---------------------------------------------------------------------------------------------------
--
-- Description : Automatically generated Test Bench for procesador_tb
--
---------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all; 
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

	-- Add your library and packages declaration here ...

entity procesador_tb is
end procesador_tb;

architecture TB_ARCHITECTURE of procesador_tb is
	-- Component declaration of the tested unit
	component procesador
   port(
   	  Clk         : in  std_logic;
	   Reset       : in  std_logic;
      -- Instruction memory
	   I_Addr      : out std_logic_vector(31 downto 0);
	   I_RdStb     : out std_logic;
	   I_WrStb     : out std_logic;
	   I_AddrStb   : out std_logic;
	   I_DataOut   : out std_logic_vector(31 downto 0);
	   I_Rdy       : in  std_logic;
	   I_DataIn    : in  std_logic_vector(31 downto 0);
	   -- Data memory
	   D_Addr      : out std_logic_vector(31 downto 0);
	   D_RdStb     : out std_logic;
	   D_WrStb     : out std_logic;
	   D_AddrStb   : out std_logic;
	   D_DataOut   : out std_logic_vector(31 downto 0);
	   D_Rdy       : in  std_logic;
	   D_DataIn    : in  std_logic_vector(31 downto 0)
   );
	end component;

	component Memoria
	generic (
	   C_ELF_FILENAME     : string;
	   C_TARGET_SECTION   : string;
      C_BASE_ADDRESS     : integer;
      C_MEM_SIZE         : integer;
      C_WAIT_STATES      : integer
   );
	port (
		Clk                : in std_logic;			 
		Reset              : in std_logic;
		Addr               : in std_logic_vector(31 downto 0);
		AddrStb            : in std_logic;
		RdStb              : in std_logic;
		WrStb              : in std_logic;
		DataIn             : in std_logic_vector(31 downto 0);
		DataOut            : out std_logic_vector(31 downto 0);
		Rdy                : out std_logic
	);
   end component;

	signal Clk         : std_logic;
	signal Reset       : std_logic;
   -- Instruction memory
	signal I_Addr      : std_logic_vector(31 downto 0);
	signal I_RdStb     : std_logic;
	signal I_WrStb     : std_logic;
	signal I_AddrStb   : std_logic;
	signal I_DataOut   : std_logic_vector(31 downto 0);
	signal I_Rdy       : std_logic;
	signal I_DataIn    : std_logic_vector(31 downto 0);
	-- Data memory
	signal D_Addr      : std_logic_vector(31 downto 0);
	signal D_RdStb     : std_logic;
	signal D_WrStb     : std_logic;
	signal D_AddrStb   : std_logic;
	signal D_DataOut   : std_logic_vector(31 downto 0);
	signal D_Rdy       : std_logic;
	signal D_DataIn    : std_logic_vector(31 downto 0);		  
	
	constant tper_clk  : time := 50 ns;
	constant tdelay    : time := 100 ns;

begin
	  
	-- Unit Under Test port map
	UUT : procesador
		port map (
			Clk             => Clk,
			Reset           => Reset,
			-- Instruction memory
	      I_Addr          => I_Addr,
  	      I_RdStb         => I_RdStb,
	      I_WrStb         => I_WrStb,
	      I_AddrStb       => I_AddrStb,
	      I_DataOut       => I_DataOut,
	      I_Rdy           => I_Rdy,
	      I_DataIn        => I_DataIn,
	      -- Data memory
	      D_Addr          => D_Addr,
  	      D_RdStb         => D_RdStb,
	      D_WrStb         => D_WrStb,
	      D_AddrStb       => D_AddrStb,
	      D_DataOut       => D_DataOut,
	      D_Rdy           => D_Rdy,
	      D_DataIn        => D_DataIn
		);

	Inst_Mem_Instr : memoria
	generic map (
	   C_ELF_FILENAME     => "programa",
	   C_TARGET_SECTION   => ".text",
      C_BASE_ADDRESS     => 16#00000000#,
      C_MEM_SIZE         => 1024,
      C_WAIT_STATES      => 0
   )
	port map (
		Clk                => Clk,			 
		Reset              => Reset,
		Addr               => I_Addr,
		AddrStb            => I_AddrStb,
		RdStb              => I_RdStb,
		WrStb              => I_WrStb,
		DataIn             => I_DataOut,
		DataOut            => I_DataIn,
		Rdy                => I_Rdy
	);

	Inst_Mem_Datos : memoria
	generic map (
	   C_ELF_FILENAME     => "datos",
	   C_TARGET_SECTION   => ".data",
      C_BASE_ADDRESS     => 16#00000000#,
      C_MEM_SIZE         => 1024,
      C_WAIT_STATES      => 0
   )	
	port map(
		Clk                => Clk,			 
		Reset              => Reset,
		Addr               => D_Addr,
		AddrStb            => D_AddrStb,
		RdStb              => D_RdStb,
		WrStb              => D_WrStb,
		DataIn             => D_DataOut,
		DataOut            => D_DataIn,
		Rdy                => D_Rdy
	);

	process	
	begin		
	   Clk <= '0';
		wait for tper_clk/2;
		Clk <= '1';
		wait for tper_clk/2; 		
	end process;
	
	process
	begin
		Reset <= '1';
		wait for tdelay;
		Reset <= '0';	   
		wait;
	end process;  	 

end TB_ARCHITECTURE;

configuration TESTBENCH_FOR_procesador of procesador_tb is
	for TB_ARCHITECTURE
		for UUT : procesador
			use entity work.procesador(procesador);
		end for;
	end for;
end TESTBENCH_FOR_procesador;

