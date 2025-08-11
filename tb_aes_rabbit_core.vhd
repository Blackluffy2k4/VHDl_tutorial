-- File: tb_aes_rabbit_core.vhd
-- Tác giả: AI Assistant
-- Mô tả: Testbench hoàn chỉnh cho aes_rabbit_core, sử dụng vector kiểm thử
--        từ FIPS 197 Appendix C.1 (AES-128).

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.textio.all;
use IEEE.STD_LOGIC_TEXTIO.ALL;

entity tb_aes_rabbit_core is
end entity tb_aes_rabbit_core;

architecture test of tb_aes_rabbit_core is

    -- Hằng số cho chu kỳ clock
    constant CLK_PERIOD : time := 10 ns;

    -- Tín hiệu kết nối đến Unit Under Test (UUT)
    signal tb_clk           : std_logic := '0';
    signal tb_reset         : std_logic;
    signal tb_key_in        : std_logic_vector(127 downto 0);
    signal tb_key_valid     : std_logic;
    signal tb_keys_ready    : std_logic;
    signal tb_plaintext_in  : std_logic_vector(127 downto 0);
    signal tb_data_valid_in : std_logic;
    signal tb_ciphertext_out: std_logic_vector(127 downto 0);
    signal tb_data_valid_out: std_logic;

    -- Hằng số từ FIPS 197, Appendix C.1 (AES-128)
    constant FIPS_KEY       : std_logic_vector(127 downto 0) := x"000102030405060708090a0b0c0d0e0f";
    constant FIPS_PLAINTEXT : std_logic_vector(127 downto 0) := x"00112233445566778899aabbccddeeff";
    constant FIPS_CIPHERTEXT: std_logic_vector(127 downto 0) := x"69c4e0d86a7b0430d8cdb78070b4c55a";

begin

    -- Khởi tạo Unit Under Test (UUT)
    uut: entity work.aes_rabbit_core
        port map (
            CLK             => tb_clk,
            RESET           => tb_reset,
            KEY_IN          => tb_key_in,
            KEY_VALID       => tb_key_valid,
            KEYS_READY      => tb_keys_ready,
            PLAINTEXT_IN    => tb_plaintext_in,
            DATA_VALID_IN   => tb_data_valid_in,
            CIPHERTEXT_OUT  => tb_ciphertext_out,
            DATA_VALID_OUT  => tb_data_valid_out
        );

    -- Process tạo clock
    clk_process: process
    begin
        tb_clk <= '0';
        wait for CLK_PERIOD / 2;
        tb_clk <= '1';
        wait for CLK_PERIOD / 2;
    end process clk_process;

    -- Process chính đieu khiển testbench
    stimulus_process: process
        variable output_line : line;
    begin
        -- =================================================================
        -- Giai đoạn 1: Reset hệ thống
        -- =================================================================
        tb_reset         <= '1';
        tb_key_valid     <= '0';
        tb_data_valid_in <= '0';
        tb_key_in        <= (others => '0');
        tb_plaintext_in  <= (others => '0');
        wait for CLK_PERIOD * 2; -- Giữ reset trong 2 chu kỳ clock

        tb_reset <= '0';
        wait until rising_edge(tb_clk);

        -- =================================================================
        -- Giai đoạn 2: Nạp khóa (Key Loading)
        -- =================================================================
        
        -- Cho cho đến khi module Key Expansion sẵn sàng (KEYS_READY = '1')
        wait until tb_keys_ready = '1' and rising_edge(tb_clk);
        
        -- Cung cấp khóa và tín hiệu valid trong 1 chu kỳ
        tb_key_in    <= FIPS_KEY;
        tb_key_valid <= '1';
        wait until rising_edge(tb_clk);
        
        -- Tắt tín hiệu valid sau 1 chu kỳ
        tb_key_valid <= '0';
        -- Thêm một vài chu kỳ để đảm bảo hệ thống ổn định
        wait for CLK_PERIOD * 2;
        
        -- Cung cấp plaintext và tín hiệu valid trong 1 chu kỳ
        tb_plaintext_in  <= FIPS_PLAINTEXT;
       tb_data_valid_in <= '1';
        
        wait until rising_edge(tb_clk);
        
        -- Tắt tín hiệu valid
         tb_data_valid_in <= '0';
        wait; -- Dừng process này

    end process stimulus_process;

end architecture test;