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

-- Name = mem1
-- type = RAM
-- width = 32
-- depth = 256
-- part family = A500K
-- output type = transparent
-- optimization = speed
-- input type = synchronous
-- parity control = ignore
-- Write =  active high
-- Read =  active high
-- Read clock =  posedge
-- Write clock =  posedge

library IEEE;
use IEEE.std_logic_1164.all;
library A500K;
use A500K.all;

entity MY_MASK_MEMORY is

   port(DO : out std_logic_vector (3 downto 0);
      RCLOCK : in std_logic;
      WCLOCK : in std_logic;
      DI : in std_logic_vector (3 downto 0);
      WRB : in std_logic;
      RDB : in std_logic;
      WADDR : in std_logic_vector (7 downto 0);
      RADDR : in std_logic_vector (7 downto 0));

end MY_MASK_MEMORY;

architecture STRUCT of MY_MASK_MEMORY is
component PWR
   port(Y : out std_logic);
end component;

attribute noopt: boolean;
attribute noopt of PWR: component is true;

component GND
   port(Y : out std_logic);
end component;

-- attribute noopt: boolean;
attribute noopt of GND: component is true;

component RAM256x9SST
   port(RCLKS : in std_logic;
      WCLKS : in std_logic;
      DO8 : out std_logic;
      DO7 : out std_logic;
      DO6 : out std_logic;
      DO5 : out std_logic;
      DO4 : out std_logic;
      DO3 : out std_logic;
      DO2 : out std_logic;
      DO1 : out std_logic;
      DO0 : out std_logic;
      DOS : out std_logic;
      WPE : out std_logic;
      RPE : out std_logic;
      WADDR7 : in std_logic;
      WADDR6 : in std_logic;
      WADDR5 : in std_logic;
      WADDR4 : in std_logic;
      WADDR3 : in std_logic;
      WADDR2 : in std_logic;
      WADDR1 : in std_logic;
      WADDR0 : in std_logic;
      RADDR7 : in std_logic;
      RADDR6 : in std_logic;
      RADDR5 : in std_logic;
      RADDR4 : in std_logic;
      RADDR3 : in std_logic;
      RADDR2 : in std_logic;
      RADDR1 : in std_logic;
      RADDR0 : in std_logic;
      DI8 : in std_logic;
      DI7 : in std_logic;
      DI6 : in std_logic;
      DI5 : in std_logic;
      DI4 : in std_logic;
      DI3 : in std_logic;
      DI2 : in std_logic;
      DI1 : in std_logic;
      DI0 : in std_logic;
      WRB : in std_logic;
      RDB : in std_logic;
      WBLKB : in std_logic;
      RBLKB : in std_logic;
      PARODD : in std_logic;
      DIS : in std_logic);
end component;

-- attribute noopt: boolean;
attribute noopt of RAM256x9SST: component is true;

component INV
   port(Y : out std_logic;
      A : in std_logic);
end component;

-- attribute noopt: boolean;
attribute noopt of INV: component is true;

signal WADDRAUX : std_logic_vector(7 downto 0); -- artificial delays
signal RADDRAUX : std_logic_vector(7 downto 0);
signal WRBAUX : std_logic;
signal RDBAUX : std_logic;
signal DIAUX : std_logic_vector(3 downto 0);

signal VDD, VSS, n1, n2 : std_logic;

begin


   WADDRAUX <= WADDR after 5 ns;
   RADDRAUX <= RADDR after 5 ns;
   WRBAUX <= WRB after 5 ns;
   RDBAUX <= RDB after 5 ns;
   DIAUX <= DI after 5 ns;

   U1 : GND port map(Y => VSS);
   M0 : RAM256x9SST port map(RCLKS =>RCLOCK, WCLKS => WCLOCK,  DO3 => DO(3), DO2 => DO(2), DO1 => DO(1), 
      DO0 => DO(0), WADDR7 => WADDRAUX(7), WADDR6 => WADDRAUX(6), WADDR5 => WADDRAUX(5), 
      WADDR4 => WADDRAUX(4), WADDR3 => WADDRAUX(3), WADDR2 => WADDRAUX(2), WADDR1 => WADDRAUX(1), 
      WADDR0 => WADDRAUX(0), RADDR7 => RADDRAUX(7), RADDR6 => RADDRAUX(6), RADDR5 => RADDRAUX(5), 
      RADDR4 => RADDRAUX(4), RADDR3 => RADDRAUX(3), RADDR2 => RADDRAUX(2), RADDR1 => RADDRAUX(1), 
      RADDR0 => RADDRAUX(0),  DI8 => VSS, DI7 => VSS, DI6 => VSS, DI5 => VSS, DI4 => VSS, DI3 => DIAUX(3), DI2 => DIAUX(2), DI1 => DIAUX(1), DI0 => DIAUX(0), 
      WRB => n1, RDB => n2, WBLKB => VSS, RBLKB => VSS, PARODD => VSS, DIS => VSS);
 
   U2 : INV port map(Y => n1, A => WRBAUX);
   U3 : INV port map(Y => n2, A => RDBAUX);

end STRUCT;

