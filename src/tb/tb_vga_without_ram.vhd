library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_vga_without_ram is
end;

architecture bench of tb_vga_without_ram is

    -- Clock period
    constant clk_period : time := 20 ns;

    -- Ports
    signal clk       : std_logic := '0';
    signal reset     : std_logic := '0';
    signal s_h_sync  : std_logic := '0';
    signal s_v_sync  : std_logic := '0';

    --Signals for finishing the test bench
    signal tb_done    : boolean := false;
    signal tb_h_sync  : boolean := false;
    signal tb_v_sync  : boolean := false;

begin

    vga_without_ram_inst : entity work.vga_without_ram
        port map(
            clk       => clk,
            reset     => reset,
            h_sync    => s_h_sync,
            v_sync    => s_v_sync,
            counter_h => open,
            counter_v => open
        );

    clk_process : process
    begin
        while (not tb_done) loop
            wait for clk_period/2;
            clk <= not clk;
        end loop;
        wait;
    end process;

    --Processes 
    tb_reset : process
    begin
        reset <= '1';
        wait for clk_period;
        reset <= '0';
        wait;
    end process;

    tb_h_sync_process : process
        variable time1 : time;
        variable time2 : time;
    begin
        wait for 2 * clk_period;
        wait until s_h_sync'event;
        time1 := now;
        wait until s_h_sync'event;
        time2 := now;
        assert time2 - time1 = 3.84 us report "Horizontal sync pulse timing failed" severity failure;
        wait until s_h_sync'event;
        time1 := now;
        assert time1 - time2 = 28.16 us report "Time between horizontal sync pulse failed" severity failure;
        report "Horizontal sync pulse ok";
        tb_h_sync <= true;
        wait;
    end process;

    tb_v_sync_process : process
        variable time1 : time;
        variable time2 : time;
    begin
        wait for 2 * clk_period;
        wait until s_v_sync'event;
        time1 := now;
        wait until s_v_sync'event;
        time2 := now;
        assert time2 - time1 = 0.064 ms report "Vertical sync pulse timing failed" severity failure;
        wait until s_v_sync'event;
        time1 := now;
        assert time1 - time2 = 16.736 ms report "Time between vertical sync pulse failed" severity failure;
        report "Vertical sync pulse ok";
        tb_v_sync <= true;
        wait;
    end process;

    --Assignments

    tb_done <= tb_h_sync and tb_v_sync;

end;