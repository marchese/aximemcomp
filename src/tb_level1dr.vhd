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
--  ENTITY       = TB_LEVEL1CR  --
--  version      = 3.0         --
--  last update  = 17/10/01     --
--  author       = Jose Nunez  --
---------------------------------


-- FUNCTION
-- test bench for level 1 using a register file in compression mode.


library ieee,std;
use ieee.std_logic_1164.all;

use ieee.std_logic_textio.all;
use std.textio.all;

entity TB_LEVEL1dr is
end TB_LEVEL1dr;


architecture TB1dr of TB_LEVEL1dr is

signal CS: bit;

signal RW : bit;

signal ADDRESS: bit_vector(2 downto 0);

signal CONTROL: std_logic_vector(15 downto 0);

signal CLK : bit ;
signal CLEAR : bit;
signal U_DATAIN : bit_vector(31 downto 0) ;
signal C_DATAIN : bit_vector(31 downto 0) ;
signal U_DATAOUT : std_logic_vector(31 downto 0) ;
signal C_DATAOUT : std_logic_vector(31 downto 0) ;

signal FINISHED_C: bit;
signal FINISHED_D: bit;

signal COMPRESSING: bit;

signal BUS_ACKNOWLEDGE_CC: bit;
signal BUS_ACKNOWLEDGE_CU: bit;
signal BUS_ACKNOWLEDGE_DC: bit;
signal BUS_ACKNOWLEDGE_DU: bit;

signal BUS_REQUEST_CC : bit;
signal BUS_REQUEST_CU : bit;
signal BUS_REQUEST_DC : bit;
signal BUS_REQUEST_DU : bit;


signal FLUSHING_C: bit;
signal FLUSHING_D: bit;

signal DECOMPRESSING: bit;

signal DECODING_OVERFLOW : bit;
signal CODING_OVERFLOW : bit;
signal C_DATA_VALID : bit;
signal U_DATA_VALID : bit;
signal CRC_ERROR: bit;
signal ONE: bit;



-- this is the component to be tested

component level1r
port
(
	CS : in bit ;
	RW : in bit;
	ADDRESS: in bit_vector(2 downto 0);
	CONTROL : inout std_logic_vector(15 downto 0);
	CLK : in bit ;	
	CLEAR: in bit;
	BUS_ACKNOWLEDGE_CC : in bit;
	BUS_ACKNOWLEDGE_CU : in bit;
	BUS_ACKNOWLEDGE_DC : in bit;
	BUS_ACKNOWLEDGE_DU : in bit;
	U_DATAIN : in bit_vector(31 downto 0);
	C_DATAIN : in bit_vector(31 downto 0);
	U_DATAOUT : out std_logic_vector(31 downto 0);
	C_DATAOUT : out std_logic_vector(31 downto 0);
	FINISHED_C : out bit;
	FINISHED_D : out bit;
	COMPRESSING : out bit;
	FLUSHING_C : out bit;
	FLUSHING_D : out bit;
	DECOMPRESSING : out bit;
	U_DATA_VALID : out bit;
	C_DATA_VALID : out bit;
	DECODING_OVERFLOW : out bit;
	CODING_OVERFLOW : out bit;
	CRC_ERROR : out bit;
	BUS_REQUEST_CC : out bit;
	BUS_REQUEST_CU : out bit;
	BUS_REQUEST_DC : out bit;
	BUS_REQUEST_DU : out bit
);
end component;

--  set up constants for test vector application & monitoring

constant CLOCK_PERIOD : time := 200 ns;
constant HALF_PERIOD : time := CLOCK_PERIOD / 2;
constant STROBE_TIME : time := 0.9 * HALF_PERIOD;

begin

