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



component ForwardingUnit Port 
		 ( ID_EX_RS : in  STD_LOGIC_VECTOR (4 downto 0);
           ID_EX_RT : in  STD_LOGIC_VECTOR (4 downto 0);
		   EX_MEM_ESCREG : in  STD_LOGIC;
           MEM_WB_ESCREG : in  STD_LOGIC;
           EX_MEM_RD : in  STD_LOGIC_VECTOR (4 downto 0);
           MEM_WB_RD : in  STD_LOGIC_VECTOR (4 downto 0);
		   AnticipaA : out  STD_LOGIC_VECTOR (1 downto 0);
           AnticipaB : out  STD_LOGIC_VECTOR (1 downto 0));
              
end component;

component HAZARD 
    Port (  PC_Write : out  STD_LOGIC;
           IFID_Write : out  STD_LOGIC;
           IDEX_Memread : in  STD_LOGIC;
           MUX_sel : out  STD_LOGIC;
           IDEX_Rt : in  STD_LOGIC_VECTOR (4 downto 0);
           IFID_Rs : in  STD_LOGIC_VECTOR (4 downto 0);
           IFID_Rt : in  STD_LOGIC_VECTOR (4 downto 0));
end component;

------------------
-----SEÑALES------
------------------

signal PC_IN : STD_LOGIC_VECTOR (31 downto 0);
signal PC_IN1 : STD_LOGIC_VECTOR (31 downto 0);
signal addResultIN : STD_LOGIC_VECTOR (31 downto 0);
signal addResultOUT : STD_LOGIC_VECTOR (31 downto 0);

signal MemMux1 : STD_LOGIC_VECTOR (31 downto 0);
signal MemMux2 : STD_LOGIC_VECTOR (31 downto 0);

-------ALU-----------------------------------------
signal OpA : STD_LOGIC_VECTOR (31 downto 0);
signal OpAPosible : STD_LOGIC_VECTOR (31 downto 0);
signal OpB : STD_LOGIC_VECTOR (31 downto 0);
signal mux1OpB: STD_LOGIC_VECTOR (31 downto 0); 
signal mux1OpBPosible : STD_LOGIC_VECTOR (31 downto 0);
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
signal EXHAZARD : std_logic_vector(3 downto 0);
signal RegDst: STD_LOGIC;
signal ALUOp: STD_LOGIC_VECTOR (1 downto 0);
signal AluSrc : STD_LOGIC;
-------M------------
signal Mctr : std_logic_vector(2 downto 0);
signal MHAZARD : std_logic_vector(2 downto 0);
signal Mctr1 : std_logic_vector(2 downto 0);
signal Mctr2 : std_logic_vector(2 downto 0);
signal PCSrc : STD_LOGIC;
------WB------------
signal WEctr : std_logic_vector(1 downto 0);
signal WEHAZARD : std_logic_vector(1 downto 0);
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


---------FORWARDINGUNIT-----------
signal ID_EX_RS :  STD_LOGIC_VECTOR (4 downto 0);
signal ID_EX_RT :  STD_LOGIC_VECTOR (4 downto 0);
signal EX_MEM_ESCREG : STD_LOGIC;
signal MEM_WB_ESCREG : STD_LOGIC;
signal EX_MEM_RD : STD_LOGIC_VECTOR (4 downto 0);
signal MEM_WB_RD : STD_LOGIC_VECTOR (4 downto 0);
signal AnticipaA : STD_LOGIC_VECTOR (1 downto 0);
signal AnticipaB : STD_LOGIC_VECTOR (1 downto 0);



signal PC_Write :  STD_LOGIC;
signal IFID_Write :  STD_LOGIC;
signal IDEX_Memread :   STD_LOGIC;
signal MUX_sel :  STD_LOGIC;
signal IDEX_Rt :   STD_LOGIC_VECTOR (4 downto 0);
signal IFID_Rs :   STD_LOGIC_VECTOR (4 downto 0);
signal IFID_Rt :  STD_LOGIC_VECTOR (4 downto 0);

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

