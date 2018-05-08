library ieee,std;
use ieee.std_logic_1164.all;

use ieee.std_logic_textio.all;
use std.textio.all;

entity tb_axi_core is
end tb_axi_core;

architecture arch_compressor of tb_axi_core is

constant CLOCK_PERIOD : time := 200 ns;
constant HALF_PERIOD : time := CLOCK_PERIOD / 2;
constant STROBE_TIME : time := 0.9 * HALF_PERIOD;

constant C_AXI_DATA_WIDTH : integer := 32;
constant C_AXI_ADDR_WIDTH : integer := 32;
constant C_AXI_ID_WIDTH   : integer := 12;

signal s_axi_aclk       : std_logic;
signal s_axi_aresetn    : std_logic;
signal s_axi_awlen      : std_logic_vector(3 downto 0);
signal s_axi_awsize     : std_logic_vector(2 downto 0);
signal s_axi_awburst    : std_logic_vector(1 downto 0);
signal s_axi_awid       : std_logic_vector(C_AXI_ID_WIDTH-1 downto 0);
signal s_axi_awaddr     : std_logic_vector(C_AXI_ADDR_WIDTH-1 downto 0);
signal s_axi_awvalid    : std_logic;
signal s_axi_wdata      : std_logic_vector(C_AXI_DATA_WIDTH-1 downto 0);
signal s_axi_wlast      : std_logic;
signal s_axi_wvalid     : std_logic;
signal s_axi_bready     : std_logic;
signal s_axi_arlen      : std_logic_vector(3 downto 0);
signal s_axi_arsize     : std_logic_vector(2 downto 0);
signal s_axi_arburst    : std_logic_vector(1 downto 0);
signal s_axi_arid       : std_logic_vector(C_AXI_ID_WIDTH-1 downto 0);
signal s_axi_araddr     : std_logic_vector(C_AXI_ADDR_WIDTH-1 downto 0);
signal s_axi_arvalid    : std_logic;
signal s_axi_rready     : std_logic;
signal s_axi_arready    : std_logic;
signal s_axi_rid        : std_logic_vector(C_AXI_ID_WIDTH-1 downto 0);
signal s_axi_rdata      : std_logic_vector(C_AXI_DATA_WIDTH-1 downto 0);
signal s_axi_rresp      : std_logic_vector(1 downto 0);
signal s_axi_rlast      : std_logic;
signal s_axi_rvalid     : std_logic;
signal s_axi_wready     : std_logic;
signal s_axi_bid        : std_logic_vector(C_AXI_ID_WIDTH-1 downto 0);
signal s_axi_bresp      : std_logic_vector(1 downto 0);
signal s_axi_bvalid     : std_logic;
signal s_axi_awready    : std_logic;
signal m_axi_aclk       : std_logic;
signal m_axi_aresetn    : std_logic;
signal md_error         : std_logic;
signal m_axi_arready    : std_logic;
signal m_axi_arvalid    : std_logic;
signal m_axi_araddr     : std_logic_vector(C_AXI_ADDR_WIDTH-1 downto 0);
signal m_axi_arlen      : std_logic_vector(3 downto 0);
signal m_axi_arsize     : std_logic_vector(2 downto 0);
signal m_axi_arburst    : std_logic_vector(1 downto 0);
signal m_axi_rready     : std_logic;
signal m_axi_rvalid     : std_logic;
signal m_axi_rdata      : std_logic_vector(C_AXI_DATA_WIDTH-1 downto 0);
signal m_axi_rresp      : std_logic_vector(1 downto 0);
signal m_axi_rlast      : std_logic;
signal m_axi_awready    : std_logic;
signal m_axi_awvalid    : std_logic;
signal m_axi_awaddr     : std_logic_vector(C_AXI_ADDR_WIDTH-1 downto 0);
signal m_axi_awlen      : std_logic_vector(3 downto 0);
signal m_axi_awsize     : std_logic_vector(2 downto 0);
signal m_axi_awburst    : std_logic_vector(1 downto 0);
signal m_axi_wready     : std_logic;
signal m_axi_wvalid     : std_logic;
signal m_axi_wdata      : std_logic_vector(C_AXI_DATA_WIDTH-1 downto 0);
signal m_axi_wlast      : std_logic;
signal m_axi_bready     : std_logic;
signal m_axi_bvalid     : std_logic;
signal m_axi_bresp      : std_logic_vector(1 downto 0);

