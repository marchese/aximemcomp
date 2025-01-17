--This library is free software; you can redistribute it and/or
--modify it under the terms of the GNU Lesser General Public
--License as published by the Free Software Foundation; either
--version 2.1 of the License, or (at your option) any later version.

--This library is distributed in the hope that it will be useful,
--but WITHOUT ANY WARRANTY; without even the implied warranty of
--MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
--Lesser General Public License for more details.

--You should have received a copy of the GNU Lesser General Public
--License along with this library; if not, write to the Free Software
--Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

-- e_mail : j.l.nunez-yanez@byacom.co.uk

--------------------------------------
--  ENTITY       = LEVEL2_4d         --
--  version      = 1.0              --
--  last update  = 16/10/00          --
--  author       = Jose Nunez       --
--------------------------------------

-- FUNCTION
-- hierarchy level.

--  PIN LIST
--  COMP_INT     = selects compression mode
--  DECOMP_INT   = selects decompression mode
--  MOVE_ENABLE  = activates the movement in the dictionary
--  CLK          = master clock
--  CLEAR        = asynchronous reset
--  U_DATAIN     = data to be compressed
--  C_DATAIN     = data to be decompressed
--  U_DATAOUT    = decompressed data
--  C_DATAOUT    = compressed data
--  FLUSH_INT     = activate flush cycle
--  FLUSH_END     = internal flush terminated
--  ADDRESS       = memory address signal
--  CE           = memory chip enable
--  OE           = memory output enable
--  RW           = memory read or write enable



library IEEE;
use IEEE.std_logic_1164.all;
--library xil_lib;
--use xil_lib.xil_comp.all;
use work.tech_package.all;
use ieee.numeric_std.all;

entity level2_4d_pbc is
  port(
    CLK : in bit;
    CLEAR : in bit;
    RESET : in bit;  	 
    DECOMP : in bit;
    MOVE_ENABLE : in bit;
	  DECODING_UNDERFLOW : in bit;
	  FINISH : in bit;
	  C_DATAIN : in bit_vector(63 downto 0);
	  U_DATAOUT : out bit_vector(31 downto 0);
	  MASK : out bit_vector(3 downto 0);
	  U_DATA_VALID : out bit ;
	  OVERFLOW_CONTROL : in bit;
	  UNDERFLOW : out bit);
end level2_4d_pbc;

architecture level2_4d of level2_4d_pbc is

	 
    -- Component declarations

 -- xilinx memory


-- component DP_RAM_XILINX_256
--	port (
--	addra: IN std_logic_VECTOR(7 downto 0);
--	clka: IN std_logic;
--	addrb: IN std_logic_VECTOR(7 downto 0);
--	clkb: IN std_logic;
--	dina: IN std_logic_VECTOR(31 downto 0);
--	wea: IN std_logic;
--	enb: IN std_logic;
--	doutb: OUT std_logic_VECTOR(31 downto 0));
-- end component;

component simulation_mem_256 is
	port (
	addra: in std_logic_vector(7 downto 0);
	addrb: in std_logic_vector(7 downto 0);
	clka: in std_logic;
	clkb: in std_logic;
	dina: in std_logic_vector(31 downto 0);
	doutb: out std_logic_vector(31 downto 0);
	enb: in std_logic;
	wea: in std_logic);
end component;

 -- Synplicity black box declaration
--attribute black_box : boolean;
--attribute black_box of DP_RAM_XILINX: component is true;

--component DP_RAM_XILINX_MASK
--	port (
--	addra: IN std_logic_VECTOR(7 downto 0);
--	clka: IN std_logic;
--	addrb: IN std_logic_VECTOR(7 downto 0);
--	clkb: IN std_logic;
--	dina: IN std_logic_VECTOR(3 downto 0);
--	wea: IN std_logic;
--	enb: IN std_logic;
--	doutb: OUT std_logic_VECTOR(3 downto 0));
-- end component;
 
component simulation_mem_mask
	port (
	addra: IN std_logic_VECTOR(7 downto 0);
	clka: IN std_logic;
	addrb: IN std_logic_VECTOR(7 downto 0);
	clkb: IN std_logic;
	dina: IN std_logic_VECTOR(3 downto 0);
	wea: IN std_logic;
	enb: IN std_logic;
	doutb: OUT std_logic_VECTOR(3 downto 0));
 end component;

 -- Synplicity black box declaration
--attribute black_box : boolean;
--attribute black_box of DP_RAM_XILINX_MASK: component is true;

 -- Actel memory

--component MY_MEMORY

--   port(DO : out std_logic_vector (31 downto 0);
--      RCLOCK : in std_logic;
--      WCLOCK : in std_logic;
--      DI : in std_logic_vector (31 downto 0);
--      WRB : in std_logic;
--      RDB : in std_logic;
--      WADDR : in std_logic_vector (7 downto 0);
--      RADDR : in std_logic_vector (7 downto 0));