-- instantiate the device under test
DUT : level1r  port map(
	CS => CS,
	RW => RW,
	ADDRESS => ADDRESS,
	CONTROL => CONTROL,
	CLK	=> CLK,
	CLEAR => CLEAR,
	BUS_ACKNOWLEDGE_CC => BUS_ACKNOWLEDGE_CC,
	BUS_ACKNOWLEDGE_CU => BUS_ACKNOWLEDGE_CU,
	BUS_ACKNOWLEDGE_DC => BUS_ACKNOWLEDGE_DC,
	BUS_ACKNOWLEDGE_DU => BUS_ACKNOWLEDGE_DU,
	U_DATAIN => U_DATAIN,
	C_DATAIN => C_DATAIN,
	U_DATAOUT => U_DATAOUT,
	C_DATAOUT => C_DATAOUT,
	FINISHED_C => FINISHED_C,
	FINISHED_D => FINISHED_D,
	COMPRESSING => COMPRESSING,
	FLUSHING_C => FLUSHING_C,
	FLUSHING_D => FLUSHING_D,
	DECOMPRESSING => DECOMPRESSING,
	U_DATA_VALID => U_DATA_VALID,
	C_DATA_VALID => C_DATA_VALID,
	DECODING_OVERFLOW => DECODING_OVERFLOW,
	CODING_OVERFLOW => CODING_OVERFLOW,
	CRC_ERROR => CRC_ERROR,
	BUS_REQUEST_CC => BUS_REQUEST_CC,
	BUS_REQUEST_CU => BUS_REQUEST_CU,
	BUS_REQUEST_DC => BUS_REQUEST_DC,
	BUS_REQUEST_DU => BUS_REQUEST_DU
);



TEST_VECTORS : process
		-- input t
