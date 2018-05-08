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


LIBRARY ieee,alt_lpm;
USE ieee.std_logic_1164.all;
USE alt_lpm.lpm_components.all;
use work.tech_package.all;


ENTITY LPM_RAM_DP_MASK IS
	PORT
	(
	  DATA : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
      RDADDRESS : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
      WRADDRESS : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
      WRCLKEN : IN STD_LOGIC;
	  RDCLKEN : IN STD_LOGIC;
      RDEN : IN STD_LOGIC;
      WREN : IN STD_LOGIC;
      WRCLOCK :IN STD_LOGIC;
	  RDCLOCK : IN STD_LOGIC;
      Q : OUT STD_LOGIC_VECTOR (3 DOWNTO 0));
END LPM_RAM_DP_MASK;


ARCHITECTURE SYN OF LPM_RAM_DP_MASK IS





	component LPM_RAM_DP
      generic (LPM_WIDTH    : positive ;
               LPM_WIDTHAD  : positive;
               LPM_NUMWORDS : positive;
               LPM_INDATA   : string;
               LPM_RDADDRESS_CONTROL : string;
               LPM_WRADDRESS_CONTROL : string;
               LPM_OUTDATA  : string;
               LPM_TYPE     : string;
               LPM_FILE     : string;
	       LPM_HINT	    : string);
	port (RDCLOCK : in std_logic;
            RDCLKEN : in std_logic;
            RDADDRESS : in std_logic_vector(7 downto 0);
            RDEN : in std_logic;
            DATA : in std_logic_vector(3 downto 0);
            WRADDRESS : in std_logic_vector(7 downto 0);
            WREN : in std_logic;
            WRCLOCK : in std_logic;
            WRCLKEN : in std_logic;
            Q : out std_logic_vector(3 downto 0));
	end component;

-- TSMC DPRAM

  component ra2sh_256W_4B_8MX_offWRMSK_8WRGRAN 
  port ( 
	CLKA: in std_logic;
	CENA: in std_logic;
	WENA: in std_logic;
	AA: in std_logic_vector(7 downto 0);
	DA: in std_logic_vector(3 downto 0);
	QA: out std_logic_vector(3 downto 0);
	CLKB: in std_logic;
	CENB: in std_logic;
	WENB: in std_logic;
	AB: in std_logic_vector(7 downto 0);
	DB: in std_logic_vector(3 downto 0);
	QB: out std_logic_vector(3 downto 0)
    );

    end component;



	signal tsmc_cena_n , tsmc_cenb_n : std_logic;
	signal tsmc_wena_n , tsmc_wenb_n : std_logic;


BEGIN


-- Altera memory



  ALT_RAM_MASK :

  if (not TSMC013) generate

	RDP_component : LPM_RAM_DP
	GENERIC MAP(LPM_WIDTH => 4,
              LPM_WIDTHAD  => 8,
              LPM_NUMWORDS => 256,
              LPM_OUTDATA  =>  "UNREGISTERED",
			  LPM_INDATA => "REGISTERED",
	        LPM_RDADDRESS_CONTROL => "REGISTERED",
	        LPM_WRADDRESS_CONTROL => "REGISTERED",
	        LPM_FILE  => "UNUSED",
            LPM_TYPE  => "LPM_RAM_DP",
	        LPM_HINT => "UNUSED")            
    PORT MAP(DATA => DATA,
             RDADDRESS => RDADDRESS,
             WRADDRESS => WRADDRESS,
             WRCLKEN => WRCLKEN,
	         RDCLKEN => RDCLKEN,
             RDEN => RDEN,
             WREN => WREN,
             WRCLOCK => WRCLOCK,
	         RDCLOCK => RDCLOCK,
             Q => Q);

	end generate;

-- Port 1 = R

-- Port 2 = R/W

TSMC013_RAM_MASK :

  if (TSMC013) generate

  TMSC_RAM : ra2sh_256W_4B_8MX_offWRMSK_8WRGRAN port map
      (
        clka        =>      WRCLOCK,
        cena        =>      tsmc_cena_n ,
        wena        =>      tsmc_wena_n,
        aa          =>      RDADDRESS,
        da          =>      DATA,
        qa          =>      Q,
        clkb        =>      WRCLOCK,
        cenb        =>      tsmc_cenb_n,
        wenb        =>      tsmc_wenb_n,
        ab          =>      WRADDRESS,
        db          =>      DATA,
        qb          =>      OPEN
      ) ;      

end generate;



tsmc_cenb_n <= not (WREN);
tsmc_cena_n <= not (RDEN);
tsmc_wena_n <='1';

--    not (RDEN_SB); Always in read-mode; read-enable used to

--    power-up ram

tsmc_wenb_n <= not (WREN);





END SYN;
 
