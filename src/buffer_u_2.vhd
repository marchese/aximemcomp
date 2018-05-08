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

-----------------------------------------------------
--  ENTITY       = DECODING_BUFFER_CU              --
--  version      = 1.0                             --
--  last update  = 16/6/00                         --
--  author       = Jose Nunez                      --
-----------------------------------------------------


-- FUNCTION
-- Control unit that controls the decoding buffer


--  PIN LIST
--  START : enable writting to the buffer
--  FINISHED : the block has been process in the decompression engine stop requesting data.
--  UNDERFLOW_GEN : 64 bit of compressed data are needed.
--  THRESHOLD : more data is available in the buffer to be decompressed than the threshold limit.
--  CODING_READ_ADDRESS : buffer location that it is being read
--  CODING_WRITE_ADDRESS : buffer location that it is being written
--  CLK : clock
--  CLEAR : clear
--  BUS_REQUEST : more compressed data is required if after getting data the bus is denied and data is in the internal buffer stop requesting.
--  CODING_OVERFLOW : the CU detects a coding overflow stop inputting compressed data 
--  CODING_UNDERFLOW_GEN : the CU detects a coding UNDERFLOW_GEN stop outputting compressed data
--  ENABLE_WRITE : enable writting to the buffer
--  FINISH : the buffer process
--  ENABLE_READ : enable reading from the buffer

library ieee;
use ieee.std_logic_1164.all;
library dzx;
use dzx.bit_arith.all;
use dzx.bit_utils.all; 


entity BUFFER_U_2 is
port
(   
	  START_D : in bit;  --  enter decompression mode
	  START_C : in bit;  --  enter test mode since compression is active
	  FINISHED_D : in bit; --  finish decompression mode
	  FINISHED_C : in bit; -- finish test mode
	  BUS_ACKNOWLEDGE : in bit;
	  WAITN : in bit; -- wait states being introduced
	  THRESHOLD_LEVEL : in bit_vector(8 downto 0);
	  DECODING_READ_ADDRESS : in bit_vector(8 downto 0);
	  DECODING_WRITE_ADDRESS : in bit_vector(8 downto 0);
	  CLK : in bit;
	  CLEAR : in bit;
	  BUS_REQUEST : out bit;
	  DECODING_UNDERFLOW_GEN : out bit;
	  ENABLE_WRITE : out bit;
	  FINISH : out bit; -- the buffer process
	  CLEAR_COUNTERS : out bit;
	  C_DATA_V : in bit; -- compressed data available in test mode
	  UNDERFLOW : in bit; -- the engine requests data
	  ENABLE_READ : out bit
);
end BUFFER_U_2;

architecture STRUCTURAL of BUFFER_U_2 is

signal CURRENT_STATE : bit_vector(3 downto 0);
signal NEXT_STATE : bit_vector(3 downto 0);
signal DECODING_OVERFLOW_AUX : bit;
signal UNDERFLOW_GEN : bit;
signal ENABLE_READ_INT : bit;
signal DECODING_UNDERFLOW_GEN_INT : bit; -- to hold UNDERFLOW_GEN until threshold is overpassed
signal ENABLE_WRITE_INT : bit;
signal BUS_ACKNOWLEDGE_INT : bit;
--signal DECODING_UNDERFLOW_GEN_DELAY : bit;

begin


UNDERFLOW_GEN <= UNDERFLOW;


STATES : process (C_DATA_V, WAITN, START_C, START_D, THRESHOLD_LEVEL, CURRENT_STATE, FINISHED_C, FINISHED_D, 
UNDERFLOW_GEN, DECODING_OVERFLOW_AUX, DECODING_READ_ADDRESS, DECODING_WRITE_ADDRESS, BUS_ACKNOWLEDGE)
begin