file TV_OUT : TEXT is out "e:\Users\eljln\compressorfiles\64_together\test_vectors\debug\32vectors_out_d.txt";	-- output test vectors file
-- file TV_IN : TEXT is in "l:\Users\eljln\compressor_files_2\xlzpv5_PBC\test\test_vectors\Cvectors_alic_256.txt";
-- file TV_IN : TEXT is in "l:\Users\eljln\compressor_files_2\xlzpv5_PBC\test\test_vectors\Cvectors_alic_2048.txt";
-- file TV_IN : TEXT is in "l:\Users\eljln\compressor_files_2\xlzpv5_PBC\test\test_vectors\Cvectors_alic_1024.txt";
-- file TV_IN : TEXT is in "l:\Users\eljln\compressor_files_2\xlzpv5_PBC\test\test_vectors\Cvectors_kenn_2048.txt";
-- file TV_IN : TEXT is in "l:\Users\eljln\compressor_files_2\xlzpv5_PBC\test\test_vectors\Cvectors_alic_kenn_2048.txt";
-- file TV_IN : TEXT is in "l:\Users\eljln\compressor_files_2\xlzpv5_PBC\test\test_vectors\Cvectors_kenn_3422.txt";
-- file TV_IN : TEXT is in "l:\Users\eljln\compressor_files_2\xlzpv5_PBC\test\test_vectors\Cvectors_ptt5_2048.txt";
-- file TV_IN : TEXT is in "l:\Users\eljln\compressor_files_2\xlzpv5_PBC\test\test_vectors\Cvectors_ptt5_1024.txt";
-- file TV_IN : TEXT is in "l:\Users\eljln\compressor_files_2\xlzpv5_PBC\test\test_vectors\Cvectors_zeros_1024.txt";
-- file TV_IN : TEXT is in "l:\Users\eljln\compressor_files_2\xlzpv5_PBC\test\test_vectors\Cvectors_zeros_2048.txt";
-- file TV_IN : TEXT is in "l:\Users\eljln\compressor_files_2\xlzpv5_PBC\test\test_vectors\Cvectors_asyo_1024.txt";
-- file TV_IN : TEXT is in "l:\Users\eljln\compressor_files_2\xlzpv5_PBC\test\test_vectors\Cvectors_fiel_1024.txt";
-- file TV_IN : TEXT is in "l:\Users\eljln\compressor_files_2\xlzpv5_PBC\test\test_vectors\Cvectors_plra_1024.txt";
-- file TV_IN : TEXT is in "l:\Users\eljln\compressor_files_2\xlzpv5_PBC\test\test_vectors\Cvectors_plra_2712.txt";
-- CRC = DB79
file TV_IN : TEXT is in "l:\Users\eljln\compressor_files_2\xlzpv5_PBC\test\test_vectors\Dvectors_alic_1024.txt";
-- file TV_IN : TEXT is in "l:\Users\eljln\compressor_files_2\xlzpv5\test\test_vectors\Cvectors_xarg_1024.txt";
-- file TV_IN : TEXT is in "l:\Users\eljln\compressor_files_2\xlzpv5\test\test_vectors\Dvectors_alic_256.txt";
-- file TV_IN : TEXT is in "e:\Users\eljln\compressorfiles\allpacketsizesbuffers16\test\test_vectors_rf\Cvectors_asyoul_16_1024t255.txt";
-- file TV_IN : TEXT is in "e:\Users\eljln\compressorfiles\allpacketsizesbuffers16\test\test_vectors_rf\Cvectors_asyoul_alic_16_1024_367.txt";
-- file TV_IN : TEXT is in "e:\Users\eljln\compressorfiles\allpacketsizesbuffers16\test\test_vectors_rf\Cvectors_expansion_16_4096.txt";
-- file TV_IN : TEXT is in "e:\Users\eljln\compressorfiles\allpacketsizesbuffers16\test\test_vectors_rf\Cvectors_expansion_16_4096t128.txt";
-- file TV_IN : TEXT is in "e:\Users\eljln\compressorfiles\allpacketsizesbuffers16\test\test_vectors_rf\Cvectors_kenn_16_16384t32.txt";
-- file TV_IN : TEXT is in "e:\Users\eljln\compressorfiles\allpacketsizesbuffers16\test\test_vectors_rf\Cvectors_kenn_16_4096t1.txt";
-- file TV_IN : TEXT is in "e:\Users\eljln\compressorfiles\allpacketsizesbuffers16\test\test_vectors_rf\Cvectors_kenn_16_8.txt";
-- file TV_IN : TEXT is in "e:\Users\eljln\compressorfiles\allpacketsizesbuffers16\test\test_vectors_rf\Cvectors_plra_16_1024.txt";
-- file TV_IN : TEXT is in "e:\Users\eljln\compressorfiles\allpacketsizesbuffers16\test\test_vectors_rf\Cvectors_plra_16_32.txt";
-- file TV_IN : TEXT is in "e:\Users\eljln\compressorfiles\allpacketsizesbuffers16\test\test_vectors_rf\Dvectors_plra_16_32768_sync.txt";
-- file TV_IN : TEXT is in "e:\Users\eljln\compressorfiles\allpacketsizesbuffers16\test\test_vectors_rf\Cvectors_plra_16_457.txt";
-- file TV_IN : TEXT is in "e:\Users\eljln\compressorfiles\allpacketsizesbuffers16\test\test_vectors_rf\Cvectors_plra_plra_16_457_1024.txt";
-- file TV_IN : TEXT is in "e:\Users\eljln\compressorfiles\allpacketsizesbuffers16\test\test_vectors_rf\Cvectors_xargss_16_1024.txt";
-- file TV_IN : TEXT is in "e:\Users\eljln\compressorfiles\allpacketsizesbuffers16\test\test_vectors_rf\Cvectors_zeros_16_1024.txt";
-- file TV_IN : TEXT is in "e:\Users\eljln\compressorfiles\allpacketsizesbuffers16\test\test_vectors_rf\Cvectors_zeros_zeros_16_1024_1024.txt";
-- file TV_IN : TEXT is in "e:\Users\eljln\compressorfiles\allpacketsizesbuffers16\test\test_vectors_rf\DCvectors_alic_alic_16_367o_367.txt";
-- file TV_IN : TEXT is in "e:\Users\eljln\compressorfiles\allpacketsizesbuffers16\test\test_vectors_rf\Dvectors_alic_16_367.txt";
-- file TV_IN : TEXT is in "e:\Users\eljln\compressorfiles\allpacketsizesbuffers16\test\test_vectors_rf\Dvectors_alic_16_367o.txt";
-- file TV_IN : TEXT is in "e:\Users\eljln\compressorfiles\allpacketsizesbuffers16\test\test_vectors_rf\Dvectors_alic_1024.txt";
-- file TV_IN : TEXT is in "e:\Users\eljln\compressorfiles\allpacketsizesbuffers16\test\test_vectors_rf\Dvectors_expansion_16_4096.txt";
-- file TV_IN : TEXT is in "e:\Users\eljln\compressorfiles\allpacketsizesbuffers16\test\test_vectors_rf\Dvectors_kenn_16_16384.txt";
-- file TV_IN : TEXT is in "e:\Users\eljln\compressorfiles\allpacketsizesbuffers16\test\test_vectors_rf\Dvectors_kenn_16_32768.txt";
-- file TV_IN : TEXT is in "e:\Users\eljln\compressorfiles\allpacketsizesbuffers16\test\test_vectors_rf\Dvectors_plra_16_32.txt";
-- file TV_IN : TEXT is in "e:\Users\eljln\compressorfiles\allpacketsizesbuffers16\test\test_vectors_rf\Dvectors_plra_16_32768.txt";
-- file TV_IN : TEXT is in "e:\Users\eljln\compressorfiles\allpacketsizesbuffers16\test\test_vectors_rf\Dvectors_plra_16_457.txt";
-- file TV_IN : TEXT is in "e:\Users\eljln\compressorfiles\allpacketsizesbuffers16\test\test_vectors_rf\Dvectors_xargss_plra_16_4096_457.txt";
-- file TV_IN : TEXT is in "e:\Users\eljln\compressorfiles\allpacketsizesbuffers16\test\test_vectors_rf\Dvectors_zeros_16_1024.txt";
-- file TV_IN : TEXT is in "e:\Users\eljln\compressorfiles\allpacketsizesbuffers16\test\test_vectors_rf\Cvectors_zeros_16_32.txt";



