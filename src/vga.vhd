library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.utils.all;

entity vga is
    port (
        clk    : in std_logic;
        reset  : in std_logic;
        h_sync : out std_logic;
        v_sync : out std_logic;
        r_bit  : out std_logic;
        g_bit  : out std_logic;
        b_bit  : out std_logic
    );
end entity;

architecture rtl of vga is

    constant size_h_sync_counter : integer := 800;
    constant size_v_sync_counter : integer := 525;

    component vga_without_ram
        port (
            clk       : in std_logic;
            reset     : in std_logic;
            h_sync    : out std_logic;
            v_sync    : out std_logic;
            counter_h : out std_logic_vector(Log2(size_h_sync_counter) - 1 downto 0);
            counter_v : out std_logic_vector(Log2(size_v_sync_counter) - 1 downto 0)
        );
    end component;

    component ram
        port (
            clk             : in std_logic;
            i_data          : in std_logic_vector (2 downto 0);
            i_write_address : in integer range 0 to 491520;
            i_read_address  : in integer range 0 to 491520;
            i_we            : in std_logic;
            o_q             : out std_logic_vector (2 downto 0)
        );
    end component;

    component register_nbits_reset
        generic (
            size : integer
        );
        port (
            d     : in std_logic_vector(size - 1 downto 0);
            clk   : in std_logic;
            reset : in std_logic;
            ce    : in std_logic;
            q     : out std_logic_vector(size - 1 downto 0)
        );
    end component;
    --Signals--

    signal s_h_sync    : std_logic                                                := '0';
    signal s_q_h_sync  : std_logic                                                := '0';
    signal s_v_sync    : std_logic                                                := '0';
    signal s_q_v_sync  : std_logic                                                := '0';
    signal s_reset     : std_logic                                                := '0';
    signal s_counter_h : std_logic_vector(Log2(size_h_sync_counter) - 1 downto 0) := (others => '0');
    signal s_counter_v : std_logic_vector(Log2(size_v_sync_counter) - 1 downto 0) := (others => '0');
    signal s_q_ram     : std_logic_vector(2 downto 0)                             := (others => '0');
    signal s_rdaddress : integer range 0 to 491520                                := 0;

begin

    --Instances

    vga_without_ram_inst : vga_without_ram
    port map(
        clk       => clk,
        reset     => s_reset,
        h_sync    => s_h_sync,
        v_sync    => s_v_sync,
        counter_h => s_counter_h,
        counter_v => s_counter_v
    );

    ram_inst : ram
    port map(
        clk             => clk,
        i_data          => "000",
        i_write_address => 0,
        i_read_address  => s_rdaddress,
        i_we            => '0',
        o_q             => s_q_ram
    );

    clk_delay_pulses: process (clk)
    begin
        if rising_edge(clk) then
            s_q_h_sync <= s_h_sync;
            s_q_v_sync <= s_v_sync;
        end if;
    end process;

    --Assignments

    -- s_reset     <= not reset;
    h_sync      <= s_h_sync;
    v_sync      <= s_v_sync;
    r_bit       <= s_q_ram(2);
    g_bit       <= s_q_ram(1);
    b_bit       <= s_q_ram(0);
    s_rdaddress <= to_integer(unsigned(s_counter_v(8 downto 0) & s_counter_h(9 downto 0)));

end rtl;