case CURRENT_STATE is
	when "0000" =>  -- state 0 buffer inactive. Two modes: test mode and decompression mode
		if (START_D = '0') then 
			NEXT_STATE <= "0001";
		elsif (START_C = '0') then
			NEXT_STATE <= "1001";
		else
			NEXT_STATE <= CURRENT_STATE;
		end if;
            BUS_ACKNOWLEDGE_INT <= '0';
		DECODING_UNDERFLOW_GEN_INT <= '0';
		ENABLE_READ_INT <= '0';
		ENABLE_WRITE_INT <= '0';
		BUS_REQUEST <= '1';
		FINISH <= '1';
		CLEAR_COUNTERS <= '1'; -- read and write counters are at 0


   when "1110" =>    -- wait state. state reading from the buffer but waiting to write more data
  		if (FINISHED_C ='0')  then --stop writting to the buffer process terminates
	   		NEXT_STATE <= "1100"; -- only reading data from the buffer	
		elsif (C_DATA_V = '0') then
			if (UNDERFLOW_GEN = '1') then
				NEXT_STATE <= "0000"; -- total wait do not read or write 
			else
				NEXT_STATE <= "1011";
			end if;	
		elsif (UNDERFLOW_GEN = '1') then -- total wait do not read or write
			NEXT_STATE <= "1011"; -- read and write
		else
			NEXT_STATE <= CURRENT_STATE;   
		end if;
		DECODING_UNDERFLOW_GEN_INT <= '0';
		BUS_ACKNOWLEDGE_INT <= '1';
		ENABLE_READ_INT <= '1';
		ENABLE_WRITE_INT <= '0';
		BUS_REQUEST <= '1';
 		FINISH <= '1';
        CLEAR_COUNTERS <= '0';

    when "1101" =>    -- signal finish
		DECODING_UNDERFLOW_GEN_INT <= '0';
		BUS_ACKNOWLEDGE_INT <= '0';
		NEXT_STATE <= "0000"; -- end
   		ENABLE_READ_INT <= '0';
		ENABLE_WRITE_INT <= '0';
		BUS_REQUEST <= '1';
 		FINISH <= '0';
		CLEAR_COUNTERS <= '0';
	when "1111" =>    -- wait state. state reading from the buffer but waiting to write more data
		if (FINISHED_C ='0')  then --stop writting to the buffer process terminates
	   		NEXT_STATE <= "1100"; -- only reading data from the buffer	
  		elsif(C_DATA_V = '0') then -- do not read or write
			NEXT_STATE <= "1010"; -- write to the buffer
		else
			NEXT_STATE <= CURRENT_STATE;   
		end if;
		DECODING_UNDERFLOW_GEN_INT <= '1';
		BUS_ACKNOWLEDGE_INT <= '1';
		ENABLE_READ_INT <= '0';
		ENABLE_WRITE_INT <= '0';
		BUS_REQUEST <= '1';
 		FINISH <= '1';
        CLEAR_COUNTERS <= '0';
	 when others =>
	 	NEXT_STATE <= "0000";
		BUS_ACKNOWLEDGE_INT <= '0';
		DECODING_UNDERFLOW_GEN_INT <= '0';
	 	ENABLE_READ_INT <= '0';
		ENABLE_WRITE_INT <= '0';
		BUS_REQUEST <= '1';
 		FINISH <= '1';
		CLEAR_COUNTERS <= '1';

end  case;    	
end process STATES;

DECODING_OVERFLOW_AUX <= '0' when ((DECODING_READ_ADDRESS(8 downto 1) = DECODING_WRITE_ADDRESS(8 downto 1) + "00000001") and (BUS_ACKNOWLEDGE_INT = '1')) else '1'; -- decoding overflow goes out of the chip is active with zero if bus_akcnowledge 1 then all the data is inside never generate overflow
ENABLE_READ <= ENABLE_READ_INT and not(UNDERFLOW_GEN); -- if decoding UNDERFLOW_GEN disable the read counter and (BUS_ACKNOWLEDGE_INT = '1') and ()
ENABLE_WRITE <= ENABLE_WRITE_INT and DECODING_OVERFLOW_AUX; -- if overflow disable writting inmediatly



FLIP_FLOPS : process(CLK, CLEAR)
begin 

if (CLEAR = '0') then
	CURRENT_STATE <= "0000"; --state 0
elsif ((CLK'event) and (CLK='1')) then
	CURRENT_STATE <= NEXT_STATE;
end if;

end process FLIP_FLOPS;

--DELAY_UNDERFLOW_GEN : process(CLK, CLEAR, DECODING_UNDERFLOW_GEN_DELAY)
--begin 

--if (CLEAR = '0') then
--	DECODING_UNDERFLOW_GEN <= '0';
--elsif ((CLK'event) and (CLK='1')) then
--	DECODING_UNDERFLOW_GEN <= DECODING_UNDERFLOW_GEN_DELAY;
--end if;
--end process DELAY_UNDERFLOW_GEN;



--DECODING_UNDERFLOW_GEN <= UNDERFLOW_GEN;

--or DECODING_UNDERFLOW_GEN_INT; -- never signal UNDERFLOW_GEN if bus_acknowledge has gone to 1 it means that all the compressed data has been fed to the buffer. It has to terminate


end STRUCTURAL;