variable LIN : line;
variable LOUT : line;
			                            -- input test vectors from input test file
variable I_CLEAR : bit ;

variable I_CS: bit;

variable I_RW: bit;

variable I_ADDRESS : bit_vector(1 downto 0);

variable I_CONTROL : std_logic_vector(15 downto 0);

variable I_U_DATAIN : bit_vector(31 downto 0) ;
variable I_C_DATAIN : bit_vector(31 downto 0) ;

variable OLD_I_C_DATAIN: bit_vector(31 downto 0);
    		                        		-- expected response vectors
variable I_COMPRESSING: bit;

variable I_DECOMPRESSING: bit;

variable I_BUS_ACKNOWLEDGE_C : bit;

variable I_BUS_ACKNOWLEDGE_U : bit;

variable I_BUS_REQUEST_C : bit;

variable I_BUS_REQUEST_U : bit;

variable I_FINISHED: bit;

variable I_FLUSHING: bit;

variable I_U_DATAOUT : std_logic_vector(31 downto 0) ;
variable I_C_DATAOUT : std_logic_vector(31 downto 0) ;

variable I_U_DATA_VALID : bit;

variable I_C_DATA_VALID : bit;
variable O_FINISHED: bit;

variable O_COMPRESSING: bit;

variable O_FLUSHING: bit;

variable O_DECOMPRESSING: bit;

variable O_DISALIGNED : bit;

variable O_BUS_REQUEST_C : bit;

variable O_BUS_REQUEST_U : bit;

variable O_U_DATAOUT : std_logic_vector(31 downto 0) ;
variable O_C_DATAOUT : std_logic_vector(31 downto 0) ;
variable O_DECODING_OVERFLOW : bit;
variable O_U_DATA_VALID : bit;
variable O_C_DATA_VALID : bit;

variable SPACE : character;


