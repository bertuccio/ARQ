library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity procesador is
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
end procesador;

architecture procesador_arq of procesador is 

------------------------
------COMPONENTES-------
------------------------
component tabla_registros PORT
		 ( CLK : in  STD_LOGIC;
           Reset : in  STD_LOGIC;
           EscrReg : in  STD_LOGIC;
           reg_lec1 : in  STD_LOGIC_VECTOR (4 downto 0);
           reg_lec2 : in  STD_LOGIC_VECTOR (4 downto 0);
		   reg_escr: in STD_LOGIC_VECTOR (4 downto 0);
           dato_escr : in  STD_LOGIC_VECTOR (31 downto 0);
           dato_leido1 : out  STD_LOGIC_VECTOR (31 downto 0);
           dato_leido2 : out  STD_LOGIC_VECTOR (31 downto 0));
end component;

component ALU PORT
		 ( A : in  STD_LOGIC_VECTOR (31 downto 0);
           B : in  STD_LOGIC_VECTOR (31 downto 0);
           control : in  STD_LOGIC_VECTOR (3 downto 0);
           resultado : out  STD_LOGIC_VECTOR (31 downto 0);
           igual : out  STD_LOGIC);
end component;

------------------
-----SEÑALES------
------------------

signal PC_IN : STD_LOGIC_VECTOR (31 downto 0);
signal PC_IN1 : STD_LOGIC_VECTOR (31 downto 0);
signal PC_IN2 : STD_LOGIC_VECTOR (31 downto 0);
signal addResultIN : STD_LOGIC_VECTOR (31 downto 0);
signal addResultOUT : STD_LOGIC_VECTOR (31 downto 0);

signal MemMux1 : STD_LOGIC_VECTOR (31 downto 0);
signal MemMux2 : STD_LOGIC_VECTOR (31 downto 0);

-------ALU-----------------------------------------
signal OpA : STD_LOGIC_VECTOR (31 downto 0);
signal OpB : STD_LOGIC_VECTOR (31 downto 0);
signal mux1OpB: STD_LOGIC_VECTOR (31 downto 0); 
signal mux2OpB: STD_LOGIC_VECTOR (31 downto 0);
signal AluControl : STD_LOGIC_VECTOR (5 downto 0);
signal ALUctr : STD_LOGIC_VECTOR (3 downto 0);
signal Zero : STD_LOGIC;
signal AluResultIN : STD_LOGIC_VECTOR (31 downto 0);
signal AluResultOUT : STD_LOGIC_VECTOR (31 downto 0);
---------------------------------------------------



--------------CONTROL----------------------------
signal Control: STD_LOGIC_VECTOR (5 downto 0);
------EX------------
signal EXctr : std_logic_vector(3 downto 0);
signal RegDst: STD_LOGIC;
signal ALUOp: STD_LOGIC_VECTOR (1 downto 0);
signal AluSrc : STD_LOGIC;
-------M------------
signal Mctr : std_logic_vector(2 downto 0);
signal Mctr1 : std_logic_vector(2 downto 0);
signal Mctr2 : std_logic_vector(2 downto 0);
signal PCSrc : STD_LOGIC;
------WB------------
signal WEctr : std_logic_vector(1 downto 0);
signal WEctr1 : std_logic_vector(1 downto 0);
signal WEctr2 : std_logic_vector(1 downto 0);
signal EscrReg : STD_LOGIC;
signal MemToReg : STD_LOGIC;
---------------------------------------------------

signal signo_extend: STD_LOGIC_VECTOR (31 downto 0);
signal reg_lect1IF : STD_LOGIC_VECTOR (4 downto 0);
signal reg_lect2IF : STD_LOGIC_VECTOR (4 downto 0);
signal rdInstCarg : STD_LOGIC_VECTOR (4 downto 0);
signal rdInstALU : STD_LOGIC_VECTOR (4 downto 0);