component axi_core
  generic
  (
    C_AXI_ADDR_WIDTH             : integer              := 32;
    C_AXI_DATA_WIDTH             : integer              := 32;
    C_AXI_ID_WIDTH               : integer              := 12
  );
  port
  (
    s_axi_aclk                     : in  std_logic := '0';
    s_axi_aresetn                  : in  std_logic;
    s_axi_awlen                    : in  std_logic_vector(3 downto 0);
    s_axi_awsize                   : in  std_logic_vector(2 downto 0);
    s_axi_awburst                  : in  std_logic_vector(1 downto 0);
    s_axi_awid                     : in  std_logic_vector(C_AXI_ID_WIDTH-1 downto 0);
    s_axi_awaddr                   : in  std_logic_vector(C_AXI_ADDR_WIDTH-1 downto 0);
    s_axi_awvalid                  : in  std_logic;
    s_axi_wdata                    : in  std_logic_vector(C_AXI_DATA_WIDTH-1 downto 0);
    s_axi_wlast                    : in  std_logic;
    s_axi_wvalid                   : in  std_logic;
    s_axi_bready                   : in  std_logic;
    s_axi_arlen                    : in  std_logic_vector(3 downto 0);
    s_axi_arsize                   : in  std_logic_vector(2 downto 0);
    s_axi_arburst                  : in  std_logic_vector(1 downto 0);
    s_axi_arid                     : in  std_logic_vector(C_AXI_ID_WIDTH-1 downto 0);
    s_axi_araddr                   : in  std_logic_vector(C_AXI_ADDR_WIDTH-1 downto 0);
    s_axi_arvalid                  : in  std_logic;
    s_axi_rready                   : in  std_logic;
    s_axi_arready                  : out std_logic := 'Z';
    s_axi_rid                      : in  std_logic_vector(C_AXI_ID_WIDTH-1 downto 0);
    s_axi_rdata                    : out std_logic_vector(C_AXI_DATA_WIDTH-1 downto 0) := (others => 'Z');
    s_axi_rresp                    : out std_logic_vector(1 downto 0) := (others => 'Z');
    s_axi_rlast                    : out std_logic := 'Z';
    s_axi_rvalid                   : out std_logic := 'Z';
    s_axi_wready                   : out std_logic := 'Z';
    s_axi_bid                      : in  std_logic_vector(C_AXI_ID_WIDTH-1 downto 0);
    s_axi_bresp                    : out std_logic_vector(1 downto 0) := (others => 'Z');
    s_axi_bvalid                   : out std_logic := 'Z';
    s_axi_awready                  : out std_logic := 'Z';
    m_axi_aclk                     : in  std_logic := '0';
    m_axi_aresetn                  : in  std_logic;
    m_axi_arready                  : in  std_logic;
    m_axi_arvalid                  : out std_logic := 'Z';
    m_axi_araddr                   : out std_logic_vector(C_AXI_ADDR_WIDTH-1 downto 0) := (others => 'Z');
    m_axi_arlen                    : out std_logic_vector(3 downto 0) := (others => 'Z');
    m_axi_arsize                   : out std_logic_vector(2 downto 0) := (others => 'Z');
    m_axi_arburst                  : out std_logic_vector(1 downto 0) := (others => 'Z');
    m_axi_rready                   : out std_logic := 'Z';
    m_axi_rvalid                   : in  std_logic;
    m_axi_rdata                    : in  std_logic_vector(C_AXI_DATA_WIDTH-1 downto 0);
    m_axi_rresp                    : in  std_logic_vector(1 downto 0);
    m_axi_rlast                    : in  std_logic;
    m_axi_awready                  : in  std_logic;
    m_axi_awvalid                  : out std_logic := 'Z';
    m_axi_awaddr                   : out std_logic_vector(C_AXI_ADDR_WIDTH-1 downto 0) := (others => 'Z');
    m_axi_awlen                    : out std_logic_vector(3 downto 0) := (others => 'Z');
    m_axi_awsize                   : out std_logic_vector(2 downto 0) := (others => 'Z');
    m_axi_awburst                  : out std_logic_vector(1 downto 0) := (others => 'Z');
    m_axi_wready                   : in  std_logic;
    m_axi_wvalid                   : out std_logic := 'Z';
    m_axi_wdata                    : out std_logic_vector(C_AXI_DATA_WIDTH-1 downto 0) := (others => 'Z');
    m_axi_wlast                    : out std_logic := 'Z';
    m_axi_bready                   : out std_logic := 'Z';
    m_axi_bvalid                   : in  std_logic;
    m_axi_bresp                    : in  std_logic_vector(1 downto 0)
  );
