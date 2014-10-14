-------------------------------------------------------------------------------
--  Memoria cache de correspondencia directa
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


-------------------------------------------------------------------------------
--  Memoria cache de correspondencia directa
-------------------------------------------------------------------------------


entity DM_CACHE is
  
  generic (
    W       : integer;             -- Ancho bus direcciones
    L       : integer;             -- Ancho bus de datos
    ENTRIES : integer);            -- Ancho direcciones de la cache

  port (
    CLK    : in  std_logic;                        -- Reloj
    REQ_C  : in  std_logic;                        -- Solicitud de direccion
    M_WAIT : in  std_logic;                        -- Esperar a la memoria
    RESET  : in  std_logic;                        -- Reset
    AD     : in  std_logic_vector(W-1 downto 0);   -- Bus direcciones
    D      : in  std_logic_vector(L-1 downto 0);   -- Bus de datos
    WAIT_C : out std_logic;                        -- Esperar a la cache
    M_REQ  : out std_logic;                        -- Solicitud de acceso
    Q      : out std_logic_vector(L-1 downto 0));  -- Salida de datos

end DM_CACHE;



architecture PRACTICA of DM_CACHE is

    --mas uno por el bit de validez
    type Matriz is array (2**ENTRIES-1 downto 0) of std_logic_vector(W-ENTRIES+L downto 0);
    type estados is(comparar,espera);
    signal SRAM: Matriz;
    signal estado : estados;
 
begin

process(RESET, CLK)
begin
         
if(RESET = '1') then
	--Q indeterminada
	M_REQ<='0';
	WAIT_C<='0';
	--bit de validez a 0 en cada entrada
	for i in 0 to 2**ENTRIES-1 loop
	SRAM(i)(0)<='0';
	end loop;
	estado<=comparar; 
else
		if(falling_edge(CLK)) then
			if(REQ_C='1') then
				
				if estado=comparar then
				  
					--si el tag coincide
					if(SRAM(conv_integer(AD(ENTRIES-1 downto 0)))(W-ENTRIES+L downto L+1) = AD(W-1 downto ENTRIES)) then
						--si el bit de validez esta a 1
						if SRAM(conv_integer(AD(ENTRIES-1 downto 0)))(0)='1' then
							--introduce el dato en Q y baja las señales WAIT_C y M_REQ
							Q<=SRAM(conv_integer(AD(ENTRIES-1 downto 0)))(L downto 1);
							WAIT_C<='0';
							M_REQ<='0';
						end if;
					else
						
						--Pone WAIT_C a 1 y M_REQ a 1. De este modo se hace esperar al 
						--microprocesador, y se pide el dato a la memoria
						estado<=espera;
						WAIT_C <= '1';
						M_REQ <= '1';
					end if;
				else
				   --Mientras M_WAIT esté a 1, espera (no hace nada)
					
					if M_WAIT='0' then
						
					   --Guarda la etiqueta y el dato en la entrada correspondiente, y pone el dato en Q, 
						--bajando las señales WAIT_C y M_REQ
						
						SRAM(conv_integer(AD(ENTRIES-1 downto 0)))(0) <= '1'; 
						SRAM(conv_integer(AD(ENTRIES-1 downto 0)))(L downto 1) <= D; 
						SRAM(conv_integer(AD(ENTRIES-1 downto 0)))(W-ENTRIES+L downto L+1) <= AD(W-1 downto ENTRIES); 
						Q <= D;
						estado <= comparar; 
						WAIT_C <= '0';
						M_REQ <= '0';
					end if;
					
				end if; 
		end if;
	end if;
end if;
end process;
end PRACTICA;