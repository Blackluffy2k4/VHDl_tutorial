----------------------------------------------------------
-- Module: AES_MIXCOLUMNS.vhd 

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;
use work.AES_MODE_PK.all;

entity AES_MIXCOLUMNS is
    port (
        DATA_IN_MIXCOL  : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
        DATA_OUT_MIXCOL : out std_logic_vector(DATA_WIDTH - 1 downto 0)
    );
end entity;

architecture dataflow of AES_MIXCOLUMNS is
    component AES_XTIME is
        port ( Xtime_in : in std_logic_vector(7 downto 0); Xtime_out: out std_logic_vector(7 downto 0) );
    end component;

    type T_BYTE_ARRAY is array (0 to 15) of std_logic_vector(7 downto 0);
    signal s_in_bytes : T_BYTE_ARRAY;
    signal s_xtime_bytes : T_BYTE_ARRAY;

begin

    -- Tách 128 bit ðau vào thành 16 byte theo thu tu state array
    -- (Byte 0 = MSB)
    byte_separator: for i in 0 to 15 generate
        s_in_bytes(i) <= DATA_IN_MIXCOL( (127-i*8) downto (120-i*8) );
    end generate;

    -- Tính giá tri nhân 2 cho moi byte
    xtime_gen: for i in 0 to 15 generate
        xtime_inst: component AES_XTIME
            port map(
                Xtime_in  => s_in_bytes(i),
                Xtime_out => s_xtime_bytes(i)
            );
    end generate;

    -- Thuc hien nhân ma tran cho 4 cot
    mix_columns_gen: for c in 0 to 3 generate
        -- Chỉ số của 4 byte trong cột hiện tại (đánh theo cột)
        constant b0 : integer := c*4;
        constant b1 : integer := c*4 + 1;
        constant b2 : integer := c*4 + 2;
        constant b3 : integer := c*4 + 3;
    begin
        -- out[0] = (2*in[0]) xor (3*in[1]) xor (1*in[2]) xor (1*in[3])
        DATA_OUT_MIXCOL( (127-b0*8) downto (120-b0*8) ) <= s_xtime_bytes(b0) xor (s_xtime_bytes(b1) xor s_in_bytes(b1)) xor s_in_bytes(b2) xor s_in_bytes(b3);
        
        -- out[1] = (1*in[0]) xor (2*in[1]) xor (3*in[2]) xor (1*in[3])
        DATA_OUT_MIXCOL( (127-b1*8) downto (120-b1*8) ) <= s_in_bytes(b0) xor s_xtime_bytes(b1) xor (s_xtime_bytes(b2) xor s_in_bytes(b2)) xor s_in_bytes(b3);

        -- out[2] = (1*in[0]) xor (1*in[1]) xor (2*in[2]) xor (3*in[3])
        DATA_OUT_MIXCOL( (127-b2*8) downto (120-b2*8) ) <= s_in_bytes(b0) xor s_in_bytes(b1) xor s_xtime_bytes(b2) xor (s_xtime_bytes(b3) xor s_in_bytes(b3));

        -- out[3] = (3*in[0]) xor (1*in[1]) xor (1*in[2]) xor (2*in[3])
        DATA_OUT_MIXCOL( (127-b3*8) downto (120-b3*8) ) <= (s_xtime_bytes(b0) xor s_in_bytes(b0)) xor s_in_bytes(b1) xor s_in_bytes(b2) xor s_xtime_bytes(b3);
    end generate;

end architecture;