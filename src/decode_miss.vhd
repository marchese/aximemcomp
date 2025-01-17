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

------------------------------------
--  ENTITY       = DECODE_MISS    --
--  version      = 1.0            --
--  last update  = 25/06/01       --
--  author       = Jose Nunez     --
------------------------------------


-- FUNCTION
-- decodes the input (Huffman) miss type code to give a mask,
-- miss length and miss+literal character length

-- PIN LIST
-- CODE         = input miss type code (Huffman)
-- M_LIT_LENGTH = length of miss type code and any required literal characters
-- SELECT_MOVE  = select a move vector
-- MASK         = decoded mask

library ieee,dzx;
use ieee.std_logic_1164.all;


entity DECODE_MISS is
port
(
   	CODE : in bit_vector(3 downto 0);
	M_LIT_LENGTH : out bit_vector(5 downto 0);
	SELECT_MOVE : out bit_vector(2 downto 0);
	MASK : out bit_vector(4 downto 0)
);
end DECODE_MISS;

architecture HUFFMAN of DECODE_MISS is
begin

TREE_DEC : process(CODE)
begin
case CODE is
    when "1000" | "1001" | "1010" |"1011" | "1100"  | "1101"  | "1110" | "1111"  
				=> MASK <= "10000";
	    	M_LIT_LENGTH <= "000010";
			SELECT_MOVE <= "000";

	

    when "0100" | "0101"| "0110" | "0111" 
	 	    	=>  MASK <= "11111";
		    M_LIT_LENGTH <= "100011";
			SELECT_MOVE <= "001";
 

    when "0010" | "0011"  
    	    	=>  MASK <= "11000";
		    M_LIT_LENGTH <= "001100";
			SELECT_MOVE <= "010";
 	

    when "0001" 
   				=>  MASK <= "11100";
		    M_LIT_LENGTH <= "010101";
			SELECT_MOVE <= "011";


    when "0000" 
    	    	=>  MASK <= "11110";
		    M_LIT_LENGTH <= "011101";
			SELECT_MOVE <= "100";


    when others
    	    	=>  MASK <= "00000";
		    M_LIT_LENGTH <= "000000";
			SELECT_MOVE <= "101";

end case;

end process TREE_DEC;


end HUFFMAN; -- end of architecture