--end component;




--component MY_MASK_MEMORY

--   port(DO : out std_logic_vector (3 downto 0);
--      RCLOCK : in std_logic;
--      WCLOCK : in std_logic;
--      DI : in std_logic_vector (3 downto 0);
--      WRB : in std_logic;
--      RDB : in std_logic;
--      WADDR : in std_logic_vector (7 downto 0);
--      RADDR : in std_logic_vector (7 downto 0));

--end component;

--component LPM_RAM_DP_MASK
--	port
--	(
--	  DATA : in std_logic_vector(3 downto 0);
--      RDADDRESS : in std_logic_vector(7 downto 0);
--      WRADDRESS : in std_logic_vector(7 downto 0);
--      WRCLKEN : in std_logic;
--	  RDCLKEN : in std_logic;
--      RDEN : in std_logic;
--      WREN : in std_logic;
--      WRCLOCK :in std_logic;
--	  RDCLOCK : in std_logic;
--      Q : out std_logic_vector(3 downto 0));
--end component;
--
--
--component LPM_RAM_DP
--      generic (LPM_WIDTH    : positive ;
--               LPM_WIDTHAD  : positive;
--               LPM_NUMWORDS : positive;
--               LPM_INDATA   : string;
--               LPM_RDADDRESS_CONTROL : string;
--               LPM_WRADDRESS_CONTROL : string;
--               LPM_OUTDATA  : string;
--               LPM_TYPE     : string;
--               LPM_FILE     : string;
--	       LPM_HINT	    : string);
--port (RDCLOCK : in std_logic;
--            RDCLKEN : in std_logic;
--            RDADDRESS : in std_logic_vector(7 downto 0);
--            RDEN : in std_logic;
--            DATA : in std_logic_vector(31 downto 0);
--            WRADDRESS : in std_logic_vector(7 downto 0);
--            WREN : in std_logic;
--            WRCLOCK : in std_logic;
--            WRCLKEN : in std_logic;
--            Q : out std_logic_vector(31 downto 0));
--end component;