signal reg_escr: STD_LOGIC_VECTOR (4 downto 0);
signal reg_escrIN: STD_LOGIC_VECTOR (4 downto 0);
signal dato_leido1 : STD_LOGIC_VECTOR (31 downto 0);
signal dato_leido2 : STD_LOGIC_VECTOR (31 downto 0);
signal dato_escr : STD_LOGIC_VECTOR (31 downto 0);
signal RegEscribir1 : STD_LOGIC_VECTOR (4 downto 0);
signal RegEscribir2 : STD_LOGIC_VECTOR (4 downto 0);



signal mux_aux1 : STD_LOGIC_VECTOR (4 downto 0);
signal mux_aux2 : STD_LOGIC_VECTOR (4 downto 0);

begin 	

-----------------
----PORT-MAPS----
-----------------

--BANCO REGISTROS--
BANCO: tabla_registros port map(
	CLK => Clk,
	Reset => Reset,
	EscrReg => EscrReg,
	reg_lec1 => reg_lect1IF,
	reg_lec2 => reg_lect2IF,
	reg_escr => reg_escr,
	dato_escr => dato_escr,
	dato_leido1 => dato_leido1,
	dato_leido2 => dato_leido2);
	
--ALU--
UAL : ALU port map(
	A => OpA,
	B => OpB,
	control => ALUctr,
	resultado => AluResultIN,
	igual => Zero);	



 
I_RdStb<='1';
I_WrStb<='0';
I_AddrStb<='1';
D_AddrStb<='1';
I_Addr<=PC_IN;
I_DataOut<=x"00000000";


------------------------------
----CONTADOR DE PROGRAMA------
------------------------------
 process(Clk,Reset)
	begin
	if Reset='1' then
		PC_IN<=x"00000000";
	else
		if rising_edge(Clk) then
			if (PCSrc='1') then
				PC_IN<=addResultOUT;
				
			else
				PC_IN<=PC_IN+4;
			end if;
		end if;
	end if;
end process;

 -----------------------
 ---PRIMER PIPE (IF)----
 ----------------------- 
process (Clk,Reset) 
	begin
	
	if (Reset='1') then
		PC_IN1<=x"00000000";
		Control<= "000000";
		reg_lect1IF<="00000";
		reg_lect2IF<="00000";
		rdInstCarg<= "00000";
		rdInstALU<= "00000";
		signo_extend<=x"00000000";
	
		
	else
		if rising_edge(Clk) then
			PC_IN1<=PC_IN;
			Control <= I_DataIn(31 downto 26);
			reg_lect1IF <=I_DataIn(25 downto 21);
			reg_lect2IF <=I_DataIn(20 downto 16);
			rdInstCarg <= I_DataIn(20 downto 16);
			rdInstALU <= I_DataIn(15 downto 11);
			
			if I_DataIn(15)='1' then
				signo_extend<=x"FFFF"&I_DataIn(15 downto 0);
			else
				signo_extend<=x"0000"&I_DataIn(15 downto 0);
			end if;
			
		end if;
		
	end if;
end process;
 
 -----------------------
 ---SEGUNDO PIPE (EX)--
 -----------------------
process (Clk,Reset) 
	begin
	
	if (Reset='1') then
		WEctr1<="00";
		Mctr1<="000";
		ALUOp<="00";
		ALUcontrol<="000000";
		OpA<=x"00000000";
		mux1OpB<=x"00000000";
		mux2OpB<=x"00000000";
		mux_aux1<="00000";
		mux_aux2<="00000";
		addResultIN<=x"00000000";
		AluSrc<='0';
		RegDst<='0';
		
		
		
	else
		if rising_edge(Clk) then
	
			WEctr1<=WEctr;
			Mctr1<=Mctr;
			ALUcontrol<=signo_extend(5 downto 0);
			mux2OpB<=signo_extend;
			addResultIN<=signo_extend(29 downto 0)&"00"+PC_IN1;
			OpA<=dato_leido1;
			mux1OpB<=dato_leido2;
			mux_aux1<=rdInstCarg;
			mux_aux2<=rdInstALU;
			RegDst<=EXctr(3);
			ALUOp<=EXctr(2 downto 1);
			AluSrc<=EXctr(0);


		end if;
	end if; 
