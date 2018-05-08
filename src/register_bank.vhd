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

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity register_bank is
    port (
        ADDR: in STD_LOGIC_VECTOR (7 downto 0);
        RW: in STD_LOGIC;
        CLK: in STD_LOGIC;
        RESET: in STD_LOGIC;
        O_PUT: inout STD_LOGIC_VECTOR(255 downto 0)
    );
end register_bank;

architecture register_bank_arch of register_bank is



signal temp_out: BIT_VECTOR (255 downto 0);
constant one: BIT_VECTOR := "1";

begin
  process (ADDR,CLK,RESET,RW)   
      variable addresses: integer;
	variable ADDR_AUX : unsigned(7 downto 0);
	begin
	ADDR_AUX := unsigned(ADDR);
	addresses := To_integer(ADDR_AUX);
      if (RESET='1') then 
          temp_out <= "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
      elsif (CLK'event and CLK='1') then
          if RW='0' then 
             temp_out<=temp_out;
          else
		 temp_out(addresses)<='1';
          end if;
      end if;
      O_PUT <= TO_X01Z(temp_out);
end process;
end register_bank_arch;
