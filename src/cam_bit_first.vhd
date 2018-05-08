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

---------------------------------------
--  ENTITY       = CAM_BIT_FIRST     --
--  version      = 1.0               --
--  last update  = 30/05/98          --
--  author       = Jose Nunez        --
---------------------------------------


-- FUNCTION
-- basic bit element of the CAM array


--  PIN LIST
--  SEARCH   = input search data bit
--  PREVIOUS = data from the previous location in the array
--  CLEAR    = asynchronous clear of the data latch (active LOW)
--  CLK      = master clock
--  DOUT     = output of the data latch
--  MATCH    = indicates a match between search bit and data bit (active LOW)


library ieee;
use ieee.std_logic_1164.all;

entity CAM_BIT_FIRST is
port
(
	SEARCH : in bit;
	PREVIOUS : in bit;
	CLEAR : in bit ;
	RESET: in bit;
	CLK : in bit ;
	DOUT : out bit;
	MATCH : out bit
);


end CAM_BIT_FIRST;


architecture BIT1 of CAM_BIT_FIRST is

signal TEMP_Q : bit;

begin


COMB : process(CLK,CLEAR) 
begin



if (CLEAR = '0') then

	
	TEMP_Q <= '0';			-- check for CLEAR active


elsif (CLK'event and CLK='1') then

	if (RESET = '0') then

	TEMP_Q <= '0';			-- check for CLEAR active

	else

	TEMP_Q <= PREVIOUS;	-- get data from previous location

	end if;

end if;

end process COMB;

DOUT <= TEMP_Q;
MATCH <= SEARCH xor TEMP_Q;		-- match goes low if SEARCH = TEMP_Q


end BIT1;
