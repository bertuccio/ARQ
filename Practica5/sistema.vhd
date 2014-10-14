library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity sistema is
port(
  Clk         : in  std_logic;
  Reset       : in  std_logic;
  -- Datos hacia el exterior del sistema
  data_perif_1 : inout  std_logic_vector(7 downto 0);
  data_perif_2 : inout  std_logic_vector(7 downto 0)
);
end sistema;

architecture sistema_arq of sistema is 


--Declaracion de componentes
--El microprocesador
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

--Las memorias tanto de datos como de instrucciones
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

--Control entradas
  COMPONENT ctrl_in
  generic(NUM_PERIF: integer);
  PORT(
    dir : IN std_logic_vector(31 downto 0);
    data_read : IN std_logic;          
    perif_en : out  STD_LOGIC_VECTOR (NUM_PERIF-1 downto 0)
    );
  END COMPONENT;

-- control salidas
  COMPONENT ctrl_out
  generic(NUM_PERIF: integer);
  PORT(
    dir : IN std_logic_vector(31 downto 0);
    data_write : IN std_logic;          
    perif_en : out  STD_LOGIC_VECTOR (NUM_PERIF-1 downto 0)
    );
  END COMPONENT;

  COMPONENT periferico_io
  PORT(
    reset : IN std_logic;
    clk : IN std_logic;
    read_en : IN std_logic;
    write_en : IN std_logic;
    address : IN std_logic_vector(31 downto 0);
    dato_bus_i : IN std_logic_vector(31 downto 0);    
    dato_inout : INOUT std_logic_vector(7 downto 0);      
    dato_bus_o : OUT std_logic_vector(31 downto 0)
    );
  END COMPONENT;

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
  signal Bus_D_DataOut   : std_logic_vector(31 downto 0);
  signal D_Rdy       : std_logic;
  signal Bus_D_DataIn    : std_logic_vector(31 downto 0);
  
  --Buffer triestado de la memoria de datos y de los perifericos
  --hacia el bus de entrada de datos
  signal data_input_memory : std_logic_vector (31 downto 0);
  signal data_input_perif_1 : std_logic_vector (31 downto 0);
  signal data_input_perif_2 : std_logic_vector (31 downto 0);
  --hacia el bus de salida de datos
  signal data_output_memory : std_logic_vector (31 downto 0);
  signal data_output_perif_1 : std_logic_vector (31 downto 0);
  signal data_output_perif_2 : std_logic_vector (31 downto 0);
  
  constant NUM_PERIF: integer := 3;  
  signal perif_entrada_en, perif_salida_en : std_logic_vector (NUM_PERIF-1 downto 0);

begin


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
      D_DataOut       => Bus_D_DataIn,
      D_Rdy           => D_Rdy,
      D_DataIn        => Bus_D_DataOut
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
    RdStb              => perif_entrada_en(0),
    WrStb              => perif_salida_en(0),
    DataIn             => data_input_memory,
    DataOut            => data_output_memory,
    Rdy                => D_Rdy
);


  Inst_ctrl_out: ctrl_out generic map(NUM_PERIF => NUM_PERIF)
    PORT MAP(
    dir => D_Addr,
    data_write => D_WrStb,
    perif_en => perif_salida_en
  );

  Inst_ctrl_in: ctrl_in generic map(NUM_PERIF => NUM_PERIF)
    PORT MAP(
    dir => D_Addr,
    data_read => D_RdStb,
    perif_en => perif_entrada_en
  );


  Perif_1: periferico_io PORT MAP(
    reset => reset,
    clk => clk,
    read_en => perif_entrada_en(1),
    write_en => perif_salida_en(1),
    address => D_Addr,
    dato_bus_i => data_input_perif_1,
    dato_bus_o => data_output_perif_1,
    dato_inout => data_perif_1
  );
  
  Perif_2: periferico_io PORT MAP(
    reset => reset,
    clk => clk,
    read_en => perif_entrada_en(2),
    write_en => perif_salida_en(2),
    address => D_Addr,
    dato_bus_i => data_input_perif_2,
    dato_bus_o => data_output_perif_2,
    dato_inout => data_perif_2
  );

--Conexiones al bus con buffers de tercer estado.
  Bus_D_DataOut <= data_output_perif_1 when perif_entrada_en(1) = '1' else (others => 'Z');
  Bus_D_DataOut <= data_output_perif_2 when perif_entrada_en(2) = '1' else (others => 'Z');
  Bus_D_DataOut <= data_output_memory when perif_entrada_en(0) = '1' else (others => 'Z');

--conexiones a los perifericos y a la memoria de datos de los datos que le llegan (configuracion o datos reales)
  data_input_perif_2 <= Bus_D_DataIn;
  data_input_perif_1 <= Bus_D_DataIn;
  data_input_memory <= Bus_D_DataIn;

end sistema_arq;
