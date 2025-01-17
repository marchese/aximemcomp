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
--  ENTITY       = LATCH96     --
--  version      = 1.0         --
--  last update  = 16/06/99    --
--  author       = Jose Nunez  --
---------------------------------


-- FUNCTION
-- 96 bit latch


-- PIN LIST
-- D_IN  = input data bus
-- CLEAR = asynchronous clear of latch
-- CLK   = master clock
-- D_OUT = output data bus

library ieee,dzx;
use ieee.std_logic_1164.all;
use dzx.attributes.all;

entity LATCH129 is
port
(
    	D_IN : in bit_vector(128 downto 0);
	CLEAR : in bit;
	RESET : in bit;
	CLK : in bit;
	D_OUT : out bit_vector(128 downto 0)
);

attribute EXTNAME of D_IN : signal is "D_IN";
attribute EXTNAME of D_OUT : signal is "D_OUT";

end LATCH129;
-----------------------------------
--  entity       = LATCH96       --
--  ARCHITECTURE = FLIP_FLOP     --
--  version      = 1.0           --
--  last update  = 16/06/95      --
--  author       = Mark Gooch    --
-----------------------------------

architecture FLIP_FLOP of LATCH129 is

begin

FLOP : process (CLK,CLEAR)
begin
if (CLEAR = '0') then
    D_OUT <= "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
elsif ((CLK'event) and (CLK = '1')) then
	if (RESET = '0') then
    	D_OUT <= "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
    else
    	D_OUT <= D_IN;
	end if;
end if;
end process FLOP;

end FLIP_FLOP; -- end of architecture


