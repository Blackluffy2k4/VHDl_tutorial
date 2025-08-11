----------------------------------------------------------
-- Cố vấn kỹ thuật: AI Assistant
-- Module: AES_INITIAL_ADDKEY.vhd
-- Dựa trên thiết kế của: Do Manh Hung
-- Purpose:
-- Thực hiện bước AddRoundKey ban đầu cho kiến trúc pipeline.
-- Đây là logic tổ hợp thuần túy.
----------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;
use work.AES_MODE_PK.all;

entity AES_INITIAL_ADDKEY is
    Port (
        DATA_IN  : in  std_logic_vector(DATA_WIDTH - 1 downto 0); -- Plaintext
        KEY_IN   : in  std_logic_vector(DATA_WIDTH - 1 downto 0); -- Round Key 0
        DATA_OUT : out std_logic_vector(DATA_WIDTH - 1 downto 0)  -- Kết quả sau khi XOR
    );
end entity AES_INITIAL_ADDKEY;

architecture structural of AES_INITIAL_ADDKEY is

    -- Khai báo component AES_ADDROUNDKEY đã có sẵn
    component AES_ADDROUNDKEY is
        Port (
            DATA_IN  : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
            KEY_IN   : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
            DATA_OUT : out std_logic_vector(DATA_WIDTH - 1 downto 0)
        );
    end component;

begin

    -- Tạo một bản sao của AES_ADDROUNDKEY và nối các cổng
    add_key_inst: component AES_ADDROUNDKEY
        port map (
            DATA_IN  => DATA_IN,
            KEY_IN   => KEY_IN,
            DATA_OUT => DATA_OUT
        );

end architecture structural;