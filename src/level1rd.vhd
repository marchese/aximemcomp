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

---------------------------------
--  ENTITY       = LEVEL1      --
--  version      = 2.0         --
--  last update  = 1/05/00     --
--  author       = Jose Nunez  --
---------------------------------


-- FUNCTION
--  Top level of the hierarchy.
--  This unit does not include a memory interface


--  PIN LIST
--  START        = indicates start of a compress or decompress operation
--  STOP         = forces the end of the current operation
--  COMPRESS     = selects compression mode
--  DECOMPRESS   = selects decompression mode
--  U_BS_IN      = 15 bits maximum block size 32K. size of the block to be compressed
--  C_BS_INOUT   = 16 bits size of the compressed block. compression read the size of the compressed block. decompresssion input the size of the compressed block. buffers stop when is reached. optional system can non-grant the bus to indicate the same. 
--  CLK          = master clock
--  CLEAR_EXT    = asynchronous reset generated externally
--  CLEAR 	     = asynchronous reset generated by the csm
--  U_DATAIN     = data to be compressed
--  C_DATAIN     = data to be decompressed
--  U_DATAOUT    = decompressed data
--  C_DATAOUT    = compressed data
--  ADDR_EN      = enable address tri-states
--  CDATA_EN     = enable compressed data tri-state outputs
--  UDATA_EN     = enable uncompressed data tri-state outputs
--  FINISHED     = signal of finished operation
--  COMPRESSING  = compression mode active
--  FLUSHING     = flush active
--  DECOMPRESSING = decompression active
--  DISALIGNED   = bytes in block is not a multiple of 4 


library ieee,std;
use ieee.std_logic_1164.all;
-- use std.textio.all;

entity level1rd is
port
(
	CS : in bit ;
	RW : in bit;
	ADDRESS: in bit_vector(1 downto 0);
	CONTROL : inout std_logic_vector(31 downto 0);
	CLK : in bit ;
	CLEAR: in bit;
	BUS_ACKNOWLEDGE_C : in bit;
	BUS_ACKNOWLEDGE_U : in bit;
   WAIT_C : in bit;
  WAIT_U : in bit;
	C_DATA_VALID : in bit;
	START_C : in bit;
	TEST_MODE : in bit;
	FINISHED_C : in bit;
	C_DATAIN : in bit_vector(31 downto 0);
	U_DATAOUT : out std_logic_vector(31 downto 0);
	FINISHED : out bit;
	FLUSHING : out bit;
	DECOMPRESSING : out bit;
	U_DATA_VALID : out bit;
	DECODING_OVERFLOW : out bit;
	CRC_OUT : out bit_vector(31 downto 0);
	BUS_REQUEST_C : out bit;
  OVERFLOW_CONTROL_DECODING_BUFFER : out bit;
	BUS_REQUEST_U : out bit
);
end level1rd;


architecture level1_1 of level1rd is

-- these are  the components that form level1

component OUT_REGISTER
        port(
            DIN : in bit_vector(31 downto 0);
            CLEAR : in bit;
			RESET : in bit;
			U_DATA_VALID_IN : in bit;
			FINISHED_IN : in bit;
		    CLK : in bit;
	  	    U_DATA_VALID_OUT : out bit;
			FINISHED_OUT : out bit;
            QOUT : out  bit_vector(31 downto 0)
        );

end component;

component CRC_UNIT_D_32
	port(DIN : in bit_vector(31 downto 0);
		 ENABLE : in bit;
		 CLK : in bit;
		 RESET : in bit;
		 CLEAR : in bit;
		 CRC_OUT : out bit_vector(31 downto 0)
	   	);
end component;