-- TSMC DPRAM

  component ra2sh_256W_32B_8MX_offWRMSK_8WRGRAN 

  port ( 
	CLKA: in std_logic;
	CENA: in std_logic;
	WENA: in std_logic;
	AA: in std_logic_vector(7 downto 0);
	DA: in std_logic_vector(31 downto 0);
	QA: out std_logic_vector(31 downto 0);
	CLKB: in std_logic;
	CENB: in std_logic;
	WENB: in std_logic;
	AB: in std_logic_vector(7 downto 0);
	DB: in std_logic_vector(31 downto 0);
	QB: out std_logic_vector(31 downto 0)

  );

    end component;


	 
	component OUT_REGISTER
        port(
            DIN : in bit_vector(31 downto 0);
            CLEAR : in bit;
			RESET : in bit;
			U_DATA_VALID_IN : in bit;
		FINISH : in bit;
		DECOMP : in bit; 
            CLK : in bit;
		U_DATA_VALID_OUT : out bit;
            QOUT : out  bit_vector(31 downto 0)
        );
    end component;
    component OB_ASSEM
        port(
            RAM_DATA : in std_logic_vector(31 downto 0);
			RAM_MASK : in std_logic_vector(3 downto 0);
            MATCH_TYPE : in bit_vector(3 downto 0);
            LITERAL_DATA : in bit_vector(31 downto 0);
			LITERAL_MASK : in bit_vector(4 downto 0);
            DOUT : out bit_vector(31 downto 0);
			MOUT : out bit_vector(3 downto 0)
        );
    end component;
	
    component MC_MUX_3D
        port(
            B : in bit_vector(15 downto 0);
            ENABLED: in bit;
            Y : out bit_vector(15 downto 0));
    end component;
   
      
    component MG_LOGIC_2
        port(
             MATCH_LOC : in bit_vector(15 downto 0);
             FULL_HIT : in bit;
             MOVE : out bit_vector(15 downto 0)
                                  );
    end component;

    component DECODE4_16_INV
        port(
            MATCH_LOC_IN : in bit_vector(3 downto 0);
            MATCH_LOC_OUT : out bit_vector(15 downto 0)
        );
    end component;

	component PIPELINE_R2_D
 		port(
			MATCH_LOC_IN_D : in bit_vector(15 downto 0);
			MATCH_TYPE_IN : in bit_vector(3 downto 0);
			LIT_DATA_IN : in bit_vector(31 downto 0);
			LIT_MASK_IN : in bit_vector(4 downto 0);
			MOVE_ENABLE_D_IN : in bit;
			FULL_HIT_IN : in bit;
			CLEAR : in bit;
			RESET : in bit;
			CLK : in bit;
			MATCH_LOC_OUT_D : out bit_vector(15 downto 0);
			MATCH_TYPE_OUT : out bit_vector(3 downto 0);
			LIT_DATA_OUT : out bit_vector(31 downto 0);
			LIT_MASK_OUT : out bit_vector(4 downto 0);
			FULL_HIT_OUT : out bit;
			MOVE_ENABLE_D_OUT : out bit		
	 );
	end component;

	component PIPELINE_R1_D
		port(
			FULL_HIT_IN:in bit;
			MATCH_TYPE_IN:in bit_vector(3 downto 0);
			MATCH_LOC_IN:in bit_vector(3 downto 0);
			LIT_DATA_IN:in bit_vector(31 downto 0);
			LIT_MASK_IN : in bit_vector(4 downto 0);
			MOVE_ENABLE_D_IN:in bit;
			CLEAR:in bit;
			RESET : in bit;
			CLK:in bit;
			FULL_HIT_OUT:out bit;
			MATCH_TYPE_OUT:out bit_vector(3 downto 0);
			MATCH_LOC_OUT:out bit_vector(3 downto 0);
			LIT_DATA_OUT:out bit_vector(31 downto 0);
			LIT_MASK_OUT : out bit_vector(4 downto 0);
			MOVE_ENABLE_D_OUT:out bit
		);
		end component;


 

	component POINTER_ARRAY 
	port
	(
		PREVIOUS : in bit_vector(3 downto 0);
		MOVE : in bit_vector(15 downto 1);
		MOVE_ENABLE : in bit;
		SEL_WRITE : in bit_vector(15 downto 0);
		SEL_READ : in bit_vector(15 downto 0);
		CLEAR : in bit ;
		RESET : in bit;
		CLK : in bit ;
		WRITE_ADDRESS : out bit_vector(3 downto 0);
		READ_ADDRESS : out bit_vector(3 downto 0) 
	);
	end component;

	component RLI_COUNTER_D 
	port (LOAD: in bit;
	  DATA : in bit_vector(7 downto 0);
	  ENABLE_D : in bit;
	  RESET : in bit;
	  CLEAR : in bit;
	  CLK : in bit;
	  END_COUNT : out bit
	  );
	end component;



	component MLD_DPROP_5
	port
	 (
	        DIN : in bit_vector(0 to 15);
	        DOUT : out bit_vector(14 downto 0);
	        FULL_OR : out bit
	);
    end component;

	component ODA_REGISTER_D
		port(
			MOVE_IN : in bit_vector(15 downto 0);
			MOVE_ENABLE :  in bit;
			CONTROL : in bit_vector(14 downto 0);
			CLK : in bit;
			RESET : in bit;
			CLEAR : in bit;
			MOVE_OUT : out bit_vector(15 downto 0)
		);
	 end component;


	 component REG_TEMP
 	  port (
		     DATA_IN : in bit_vector(31 downto 0);
		     MASK_IN : in bit_vector(3 downto 0);
		     CLK : in bit;
		     CLEAR : in bit;
		     RESET : in bit;
				ENABLE : in bit;
     		     DATA_OUT : out std_logic_vector(31 downto 0);
		     MASK_OUT : out std_logic_vector(3 downto 0)
	 );
	 end component;

	 component MUX_RAM
	 port (
			RAM_DATA : in std_logic_vector(31 downto 0);
			RAM_MASK : in std_logic_vector(3 downto 0);
			REG_DATA : in std_logic_vector(31 downto 0);
			REG_MASK : in std_logic_vector(3 downto 0);
			EQUAL : in bit;
			ASSEM_DATA : out std_logic_vector(31 downto 0);
			ASSEM_MASK : out std_logic_vector(3 downto 0)
	  );
	  end component;

	 component SYNC_RAM_REGISTER
	 port (
		  WRITE_ADDRESS_IN : in bit_vector(3 downto 0);
		  MATCH_TYPE_IN : in bit_vector(3 downto 0);
		  LITERAL_DATA_IN : in bit_vector(31 downto 0);
		  LITERAL_MASK_IN : in bit_vector(4 downto 0);
		  U_DATA_VALID_IN : in bit;
			ENABLE : in bit;
	      RESET : in bit;
   		  CLEAR : in bit;
		  CLK : in bit;
		  WRITE_ADDRESS_OUT :out bit_vector(3 downto 0);
		  MATCH_TYPE_OUT : out bit_vector(3 downto 0);
		  LITERAL_DATA_OUT :out bit_vector(31 downto 0);
		  LITERAL_MASK_OUT : out bit_vector(4 downto 0);
		  U_DATA_VALID_OUT : out bit
	  );
	  end component;

	component LOCATION_EQUAL
	port (
		  WRITE_ADDRESS_IN : in bit_vector(3 downto 0);
		  READ_ADDRESS_IN : in bit_vector(3 downto 0);
		  CLK : in bit;
		  RESET : in bit;
       CLEAR : in bit;
		  ENABLE : in bit;
		  WRITE_ADDRESS_OUT : out bit_vector(3 downto 0);
		  READ_ADDRESS_OUT  : out bit_vector(7 downto 0);
	      EQUAL : out bit);
	end component;



    component DECODE_LOGIC_PBC
        port(
            LITERAL_DATA : out bit_vector(31 downto 0);
            MATCH_TYPE : out bit_vector(3 downto 0);
            MATCH_LOC : out bit_vector(3 downto 0);
		MASK : out bit_vector(4 downto 0);
		WAIT_DATA : out bit;
            D_FULL_HIT : out bit;
            UNDERFLOW : out bit;
		RL_DETECTED : out bit;
		RL_COUNT : out bit_vector(7 downto 0);
		COUNT_ENABLE : out bit;
		END_COUNT : in bit;
            DIN : in bit_vector(63 downto 0);
            DECOMP : in bit;
            CLEAR : in bit;
			RESET : in bit;
            CLK : in bit;
		ENABLE : in bit ;
     OVERFLOW_CONTROL : in bit;
		DECODING_UNDERFLOW : in bit 
        );
    end component;

    -- Signal declarations
    signal C_DIN : bit_vector(63 downto 0);
    signal RAM_DATA : std_logic_vector(31 downto 0); 
    signal RAM_MASK : std_logic_vector(3 downto 0);
	signal RAM_DATA_AUX : std_logic_vector(31 downto 0);
	signal RAM_MASK_AUX : std_logic_vector(3 downto 0);
 
    signal D_FULL_HIT : bit;


    signal D_LIT_DATA : bit_vector(31 downto 0);
	signal D_LIT_MASK : bit_vector(4 downto 0);
    signal D_MLOC : bit_vector(15 downto 0);
    signal D_MTYPE : bit_vector(3 downto 0);
   
    signal D_MOVE: bit_vector(15 downto 0);
    
 
    signal U_DOUT : bit_vector(31 downto 0); 
   
   
    signal ENABLED:bit;

    signal D_LIT_DATA_P1: bit_vector(31 downto 0);
	signal D_LIT_MASK_P1: bit_vector(4 downto 0);
    signal D_MTYPE_P1 : bit_vector(3 downto 0);
	signal D_LIT_DATA_P2: bit_vector(31 downto 0);
	signal D_LIT_MASK_P2: bit_vector(4 downto 0);
    signal D_MTYPE_P2 : bit_vector(3 downto 0);
    signal MLOC_P1 : bit_vector(3 downto 0);
	signal D_MLOC_P2 : bit_vector(15 downto 0);
    signal MLOC : bit_vector(3 downto 0);
    signal D_FULL_HIT_P1 : bit;
    signal D_FULL_HIT_P2 : bit;

	signal MOVE_ENABLE_P2 : bit;

   signal MOVE : bit_vector(14 downto 0);  
   signal MOVE_INT : bit_vector(15 downto 0); -- Out of order adaptation
   signal MOVE_INT_AUX : bit_vector(15 downto 0); -- ram initial
   signal MOVE_DROP : bit_vector(15 downto 0);

   --RLI signals

  
   signal RL_DETECTED_D : bit;
   signal RL_COUNT_D : bit_vector(7 downto 0); -- data of the number of repeticions
   signal END_COUNT_D : bit;
   signal COUNT_ENABLE_D : bit;
 	
   signal U_DOUT_R : bit_vector(31 downto 0);
   signal U_MASK_R : bit_vector(3 downto 0);


   -- to control underflow condtions in the decompression buffer

   signal WAIT_DATA : bit;

   -- memory signals

   signal WRITE_ADDRESS : bit_vector(3 downto 0);
   signal READ_ADDRESS : bit_vector(3 downto 0);
   signal WRITE_ADDRESS_MEMORY : std_logic_vector(7 downto 0);
   signal READ_ADDRESS_MEMORY : std_logic_vector(7 downto 0);    
   signal CLK_MEMORY : std_logic;
   signal U_DOUT_R_MEMORY : std_logic_vector(31 downto 0);
   signal ENABLED_MEMORY_RD : std_logic;
   signal ENABLED_MEMORY_WR : std_logic;
   signal MOVE_POINTER : bit_vector(15 downto 0);
   signal D_MTYPE_MEM :std_logic_vector(3 downto 0);
   signal U_MASK_R_MEMORY : std_logic_vector(3 downto 0);
   -- RAM syncrnous

   signal ASSEM_DATA : std_logic_vector(31 downto 0); 
   signal ASSEM_MASK : std_logic_vector(3 downto 0);
   signal D_MTYPE_OUT : bit_vector(3 downto 0);
   signal D_LIT_DATA_OUT : bit_vector(31 downto 0);
   signal D_LIT_MASK_OUT : bit_vector(4 downto 0);
   signal U_DOUT_R_INT : std_logic_vector(31 downto 0);
   signal U_MASK_R_INT : std_logic_vector(3 downto 0);
   signal EQUAL : bit;
   signal U_DATA_VALID_INT : bit;
   signal READ_ADDRESS_OUT : bit_vector(7 downto 0);
   signal WRITE_ADDRESS_OUT : bit_vector(3 downto 0);
   signal WRITE_ADDRESS_INT : bit_vector(3 downto 0); 

	signal tsmc_cena_n , tsmc_cenb_n : std_logic;
	signal tsmc_wena_n , tsmc_wenb_n : std_logic;
    
    
    type MY_MASK_MEM is array (0 to 511) of std_logic_vector(3 downto 0);
    signal mem_mask : MY_MASK_MEM;
	
	


   begin
    -- Signal assignments

    C_DIN <= C_DATAIN;
 
    U_DATAOUT <= U_DOUT;
   
    -- Component instances
   

    OB_ASSEM_1 : OB_ASSEM
        port map(
            RAM_DATA => ASSEM_DATA,
		RAM_MASK => ASSEM_MASK,
            MATCH_TYPE => D_MTYPE_OUT,
            LITERAL_DATA => D_LIT_DATA_OUT,
			LITERAL_MASK => D_LIT_MASK_OUT,
            DOUT => U_DOUT_R,
			MOUT => U_MASK_R
        );
 
  
	REG_TEMP1 : REG_TEMP
 	  port map(
		     DATA_IN => U_DOUT_R,
			 MASK_IN => U_MASK_R,
		     CLK => CLK,
		     CLEAR => CLEAR,
			 RESET => RESET,
			ENABLE => U_DATA_VALID_INT,
			 MASK_OUT => U_MASK_R_INT,
		     DATA_OUT => U_DOUT_R_INT
	 );

	MUX_RAM1: MUX_RAM
	port map(
			RAM_MASK => RAM_MASK,
			RAM_DATA => RAM_DATA,
			REG_DATA => U_DOUT_R_INT,
			REG_MASK => U_MASK_R_INT,
			EQUAL => EQUAL,
			ASSEM_DATA => ASSEM_DATA,
			ASSEM_MASK => ASSEM_MASK

		);
      	

	ODA_REGISTER_1 : ODA_REGISTER_D
		port map(
			MOVE_IN => MOVE_DROP,
			MOVE_ENABLE => ENABLED, -- ram initialization 
			CONTROL => MOVE,
			CLK => CLK,
			CLEAR => CLEAR,
			RESET => RESET,
			MOVE_OUT => MOVE_INT
			);

	MC_MUX_1 : MC_MUX_3D
        port map(
            B => D_MOVE,
            ENABLED => ENABLED,
            Y => MOVE_DROP
        );


	
	MOVE_GENERATION : MLD_DPROP_5 port map ( DIN => MOVE_INT_AUX,
								DOUT => MOVE,
								FULL_OR => open
								);

    MG_LOGIC_1 : MG_LOGIC_2
        port map(
            MOVE => D_MOVE,
            MATCH_LOC => D_MLOC,
            FULL_HIT => D_FULL_HIT
        );


   DECODE4_17 : DECODE4_16_INV
        port map(
            MATCH_LOC_IN => MLOC,
            MATCH_LOC_OUT => D_MLOC_P2
        );

	PIPELINE_R1_D_1: PIPELINE_R1_D
		port map(
			FULL_HIT_IN => D_FULL_HIT_P1,
			MATCH_TYPE_IN => D_MTYPE_P1,
			MATCH_LOC_IN => MLOC_P1,
			LIT_DATA_IN => D_LIT_DATA_P1,
			LIT_MASK_IN => D_LIT_MASK_P1,
			MOVE_ENABLE_D_IN => WAIT_DATA,
			CLEAR => CLEAR,
			RESET => RESET,
			CLK => CLK,
			FULL_HIT_OUT => D_FULL_HIT_P2,
			MATCH_TYPE_OUT => D_MTYPE_P2,
			MATCH_LOC_OUT => MLOC,
			LIT_DATA_OUT => D_LIT_DATA_P2,
			LIT_MASK_OUT => D_LIT_MASK_P2,
			MOVE_ENABLE_D_OUT => MOVE_ENABLE_P2
	);	
	
 PIPELINE_R2_D_1: PIPELINE_R2_D
 		port map(
			MATCH_LOC_IN_D => D_MLOC_P2,
			MATCH_TYPE_IN => D_MTYPE_P2,
			LIT_DATA_IN => D_LIT_DATA_P2,
			LIT_MASK_IN => D_LIT_MASK_P2,
			MOVE_ENABLE_D_IN => MOVE_ENABLE_P2,
			FULL_HIT_IN => D_FULL_HIT_P2,
			CLEAR => CLEAR,
			RESET => RESET,
			CLK => CLK,
			MATCH_LOC_OUT_D => D_MLOC,
			MATCH_TYPE_OUT => D_MTYPE,
			LIT_DATA_OUT => D_LIT_DATA,
			LIT_MASK_OUT => D_LIT_MASK,
			FULL_HIT_OUT => D_FULL_HIT,
			MOVE_ENABLE_D_OUT => ENABLED
	
	 );


  SYNC_RAM_REGISTER1 : SYNC_RAM_REGISTER
	port map(
		  WRITE_ADDRESS_IN => WRITE_ADDRESS,
		  MATCH_TYPE_IN => D_MTYPE,
		  LITERAL_DATA_IN => D_LIT_DATA,
		  LITERAL_MASK_IN => D_LIT_MASK,
		  U_DATA_VALID_IN => ENABLED,
			ENABLE => ENABLED,
	      CLEAR => CLEAR,
		  RESET => RESET,
	      CLK => CLK,
		  WRITE_ADDRESS_OUT => WRITE_ADDRESS_INT,
		  MATCH_TYPE_OUT => D_MTYPE_OUT,
		  LITERAL_DATA_OUT => D_LIT_DATA_OUT,
		  LITERAL_MASK_OUT => D_LIT_MASK_OUT,
		  U_DATA_VALID_OUT => U_DATA_VALID_INT);

  LOCATION_EQUAL1: LOCATION_EQUAL
	port map(
		  WRITE_ADDRESS_IN => WRITE_ADDRESS_INT,
		  READ_ADDRESS_IN => READ_ADDRESS,
		  CLK => CLK,
		  CLEAR => CLEAR,
		  RESET => RESET,
		  ENABLE => ENABLED, -- U_DATA_VALID_INT,
		  WRITE_ADDRESS_OUT => WRITE_ADDRESS_OUT,
		  READ_ADDRESS_OUT => READ_ADDRESS_OUT,
	      EQUAL => EQUAL);


