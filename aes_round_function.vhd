----------------------------------------------------------
-- Cố vấn kỹ thuật: AI Assistant
-- Module: AES_ROUND_FUNCTION.vhd
-- Dựa trên thiết kế của: Do Manh Hung
-- Purpose:
-- Thực hiện một vòng mã hóa AES chuẩn (SubBytes -> ShiftRows ->
-- MixColumns -> AddRoundKey). Dùng trong các tầng pipeline.
-- Đây là logic tổ hợp thuần túy.
----------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;
use work.AES_MODE_PK.all;

entity AES_ROUND_FUNCTION is
    Port (
        DATA_IN        : in  std_logic_vector(DATA_WIDTH - 1 downto 0); -- Dữ liệu từ tầng pipeline trước
        ROUND_KEY_IN   : in  std_logic_vector(DATA_WIDTH - 1 downto 0); -- Khóa con cho vòng này
        DATA_OUT       : out std_logic_vector(DATA_WIDTH - 1 downto 0)  -- Dữ liệu ra cho tầng pipeline sau
    );
end entity AES_ROUND_FUNCTION;

architecture structural of AES_ROUND_FUNCTION is

    -- 1. Khai báo các component cần thiết (lấy từ các file bạn đã cung cấp)
    component AES_SUBBYTES is
        port (
            DATA_IN_SUB  : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
            DATA_OUT_SUB : out std_logic_vector(DATA_WIDTH - 1 downto 0)
        );
    end component;

    component AES_SHIFTROWS is
        port (
            DATA_IN_SHIFT  : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
            DATA_OUT_SHIFT : out std_logic_vector(DATA_WIDTH - 1 downto 0)
        );
    end component;

    component AES_MIXCOLUMNS is
        port (
            DATA_IN_MIXCOL  : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
            DATA_OUT_MIXCOL : out std_logic_vector(DATA_WIDTH - 1 downto 0)
        );
    end component;

    component AES_ADDROUNDKEY is
        port (
            DATA_IN  : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
            KEY_IN   : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
            DATA_OUT : out std_logic_vector(DATA_WIDTH - 1 downto 0)
        );
    end component;

    -- 2. Khai báo các "dây nối" trung gian
    signal sub_to_shift_wire   : std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal shift_to_mix_wire   : std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal mix_to_add_wire     : std_logic_vector(DATA_WIDTH - 1 downto 0);

begin

    -- 3. Tạo bản sao và nối các khối lại với nhau thành một chuỗi
    
    -- Tầng 1: SubBytes
    sub_inst: component AES_SUBBYTES
        port map (
            DATA_IN_SUB  => DATA_IN,
            DATA_OUT_SUB => sub_to_shift_wire
        );

    -- Tầng 2: ShiftRows
    shift_inst: component AES_SHIFTROWS
        port map (
            DATA_IN_SHIFT  => sub_to_shift_wire,
            DATA_OUT_SHIFT => shift_to_mix_wire
        );

    -- Tầng 3: MixColumns
    mix_inst: component AES_MIXCOLUMNS
        port map (
            DATA_IN_MIXCOL  => shift_to_mix_wire,
            DATA_OUT_MIXCOL => mix_to_add_wire
        );

    -- Tầng 4: AddRoundKey
    addkey_inst: component AES_ADDROUNDKEY
        port map (
            DATA_IN  => mix_to_add_wire,
            KEY_IN   => ROUND_KEY_IN,
            DATA_OUT => DATA_OUT
        );

end architecture structural;