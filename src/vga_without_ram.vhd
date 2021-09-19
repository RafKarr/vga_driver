library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.utils.all;

entity vga_without_ram is
    generic (
        size_h_sync_counter   : integer := 800;
        size_v_sync_counter   : integer := 525;
        ticks_to_divide       : integer := 2;
        pixels_h_visible_area : integer := 640;
        pixels_v_visible_area : integer := 480;
        front_porch_h         : integer := 16;
        sync_width_h          : integer := 96;
        front_porch_v         : integer := 10;
        sync_width_v          : integer := 2
    );
    port (
        clk       : in std_logic;
        reset     : in std_logic;
        h_sync    : out std_logic;
        v_sync    : out std_logic;
        counter_h : out std_logic_vector(Log2(size_h_sync_counter) - 1 downto 0);
        counter_v : out std_logic_vector(Log2(size_v_sync_counter) - 1 downto 0)
        -- h_pixel : out std_logic;
        -- v_pixel : out std_logic
    );
end entity;

architecture rtl of vga_without_ram is

    ---Component declaration---

    component counter
        generic (
            count_to : integer
        );
        port (
            clk     : in std_logic;
            reset   : in std_logic;
            i_en    : in std_logic;
            o_value : out std_logic_vector((count_to - 1) downto 0)
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

    ---Constants---

    ---Signals---

    signal s_h_sync_counter_output      : std_logic_vector(Log2(size_h_sync_counter) - 1 downto 0) := (others => '0');
    signal s_h_sync_counter_en          : std_logic                                                := '0';
    signal s_v_sync_counter_en          : std_logic                                                := '0';
    signal s_v_sync_counter_output      : std_logic_vector(Log2(size_v_sync_counter) - 1 downto 0) := (others => '0');
    signal s_freq_div_counter_output    : std_logic_vector(Log2(ticks_to_divide) - 1 downto 0)     := (others => '0');
    signal s_counter_freq_divider_reset : std_logic                                                := '0';
    signal s_counter_h_sync_reset       : std_logic                                                := '0';
    signal s_counter_v_sync_reset       : std_logic                                                := '0';

    signal s_d_register_h_sync : std_logic := '0';
    -- signal s_reset_register_h_sync : std_logic_vector := '0';
    -- signal s_ce_register_h_sync : std_logic := '0';
    signal s_q_register_h_sync : std_logic := '0';
    signal s_d_register_v_sync : std_logic := '0';
    -- signal s_reset_register_v_sync : std_logic_vector := '0';
    -- signal s_ce_register_v_sync : std_logic := '0';
    signal s_q_register_v_sync  : std_logic := '0';
    signal s_d_register_h_pixel : std_logic := '0';
    -- signal s_reset_register_h_pixel : std_logic_vector := '0';
    -- signal s_ce_register_h_pixel : std_logic := '0';
    signal s_q_register_h_pixel : std_logic := '0';
    signal s_d_register_v_pixel : std_logic := '0';
    -- signal s_reset_register_v_pixel : std_logic_vector := '0';
    -- signal s_ce_register_v_pixel : std_logic := '0';
    signal s_q_register_v_pixel : std_logic := '0';

begin

    --Instantiations

    counter_freq_divider : counter
    generic map(
        count_to => Log2(ticks_to_divide)
    )
    port map(
        clk     => clk,
        reset   => s_counter_freq_divider_reset,
        i_en    => '1',
        o_value => s_freq_div_counter_output
    );

    counter_h_sync : counter
    generic map(
        count_to => Log2(size_h_sync_counter)
    )
    port map(
        clk     => clk,
        reset   => s_counter_h_sync_reset,
        i_en    => s_h_sync_counter_en,
        o_value => s_h_sync_counter_output
    );

    counter_v_sync : counter
    generic map(
        count_to => Log2(size_v_sync_counter)
    )
    port map(
        clk     => clk,
        reset   => s_counter_v_sync_reset,
        i_en    => s_v_sync_counter_en,
        o_value => s_v_sync_counter_output
    );

    register_h_sync : register_nbits_reset
    generic map(
        size => 1
    )
    port map(
        d(0)  => s_d_register_h_sync,
        clk   => clk,
        reset => reset,
        ce    => '1',
        q(0)  => s_q_register_h_sync
    );

    register_v_sync : register_nbits_reset
    generic map(
        size => 1
    )
    port map(
        d(0)  => s_d_register_v_sync,
        clk   => clk,
        reset => reset,
        ce    => '1',
        q(0)  => s_q_register_v_sync
    );

    -- register_h_pixel : register_nbits_reset
    -- generic map(
    --     size => 1
    -- )
    -- port map(
    --     d(0)  => s_d_register_h_pixel,
    --     clk   => clk,
    --     reset => reset,
    --     ce    => '1',
    --     q(0)  => s_q_register_h_pixel
    -- );

    -- register_v_pixel : register_nbits_reset
    -- generic map(
    --     size => 1
    -- )
    -- port map(
    --     d(0)  => s_d_register_v_pixel,
    --     clk   => clk,
    --     reset => reset,
    --     ce    => '1',
    --     q(0)  => s_q_register_v_pixel
    -- );

    ---Processes---

    combinatorial_h_sync : process (s_h_sync_counter_output)
    begin
        -- if to_integer(unsigned(s_h_sync_counter_output)) < pixels_h_visible_area then
        --     s_d_register_h_pixel <= '1';
        -- else
        --     s_d_register_h_pixel <= '0';
        -- end if;

        if to_integer(unsigned(s_h_sync_counter_output)) >= pixels_h_visible_area + front_porch_h and to_integer(unsigned(s_h_sync_counter_output)) < pixels_h_visible_area + front_porch_h + sync_width_h then
            s_d_register_h_sync <= '0';
        else
            s_d_register_h_sync <= '1';
        end if;
    end process;

    combinatorial_v_sync : process (s_v_sync_counter_output)
    begin
        -- if to_integer(unsigned(s_v_sync_counter_output)) < pixels_v_visible_area then
        --     s_d_register_v_pixel <= '1';
        -- else
        --     s_d_register_v_pixel <= '0';
        -- end if;

        if to_integer(unsigned(s_v_sync_counter_output)) >= pixels_v_visible_area + front_porch_v and to_integer(unsigned(s_v_sync_counter_output)) < pixels_v_visible_area + front_porch_v + sync_width_v then
            s_d_register_v_sync <= '0';
        else
            s_d_register_v_sync <= '1';
        end if;
    end process;

    ---Assignments---

    h_sync <= s_q_register_h_sync;
    v_sync <= s_q_register_v_sync;
    -- h_pixel <= s_q_register_h_pixel;
    -- v_pixel <= s_q_register_v_pixel;

    s_counter_freq_divider_reset <= '1' when (to_integer(unsigned(s_freq_div_counter_output)) = ticks_to_divide - 1) else reset;
    s_counter_h_sync_reset       <= '1' when (to_integer(unsigned(s_freq_div_counter_output)) = ticks_to_divide - 1 and to_integer(unsigned(s_h_sync_counter_output)) = size_h_sync_counter - 1) else reset;
    s_counter_v_sync_reset       <= '1' when (to_integer(unsigned(s_freq_div_counter_output)) = ticks_to_divide - 1 and to_integer(unsigned(s_h_sync_counter_output)) = size_h_sync_counter - 1 and to_integer(unsigned(s_v_sync_counter_output)) = size_v_sync_counter - 1) else reset;

    s_h_sync_counter_en <= '1' when (to_integer(unsigned(s_freq_div_counter_output)) = ticks_to_divide - 1) else '0';
    s_v_sync_counter_en <= '1' when (to_integer(unsigned(s_freq_div_counter_output)) = ticks_to_divide - 1 and to_integer(unsigned(s_h_sync_counter_output)) = size_h_sync_counter - 1) else '0';

end rtl;