end component axi_core;

begin

MODULE_AXI_CORE : axi_core  port map(
    s_axi_aclk     =>  s_axi_aclk,
    s_axi_aresetn  =>  s_axi_aresetn,
    s_axi_awlen    =>  s_axi_awlen,
    s_axi_awsize   =>  s_axi_awsize,
    s_axi_awburst  =>  s_axi_awburst,
    s_axi_awid     =>  s_axi_awid,
    s_axi_awaddr   =>  s_axi_awaddr,
    s_axi_awvalid  =>  s_axi_awvalid,
    s_axi_wdata    =>  s_axi_wdata,
    s_axi_wlast    =>  s_axi_wlast,
    s_axi_wvalid   =>  s_axi_wvalid,
    s_axi_bready   =>  s_axi_bready,
    s_axi_arlen    =>  s_axi_arlen,
    s_axi_arsize   =>  s_axi_arsize,
    s_axi_arburst  =>  s_axi_arburst,
    s_axi_arid     =>  s_axi_arid,
    s_axi_araddr   =>  s_axi_araddr,
    s_axi_arvalid  =>  s_axi_arvalid,
    s_axi_rready   =>  s_axi_rready,
    s_axi_arready  =>  s_axi_arready,
    s_axi_rid      =>  s_axi_rid,
    s_axi_rdata    =>  s_axi_rdata,
    s_axi_rresp    =>  s_axi_rresp,
    s_axi_rlast    =>  s_axi_rlast,
    s_axi_rvalid   =>  s_axi_rvalid,
    s_axi_wready   =>  s_axi_wready,
    s_axi_bid      =>  s_axi_bid,
    s_axi_bresp    =>  s_axi_bresp,
    s_axi_bvalid   =>  s_axi_bvalid,
    s_axi_awready  =>  s_axi_awready,
    m_axi_aclk     =>  m_axi_aclk,
    m_axi_aresetn  =>  m_axi_aresetn,
    m_axi_arready  =>  m_axi_arready,
    m_axi_arvalid  =>  m_axi_arvalid,
    m_axi_araddr   =>  m_axi_araddr,
    m_axi_arlen    =>  m_axi_arlen,
    m_axi_arsize   =>  m_axi_arsize,
    m_axi_arburst  =>  m_axi_arburst,
    m_axi_rready   =>  m_axi_rready,
    m_axi_rvalid   =>  m_axi_rvalid,
    m_axi_rdata    =>  m_axi_rdata,
    m_axi_rresp    =>  m_axi_rresp,
    m_axi_rlast    =>  m_axi_rlast,
    m_axi_awready  =>  m_axi_awready,
    m_axi_awvalid  =>  m_axi_awvalid,
    m_axi_awaddr   =>  m_axi_awaddr,
    m_axi_awlen    =>  m_axi_awlen,
    m_axi_awsize   =>  m_axi_awsize,
    m_axi_awburst  =>  m_axi_awburst,
    m_axi_wready   =>  m_axi_wready,
    m_axi_wvalid   =>  m_axi_wvalid,
    m_axi_wdata    =>  m_axi_wdata,
    m_axi_wlast    =>  m_axi_wlast,
    m_axi_bready   =>  m_axi_bready,
    m_axi_bvalid   =>  m_axi_bvalid,
    m_axi_bresp    =>  m_axi_bresp   
);