begin
while not(endfile(TV_IN)) loop				-- check for end of file

	readline(TV_IN , LIN);
      read(LIN , I_CLEAR);
	read(LIN , SPACE);
	read(LIN , I_CS);				-- read in input test vectors
	read(LIN , SPACE);
	read(LIN , I_RW);
	read(LIN , SPACE);
	read(LIN , I_ADDRESS);
	read(LIN , SPACE);
	read(LIN , I_CONTROL);
	read(LIN , SPACE);
	read(LIN , I_BUS_ACKNOWLEDGE_C);
	read(LIN , SPACE);
	read(LIN , I_BUS_ACKNOWLEDGE_U);
	read(LIN , SPACE);
	read(LIN , I_U_DATAIN);
	read(LIN , SPACE);
	read(LIN , I_C_DATAIN);
	read(LIN , SPACE);
	read(LIN , I_COMPRESSING);			-- read in expected response vectors
	read(LIN , SPACE);
    read(LIN , I_DECOMPRESSING);
	read(LIN , SPACE);
	read(LIN, I_BUS_REQUEST_C);
	read(LIN, SPACE);
	read(LIN, I_BUS_REQUEST_U);
	read(LIN, SPACE);
	read(LIN, I_C_DATA_VALID);
	read(LIN, SPACE);
      read(LIN , I_FINISHED);
	read(LIN , SPACE);
      read(LIN , I_FLUSHING);
	read(LIN , SPACE);
      read(LIN , I_U_DATA_VALID);
	read(LIN , SPACE);
	read(LIN , I_U_DATAOUT);
	read(LIN , SPACE);
	read(LIN , I_C_DATAOUT);
	read(LIN , SPACE);

	CLK <= '1';					-- rising clock edge

	wait for 10 ns;
	CS <= I_CS;

    RW <= I_RW;

	ADDRESS <= '0' & I_ADDRESS;

	CONTROL <= I_CONTROL;

    BUS_ACKNOWLEDGE_DC <= I_BUS_ACKNOWLEDGE_C;
    BUS_ACKNOWLEDGE_DU <= I_BUS_ACKNOWLEDGE_U;
	BUS_ACKNOWLEDGE_CC <= '1';
	BUS_ACKNOWLEDGE_CU <= '1';

    CLEAR <= I_CLEAR;				-- apply control inputs on rising clock edge + 2ns
    U_DATAIN <= I_U_DATAIN;                    			-- (these will be generated by a synchronous state machine,	

				                    -- and so this is perfectly valid).

    C_DATAIN<=I_C_DATAIN;			-- this changes on a rising clock edge (follows RAM address)

	wait for (HALF_PERIOD - 10ns);

	CLK <= '0';
	                            -- RESET <= I_RESET;

	                            -- apply external inputs on falling clock edge
	


	wait for STROBE_TIME;				-- wait for strobe time
	
    O_FINISHED := FINISHED_C;

    O_COMPRESSING := COMPRESSING;

    O_DECOMPRESSING := DECOMPRESSING;
	
    O_BUS_REQUEST_C := BUS_REQUEST_CC;

	O_BUS_REQUEST_U := BUS_REQUEST_CU;

    O_C_DATA_VALID := C_DATA_VALID;

    O_FLUSHING := FLUSHING_C;

	O_U_DATA_VALID := U_DATA_VALID;

    O_U_DATAOUT := U_DATAOUT;
    O_C_DATAOUT := C_DATAOUT;
	
	                		-- write input vectors to results file
	write(LOUT , I_CLEAR , LEFT , 2);
	write(LOUT , I_CS , LEFT , 2);
	write(LOUT , I_RW , LEFT , 2);
	write(LOUT , I_ADDRESS, LEFT, 3);
	write(LOUT , I_CONTROL , LEFT , 17);
	write(LOUT , I_BUS_ACKNOWLEDGE_C, LEFT, 2);
	write(LOUT , I_U_DATAIN , LEFT , 33);
	write(LOUT , I_C_DATAIN , LEFT , 33);
    write(LOUT , O_COMPRESSING , LEFT , 2);
    write(LOUT , O_DECOMPRESSING , LEFT , 2);
	write(LOUT, O_BUS_REQUEST_C, LEFT, 2);
	write(LOUT, O_C_DATA_VALID, LEFT, 2);
   	write(LOUT , O_FINISHED , LEFT , 2);
  	write(LOUT , O_FLUSHING , LEFT , 2);		-- write output vectors to results file
 	write(LOUT , O_U_DATA_VALID , LEFT , 2);	
	write(LOUT , O_U_DATAOUT , LEFT, 33);
 	write(LOUT , O_C_DATAOUT, LEFT, 33 );
	writeline(TV_OUT , LOUT);

	-- compare actual circuit response with expected response vectors
	assert CRC_ERROR = ONE

		report "Unexpected value on output CRC_ERROR." severity error;

 	wait for (HALF_PERIOD - STROBE_TIME);		-- resynchronise with tester period

end loop;
wait;

end process TEST_VECTORS;


ONE <= '1';


end TB1dr; --end of architecture