component OUTPUT_BUFFER_32_32
port
(
	FORCE_STOP : in bit;
	START_D: in bit;
	START_C: in bit;
	WRITE : in bit;
	FINISHED : in bit;
  WAITN : in bit;
	DATA_IN_32 : in bit_vector(31 downto 0);
	THRESHOLD : in bit_vector(7 downto 0);
	BUS_ACKNOWLEDGE : in bit;
	CLEAR : in bit ;
	CLK : in bit ;
	FLUSHING : out bit;
	FINISHED_FLUSHING : out bit;
	OVERFLOW_DETECTED : out bit;
	DATA_OUT_32: out bit_vector(31 downto 0);
	READY : out bit;
  OVERFLOW_CONTROL : out bit;
	BUS_REQUEST : out bit
);
end component;


component ASSEMBLING_UNIT
port
(
	ENABLE: in bit;
	DATA_IN_32 : in bit_vector(31 downto 0);
	CLEAR : in bit ;
	RESET : in bit;
	CLK : in bit ;
	MASK : in bit_vector(3 downto 0);
	WRITE : out bit;
	DATA_OUT_32: out bit_vector(31 downto 0)
);
end  component;

component REG_FILE_D
port
(
        DIN : in bit_vector(31 downto 0);
	  	ADDRESS : in bit_vector(1 downto 0);
		CRC_IN : in bit_vector(31 downto 0);
		LOAD_CRC : in bit;
        CLEAR_CR : in bit;
	    RW : in bit;
        ENABLE : in bit;
        CLEAR : in bit;
        CLK : in bit;
	    DOUT : out std_logic_vector(31 downto 0);
	    C_BS_OUT : out bit_vector(31 downto 0);
	    U_BS_OUT : out bit_vector(31 downto 0);
		CRC_OUT : out bit_vector(31 downto 0);
	    START_D : out bit;
	    STOP :out bit;
	    THRESHOLD_LEVEL : out bit_vector(7 downto 0)

);
end component;



component C_BS_COUNTER_D
port
(
	C_BS_IN : in bit_vector(31 downto 0);
 	DECOMPRESS : in bit;
	CLEAR : in bit;
	CLEAR_COUNTER :  in bit;
	CLK : in bit;
	ENABLE_D : in bit;
	ALL_C_DATA : out bit;
	C_BS_OUT : out bit_vector(31 downto 0)
);

end component;


component DECODING_BUFFER_32_64_2
port
(
  FORCE_STOP : in bit;
	START_D : in bit;
	START_C : in bit;
	FINISHED_D : in bit;
	FINISHED_C : in bit;
	UNDERFLOW : in bit;
	DATA_IN_32 : in bit_vector(31 downto 0);
	THRESHOLD_LEVEL : in bit_vector(9 downto 0);
	BUS_ACKNOWLEDGE : in bit;
	C_DATA_VALID : in bit;
  WAITN : in bit;
	CLEAR : in bit ;
	CLK : in bit ;
	DATA_OUT_64: out bit_vector(63 downto 0);
	UNDERFLOW_DETECTED : out bit;
	FINISH : out bit;
	START_ENGINE : out bit;
  OVERFLOW_CONTROL : out bit;
	BUS_REQUEST : out bit
);
end component;


component csm_d
port
(
	START_C : in bit; -- for test mode
	START_D : in bit;
	START_D_ENGINE : in bit;
	STOP : in bit ;
	END_OF_BLOCK : in bit ;
	CLK : in bit;
	CLEAR: in bit;
	DECOMP : out bit ;
	FINISH : out bit ;
	MOVE_ENABLE : out bit ;
	RESET : out bit 
);
end component;


component BSL_TC_2_D 
port
(
      BLOCK_SIZE : in bit_vector(31 downto 0) ;
      INC : in bit ;
      CLEAR : in bit ;
	  RESET : in bit;
      CLK : in bit ;
      EO_BLOCK : out bit ;
      FINISH_D_BUFFERS : out bit

);

end component;


