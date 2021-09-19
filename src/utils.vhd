library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package utils is

    function Log2(input : integer) return integer;

end package;

package body utils is

    function Log2(input : integer) return integer is
        variable temp, log  : integer;
    begin
        temp := input;
        log  := 0;
        while (temp /= 0) loop
            temp := temp/2;
            log  := log + 1;
        end loop;
        return log;
    end function log2;

end package body;