UnitForward:  ForwardingUnit port map(

   ID_EX_RS =>ID_EX_RS,
   ID_EX_RT =>ID_EX_RT,
   EX_MEM_ESCREG => EX_MEM_ESCREG,
   MEM_WB_ESCREG =>MEM_WB_ESCREG,
   EX_MEM_RD => EX_MEM_RD,
   MEM_WB_RD => MEM_WB_RD,
   AnticipaA => AnticipaA,
   AnticipaB => AnticipaB);
 
HazardUnit: HAZARD  port map(
     PC_Write=>PC_Write,
           IFID_Write=> IFID_Write,
           IDEX_Memread=>IDEX_Memread,
           MUX_sel=>MUX_sel,
           IDEX_Rt=>IDEX_Rt,
           IFID_Rs=>IFID_Rs,
           IFID_Rt=>IFID_Rt);

 
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
			if PC_Write='1' then
				if (PCSrc='1') then
					PC_IN<=addResultOUT;
					
				else
					PC_IN<=PC_IN+4;
				end if;
			end if;
		end if;
	end if;
end process;

 -----------------------
 ---PRIMER PIPE (IF)----
 ----------------------- 
process (Clk,Reset) 
	begin
	
	if (Reset='1')or (PcSrc='1') then
		PC_IN1<=x"00000000";
		Control<= "111111";
				     
		reg_lect1IF<="00000";
		reg_lect2IF<="00000";
		rdInstCarg<= "00000";
		rdInstALU<= "00000";
		signo_extend<=x"00000000";
		IFID_Rs<="00000";
		IFID_Rt<="00000";
		
	else
		if rising_edge(Clk) then
			if (IFID_Write='1') then
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
		
	end if;
end process;



IFID_Rs<=reg_lect1IF;
IFID_Rt<=reg_lect2IF;

IDEX_Rt<=mux_aux1;

IDEX_Memread<=Mctr1(1);
 
 -----------------------
 ---SEGUNDO PIPE (EX)--
 -----------------------
process (Clk,Reset) 
	begin
	
	if (Reset='1')or (PcSrc='1') then
		WEctr1<="00";
		Mctr1<="000";
		ALUOp<="00";
		ALUcontrol<="000000";
		OpAPosible<=x"00000000";
		mux1OpBPosible<=x"00000000";
		mux2OpB<=x"00000000";
		mux_aux1<="00000";
		mux_aux2<="00000";
		addResultIN<=x"00000000";
		AluSrc<='0';
		RegDst<='0';
		ID_EX_RS<="00000";
		ID_EX_RT<="00000";
		IDEX_Rt<="00000";
		
	else
		if rising_edge(Clk) then
			if (PcSrc='1') then
				WEctr1<="00";
				Mctr1<="000";
				ALUOp<="00";
				ALUcontrol<="000000";
				OpAPosible<=x"00000000";
				mux1OpBPosible<=x"00000000";
				mux2OpB<=x"00000000";
				mux_aux1<="00000";
				mux_aux2<="00000";
				addResultIN<=x"00000000";
				AluSrc<='0';
				RegDst<='0';
				ID_EX_RS<="00000";
				ID_EX_RT<="00000";
				IDEX_Rt<="00000";
			else
	
				WEctr1<=WEctr;
				Mctr1<=Mctr;
				
				
		
				
				ALUcontrol<=signo_extend(5 downto 0);
				mux2OpB<=signo_extend;
				addResultIN<=signo_extend(29 downto 0)&"00"+PC_IN1;
				OpAPosible<=dato_leido1;
				mux1OpBPosible<=dato_leido2;
				mux_aux1<=rdInstCarg;
				mux_aux2<=rdInstALU;
				RegDst<=EXctr(3);
				ALUOp<=EXctr(2 downto 1);
				AluSrc<=EXctr(0);
			
				ID_EX_RS<=reg_lect1IF;
				ID_EX_RT<=reg_lect2IF;
			end if;
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
--MULTIPLEXOR PARA ELEGIR LA ENTRADA A LA ALU DEL OPERANDO A
process (OpAPosible, AnticipaA, dato_escr, aluResultOUT) 
begin
	 if( AnticipaA= "00" )then
			OpA <= OpAPosible;
	 elsif( AnticipaA="01"  ) then
			OpA <= dato_escr;
	 elsif( AnticipaA="10" ) then
			OpA <= aluResultOUT;--when AnticipaA="10"
	
	end if;
		