CLK_PROCESS : process
begin
    wait for HALF_PERIOD;
    s_axi_aclk <= '0';
    m_axi_aclk <= '0';
    wait for HALF_PERIOD;
    s_axi_aclk <= '1';
    m_axi_aclk <= '1';
end process CLK_PROCESS;

MAIN_PROCESS : process
begin

    s_axi_aresetn <= '0';
    m_axi_aresetn <= '0';
    
    wait for 4*CLOCK_PERIOD;
    s_axi_aresetn <= '1';
    m_axi_aresetn <= '1';
    wait for CLOCK_PERIOD;
    
    
    --------------------------------------------------
    -- Perform a write operation in burst mode
    wait for 30*CLOCK_PERIOD;
    s_axi_awlen <= x"3";
    s_axi_awsize <= "100";
    s_axi_awburst <= "01";
    s_axi_awaddr  <= x"48000000";
    s_axi_awvalid <= '1';
    s_axi_wdata <= x"DEADBEEF";
    wait for 1*CLOCK_PERIOD;
    s_axi_wvalid <= '1';
    s_axi_awvalid <= '0';
    s_axi_awaddr  <= x"00000000";
    s_axi_wdata <= x"55555555";
    wait for 1*CLOCK_PERIOD;
    s_axi_wdata <= x"FFFFFFFF";
    wait for CLOCK_PERIOD;
    s_axi_wdata <= x"55555555";
    wait for CLOCK_PERIOD;
    s_axi_wdata <= x"FFFFFFFF";
    wait for CLOCK_PERIOD;
    s_axi_wdata <= x"DEADBEEF";
    s_axi_awvalid <= '0';
    s_axi_wvalid <= '0';
    wait for CLOCK_PERIOD;
    s_axi_bready <= '1';
    wait for CLOCK_PERIOD;
    s_axi_bready <= '0';
    -- End of the write operation
    -----------------------------------------------
    
    
    --------------------------------------------------
    -- Fake slave (MIG) awnser
    wait for 24*CLOCK_PERIOD;
    m_axi_awready <= '1';
    wait for CLOCK_PERIOD;
    m_axi_awready <= '0';
    m_axi_wready <= '1';
    assert m_axi_wdata /= x"AAAAAAAA" report "Data wrong" severity error;
    wait for CLOCK_PERIOD;
    assert m_axi_wdata /= x"B7FFFFFF" report "Data wrong" severity error;
    wait for CLOCK_PERIOD;
    assert m_axi_wdata /= x"FD380000" report "Data wrong" severity error;
    wait for CLOCK_PERIOD;
    m_axi_wready <= '0';
    m_axi_bresp <= "01";
    m_axi_bvalid <= '1';
    wait for 1*CLOCK_PERIOD;
    m_axi_bresp <= "00";
    m_axi_bvalid <= '0';
    
    
    wait for 30*CLOCK_PERIOD;
    --------------------------------------------------
    -- Perform a read operation in burst mode
    s_axi_arlen <= x"3";
    s_axi_arsize <= "100";
    s_axi_arburst <= "01";
    s_axi_araddr  <= x"48000000";
    s_axi_arvalid <= '1';
    wait for 1*CLOCK_PERIOD;
    s_axi_arvalid <= '0';
    s_axi_rready <= '1';
    wait for 4*CLOCK_PERIOD;
    s_axi_rready <= '0';
    -- End of the read operation
    -----------------------------------------------
    wait;
end process MAIN_PROCESS;

end arch_compressor;
