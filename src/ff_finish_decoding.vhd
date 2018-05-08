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
--  ENTITY       = FF_FINISH_DECODING--
--  version      = 1.0               --
--  last update  = 21/08/00          --
--  author       = Jose Nunez        --
---------------------------------------


-- FUNCTION
-- out register


--  PIN LIST
--  FINISH_IN   = 1 bit input data
--  CLEAR = asynchronous clear of register
--  CLK   = clock
--  FINISH_OUT  = 1 bit output of flip-flops



library ieee,dzx;
use ieee.std_logic_1164.all;
use dzx.attributes.all;

entity FF_FINISH_DECODING is
port
(
      FINISH_IN : in bit;
  	CLEAR : in bit ;
	RESET : in bit;
      CLK : in bit ;
	FINISH_OUT : out bit

);


end FF_FINISH_DECODING;



architecture LATCH of FF_FINISH_DECODING is
begin

FLIP_FLOPS : process (CLK,CLEAR)
begin
    	-- asynchronous RESET signal forces all outputs LOW
        if (CLEAR = '0') then
	    		FINISH_OUT <= '1';
	    -- check for +ve clock edge
	  elsif ((CLK'event) and (CLK = '1')) then
	  		if (RESET = '0') then
	    					FINISH_OUT <= '1';
	     	        else
							FINISH_OUT <= FINISH_IN;
			end if;
	  end if;
end process FLIP_FLOPS;

end LATCH;