component level2_4d_pbc
port(
        CLK : in bit;
        RESET : in bit;
    	CLEAR : in bit;   	 
        DECOMP : in bit;
        MOVE_ENABLE : in bit;
	  DECODING_UNDERFLOW : in bit;
	  FINISH : in bit;	
      C_DATAIN : in bit_vector(63 downto 0);
    U_DATAOUT : out bit_vector(31 downto 0);
	MASK : out bit_vector(3 downto 0);
	U_DATA_VALID : out bit ;
   OVERFLOW_CONTROL : in bit;
	UNDERFLOW : out bit
    );
end component;


signal  FINISHED_INT : bit;
signal UNDERFLOW_INT : bit;
signal  MOVE_ENABLE: bit;

signal  DECOMP_INT: bit;
signal  LOAD_BS: bit;
signal  INC_TC: bit;
signal  RESET: bit;
signal  EO_BLOCK: bit;
signal  STOP_INT: bit;



signal  START_D_INT : bit;
signal START_D_INT_BUFFERS : bit; -- to start the decompression engine

signal  LATCHED_BS: bit_vector(31 downto 0);

signal C_DATAIN_INT : bit_vector(63 downto 0);
signal U_DATAOUT_INT : bit_vector(31 downto 0);
signal U_DATAOUT_BUFFER : bit_vector(31 downto 0);
signal U_DATAOUT_AUX : bit_vector(31 downto 0);

signal U_DATAOUT_REG: bit_vector(31 downto 0);

signal ENABLE_READ : bit;


signal BUS_REQUEST_DECODING : bit;




signal OVERFLOW_DETECTED_DECODING : bit;
signal UNDERFLOW_DETECTED_DECODING : bit;

signal THRESHOLD_LEVEL : bit_vector(7 downto 0);
signal THRESHOLD_LEVEL_FIXED : bit_vector(9 downto 0);


signal U_DATA_VALID_INT : bit;
signal U_DATA_VALID_REG : bit;
signal U_DATA_VALID_AUX:  bit;

signal MASK_INT : bit_vector(3 downto 0);
signal WRITE_INT : bit;


signal FINISH_D_BUFFERS : bit;
signal FINISHED_BUFFER_DECODING : bit;

signal FINISHED_AUX : bit;

signal ALL_C_DATA : bit;
signal BUS_ACKNOWLEDGE_AUX : bit;

signal C_BS_INT : bit_vector(31 downto 0);

signal C_BS_OUT : bit_vector(31 downto 0);

signal CONTROL_AUX : bit_vector(31 downto 0);

signal CLEAR_COMMAND : bit; -- to reset the command register

signal ENABLE_D_COUNT : bit;  -- count compressed data during decompression

signal CRC_CODE : bit_vector(31 downto 0);
signal ENABLE_CRC : bit;
signal DATA_CRC : bit_vector(31 downto 0);
signal ENABLE_ASSEMBLE : bit; -- stop assembling when block recovered
signal FINISHED_BUFFER : bit;
signal BUS_ACKNOWLEDGE_U_AUX : bit;
signal BUS_REQUEST_U_AUX : bit;
signal THRESHOLD_LEVEL_AUX : bit_vector(7 downto 0);
signal OVERFLOW_CONTROL : bit;



begin


OUT_REGISTER_1: OUT_REGISTER
        port map(
            DIN =>U_DATAOUT_REG,
            CLEAR =>CLEAR,
			RESET =>RESET,
			U_DATA_VALID_IN =>U_DATA_VALID_REG,
			FINISHED_IN => FINISHED_BUFFER,
		    CLK =>CLK,
	  	    U_DATA_VALID_OUT =>U_DATA_VALID_AUX,
			FINISHED_OUT => FINISHED,
            QOUT =>   U_DATAOUT_AUX
       );


CRC_UNIT_1: CRC_UNIT_D_32
	port map(DIN =>DATA_CRC,
		 ENABLE =>ENABLE_CRC,
		 CLK => CLK,
		 RESET => FINISHED_BUFFER,
		 CLEAR => CLEAR,
		 CRC_OUT => CRC_CODE
	   	);

