library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity simulation_mem_256 is
	port (
	addra: in std_logic_vector(7 downto 0);
	addrb: in std_logic_vector(7 downto 0);
	clka: in std_logic;
	clkb: in std_logic;
	dina: in std_logic_vector(31 downto 0);
	doutb: out std_logic_vector(31 downto 0);
	enb: in std_logic;
	wea: in std_logic);
end simulation_mem_256;

architecture simulation_mem_a of simulation_mem_256 is

type SIMULATION_MEM_TYPE is array (0 to 255) of std_logic_vector(31 downto 0);
signal mem : SIMULATION_MEM_TYPE;

begin

process (clka)
begin
    if (rising_edge(clka)) then
        if wea = '1' then
            mem(to_integer(ieee.NUMERIC_STD.UNSIGNED(addra))) <= dina;
        end if;
    end if;
end process;

process (clkb)
begin
    if (rising_edge(clkb)) then
        if enb = '1' then
            doutb <= mem(to_integer(ieee.NUMERIC_STD.UNSIGNED(addrb)));
        end if;
    end if;
end process;

end simulation_mem_a;

