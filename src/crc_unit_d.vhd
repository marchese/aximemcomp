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
--  ENTITY       = CRC_UNIT    --
--  version      = 1.0         --
--  last update  = 30/08/01    --
--  author       = Jose Nunez  --
---------------------------------


-- FUNCTION
-- calculates a 16 bit X25 CRC code
-- Purpose: VHDL package containing a synthesizable CRC function
--   * polynomial: (0 5 12 16)
--   * data width: 32

--  PIN LIST
--  DIN   = input data
--  ENABLE = activate CRC calculation
--  CRC_OUT = CRC output
 
library ieee;
use ieee.std_logic_1164.all;

entity CRC_UNIT_D is

port(DIN : in bit_vector(31 downto 0);
	 ENABLE : in bit;
	 CLK : in bit;
	 RESET : in bit;
	 CLEAR : in bit;
	 CRC_OUT : out bit_vector(15 downto 0)
);
 
end CRC_UNIT_D;

architecture CRC1 of CRC_UNIT_D is

signal CRC_AUX : bit_vector(15 downto 0);
signal CRC_NEW : bit_vector(15 downto 0);

begin


FLIP_FLOPS : process (CLK,CLEAR)
begin

if (CLEAR = '0') then
	CRC_AUX <= x"0000";	
elsif ((CLK'event) and (CLK = '1')) then
	if (RESET = '0') then
		CRC_AUX <= x"0000";	
	elsif (ENABLE = '1') then
		CRC_AUX <= CRC_NEW;
	else
		CRC_AUX <= CRC_AUX;
	end if;
end if;

end process FLIP_FLOPS;



NEXT_CRC : process(DIN, CRC_AUX)

variable D: bit_vector(31 downto 0);
variable C: bit_vector(15 downto 0);
variable NewCRC : bit_vector(15 downto 0);

begin

    D := DIN;
    C := CRC_AUX;

    NewCRC(0) := D(28) xor D(27) xor D(26) xor D(22) xor D(20) xor D(19) xor 
                 D(12) xor D(11) xor D(8) xor D(4) xor D(0) xor C(3) xor 
                 C(4) xor C(6) xor C(10) xor C(11) xor C(12);
    NewCRC(1) := D(29) xor D(28) xor D(27) xor D(23) xor D(21) xor D(20) xor 
                 D(13) xor D(12) xor D(9) xor D(5) xor D(1) xor C(4) xor 
                 C(5) xor C(7) xor C(11) xor C(12) xor C(13);
    NewCRC(2) := D(30) xor D(29) xor D(28) xor D(24) xor D(22) xor D(21) xor 
                 D(14) xor D(13) xor D(10) xor D(6) xor D(2) xor C(5) xor 
                 C(6) xor C(8) xor C(12) xor C(13) xor C(14);
    NewCRC(3) := D(31) xor D(30) xor D(29) xor D(25) xor D(23) xor D(22) xor 
                 D(15) xor D(14) xor D(11) xor D(7) xor D(3) xor C(6) xor 
                 C(7) xor C(9) xor C(13) xor C(14) xor C(15);
    NewCRC(4) := D(31) xor D(30) xor D(26) xor D(24) xor D(23) xor D(16) xor 
                 D(15) xor D(12) xor D(8) xor D(4) xor C(0) xor C(7) xor 
                 C(8) xor C(10) xor C(14) xor C(15);
    NewCRC(5) := D(31) xor D(28) xor D(26) xor D(25) xor D(24) xor D(22) xor 
                 D(20) xor D(19) xor D(17) xor D(16) xor D(13) xor D(12) xor 
                 D(11) xor D(9) xor D(8) xor D(5) xor D(4) xor D(0) xor 
                 C(0) xor C(1) xor C(3) xor C(4) xor C(6) xor C(8) xor 
                 C(9) xor C(10) xor C(12) xor C(15);
    NewCRC(6) := D(29) xor D(27) xor D(26) xor D(25) xor D(23) xor D(21) xor 
                 D(20) xor D(18) xor D(17) xor D(14) xor D(13) xor D(12) xor 
                 D(10) xor D(9) xor D(6) xor D(5) xor D(1) xor C(1) xor 
                 C(2) xor C(4) xor C(5) xor C(7) xor C(9) xor C(10) xor 
                 C(11) xor C(13);
    NewCRC(7) := D(30) xor D(28) xor D(27) xor D(26) xor D(24) xor D(22) xor 
                 D(21) xor D(19) xor D(18) xor D(15) xor D(14) xor D(13) xor 
                 D(11) xor D(10) xor D(7) xor D(6) xor D(2) xor C(2) xor 
                 C(3) xor C(5) xor C(6) xor C(8) xor C(10) xor C(11) xor 
                 C(12) xor C(14);
    NewCRC(8) := D(31) xor D(29) xor D(28) xor D(27) xor D(25) xor D(23) xor 
                 D(22) xor D(20) xor D(19) xor D(16) xor D(15) xor D(14) xor 
                 D(12) xor D(11) xor D(8) xor D(7) xor D(3) xor C(0) xor 
                 C(3) xor C(4) xor C(6) xor C(7) xor C(9) xor C(11) xor 
                 C(12) xor C(13) xor C(15);
    NewCRC(9) := D(30) xor D(29) xor D(28) xor D(26) xor D(24) xor D(23) xor 
                 D(21) xor D(20) xor D(17) xor D(16) xor D(15) xor D(13) xor 
                 D(12) xor D(9) xor D(8) xor D(4) xor C(0) xor C(1) xor 
                 C(4) xor C(5) xor C(7) xor C(8) xor C(10) xor C(12) xor 
                 C(13) xor C(14);
    NewCRC(10) := D(31) xor D(30) xor D(29) xor D(27) xor D(25) xor D(24) xor 
                  D(22) xor D(21) xor D(18) xor D(17) xor D(16) xor D(14) xor 
                  D(13) xor D(10) xor D(9) xor D(5) xor C(0) xor C(1) xor 
                  C(2) xor C(5) xor C(6) xor C(8) xor C(9) xor C(11) xor 
                  C(13) xor C(14) xor C(15);
    NewCRC(11) := D(31) xor D(30) xor D(28) xor D(26) xor D(25) xor D(23) xor 
                  D(22) xor D(19) xor D(18) xor D(17) xor D(15) xor D(14) xor 
                  D(11) xor D(10) xor D(6) xor C(1) xor C(2) xor C(3) xor 
                  C(6) xor C(7) xor C(9) xor C(10) xor C(12) xor C(14) xor 
                  C(15);
    NewCRC(12) := D(31) xor D(29) xor D(28) xor D(24) xor D(23) xor D(22) xor 
                  D(18) xor D(16) xor D(15) xor D(8) xor D(7) xor D(4) xor 
                  D(0) xor C(0) xor C(2) xor C(6) xor C(7) xor C(8) xor 
                  C(12) xor C(13) xor C(15);
    NewCRC(13) := D(30) xor D(29) xor D(25) xor D(24) xor D(23) xor D(19) xor 
                  D(17) xor D(16) xor D(9) xor D(8) xor D(5) xor D(1) xor 
                  C(0) xor C(1) xor C(3) xor C(7) xor C(8) xor C(9) xor 
                  C(13) xor C(14);
    NewCRC(14) := D(31) xor D(30) xor D(26) xor D(25) xor D(24) xor D(20) xor 
                  D(18) xor D(17) xor D(10) xor D(9) xor D(6) xor D(2) xor 
                  C(1) xor C(2) xor C(4) xor C(8) xor C(9) xor C(10) xor 
                  C(14) xor C(15);
    NewCRC(15) := D(31) xor D(27) xor D(26) xor D(25) xor D(21) xor D(19) xor 
                  D(18) xor D(11) xor D(10) xor D(7) xor D(3) xor C(2) xor 
                  C(3) xor C(5) xor C(9) xor C(10) xor C(11) xor C(15);

CRC_NEW <= NewCRC;

end process NEXT_CRC;

CRC_OUT <= CRC_AUX;
		 
end CRC1;