-- 	RAM_DIC : DP_RAM_XILINX_256
--	port map (
--	addra =>WRITE_ADDRESS_MEMORY,
--	clka =>CLK_MEMORY,
--	addrb =>READ_ADDRESS_MEMORY,
--	clkb =>CLK_MEMORY,
--	dina =>U_DOUT_R_MEMORY,
--	wea =>ENABLED_MEMORY_WR,
--	enb =>ENABLED_MEMORY_RD,
--	doutb =>RAM_DATA);

level2_4d_pbc_sim_mem: simulation_mem_256
port map (
    addra => WRITE_ADDRESS_MEMORY,
    clka =>  CLK_MEMORY,
    addrb => READ_ADDRESS_MEMORY,
    clkb => CLK_MEMORY,
    dina => U_DOUT_R_MEMORY,
    wea => ENABLED_MEMORY_WR,
    enb =>  ENABLED_MEMORY_RD,
    doutb =>  RAM_DATA
);


-- Actel memory

--   RAM_DIC : MY_MEMORY
--   port map(DO => RAM_DATA,
--      RCLOCK => CLK_MEMORY,
--      WCLOCK => CLK_MEMORY,
--      DI => U_DOUT_R_MEMORY,
--      WRB => ENABLED_MEMORY_WR,
--      RDB => ENABLED_MEMORY_RD,
--      WADDR =>  WRITE_ADDRESS_MEMORY,
--      RADDR => READ_ADDRESS_MEMORY);