end process;

--MULTIPLEXOR PARA ELEGIR LA ENTRADA POSIBLE DEL OPERANDO B
process (mux1OpB, AnticipaB, dato_escr, aluResultOUT) 
begin
	 if( AnticipaB= "00" )then
			 mux1OpB <= mux1OpBPosible;
	 elsif( AnticipaB="01"  ) then
			mux1OpB <= dato_escr;
			
	 elsif( AnticipaB="10" ) then
			mux1OpB <= aluResultOUT;
	end if;
		
end process;








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
		EX_MEM_ESCREG<='0';
		IDEX_Memread <= '0';
		EX_MEM_RD<="00000";
	else
		if rising_edge(Clk) then
			if (PcSrc='1') then
				addResultOUT<=x"00000000";
				D_WrStb<='0';--memwrite
				D_RdStb<='0';--memread
				PCSrc<='0';
				D_DataOut<=x"00000000";
				aluResultOUT<=x"00000000";
				WEctr2<="00";
				regEscribir2<="00000";
				D_Addr<=x"00000000";
				EX_MEM_ESCREG<='0';
				IDEX_Memread <= '0';
				EX_MEM_RD<="00000";
			else
				WEctr2<=WEctr1;
				
				addResultOUT<=addResultIN;
				D_WrStb<=Mctr1(0);--memwrite
				D_RdStb<=Mctr1(1);--memread
				

				PCSrc<=Mctr1(2) and Zero;
				EX_MEM_RD<=regEscribir1;
				D_Addr<=AluResultIN;
				aluResultOUT<=AluResultIN;
				D_DataOut<=mux1OpB;
				regEscribir2<=regEscribir1;
				EX_MEM_ESCREG<=WEctr1(1);
			end if;
		end if;

	end if;
end process;
		
-------------------
----REGISTRO 4-----
-------------------
process (Clk,Reset) begin

	if (Reset='1')or (PcSrc='1')  then
	
		MemMux1<=x"00000000";
		MemMux2<=x"00000000";
		reg_escr<="00000";
		MemToReg<='0';
		EscrReg<='0';
		MEM_WB_ESCREG<='0';
		

	else
		
		if rising_edge(Clk) then
			MemMux1<=D_DataIn;
			MemMux2<=aluResultOUT;
			reg_escr<=regEscribir2;
			MemToReg<=WEctr2(0);
			EscrReg<=WEctr2(1);
			MEM_WB_ESCREG<=WEctr2(1);
			MEM_WB_RD<=regEscribir2;
		
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
			EXHAZARD<="1100";
			MHAZARD<="000";
			WEHAZARD<="10";
		when "100011"=> --LW
			EXHAZARD<="0001";
			MHAZARD<="010";
			WEHAZARD<="11";
		when "101011"=> --SW
			EXHAZARD<="0001";
			MHAZARD<="001";
			WEHAZARD<="00";
		when "001111"=> --LIU
			EXHAZARD<="0110";
			MHAZARD<="000";
			WEHAZARD<="10";
		when "000100"=> --BE
			EXHAZARD<="0010";
			MHAZARD<="100";
			WEHAZARD<="00";
		when others => 
		   EXHAZARD<="0000";
		   MHAZARD<="000";
		   WEHAZARD<="00";

	end case;
end process;

process (MUX_Sel, WEHAZARD,MHAZARD,EXHAZARD) 

begin 

	if MUX_Sel='1' then
		WEctr<="00";
		Mctr<="000";
		EXctr<="0000";
		
	elsif MUX_Sel='0' then
		WEctr<=WEHAZARD;
		Mctr<=MHAZARD;
		EXctr<=EXHAZARD;
		
	end if;
	
end process;
				
end procesador_arq;
 

