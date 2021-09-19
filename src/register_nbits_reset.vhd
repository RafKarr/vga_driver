library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity register_nbits_reset is
    generic (
        size : integer
    );
    port (
        d     : in std_logic_vector(size - 1 downto 0);
        clk   : in std_logic;
        reset : in std_logic; --Reset in '1'
        ce    : in std_logic; --Enabled in '1'
        q     : out std_logic_vector(size - 1 downto 0)
    );
end entity register_nbits_reset;

architecture rtl of register_nbits_reset is

begin

    process (clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                q <= (others => '0');
            elsif ce = '1' then
                q <= d;
            else
                null;
            end if;
        end if;
    end process;

end architecture rtl;