-- Altera memory



--ALT_RAM_DIC :
--
--if (not TSMC013) generate
--
--RAM_DIC :   LPM_RAM_DP
-- generic map(LPM_WIDTH => 32,
--             LPM_WIDTHAD  => 8,
--             LPM_NUMWORDS => 256,
--             LPM_OUTDATA  =>  "UNREGISTERED",
--			 LPM_INDATA => "REGISTERED",
--	        LPM_RDADDRESS_CONTROL => "REGISTERED",
--	        LPM_WRADDRESS_CONTROL => "REGISTERED",
--	        LPM_FILE  => "UNUSED",
--	        LPM_TYPE  => "LPM_RAM_DP",
--	        LPM_HINT => "UNUSED")            
--   PORT MAP(data => U_DOUT_R_MEMORY,
--            rdaddress => READ_ADDRESS_MEMORY,
--            wraddress => WRITE_ADDRESS_MEMORY,
--            wrclken => ENABLED_MEMORY_WR,
--	        rdclken => ENABLED_MEMORY_RD,
--            rden => ENABLED_MEMORY_RD,
--            wren => ENABLED_MEMORY_WR,
--            wrclock => CLK_MEMORY,
--	        rdclock => CLK_MEMORY,
--           q => RAM_DATA);
--
--end generate;

