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


--------------------------------------
--  ENTITY       = CAM_WORD_FIRST    --
--  version      = 1.0               --
--  last update  = 14/06/98          --
--  author       = Jose Nunez        --
---------------------------------------


-- FUNCTION
-- 32 bit word element of the CAM array.


--  PIN LIST
--  SEARCH    = input search data word
--  PREVIOUS  = data word from the previous location in the array
--  CLEAR     = asynchronous clear of the data latch (active LOW)
--  CLK       = master clock
--  DOUT      = output of the data latch
--  MATCH     = indicates a match between search bytes and data bytes (active LOW)

-- no movement control because the first word is always loaded

library ieee;
use ieee.std_logic_1164.all;

entity CAM_WORD_FIRST is
port
(
	SEARCH : in bit_vector(31 downto 0);
	PREVIOUS : in bit_vector(31 downto 0);
	CLEAR : in bit ;
	RESET : in bit;
	CLK : in bit ;
	DOUT : out bit_vector(31 downto 0);
	MATCH : out bit_vector(3 downto 0)
);


end CAM_WORD_FIRST;



architecture WORD1 of CAM_WORD_FIRST is

component CAM_BYTE_FIRST
port
(
	SEARCH : in bit_vector(7 downto 0);
	PREVIOUS : in bit_vector(7 downto 0);
	CLEAR : in bit;
	RESET : in bit;
	CLK : in bit ;
	DOUT : out bit_vector(7 downto 0);
	MATCH : out bit
);
end component;



 

begin




-- GEN_WORD : for I in 0 to 3 generate
--     BYTE3 : CAM_BYTE port map ( SEARCH => SEARCH(7+8*I downto 8*I),
--    	    	    	    	PREVIOUS => PREVIOUS(7+8*I downto 8*I),
--			    	MOVE => MOVE,
--			    	CLEAR => CLEAR,
--			    	CLK => CLK,
--			    	RESET => RESET,
--			    	DOUT => DOUT(7+8*I downto 8*I),
--			    	MATCH => TEMP_MATCH(I));


--end generate;

BYTE1 : CAM_BYTE_FIRST port map ( SEARCH => SEARCH(7 downto 0),

    	    	    	    	PREVIOUS => PREVIOUS(7 downto 0),

		    	      CLEAR => CLEAR,

					  RESET => RESET,

			    	CLK => CLK,

			    	DOUT => DOUT(7 downto 0),

			    	MATCH => MATCH(0));



BYTE2 : CAM_BYTE_FIRST port map ( SEARCH => SEARCH(15 downto 8),

    	    	    	    	PREVIOUS => PREVIOUS(15 downto 8),

			    	CLEAR => CLEAR,

					RESET => RESET,

			    	CLK => CLK,

			    	DOUT => DOUT(15 downto 8),

			    	MATCH => MATCH(1));



BYTE3 : CAM_BYTE_FIRST port map ( SEARCH => SEARCH(23 downto 16),

    	    	    	    	PREVIOUS => PREVIOUS(23 downto 16),

			    	CLEAR => CLEAR,

					RESET=> RESET,

			    	CLK => CLK,

			    	DOUT => DOUT(23 downto 16),

			    	MATCH => MATCH(2));

BYTE4 : CAM_BYTE_FIRST port map ( SEARCH => SEARCH(31 downto 24),

    	    	    	    	PREVIOUS => PREVIOUS(31 downto 24),

			    	CLEAR => CLEAR,

					RESET=>RESET,

			    	CLK => CLK,

			    	DOUT => DOUT(31 downto 24),

			    	MATCH => MATCH(3));



-- No logic for validate the word. All the words valid because the dictionary does not grow


end WORD1;