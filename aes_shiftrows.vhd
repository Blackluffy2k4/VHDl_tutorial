

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;
use work.AES_MODE_PK.all;

entity AES_SHIFTROWS is
    port(
        DATA_IN_SHIFT  : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
        DATA_OUT_SHIFT : out std_logic_vector(DATA_WIDTH - 1 downto 0)
    );
end entity AES_SHIFTROWS;

architecture dataflow of AES_SHIFTROWS is
    -- State được xem như một mảng 4x4 byte
    -- s[row, col]
    -- s[0,0] = DATA_IN_SHIFT(127 downto 120)
    -- s[1,0] = DATA_IN_SHIFT(119 downto 112)
    -- ...
    -- s[0,1] = DATA_IN_SHIFT(95 downto 88)
    -- ...
begin
    -- Row 0: No shift
    -- s'[0,0] = s[0,0], s'[0,1] = s[0,1], s'[0,2] = s[0,2], s'[0,3] = s[0,3]
    DATA_OUT_SHIFT(127 downto 120) <= DATA_IN_SHIFT(127 downto 120); -- s[0,0]
    DATA_OUT_SHIFT(95 downto 88)   <= DATA_IN_SHIFT(95 downto 88);   -- s[0,1]
    DATA_OUT_SHIFT(63 downto 56)   <= DATA_IN_SHIFT(63 downto 56);   -- s[0,2]
    DATA_OUT_SHIFT(31 downto 24)   <= DATA_IN_SHIFT(31 downto 24);   -- s[0,3]

    -- Row 1: Shift left by 1
    -- s'[1,0] = s[1,1], s'[1,1] = s[1,2], s'[1,2] = s[1,3], s'[1,3] = s[1,0]
    DATA_OUT_SHIFT(119 downto 112) <= DATA_IN_SHIFT(87 downto 80);   -- s[1,1] -> s'[1,0]
    DATA_OUT_SHIFT(87 downto 80)   <= DATA_IN_SHIFT(55 downto 48);   -- s[1,2] -> s'[1,1]
    DATA_OUT_SHIFT(55 downto 48)   <= DATA_IN_SHIFT(23 downto 16);   -- s[1,3] -> s'[1,2]
    DATA_OUT_SHIFT(23 downto 16)   <= DATA_IN_SHIFT(119 downto 112); -- s[1,0] -> s'[1,3]

    -- Row 2: Shift left by 2
    -- s'[2,0] = s[2,2], s'[2,1] = s[2,3], s'[2,2] = s[2,0], s'[2,3] = s[2,1]
    DATA_OUT_SHIFT(111 downto 104) <= DATA_IN_SHIFT(47 downto 40);   -- s[2,2] -> s'[2,0]
    DATA_OUT_SHIFT(79 downto 72)   <= DATA_IN_SHIFT(15 downto 8);    -- s[2,3] -> s'[2,1]
    DATA_OUT_SHIFT(47 downto 40)   <= DATA_IN_SHIFT(111 downto 104); -- s[2,0] -> s'[2,2]
    DATA_OUT_SHIFT(15 downto 8)    <= DATA_IN_SHIFT(79 downto 72);   -- s[2,1] -> s'[2,3]

    -- Row 3: Shift left by 3
    -- s'[3,0] = s[3,3], s'[3,1] = s[3,0], s'[3,2] = s[3,1], s'[3,3] = s[3,2]
    DATA_OUT_SHIFT(103 downto 96)  <= DATA_IN_SHIFT(7 downto 0);     -- s[3,3] -> s'[3,0]
    DATA_OUT_SHIFT(71 downto 64)   <= DATA_IN_SHIFT(103 downto 96);  -- s[3,0] -> s'[3,1]
    DATA_OUT_SHIFT(39 downto 32)   <= DATA_IN_SHIFT(71 downto 64);   -- s[3,1] -> s'[3,2]
    DATA_OUT_SHIFT(7 downto 0)     <= DATA_IN_SHIFT(39 downto 32);   -- s[3,2] -> s'[3,3]

end architecture;