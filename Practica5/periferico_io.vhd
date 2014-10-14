----------------------------------------------------------------------------------
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity periferico_io is
    Port ( reset : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           read_en, write_en : in  STD_LOGIC; --señales de habilitación para la lectura y escritura en los periféricos
           address: in  STD_LOGIC_VECTOR (31 downto 0); --dirección del periférico mapeada en el espacio de direcciones
           dato_bus_i : in  STD_LOGIC_VECTOR (31 downto 0); --dato de entrada al periférico desde el bus
           dato_bus_o : out  STD_LOGIC_VECTOR (31 downto 0); --dato de salida del periférico hacia el bus
           dato_inout : inout  STD_LOGIC_VECTOR (7 downto 0) --conexión del periférico hacia el exterior
           );
end periferico_io;

architecture Behavioral of periferico_io is

signal config_perif : STD_LOGIC_VECTOR (31 downto 0);
signal reg_salida, reg_entrada : STD_LOGIC_VECTOR (7 downto 0);

begin

-- configuración del periferico
process(clk, reset)
begin
  if reset = '1' then
    config_perif <= (others => '0'); 
  elsif falling_edge(clk) then
   if write_en = '1' then
     --La dirección terminada en 0 es el puerto de config
     if address(3 downto 0) = x"0" then 
       config_perif <= dato_bus_i;
     end if;
    end if;
  end if;
end process;

-- config_perif = 00000002 lectura
-- config_perif = 00000004 escritura
-- config_perif = 0000000X no inicializado


--Si el periferico se usa de entrada
process(clk, reset)
begin
  if reset = '1' then
    reg_entrada <= (others => '0'); 
  elsif falling_edge(clk) then
    if read_en = '1' then
      if address(3 downto 0) = x"4" then
        if config_perif(3 downto 0) = x"2" then -- si config como lectura
          --se almacena el dato dentro del periferico
          reg_entrada <= dato_inout; 
        end if;
      end if;
    end if;
  end if;
end process;

dato_bus_o <= x"000000" & reg_entrada; --se saca el dato hacia el bus

--Si el periferico se usa de salida
process(clk, reset)
begin
  if reset = '1' then
    reg_salida <= (others => '0'); 
  elsif falling_edge(clk) then
    if write_en = '1' then
     if address(3 downto 0) = x"4" then
       if config_perif(3 downto 0) = x"4" then -- config como escritura
         --se almacena el dato dentro del periferico. Solo 8 bits
         reg_salida <= dato_bus_i(7 downto 0); 
       end if;
     end if;
    end if;
  end if;
end process;

--se saca el dato cuando es de salida, sino se deja a alta impedancia
dato_inout <= reg_salida when config_perif(3 downto 0) = x"4" else (others => 'Z'); 

end Behavioral;

