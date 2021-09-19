library ieee;
use ieee.std_logic_1164.all;
entity ram is
    port (
        clk             : in std_logic;
        i_data          : in std_logic_vector (2 downto 0);
        i_write_address : in integer range 0 to 491520;
        i_read_address  : in integer range 0 to 491520;
        i_we            : in std_logic;
        o_q             : out std_logic_vector (2 downto 0)
    );
end ram;
architecture rtl of ram is
    type mem is array(0 to 491520) of std_logic_vector(2 downto 0);
    signal ram_block : mem := (others => "100") ;
begin
    process (clk)
    begin
        if (clk'event and clk = '1') then
            if (i_we = '1') then
                ram_block(i_write_address) <= i_data;
            end if;
            o_q <= ram_block(i_read_address);
        end if;
    end process;
end rtl;