-- Port 1 = R

-- Port 2 = R/W

--TSMC013_RAM_DIC :
--
--  if (TSMC013) generate
--
--  TMSC_RAM : ra2sh_256W_32B_8MX_offWRMSK_8WRGRAN port map
--      (
--        clka        =>      CLK_MEMORY,
--        cena        =>      tsmc_cena_n ,
--        wena        =>      tsmc_wena_n,
--        aa          =>      READ_ADDRESS_MEMORY,
--        da          =>      U_DOUT_R_MEMORY,
--        qa          =>      RAM_DATA,
--        clkb        =>      CLK_MEMORY,
--        cenb        =>      tsmc_cenb_n,
--        wenb        =>      tsmc_wenb_n,
--        ab          =>      WRITE_ADDRESS_MEMORY,
--        db          =>      U_DOUT_R_MEMORY,
--        qb          =>      OPEN
--      ) ;      
--
--end generate;



tsmc_cenb_n <= not (ENABLED_MEMORY_WR);
tsmc_cena_n <= not (ENABLED_MEMORY_RD);
tsmc_wena_n <='1';

--    not (RDEN_SB); Always in read-mode; read-enable used to

--    power-up ram

tsmc_wenb_n <= not (ENABLED_MEMORY_WR);

--MASK_ARRAY : DP_RAM_XILINX_MASK
--	port map (
--	addra => WRITE_ADDRESS_MEMORY,
--	clka =>CLK_MEMORY,
--	addrb =>READ_ADDRESS_MEMORY,
--	clkb =>CLK_MEMORY,
--	dina => U_MASK_R_MEMORY,
--	wea =>ENABLED_MEMORY_WR,
--	enb =>ENABLED_MEMORY_RD,
--	doutb =>RAM_MASK);

