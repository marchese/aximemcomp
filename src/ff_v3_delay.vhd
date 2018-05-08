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
--  ENTITY       = FF_V3_DELAY --
--  version      = 1.0         --
--  last update  = 11/04/00    --
--  author       = Jose Nunez  --
---------------------------------

--  FUNCTION
--  Introduces an extra level of delay for the decompression counter


--  PIN LIST
--  COUNT_D_IN : in enable count signal
--  CLK : in clock signal		
--  CLEAR : in clear signal
--  COUNT_D_OUT : out enable count signal	


library ieee;
use ieee.std_logic_1164.all;

entity FF_V3_DELAY is
port
	(
	COUNT_D_IN : in bit;
	CLK : in bit;
	CLEAR : in bit;
	RESET : in bit;
	COUNT_D_OUT : out bit
	);

end FF_V3_DELAY;


architecture FF of FF_V3_DELAY is

signal Q1,Q2 : bit;

begin

FLIP_FLOP1 : process(CLK,CLEAR)
begin
	if (CLEAR = '0') then
		Q1 <= '1';
	elsif ((CLK'event) and (CLK='1')) then
		if (RESET = '0') then
			Q1 <= '1';
		else
			Q1 <= COUNT_D_IN;
		end if;
	end if;
end process FLIP_FLOP1;

FLIP_FLOP2 : process(CLK,CLEAR)
begin
	if (CLEAR = '0') then
		Q2 <= '1';
	elsif ((CLK'event) and (CLK='1')) then
		if (RESET = '0') then
			Q2 <= '1';
		else
			Q2 <= Q1;
		end if;
	end if;
end process FLIP_FLOP2;


COUNT_D_OUT <= Q2;

end FF;


