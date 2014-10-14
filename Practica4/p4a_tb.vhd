-------------------------------------------------------------------------------
--  Banco de pruebas para la cache
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity p4a_tb is
end p4a_tb;

architecture PRACTICA of p4a_tb is

component DM_CACHE
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

end component;

-------------------------------------------------------------------------------
-- Parametros para la instanciacion
-------------------------------------------------------------------------------
constant L : integer := 8;
constant W : integer := 5;
constant ENTRIES : integer := 4;


-------------------------------------------------------------------------------
-- Otras constantes
-------------------------------------------------------------------------------
constant CLK_PERIOD : time := 50 ns;
constant tdelay     : time := 10 ns;
constant TAM_CACHE  : integer:=(2**ENTRIES-1);

-- Tiempo que la memoria tarda en devolver el dato solicitado
-- En ciclos de reloj
constant RETRASO : integer := 3;        

signal clk,req_c,M_wait,reset : std_logic;
signal wait_c, m_req : std_logic;
signal ad : std_logic_vector(W-1 downto 0):=(others =>'0');
signal d : std_logic_vector(L-1 downto 0);
signal q : std_logic_vector(L-1 downto 0);

signal contador_ciclos : integer := 0;
signal inicializar : boolean := FALSE;
signal end_sim : boolean := FALSE;

begin  -- PRACTICA

  -----------------------------------------------------------------------------
  -- Instanciar la cache
  -----------------------------------------------------------------------------
  UUT : DM_CACHE
    generic map (
      W       => W,
      L       => L,
      ENTRIES => ENTRIES)
    port map (
      CLK    => clk,
      REQ_C  => req_c,
      M_WAIT => m_wait,
      RESET  => reset,
      AD     => ad,
      D      => d,
      WAIT_C => wait_c,
      M_REQ  => m_req,
      Q      => q);

  -----------------------------------------------------------------------------
  -- Proceso de reloj
  -----------------------------------------------------------------------------
  process
  begin
    while not end_sim loop
      clk <= '1';
      wait for CLK_PERIOD/2;
      clk <= '0';
      wait for CLK_PERIOD/2;
    end loop;
    wait;
  end process;

  -----------------------------------------------------------------------------
  -- Proceso que simula la memoria principal
  -- El dato que hay almacenado en cada dirección es igual a la
  -- propia dirección. Así:
  --   * Direccion 0: Dato 0
  --   * Direccion 1: Dato 1
  --   etc
  -----------------------------------------------------------------------------
  process(clk)
    variable dir     : integer;
    variable counter : integer := 2;
    variable t_espera : integer := RETRASO;  -- Tiempo de espera de la memoria
  begin
      -- Esta memoria funciona en flanco de bajada
      if falling_edge(clk) then

        -- Si dato solicitado
        if m_req='1' then

          -- y si ha transcurrido el tiempo de espera
          if t_espera=0 then
            m_wait<='0';

            -- Leer la direccion
            dir:=to_integer(unsigned(AD));

            -- Se devuelve como dato la propia direccion
            D<=std_logic_vector(to_unsigned(dir,L));

            -- Para depuracion
            --report "Acceso a memoria principal";

            -- Reiniciar el tiempo de esperera para la proxima
            -- lectura
            t_espera:=RETRASO;
          else
            -- Todavia no ha transcurrido el tiempo de espera
            -- No devolver dato
            -- Queda un ciclo menos
            t_espera:=t_espera-1;
            m_wait<='1';
          end if;
        end if;
      end if;
      
  end process;


  -----------------------------------------------------------------------------
  -- Proceso para contar ciclos
  -----------------------------------------------------------------------------
  process(clk,inicializar)
  begin
    if inicializar=TRUE then
      contador_ciclos<=0;
    elsif rising_edge(clk) then
      -- Un ciclo mas
      contador_ciclos<=contador_ciclos + 1;
    end if;
  end process;
  
  -----------------------------------------------------------------------------
  -- Proceso que simula el micro
  -----------------------------------------------------------------------------
  process
    variable dato : integer;
    variable ciclos : integer := 0;     -- Contador de ciclos
  begin
    RESET <= '1';
    inicializar<=TRUE;                  -- Inicializar contador de ciclos
    wait for tdelay;


    ---------------------------------------------------------------------------
    -- Recorrer la memoria. Como es el primer acceso, la cache debe
    -- activar la senal de Wait_C, porque los datos no estan
    -- todavia cacheados y se debe acceder a la memoria principal
    ---------------------------------------------------------------------------
    RESET <= '0';
    inicializar<=FALSE;
    for i in 0 to TAM_CACHE loop
      
      REQ_C   <= '1';
      AD <= std_logic_vector(to_unsigned(i,w));
      wait until rising_edge(clk); wait for tdelay;
      assert wait_c='1'
        report "Error. deberia activarse wait_c"
        severity FAILURE;

      -- Esperear a que termine acceso a memoria
      wait until WAIT_C = '0';

      -- Para depuracion: sacar el valor leido de la memoria
      -- Debe ser igual a la direccion accedida
      --report "Dato: " & integer'image(to_integer(unsigned(Q)));
      
      req_c <= '0';
      wait until rising_edge(clk); wait for tdelay;
 
    end loop;

    -- Informar del numero de ciclos transcurridos la primera vez
    report "Ciclos la primera vez: " & integer'image(contador_ciclos);


    inicializar<=TRUE;                  -- Poner a cero contador ciclos
    wait for tdelay;

    inicializar<=FALSE;
    ---------------------------------------------------------------------------
    -- Volver a recorrer la memoria. Ahora los datos deben estar cacheados
    -- y por tanto no debe haber acceso a la memoria principal. La
    -- senal wait_c debe permanecer a '0'
    ---------------------------------------------------------------------------
    for i in 0 to TAM_CACHE loop
      
      REQ_C   <= '1';
      AD <= std_logic_vector(to_unsigned(i,w));
      wait until rising_edge(clk); wait for tdelay;
      assert wait_c='0'
        report "Error. wait_c deberia estar a 0"
        severity FAILURE;

      -- Comprobar ademas que el dato leido es el correcto
      -- Debe ser igual a la direccion a la que se accede
      assert Q=std_logic_vector(to_unsigned(i,L))
        report "Error en lectura de cache. Dato leido erroneo"
        severity FAILURE;
      
      -- Para depuracion: Imprimir el dato leido
      --dato:=to_integer(unsigned(Q));
      --report "Dato: " & integer'image(dato);

    end loop;

    -- Informar del numero de ciclos transcurridos la segunda vez
    -- Como los datos estaban "cacheados" debe tardar menos
    report "Ciclos la segunda vez: " & integer'image(contador_ciclos);

    ---------------------------------------------------------------------------
    -- Fin de la simulacion
    ---------------------------------------------------------------------------
    report "Fin de la simulacion";
    end_sim<=TRUE;
    wait;
  end process;
  
end PRACTICA; 

