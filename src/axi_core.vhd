library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.all;

entity axi_core is
  generic
  (
    C_AXI_ADDR_WIDTH             : integer              := 32;
    C_AXI_DATA_WIDTH             : integer              := 32;
    C_AXI_ID_WIDTH               : integer              := 12;
    C_BASE_ADDRESS               : std_logic_vector(31 downto 0) := x"40000000";
    C_MEMORY_SIZE                : std_logic_vector(31 downto 0) := x"40000000"
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
end entity axi_core;
  
architecture arch_axi_core of axi_core is

constant MAX_COUNTER : integer := 255;
constant BUFFER_SIZE : integer := 255;
constant MAX_BLOCKS : integer := 30;
type slave_write_state_type is (waiting_address, waiting_data, notify, response);
type xmatch_compress_state_type is (idle, configuring, processing, writing, notify);
type master_write_state_type is (idle, set_address, set_data, response);

type slave_read_state_type is (waiting_address, waiting_data, waiting_decompressor, response, done);
type master_read_state_type is (idle, set_address, reading, done);
type xmatch_decompress_state_type is (idle, configuring, reading, processing, save_data, notify);

-- Slave interface signals
signal slave_write_state : slave_write_state_type := waiting_address;
signal count_slave : integer range 0 to MAX_COUNTER := 0;
signal reg_s_axi_awaddr : std_logic_vector(31 downto 0) := (others => '0');
signal reg_s_axi_awlen : std_logic_vector(3 downto 0) := (others => '0');
signal reg_s_axi_awsize : std_logic_vector(2 downto 0) := (others => '0');
signal reg_s_axi_awburst : std_logic_vector(1 downto 0) := (others => '0');
signal slave_buffer_available : std_logic := '1';
signal wp_buffer_slave : integer range 0 to MAX_COUNTER := 0;

-- XMatch control signals
signal xmatch_compress_state : xmatch_compress_state_type := idle;
signal count_xmatch : integer range 0 to MAX_COUNTER := 0;
signal xmatch_flag : std_logic := '0';

-- XMatch compressor interface signals
signal CLK                   : bit ;	
signal C_OVERFLOW_CONTROL    : bit;
signal C_CS                  : bit ;
signal C_RW                  : bit;
signal C_ADDRESS             : bit_vector(1 downto 0);
signal C_CONTROL             : std_logic_vector(31 downto 0);
signal C_CLEAR               : bit;
signal C_BUS_ACKNOWLEDGE_U   : bit;
signal C_BUS_ACKNOWLEDGE_C   : bit;
signal C_WAIT_U              : bit;
signal C_WAIT_C              : bit;
signal C_U_DATAIN            : bit_vector(31 downto 0);
signal C_C_DATAOUT           : std_logic_vector(31 downto 0);
signal C_C_DATAOUT_TO_DECOMP : std_logic_vector(31 downto 0);
signal C_FINISHED            : bit;
signal C_COMPRESSING         : bit;
signal C_MODE                : bit;
signal C_FLUSHING            : bit;
signal C_CODING_OVERFLOW     : bit;
signal C_C_DATA_VALID        : bit;
signal C_CRC_OUT             : bit_vector(31 downto 0);
signal C_BUS_REQUEST_U       : bit;
signal C_BUS_REQUEST_C       : bit;

-- XMatch decompressor interface signals
signal D_CS                               : bit;
signal D_RW                               : bit;
signal D_ADDRESS                          : bit_vector(1 downto 0);
signal D_CONTROL                          : std_logic_vector(31 downto 0);
signal D_CLEAR                            : bit;
signal D_BUS_ACKNOWLEDGE_C                : bit;
signal D_BUS_ACKNOWLEDGE_U                : bit;
signal D_WAIT_C                           : bit;
signal D_WAIT_U                           : bit;
signal D_C_DATA_VALID                     : bit;
signal D_START_C                          : bit;
signal D_TEST_MODE                        : bit;
signal D_FINISHED_C                       : bit;
signal D_C_DATAIN                         : bit_vector(31 downto 0);
signal D_U_DATAOUT                        : std_logic_vector(31 downto 0);
signal D_FINISHED                         : bit;
signal D_FLUSHING                         : bit;
signal D_DECOMPRESSING                    : bit;
signal D_U_DATA_VALID                     : bit;
signal D_DECODING_OVERFLOW                : bit;
signal D_CRC_OUT                          : bit_vector(31 downto 0);
signal D_BUS_REQUEST_C                    : bit;
signal D_OVERFLOW_CONTROL_DECODING_BUFFER : bit;
signal D_BUS_REQUEST_U                    : bit;

-- Master interface signals
signal master_write_state      : master_write_state_type := idle;
signal count_master            : integer range 0 to MAX_COUNTER := 0;
signal reg_m_axi_awaddr        : std_logic_vector(31 downto 0) := (others => '0');
signal reg_m_axi_awlen         : std_logic_vector(3 downto 0) := (others => '0');
signal reg_m_axi_awsize        : std_logic_vector(2 downto 0) := (others => '0');
signal reg_m_axi_awburst       : std_logic_vector(1 downto 0) := (others => '0');
signal master_buffer_available : std_logic := '1';
signal wp_buffer_master        : integer range 0 to MAX_COUNTER := 0;

signal next_block_address : std_logic_vector(31 downto 0) := C_BASE_ADDRESS;
signal block_len : std_logic_vector(7 downto 0) := (others => '0');

signal slave_read_state : slave_read_state_type;
signal master_read_state : master_read_state_type;
signal xmatch_decompress_state : xmatch_decompress_state_type;

signal read_block_address : std_logic_vector(31 downto 0) := (others => '0');
signal read_block_len : std_logic_vector(7 downto 0) := (others => '0');

signal wp_buffer_xmatch_decompress : integer range 0 to MAX_COUNTER := 0;
signal wp_buffer_slave_read : integer range 0 to MAX_COUNTER := 0;
signal xmatch_decompress_count : integer range 0 to MAX_COUNTER := 0;
signal slave_read_count : integer range 0 to MAX_COUNTER := 0;
signal offset : std_logic_vector(7 downto 0) := (others => '0');
signal reg_m_axi_arlen : std_logic_vector(3 downto 0) := (others => '0');
signal reg_s_axi_arlen : std_logic_vector(3 downto 0) := (others => '0');

--COMPRESSOR_BUFFER_SLAVE
signal cbs_addra : std_logic_vector(7 downto 0) := (others => '0');
signal cbs_addrb : std_logic_vector(7 downto 0) := (others => '0');
signal cbs_dina  : std_logic_vector(31 downto 0) := (others => '0');
signal cbs_doutb : std_logic_vector(31 downto 0) := (others => '0');
signal cbs_enb   : std_logic := '0';
signal cbs_wea   : std_logic := '0';

--COMPRESSOR_BUFFER_MASTER
signal cbm_addra : std_logic_vector(7 downto 0) := (others => '0');
signal cbm_addrb : std_logic_vector(7 downto 0) := (others => '0');
signal cbm_dina  : std_logic_vector(31 downto 0) := (others => '0');
signal cbm_doutb : std_logic_vector(31 downto 0) := (others => '0');
signal cbm_enb   : std_logic := '0';
signal cbm_wea   : std_logic := '0';

--BLOCKS_ADDRESSES
signal ba_addra : std_logic_vector(7 downto 0) := (others => '0');
signal ba_addrb : std_logic_vector(7 downto 0) := (others => '0');
signal ba_dina  : std_logic_vector(31 downto 0) := (others => '0');
signal ba_doutb : std_logic_vector(31 downto 0) := (others => '0');
signal ba_enb   : std_logic := '0';
signal ba_wea   : std_logic := '0';

--BLOCKS_LENGTHS
signal bl_addra : std_logic_vector(7 downto 0) := (others => '0');
signal bl_addrb : std_logic_vector(7 downto 0) := (others => '0');
signal bl_dina  : std_logic_vector(31 downto 0) := (others => '0');
signal bl_doutb : std_logic_vector(31 downto 0) := (others => '0');
signal bl_enb   : std_logic := '0';
signal bl_wea   : std_logic := '0';

--DECOMPRESSOR_BUFFER_IN
signal dbi_addra : std_logic_vector(7 downto 0) := (others => '0');
signal dbi_addrb : std_logic_vector(7 downto 0) := (others => '0');
signal dbi_dina  : std_logic_vector(31 downto 0) := (others => '0');
signal dbi_doutb : std_logic_vector(31 downto 0) := (others => '0');
signal dbi_enb   : std_logic := '0';
signal dbi_wea   : std_logic := '0';

--DECOMPRESSOR_BUFFER_OUT
signal dbo_addra : std_logic_vector(7 downto 0) := (others => '0');
signal dbo_addrb : std_logic_vector(7 downto 0) := (others => '0');
signal dbo_dina  : std_logic_vector(31 downto 0) := (others => '0');
signal dbo_doutb : std_logic_vector(31 downto 0) := (others => '0');
signal dbo_enb   : std_logic := '0';
signal dbo_wea   : std_logic := '0';

component level1rc
port
(
    OVERFLOW_CONTROL    : in bit;
    CS                  : in bit ;
    RW                  : in bit;
    ADDRESS             : in bit_vector(1 downto 0);
    CONTROL             : inout std_logic_vector(31 downto 0);
    CLK                 : in bit ;	
    CLEAR               : in bit;
    BUS_ACKNOWLEDGE_U   : in bit;
    BUS_ACKNOWLEDGE_C   : in bit;
    WAIT_U              : in bit;
    WAIT_C              : in bit;
    U_DATAIN            : in bit_vector(31 downto 0);
    C_DATAOUT           : out std_logic_vector(31 downto 0);
    C_DATAOUT_TO_DECOMP : out std_logic_vector(31 downto 0);
    FINISHED            : out bit;
    COMPRESSING         : out bit;
    MODE                : out bit;
    FLUSHING            : out bit;
    CODING_OVERFLOW     : out bit;
    C_DATA_VALID        : out bit;
    CRC_OUT             : out bit_vector(31 downto 0);
    BUS_REQUEST_U       : out bit;
    BUS_REQUEST_C       : out bit
);
end component;

component level1rd
port
(
    CS                               : in bit;
    RW                               : in bit;
    ADDRESS                          : in bit_vector(1 downto 0);
    CONTROL                          : inout std_logic_vector(31 downto 0);
    CLK                              : in bit;
    CLEAR                            : in bit;
    BUS_ACKNOWLEDGE_C                : in bit;
    BUS_ACKNOWLEDGE_U                : in bit;
    WAIT_C                           : in bit;
    WAIT_U                           : in bit;
    C_DATA_VALID                     : in bit;
    START_C                          : in bit;
    TEST_MODE                        : in bit;
    FINISHED_C                       : in bit;
    C_DATAIN                         : in bit_vector(31 downto 0);
    U_DATAOUT                        : out std_logic_vector(31 downto 0);
    FINISHED                         : out bit;
    FLUSHING                         : out bit;
    DECOMPRESSING                    : out bit;
    U_DATA_VALID                     : out bit;
    DECODING_OVERFLOW                : out bit;
    CRC_OUT                          : out bit_vector(31 downto 0);
    BUS_REQUEST_C                    : out bit;
    OVERFLOW_CONTROL_DECODING_BUFFER : out bit;
    BUS_REQUEST_U                    : out bit
);
end component;

component simulation_mem_256
port
(
	addra : in std_logic_vector(7 downto 0);
	addrb : in std_logic_vector(7 downto 0);
	clka  : in std_logic;
	clkb  : in std_logic;
	dina  : in std_logic_vector(31 downto 0);
	doutb : out std_logic_vector(31 downto 0);
	enb   : in std_logic;
	wea   : in std_logic
);
end component;

function clog2 (bit_depth : integer) return integer is 
begin
    if bit_depth <= 1 then
        return 0;
    else
        return clog2(bit_depth / 2) + 1;
    end if;
end function clog2;

begin

CLK <= to_bit(s_axi_aclk);

COMPRESSOR_XMATCH : level1rc  port map(
    OVERFLOW_CONTROL    => C_OVERFLOW_CONTROL,
    CS                  => C_CS,
    RW                  => C_RW,
    ADDRESS             => C_ADDRESS,
    CONTROL             => C_CONTROL,
    CLK                 => CLK,
    CLEAR               => C_CLEAR,
    BUS_ACKNOWLEDGE_U   => C_BUS_ACKNOWLEDGE_U,
    BUS_ACKNOWLEDGE_C   => C_BUS_ACKNOWLEDGE_C,
    WAIT_U              => C_WAIT_U,
    WAIT_C              => C_WAIT_C,
    U_DATAIN            => C_U_DATAIN,
    C_DATAOUT           => C_C_DATAOUT,
    C_DATAOUT_TO_DECOMP => C_C_DATAOUT_TO_DECOMP,
    FINISHED            => C_FINISHED,
    COMPRESSING         => C_COMPRESSING,
    MODE                => C_MODE,
    FLUSHING            => C_FLUSHING,
    CODING_OVERFLOW     => C_CODING_OVERFLOW,
    C_DATA_VALID        => C_C_DATA_VALID,
    CRC_OUT             => C_CRC_OUT,
    BUS_REQUEST_U       => C_BUS_REQUEST_U,
    BUS_REQUEST_C       => C_BUS_REQUEST_C
);

DECOMPRESSOR_XMATCH : level1rd  port map(
    CS                               =>  D_CS,
    RW                               =>  D_RW,
    ADDRESS                          =>  D_ADDRESS,
    CONTROL                          =>  D_CONTROL,
    CLK                              =>  CLK,
    CLEAR                            =>  D_CLEAR,
    BUS_ACKNOWLEDGE_C                =>  D_BUS_ACKNOWLEDGE_C,
    BUS_ACKNOWLEDGE_U                =>  D_BUS_ACKNOWLEDGE_U,
    WAIT_C                           =>  D_WAIT_C,
    WAIT_U                           =>  D_WAIT_U,
    C_DATA_VALID                     =>  D_C_DATA_VALID,
    START_C                          =>  D_START_C,
    TEST_MODE                        =>  D_TEST_MODE,
    FINISHED_C                       =>  D_FINISHED_C,
    C_DATAIN                         =>  D_C_DATAIN,
    U_DATAOUT                        =>  D_U_DATAOUT,
    FINISHED                         =>  D_FINISHED,
    FLUSHING                         =>  D_FLUSHING,
    DECOMPRESSING                    =>  D_DECOMPRESSING,
    U_DATA_VALID                     =>  D_U_DATA_VALID,
    DECODING_OVERFLOW                =>  D_DECODING_OVERFLOW,
    CRC_OUT                          =>  D_CRC_OUT,
    BUS_REQUEST_C                    =>  D_BUS_REQUEST_C,
    OVERFLOW_CONTROL_DECODING_BUFFER =>  D_OVERFLOW_CONTROL_DECODING_BUFFER,
    BUS_REQUEST_U                    =>  D_BUS_REQUEST_U
);

-- Memories for storing block information
-- portmap block_base_address_dictionary -- 256*4 Bytes = 1GB
BLOCKS_ADDRESSES : simulation_mem_256 port map(
	addra => ba_addra, 
	addrb => ba_addrb, 
	clka  => s_axi_aclk,  
	clkb  => s_axi_aclk,  
	dina  => ba_dina,  
	doutb => ba_doutb, 
	enb   => ba_enb,   
	wea   => ba_wea   
);

ba_wea <= '1' when master_write_state = idle and xmatch_compress_state = notify else '0';
ba_addra <= conv_std_logic_vector(conv_integer(reg_m_axi_awaddr), 8);
ba_dina <= conv_std_logic_vector(conv_integer(next_block_address), 32);

ba_enb <= '1' when slave_read_state = waiting_address and s_axi_arvalid = '1' else '0';
ba_addrb <= conv_std_logic_vector(conv_integer(s_axi_araddr), 8);
read_block_address <= conv_std_logic_vector(conv_integer(ba_doutb), read_block_address'length);

-- portmap block_len_dictionary -- 256*4 Bytes = 1GB
BLOCKS_LENGTHS : simulation_mem_256 port map(
	addra => bl_addra, 
	addrb => bl_addrb, 
	clka  => s_axi_aclk,  
	clkb  => s_axi_aclk,  
	dina  => bl_dina,  
	doutb => bl_doutb, 
	enb   => bl_enb,   
	wea   => bl_wea   
);

bl_wea <= '1' when master_write_state = idle and xmatch_compress_state = notify else '0';
bl_addra <= conv_std_logic_vector(conv_integer(reg_m_axi_awaddr), 8);
bl_dina <= conv_std_logic_vector(conv_integer(block_len), 32);

bl_enb <= '1' when slave_read_state = waiting_address and s_axi_arvalid = '1' else '0';
bl_addrb <= conv_std_logic_vector(conv_integer(s_axi_araddr), 8);
read_block_len <= conv_std_logic_vector(conv_integer(bl_doutb), read_block_len'length);

-- Memory for compression/writing -- buffer slave -- 256*4 Bytes = 1GB
COMPRESSOR_BUFFER_IN : simulation_mem_256 port map(
	addra => cbs_addra, 
	addrb => cbs_addrb, 
	clka  => s_axi_aclk,  
	clkb  => s_axi_aclk,  
	dina  => cbs_dina,  
	doutb => cbs_doutb, 
	enb   => cbs_enb,   
	wea   => cbs_wea   
);

--write
cbs_addra <= conv_std_logic_vector(wp_buffer_slave, 8);
cbs_wea <= '1' when slave_write_state = waiting_data and s_axi_wvalid = '1' else '0';
cbs_dina <= s_axi_wdata;
--read
cbs_addrb <= conv_std_logic_vector(count_xmatch, 8);
cbs_enb <= '1' when xmatch_compress_state = processing and xmatch_flag = '0' else '0';
C_U_DATAIN <= to_bitvector(cbs_doutb);

-- Memory for compression/writing -- buffer master -- 256*4 Bytes = 1GB
COMPRESSOR_BUFFER_OUT : simulation_mem_256 port map(
	addra => cbm_addra, 
	addrb => cbm_addrb, 
	clka  => s_axi_aclk,  
	clkb  => s_axi_aclk,  
	dina  => cbm_dina,  
	doutb => cbm_doutb, 
	enb   => cbm_enb,   
	wea   => cbm_wea  
);

--write
cbm_addra <= conv_std_logic_vector(wp_buffer_master, 8);
cbm_wea <= '1' when xmatch_compress_state = writing and C_C_DATA_VALID = '0' else '0';
cbm_dina <= C_C_DATAOUT;
--read
cbm_addrb <= conv_std_logic_vector(count_master, 8);
cbm_enb <= '1' when (master_write_state = set_address and m_axi_awready = '1') or (master_write_state = set_data and count_master < wp_buffer_master) else '0';
m_axi_wdata <= cbm_doutb when master_write_state = set_data else (others => '0');

-- Memories for decompression/reading
-- portmap buffer_xmatch_decompress
DECOMPRESSOR_BUFFER_IN : simulation_mem_256 port map(
	addra => dbi_addra, 
	addrb => dbi_addrb, 
	clka  => s_axi_aclk,  
	clkb  => s_axi_aclk,  
	dina  => dbi_dina,  
	doutb => dbi_doutb, 
	enb   => dbi_enb,   
	wea   => dbi_wea  
);

dbi_enb <= '1' when slave_read_state = response else '0';
dbi_addrb <= conv_std_logic_vector(slave_read_count, 8);
s_axi_rdata <= dbi_doutb;

dbi_wea <= '1' when (xmatch_decompress_state = processing or xmatch_decompress_state = save_data) and D_U_DATA_VALID = '0' else '0';
dbi_addra <= conv_std_logic_vector(wp_buffer_xmatch_decompress, 8);
dbi_dina <= D_U_DATAOUT;

-- portmap buffer_slave_read 
DECOMPRESSOR_BUFFER_OUT : simulation_mem_256 port map(
	addra => dbo_addra, 
	addrb => dbo_addrb, 
	clka  => s_axi_aclk,  
	clkb  => s_axi_aclk,  
	dina  => dbo_dina,  
	doutb => dbo_doutb, 
	enb   => dbo_enb,   
	wea   => dbo_wea  
);

dbo_enb <= '1' when xmatch_decompress_state = reading and xmatch_decompress_count <= wp_buffer_slave_read else '0';
dbo_addrb <= conv_std_logic_vector(xmatch_decompress_count, 8);
D_C_DATAIN <= to_bitvector(dbo_doutb);

dbo_wea <= '1' when master_read_state = reading and m_axi_rvalid = '1' else '0';
dbo_addra <= conv_std_logic_vector(wp_buffer_slave_read, 8);
dbo_dina <= m_axi_rdata;

------------------------------------------------------
-- READ operations bypass the decompressor
--m_axi_arlen   <= s_axi_arlen;
--m_axi_arsize  <= s_axi_arsize;
--m_axi_arburst <= s_axi_arburst;
--m_axi_araddr  <= s_axi_araddr;
--m_axi_arvalid <= s_axi_arvalid;
--m_axi_rready  <= s_axi_rready;

--s_axi_arready <= m_axi_arready;
--s_axi_rdata   <= m_axi_rdata;
--s_axi_rvalid  <= m_axi_rvalid;
--s_axi_rresp   <= m_axi_rresp;
--s_axi_rlast   <= m_axi_rlast;
------------------------------------------------

------------------------
-- READ/DECOMPRESSING --
------------------------

s_axi_arready <= '1' when s_axi_arvalid = '1' and slave_read_state = waiting_address else '0';
--s_axi_rdata <= buffer_xmatch_decompress(slave_read_count) when slave_read_state = response else (others => '0');
s_axi_rvalid <= '1' when slave_read_state = response else '0';
s_axi_rlast <= '1' when slave_read_state = response and slave_read_count = wp_buffer_xmatch_decompress else '0';
s_axi_rresp <= "00" when slave_read_state = done else "00";
-------------------------------------------------
-- Manages slave signals to interface with master (CPU)
AXI_SLAVE_READ : process (s_axi_aclk, s_axi_aresetn)
begin

    if s_axi_aresetn = '0' then
        slave_read_state <= waiting_address;
    elsif rising_edge(s_axi_aclk) then
        case slave_read_state is
        
            when waiting_address =>
                if s_axi_arvalid = '1' then
                    slave_read_state <= waiting_data;
                    reg_s_axi_arlen <= s_axi_arlen;
                end if;
                
            when waiting_data =>
                if master_read_state = done then
                    slave_read_state <= waiting_decompressor;
                else
                    slave_read_state <= waiting_data;
                end if;
                
            when waiting_decompressor =>
                if xmatch_decompress_state = notify then
                    slave_read_state <= response;
                    slave_read_count <= 0;
                end if;
                
            when response =>
                if slave_read_count = wp_buffer_xmatch_decompress and s_axi_rready = '1' then
                    slave_read_state <= done;
                elsif s_axi_rready = '1' then
                    slave_read_count <= slave_read_count + 1;
                end if;
                
            when done =>
                slave_read_state <= waiting_address;
                
        end case;
    end if;

end process AXI_SLAVE_READ;

-------------------------------------------------
-- Manages master signals to interface with slave (MIG)
m_axi_araddr <= read_block_address + offset when master_read_state = set_address else (others => '0');
reg_m_axi_arlen <= x"f" when conv_integer(read_block_len)-conv_integer(offset) >= 15 else read_block_len(3 downto 0);
m_axi_arlen <= reg_m_axi_arlen when master_read_state = set_address else (others => '0');
m_axi_arsize <= "010" when master_read_state = set_address else (others => '0');
m_axi_arburst <= "01" when master_read_state = set_address else (others => '0');
m_axi_arvalid <= '1' when master_read_state = set_address else '0';
m_axi_rready <= '1' when master_read_state = reading else '0';
AXI_MASTER_READ : process (s_axi_aclk, s_axi_aresetn)
begin

    if s_axi_aresetn = '0' then
        master_read_state <= idle;
    elsif rising_edge(s_axi_aclk) then
        case master_read_state is
        
            when idle =>
                offset <= x"00";
                if slave_read_state = waiting_data then
                    master_read_state <= set_address;
                    wp_buffer_slave_read <= 0;
                end if;
        
            when set_address =>
                if m_axi_arready = '1' then
                    master_read_state <= reading;
                end if;
        
            when reading =>
                if wp_buffer_slave_read = conv_integer(read_block_len) + 1 then
                    master_read_state <= done;
                    wp_buffer_slave_read <= wp_buffer_slave_read - 1;
                elsif m_axi_rlast = '1' and wp_buffer_slave_read < conv_integer(read_block_len) then
                    offset <= offset + x"10";
                    wp_buffer_slave_read <= wp_buffer_slave_read + 1;
                    master_read_state <= set_address;
                elsif m_axi_rvalid = '1' then
                    wp_buffer_slave_read <= wp_buffer_slave_read + 1;
                    --buffer_slave_read(wp_buffer_slave_read) <= m_axi_rdata;
                end if;
        
            when done =>
                master_read_state <= idle;
                
        end case;
    end if;

end process AXI_MASTER_READ;

-------------------------------------------------
-- Manages signals to interface with XMATCH IP
XMATCH_DECOMPRESS : process (s_axi_aclk, s_axi_aresetn)
begin

    if s_axi_aresetn = '0' then
        xmatch_decompress_state <= idle;
    elsif rising_edge(s_axi_aclk) then
        case xmatch_decompress_state is
        
            when idle =>
                xmatch_decompress_count <= 0;
                if slave_read_state = waiting_decompressor then
                    xmatch_decompress_state <= configuring;
                    D_CLEAR <= '1';
                    D_CS <= '0';
                    D_RW <= '0';
                    D_ADDRESS <= "01";
                    D_CONTROL <= conv_std_logic_vector((conv_integer(reg_s_axi_arlen) + 1) * 4, 32);
                else
                    D_CLEAR <= '0';
                    D_CS <= '1';
                    D_RW <= '1';
                    D_ADDRESS <= (others => '0');
                    D_CONTROL <= (others => '0');
                    D_BUS_ACKNOWLEDGE_C <= '1';
                    D_BUS_ACKNOWLEDGE_U <= '1';
                    D_BUS_ACKNOWLEDGE_C <= '1';
                    D_BUS_ACKNOWLEDGE_U <= '1';
                    D_WAIT_C <= '1';
                    D_WAIT_U <= '1';
                    D_C_DATA_VALID <= '1';
                    D_START_C <= '1';
                    D_TEST_MODE <= '1';
                    D_FINISHED_C <= '1';
                    --D_C_DATAIN <= (others => '0');
                end if;
        
            when configuring =>
                if xmatch_decompress_count = 0 then
                    xmatch_decompress_count <= xmatch_decompress_count + 1;
                    D_ADDRESS <= "00";
                    D_CONTROL <= x"00004081";-- Set decompression mode
                elsif xmatch_decompress_count = 1 then
                    D_CS <= '1';
                    D_RW <= '1';
                    D_ADDRESS <= (others => '0');
                    D_CONTROL <= (others => '0');
                    
                    if D_BUS_REQUEST_C = '0' then
                        D_BUS_ACKNOWLEDGE_C <= '0';
                        xmatch_decompress_count <= xmatch_decompress_count + 1;
                    end if;
                elsif xmatch_decompress_count = 2 then
                    xmatch_decompress_state <= reading;
                    xmatch_decompress_count <= 0;
                end if;
                
            when reading =>
                if xmatch_decompress_count = wp_buffer_slave_read + 1 then
                    xmatch_decompress_state <= processing;
                    D_C_DATA_VALID <= '1';
                    D_BUS_ACKNOWLEDGE_C <= '1';
                else
                    D_C_DATA_VALID <= '0';
                    xmatch_decompress_count <= xmatch_decompress_count + 1;
                    --D_C_DATAIN <= to_bitvector(buffer_slave_read(xmatch_decompress_count));
                end if;
                    
            when processing =>
                if D_U_DATA_VALID = '0' then
                    xmatch_decompress_state <= save_data;
                    --buffer_xmatch_decompress(0) <= D_U_DATAOUT;
                    wp_buffer_xmatch_decompress <= 1;
                end if;
                
            when save_data =>
                if D_U_DATA_VALID = '0' then
                    --buffer_xmatch_decompress(wp_buffer_xmatch_decompress) <= D_U_DATAOUT;
                    wp_buffer_xmatch_decompress <= wp_buffer_xmatch_decompress + 1;
                elsif D_FINISHED = '0' then
                    wp_buffer_xmatch_decompress <= wp_buffer_xmatch_decompress - 1;
                    xmatch_decompress_state <= notify;
                end if;
            
            when notify =>
                D_BUS_ACKNOWLEDGE_U <= '1';
                xmatch_decompress_state <= idle;
                
        end case;
    end if;

end process XMATCH_DECOMPRESS;



-----------------------
-- WRITE/COMPRESSING --
-----------------------

------------------------------------------------
-- Manages slave signals to interface with master (CPU)
s_axi_awready <= '1' when s_axi_awvalid = '1' and slave_write_state = waiting_address and slave_buffer_available = '1' and xmatch_compress_state = idle else '0';
s_axi_wready <= '1' when s_axi_wvalid = '1' and (slave_write_state = waiting_data or slave_write_state = notify) else '0';
s_axi_bresp <= "00" when slave_write_state = response else "11";
s_axi_bvalid <= '1' when slave_write_state = response else '0';

AXI_SLAVE_WRITE : process (s_axi_aclk, s_axi_aresetn)
begin
    if s_axi_aresetn = '0' then
        slave_write_state <= waiting_address;
    elsif rising_edge(s_axi_aclk) then
        case slave_write_state is
        
            when waiting_address =>
                if s_axi_awvalid = '1' and slave_buffer_available = '1' and xmatch_compress_state = idle then
                    slave_write_state <= waiting_data;
                    reg_s_axi_awlen <= s_axi_awlen;
                    reg_s_axi_awaddr <= s_axi_awaddr;
                    reg_s_axi_awsize <= s_axi_awsize;
                    reg_s_axi_awburst <= s_axi_awburst;
                    wp_buffer_slave <= 0;
                end if;                
                
            when waiting_data =>
                if s_axi_wvalid = '1' then
                    --buffer_slave(wp_buffer_slave) <= s_axi_wdata;
                    if s_axi_wlast = '1' then
                        slave_write_state <= notify;
                    else
                        wp_buffer_slave <= wp_buffer_slave + 1;
                    end if;
                end if;
                
            when notify =>
                if s_axi_bready = '1' then
                    slave_write_state <= waiting_address;
                else
                    slave_write_state <= response;  
                end if;  
                
            when response => 
                if s_axi_bready = '1' then
                    slave_write_state <= waiting_address;
                end if;     
            
        end case;
    end if;
end process AXI_SLAVE_WRITE;

------------------------------------------------
-- Manages signals to interface with XMATCH IP
XMATCH_COMPRESS : process (s_axi_aclk, s_axi_aresetn)
begin

    if s_axi_aresetn = '0' then
        xmatch_compress_state <= idle;
    elsif rising_edge(s_axi_aclk) then

        case xmatch_compress_state is
            when idle =>
                if slave_write_state = waiting_data then
                    slave_buffer_available <= '0';
                    C_CLEAR <= '0';
                elsif slave_write_state = notify then
                    xmatch_compress_state <= configuring;
                    C_CLEAR <= '1';
                    count_xmatch <= 0;
                    C_CS <= '0';
                    C_RW <= '0';
                    C_ADDRESS <= "01";
                    C_CONTROL(31 downto 0) <= conv_std_logic_vector((wp_buffer_slave + 1) * 4, 32);
                else
                    C_CLEAR <= '0';
                    C_CS <= '1';
                    C_RW <= '1';
                    C_ADDRESS <= "00";
                    C_CONTROL <= "00000000000000000000000000000000";
                end if;
                
                C_BUS_ACKNOWLEDGE_C <= '1';
                C_BUS_ACKNOWLEDGE_U <= '1';
                C_WAIT_U <= '1';
                C_WAIT_C <= '1';

            when configuring =>
             
                if count_xmatch = 0 then
                    C_RW <= '0';
                    C_CS <= '0';
                    C_ADDRESS <= "00";
                    C_CONTROL <= x"00005080";-- Set compression mode
                    count_xmatch <= count_xmatch + 1;
                elsif count_xmatch = 1 then
                    C_RW <= '1';
                    C_CS <= '1';
                    C_CONTROL <= "00000000000000000000000000000000";
                    C_ADDRESS <= "00";
                    if master_buffer_available = '1' and C_BUS_REQUEST_U = '0' then
                        xmatch_compress_state <= processing;
                        C_BUS_ACKNOWLEDGE_U <= '0';
                        xmatch_flag <= '0';
                        count_xmatch <= 0;
                    end if;
                end if;

            when processing =>
                if xmatch_flag = '0' then
                    --C_U_DATAIN <= to_bitvector(buffer_slave(count_xmatch));
                    if count_xmatch = wp_buffer_slave then
                        xmatch_flag <= '1';
                        count_xmatch <= 0;
                    else
                        count_xmatch <= count_xmatch + 1;
                    end if;
                else
                    --C_U_DATAIN <= x"00000000";
                    if C_BUS_REQUEST_C = '0' then
                        C_BUS_ACKNOWLEDGE_C <= '0';
                        
                        if count_xmatch = 1 then
                            wp_buffer_master <= 0;
                            xmatch_flag <= '0';
                            xmatch_compress_state <= writing;
                            reg_m_axi_awaddr <= reg_s_axi_awaddr;
                            reg_m_axi_awlen <= reg_s_axi_awlen;
                            reg_m_axi_awsize <= reg_s_axi_awsize;
                            reg_m_axi_awburst <= reg_s_axi_awburst;
                        else
                            count_xmatch <= count_xmatch + 1;
                        end if;
                    end if;
                    
                end if;
                
            when writing =>
                slave_buffer_available <= '1';
                
                if C_FINISHED = '0' then
                    xmatch_compress_state <= notify;
                elsif C_C_DATA_VALID = '0' then
                        --buffer_master(wp_buffer_master) <= C_C_DATAOUT;
                        wp_buffer_master <= wp_buffer_master + 1;
                end if;
                
            when notify =>
                xmatch_compress_state <= idle;
            
        end case;
    end if;
end process XMATCH_COMPRESS;

------------------------------------------------
-- Manages master signals to interface with slave (MIG)
m_axi_wvalid <= '1' when master_write_state = set_data else '0';
--m_axi_wdata <= buffer_master(count_master) when master_write_state = set_data else (others => '0');
m_axi_wlast <= '1' when master_write_state = set_data and count_master = wp_buffer_master else '0';
m_axi_bready <= '1' when master_write_state = response and m_axi_bresp = "00" and m_axi_bvalid = '1' else '0';
m_axi_awvalid <= '1' when master_write_state = set_address else '0';                   
block_len <= conv_std_logic_vector(wp_buffer_master - 1, 8) when xmatch_compress_state = notify else (others => '0');

--m_axi_awaddr <= next_block_address when master_write_state = notify else (others => '0');
--m_axi_awlen <= block_len(3 downto 0) when master_write_state = notify else m_axi_awlen;
--m_axi_awsize <= reg_m_axi_awsize when master_write_state = notify else m_axi_awsize;
--m_axi_awburst <= reg_m_axi_awburst when master_write_state = notify else m_axi_awburst;

AXI_MASTER_WRITE : process (s_axi_aclk, s_axi_aresetn)
begin
    if s_axi_aresetn = '0' then
        master_write_state <= idle;
    elsif rising_edge(s_axi_aclk) then
        case master_write_state is
            when idle =>
                count_master <= 0;
                if xmatch_compress_state = writing then
                    master_buffer_available <= '0';
                end if;
                
                if xmatch_compress_state = notify then
                    master_write_state <= set_address;
					-- TODO: move AXI signals to out of process
                    m_axi_awaddr <= next_block_address;
                    m_axi_awlen <= block_len(3 downto 0);
                    m_axi_awsize <= reg_m_axi_awsize;
                    m_axi_awburst <= reg_m_axi_awburst;
					next_block_address <= next_block_address + SHL(x"00000001", (SHL(x"00000001", reg_m_axi_awsize))) + x"00000004";
                end if;
        
            when set_address =>                
                if m_axi_awready = '1' then
                    master_write_state <= set_data;
					--count_master <= count_master + 1;
                end if;
            
            when set_data =>
                if count_master = wp_buffer_master then
                    master_write_state <= response;
                --elsif m_axi_wready = '1' then
                --    count_master <= count_master + 1;
                end if;
				-- FIXME: It should increment the counter only if wready = '1',
				--		  but in the same cycle. Adding the statement above
				--		  will delay the incrementing process in 1 cycle.
				count_master <= count_master + 1;
            
            when response =>
                master_buffer_available <= '1';                
                if m_axi_bresp = "00" and m_axi_bvalid = '1' then
                    master_write_state <= idle;
                end if;
            
        end case;
    end if;
end process AXI_MASTER_WRITE;

end arch_axi_core;