DATA_CRC <= U_DATAOUT_REG; 
ENABLE_CRC <= not(U_DATA_VALID_REG);

OUTPUT_BUFFER_32_32_1 : OUTPUT_BUFFER_32_32
port map
( 
	FORCE_STOP => STOP_INT, 
	START_D =>START_D_INT,
	START_C => START_C,
	WRITE =>WRITE_INT,
	FINISHED =>FINISHED_INT,
  WAITN => WAIT_U,
	DATA_IN_32 =>U_DATAOUT_BUFFER,
	THRESHOLD =>THRESHOLD_LEVEL_AUX,
	BUS_ACKNOWLEDGE =>BUS_ACKNOWLEDGE_U_AUX,
	CLEAR =>CLEAR,
	CLK =>CLK,
	FLUSHING =>FLUSHING,
	FINISHED_FLUSHING =>FINISHED_BUFFER,
	OVERFLOW_DETECTED => OVERFLOW_DETECTED_DECODING,
	DATA_OUT_32 =>U_DATAOUT_REG,
	READY => U_DATA_VALID_REG,
  OVERFLOW_CONTROL => OVERFLOW_CONTROL,
	BUS_REQUEST =>BUS_REQUEST_U_AUX
);



ASSEMBLING_UNIT_1: ASSEMBLING_UNIT
port map (
	ENABLE => ENABLE_ASSEMBLE,
	DATA_IN_32 => U_DATAOUT_INT,
	CLEAR =>CLEAR,
	RESET => RESET,
	CLK =>CLK,
	MASK =>MASK_INT,
	WRITE =>WRITE_INT,
	DATA_OUT_32 => U_DATAOUT_BUFFER
);


ENABLE_ASSEMBLE <= U_DATA_VALID_INT;
				 

level2_4_1 : level2_4d_pbc port map (CLK => CLK,
				RESET => RESET,
				CLEAR => CLEAR,
				DECOMP => DECOMP_INT,
				MOVE_ENABLE => MOVE_ENABLE,
				DECODING_UNDERFLOW => UNDERFLOW_DETECTED_DECODING, -- to stop the decompression engine
				FINISH => FINISHED_INT,
				C_DATAIN => C_DATAIN_INT,
				U_DATAOUT => U_DATAOUT_INT,
				MASK => MASK_INT,
				U_DATA_VALID => U_DATA_VALID_INT,
          OVERFLOW_CONTROL => OVERFLOW_CONTROL,
				UNDERFLOW => UNDERFLOW_INT
	);





csm_1 : csm_d port map (
    START_C => START_C,
	START_D => START_D_INT,
	START_D_ENGINE => START_D_INT_BUFFERS,
	STOP => STOP_INT,
	END_OF_BLOCK => EO_BLOCK,
	CLK => CLK,
	CLEAR => CLEAR,
	DECOMP => DECOMP_INT,
	FINISH => FINISHED_INT,
	MOVE_ENABLE => MOVE_ENABLE,
	RESET => RESET
);



-- if decoding underflow active do not increment the counter


BSL_TC_1: BSL_TC_2_D port map (
      BLOCK_SIZE => LATCHED_BS,
      INC => WRITE_INT,
	  CLEAR => CLEAR,
      RESET => RESET,
      CLK => CLK,
      EO_BLOCK => EO_BLOCK,
   	  FINISH_D_BUFFERS => FINISH_D_BUFFERS
);

  
REG_FILE_1 : REG_FILE_D
port map
(
        DIN => CONTROL_AUX,	
        ADDRESS => ADDRESS,
		CRC_IN => CRC_CODE,
		LOAD_CRC => FINISHED_BUFFER,
  	    CLEAR_CR => CLEAR_COMMAND,    -- reset the comand register to avoid restart.
	    RW => RW,
	    ENABLE =>CS,
        CLEAR =>CLEAR,
        CLK =>CLK,
	    DOUT => CONTROL,
    	C_BS_OUT => C_BS_INT,
	    U_BS_OUT => LATCHED_BS,
		CRC_OUT => CRC_OUT,
	    START_D => START_D_INT,
	    STOP => STOP_INT,
	    THRESHOLD_LEVEL => THRESHOLD_LEVEL 
);