simulation_mem_mask_level24d : simulation_mem_mask
	port map (
	addra => WRITE_ADDRESS_MEMORY,
	clka =>CLK_MEMORY,
	addrb =>READ_ADDRESS_MEMORY,
	clkb =>CLK_MEMORY,
	dina => U_MASK_R_MEMORY,
	wea =>ENABLED_MEMORY_WR,
	enb =>ENABLED_MEMORY_RD,
	doutb =>RAM_MASK);

--MASK_ARRAY : MY_MASK_MEMORY

--	port map(DO => RAM_MASK,
--    RCLOCK => CLK_MEMORY,
--      WCLOCK => CLK_MEMORY,
--      DI => U_MASK_R_MEMORY,
--      WRB => ENABLED_MEMORY_WR,
--     RDB => ENABLED_MEMORY_RD,
--      WADDR =>  WRITE_ADDRESS_MEMORY,
--      RADDR => READ_ADDRESS_MEMORY);



--MASK_ARRAY :   LPM_RAM_DP_MASK
--
-- PORT MAP(data => U_MASK_R_MEMORY,
--            rdaddress => READ_ADDRESS_MEMORY,
--           wraddress => WRITE_ADDRESS_MEMORY,
--            wrclken => ENABLED_MEMORY_WR,
--	        rdclken => ENABLED_MEMORY_RD,
--           rden => ENABLED_MEMORY_RD,
--            wren => ENABLED_MEMORY_WR,
--            wrclock => CLK_MEMORY,
--	        rdclock => CLK_MEMORY,
--            q => RAM_MASK);



	--CLK_MEMORY <= To_X01Z(CLK);
	--WRITE_ADDRESS_MEMORY <= To_X01Z("0000" & WRITE_ADDRESS_OUT) after 5 ns when RESET = '1' else "00000000" after 5 ns;
	--READ_ADDRESS_MEMORY <= To_X01Z(READ_ADDRESS_OUT)  after 5 ns ; -- memory is defined to hold 256 values;
	--U_DOUT_R_MEMORY <= To_X01Z(U_DOUT_R)  after 5 ns  when RESET = '1' else x"00000000"  after 5 ns;
	--U_MASK_R_MEMORY <= To_X01Z(U_MASK_R)  after 5 ns  when RESET = '1' else "1111"  after 5 ns ; -- write this data at the beggining of each operation
	--ENABLED_MEMORY_WR <= To_X01Z(not(U_DATA_VALID_INT)) or To_X01Z(not(RESET))  after 5 ns ; -- write 0 in location 0 ram initial
	--ENABLED_MEMORY_RD <= To_X01Z(not(ENABLED))  after 5 ns ;
	CLK_MEMORY <= To_X01Z(CLK);
	WRITE_ADDRESS_MEMORY <= To_X01Z("0000" & WRITE_ADDRESS_OUT) when RESET = '1' else "00000000";
	READ_ADDRESS_MEMORY <= To_X01Z(READ_ADDRESS_OUT) ; -- memory is defined to hold 256 values;
	U_DOUT_R_MEMORY <= To_X01Z(U_DOUT_R) when RESET = '1' else x"00000000";
	U_MASK_R_MEMORY <= To_X01Z(U_MASK_R) when RESET = '1' else "1111"; -- write this data at the beggining of each operation
	ENABLED_MEMORY_WR <= To_X01Z(not(U_DATA_VALID_INT)) or To_X01Z(not(RESET)); -- write 0 in location 0 ram initial
	ENABLED_MEMORY_RD <= To_X01Z(not(ENABLED));
    

      -- if D_LIT_MASK_OUT(3) = 0 then mask is 10000 single byte move vector leaves the pointer array intact

	MOVE_POINTER <= MOVE_INT(15 downto 1) & MOVE(14) when (ENABLED = '0' and D_LIT_MASK_OUT(3) = '1') else "1000000000000000"; -- ram initial
	MOVE_INT_AUX <= MOVE_INT when (ENABLED ='0' and D_LIT_MASK_OUT(3) = '1') else "1000000000000000";
