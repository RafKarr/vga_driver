library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity counter is
  generic (
    count_to : integer
  );
  port (
    clk     : in std_logic;
    reset   : in std_logic;
    i_en    : in std_logic; --! Enable signal
    o_value : out std_logic_vector((count_to - 1) downto 0)
  );
end entity;

architecture rtl of counter is

  signal r_value : unsigned ((count_to - 1) downto 0) := (others => '0');

begin
  o_value <= std_logic_vector(r_value);

  counter : process (clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then 
        r_value <= (others => '0');
      elsif i_en = '1' then
        r_value <= r_value + 1;
      end if;
    end if;
  end process;

end architecture;