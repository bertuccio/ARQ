library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity tabla_registros is

PORT(       CLK      	 : in std_logic;                       -- Reloj
            EscrReg  	 : in std_logic;                       -- Habilitacion escritura
            Reset    	 : in std_logic;                       -- Reset asíncrono a nivel alto
            reg_lec1 	 : in  std_logic_vector(4 downto 0);   -- Direccion lectura 1
            reg_lec2 	 : in  std_logic_vector(4  downto 0);  -- Direccion lectura 2
            reg_escr 	 : in  std_logic_vector(4 downto 0);   -- Direccion escritura 1
            dato_escr    : in  std_logic_vector(31 downto 0);   -- Dato entrada escritura
            dato_leido1  : out std_logic_vector(31 downto 0);  -- Dato salida 1
            dato_leido2  : out std_logic_vector(31 downto 0)); -- Dato salida 2

end tabla_registros;

architecture Behavioral of tabla_registros is

type Matriz is array (0 to 31) of std_logic_vector(31 downto 0);
signal banco: matriz;
constant ZERO: std_logic_vector(31 downto 0):=x"00000000";
constant TAMANO : integer:=31;

begin
    
    
    process(CLK,Reset)  
																
	   

    begin
    
       if(Reset='1') then
             for i in 0 to TAMANO loop
                       banco(i)<=(others=>'0');
             end loop;

       else

              --Escribir en registro
              if (falling_edge(CLK)and EscrReg='1') then          
		              banco(conv_integer(reg_escr(4 downto 0)))<=dato_escr(31 downto 0);
              end if;
              
         end if;

     end process;    
     
	  --Lectura combinacional
	  
	  dato_leido1<=ZERO(31 downto 0) when(reg_lec1=ZERO(4 downto 0)) else
					   banco(conv_integer(reg_lec1(4 downto 0)));
						
	  dato_leido2<=ZERO(31 downto 0) when(reg_lec2=ZERO(4 downto 0)) else
					   banco(conv_integer(reg_lec2(4 downto 0)));						

end architecture;