--	MOVE_POINTER <= MOVE_INT(15 downto 0) when (ENABLED = '0' and D_LIT_MASK_OUT(3) = '1') else "1000000000000000"; -- ra

--	MOVE_POINTER <= MOVE_INT(15 downto 2) & MOVE(13) when ENABLED = '0' else "100000000000000"; -- ram initial
--	MOVE_INT_AUX <= MOVE_INT when ENABLED ='0' else "1000000000000000";

	POINTER_ARRAY_1 : POINTER_ARRAY 
	port map
	(
		PREVIOUS => WRITE_ADDRESS,
		MOVE =>  MOVE,
		MOVE_ENABLE => ENABLED,
		SEL_WRITE =>MOVE_POINTER,
		SEL_READ => D_MLOC,
		CLEAR => CLEAR,
		RESET => RESET,
		CLK => CLK,
		WRITE_ADDRESS => WRITE_ADDRESS, 
		READ_ADDRESS => READ_ADDRESS
	);

	
	

  	RLI_D : RLI_COUNTER_D
		port map(
		LOAD => RL_DETECTED_D, 
	  	DATA => RL_COUNT_D,
	    ENABLE_D => COUNT_ENABLE_D,
		CLEAR => CLEAR,
		RESET => RESET,
  		CLK => CLK,
		END_COUNT => END_COUNT_D
	    );



    
    DECODE_LOGIC_1 : DECODE_LOGIC_PBC
        port map (
            LITERAL_DATA => D_LIT_DATA_P1,
            MATCH_TYPE => D_MTYPE_P1,
            MATCH_LOC =>MLOC_P1,
			MASK => D_LIT_MASK_P1,
		    WAIT_DATA => WAIT_DATA,
            D_FULL_HIT => D_FULL_HIT_P1,
		    RL_DETECTED => RL_DETECTED_D,
		    RL_COUNT => RL_COUNT_D,
            UNDERFLOW => UNDERFLOW,
		    COUNT_ENABLE => COUNT_ENABLE_D,
		    END_COUNT => END_COUNT_D,
            DIN => C_DIN,
            DECOMP => DECOMP,
            CLEAR => CLEAR,
			RESET => RESET,
	       	ENABLE => MOVE_ENABLE,

   		    DECODING_UNDERFLOW => DECODING_UNDERFLOW,
            OVERFLOW_CONTROL => OVERFLOW_CONTROL,
            CLK => CLK
        );


		U_DATA_VALID <= U_DATA_VALID_INT;
		U_DOUT <= U_DOUT_R;
		MASK   <= U_MASK_R;


--	OUT_REGISTER_1 : OUT_REGISTER 
--        port map(
--        DIN => U_DOUT_R,
--		U_DATA_VALID_IN => U_DATA_VALID_INT,
--        FINISH => FINISH,
--		DECOMP => DECOMP,
--		CLEAR => CLEAR,
--       RESET => RESET,
--		CLK => CLK,
--		U_DATA_VALID_OUT => U_DATA_VALID,
--        QOUT => U_DOUT
--        );

end level2_4d;