C_BS_COUNTER_1 : C_BS_COUNTER_D
port map
(
	C_BS_IN => C_BS_INT,
	DECOMPRESS => START_D_INT,
	CLEAR_COUNTER => FINISHED_AUX,
	CLEAR => CLEAR,
	CLK => CLK,
	ENABLE_D => ENABLE_D_COUNT,
	ALL_C_DATA => ALL_C_DATA,
	C_BS_OUT => C_BS_OUT
);



DECODING_BUFFER : DECODING_BUFFER_32_64_2
port map
(
  FORCE_STOP => STOP_INT,
	START_D => START_D_INT,
	START_C => START_C,
	FINISHED_D => FINISH_D_BUFFERS,
    FINISHED_C => FINISHED_C,
	UNDERFLOW  => UNDERFLOW_INT,
	DATA_IN_32 => C_DATAIN,
	THRESHOLD_LEVEL => THRESHOLD_LEVEL_FIXED,
	BUS_ACKNOWLEDGE => BUS_ACKNOWLEDGE_AUX,
	C_DATA_VALID => C_DATA_VALID,
  WAITN => WAIT_C,
	CLEAR => CLEAR,
	CLK => CLK,
	DATA_OUT_64 => C_DATAIN_INT,
	UNDERFLOW_DETECTED => UNDERFLOW_DETECTED_DECODING,
	FINISH => FINISHED_BUFFER_DECODING,
	START_ENGINE => START_D_INT_BUFFERS,
  OVERFLOW_CONTROL => OVERFLOW_CONTROL_DECODING_BUFFER,
	BUS_REQUEST => BUS_REQUEST_DECODING
);	

THRESHOLD_LEVEL_FIXED <= "0000000001";  -- buffer present in the ouput. Activate the input buffer inmediatly

-- careful I change this for the PCI implementation
-- U_DATAOUT <= To_X01Z(U_DATAOUT_AUX) when BUS_ACKNOWLEDGE_U = '0' and TEST_MODE = '0' else "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
U_DATAOUT <= To_X01Z(U_DATAOUT_AUX); 
DECOMPRESSING <= DECOMP_INT;
BUS_REQUEST_C <= BUS_REQUEST_DECODING;
FINISHED_AUX <= DECOMP_INT or FINISHED_INT;

CLEAR_COMMAND <= DECOMP_INT or FINISHED_INT; -- clear the command register
U_DATA_VALID <= U_DATA_VALID_REG; -- valid at zero
--U_DATA_VALID <= U_DATA_VALID_AUX when TEST_MODE = '0' else '1'; -- valid at zero

DECODING_OVERFLOW <= OVERFLOW_DETECTED_DECODING;
BUS_ACKNOWLEDGE_AUX  <= BUS_ACKNOWLEDGE_C or ALL_C_DATA;
CONTROL_AUX <= To_bitvector(CONTROL);

BUS_ACKNOWLEDGE_U_AUX <= BUS_ACKNOWLEDGE_U when TEST_MODE = '0' else '0'; -- always acknowledge in test mode 


ENABLE_D_COUNT <= BUS_ACKNOWLEDGE_C or BUS_REQUEST_DECODING; -- both at zero

BUS_REQUEST_U <= BUS_REQUEST_U_AUX when TEST_MODE = '0' else '1';   -- never request
THRESHOLD_LEVEL_AUX <= THRESHOLD_LEVEL when TEST_MODE = '0' else "00001000"; 

end level1_1;