end process;
	
----------MULTIPLEXORES--------------
WITH AluSrc  SELECT
    OpB	<=mux1OpB WHEN '0',
          mux2OpB WHEN OTHERS;
			   
WITH RegDst  SELECT
    regEscribir1 <=mux_aux1 WHEN '0',
                 mux_aux2 WHEN OTHERS;
			   
WITH MemToReg  SELECT
    dato_escr <=MemMux2 WHEN '0',
                MemMux1 WHEN OTHERS;			   
			 
------------------------------------	


 -----------------------
 ---TERCER PIPE (MEM)--
 -----------------------
process (Clk,Reset) 
begin
	if (Reset='1') then
		addResultOUT<=x"00000000";
		D_WrStb<='0';--memwrite
		D_RdStb<='0';--memread
		PCSrc<='0';
		D_DataOut<=x"00000000";
		aluResultOUT<=x"00000000";
		WEctr2<="00";
		regEscribir2<="00000";
		D_Addr<=x"00000000";
	else
		if rising_edge(Clk) then
			WEctr2<=WEctr1;
			addResultOUT<=addResultIN;
			D_WrStb<=Mctr1(0);--memwrite
			D_RdStb<=Mctr1(1);--memread
			PCSrc<=Mctr1(2) and Zero;
		
			D_Addr<=AluResultIN;
			aluResultOUT<=AluResultIN;
			D_DataOut<=mux1OpB;
			regEscribir2<=regEscribir1;
		end if;

	end if;
end process;

-------------------
----REGISTRO 4-----
-------------------
process (Clk) begin

	if (Reset='1') then
	
		MemMux1<=x"00000000";
		MemMux2<=x"00000000";
		reg_escr<="00000";
		MemToReg<='0';
		EscrReg<='0';
		

	else
		if rising_edge(Clk) then
	
			MemMux1<=D_DataIn;
			MemMux2<=aluResultOUT;
			reg_escr<=regEscribir2;
			MemToReg<=WEctr2(0);
			EscrReg<=WEctr2(1);
			
			
		end if;
	end if;	
end process;

process (ALUOp, ALUcontrol) begin
	
	case ALUOp is
		when "10"=>--REG_A_REG
			case ALUcontrol is
				when "100000"=>--ADD
					ALUctr<="0011";
				when "100010"=>--SUB
					ALUctr<="1000";
				when "100100"=>--AND
					ALUctr<="0000";
				when "100101"=>--OR
					ALUctr<="0001";
				when "100110"=>--XOR
					ALUctr<="0010";
				when "101010"=>--SLT
					ALUctr<="1010";
				when others =>
				   ALUctr<="1111";
			end case;
		when "00"=>--LW ó SW
			ALUctr<="0011";--ADD PARA CONSEGUIR LA DIRECCION DE MEMORIA
		when "01"=>--BEQ
			ALUctr<="0010";--XOR PARA VER SI RS Y RT SON IGUALES
		when "11"=>--LIU
			ALUctr<="1001";
		when others => 
			ALUctr<="1111";

	end case;
end process;


 process (Control) begin
	case Control is
		when "000000"=> --SPECIAL (R)
			EXctr<="1100";
			Mctr<="000";
			WEctr<="10";
		when "100011"=> --LW
			EXctr<="0001";
			Mctr<="010";
			WEctr<="11";
		when "101011"=> --SW
			EXctr<="0001";
			Mctr<="001";
			WEctr<="00";
		when "001111"=> --LIU
			EXctr<="0110";
			Mctr<="000";
			WEctr<="10";
		when "000100"=> --BE
			EXctr<="0010";
			Mctr<="100";
			WEctr<="00";
		when others => 
		   EXctr<="0000";
		   Mctr<="000";
		   WEctr<="00";

	end case;
end process;
 
end procesador_arq;
