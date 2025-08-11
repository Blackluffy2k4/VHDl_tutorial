-- File: aes_top.vhd
-- Tác giả: AI Assistant
-- Mô tả: Top-level cho thiết kế AES, tích hợp VIO và ILA để chạy trên bo mạch Artix-7.
--        Điều khiển quá trình nạp khóa và plaintext, sau đó chờ kết quả.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity aes_top is
    port (
        CLK_50M     : in  std_logic;
        SYS_RESET_N : in  std_logic
    );
end entity aes_top;

architecture Behavioral of aes_top is

    -- Tín hiệu nội bộ
    signal clk          : std_logic;
    signal reset        : std_logic;

    -- Tín hiệu kết nối đến AES Core
    signal core_key_in        : std_logic_vector(127 downto 0);
    signal core_key_valid     : std_logic;
    signal core_keys_ready    : std_logic;
    signal core_plaintext_in  : std_logic_vector(127 downto 0);
    signal core_data_valid_in : std_logic;
    signal core_ciphertext_out: std_logic_vector(127 downto 0);
    signal core_data_valid_out: std_logic;

    -- Tín hiệu từ VIO
    signal vio_plaintext      : std_logic_vector(127 downto 0);
    signal vio_key            : std_logic_vector(127 downto 0);
    signal vio_start_encrypt  : std_logic_vector(0 downto 0);

    -- FSM điều khiển
    type T_FSM_STATE is (S_IDLE, S_LOAD_KEY, S_WAIT_KEY, S_LOAD_DATA, S_ENCRYPTING, S_DONE);
    signal current_state : T_FSM_STATE := S_IDLE;

    -- Component cho AES Core
    component aes_rabbit_core is
        port (
            CLK             : in  std_logic;
            RESET           : in  std_logic;
            KEY_IN          : in  std_logic_vector(127 downto 0);
            KEY_VALID       : in  std_logic;
            KEYS_READY      : out std_logic;
            PLAINTEXT_IN    : in  std_logic_vector(127 downto 0);
            DATA_VALID_IN   : in  std_logic;
            CIPHERTEXT_OUT  : out std_logic_vector(127 downto 0);
            DATA_VALID_OUT  : out std_logic
        );
    end component;

    -- Component cho VIO
    component vio_aes_input is
        port (
            clk         : in  std_logic;
            probe_in0   : in  std_logic_vector(127 downto 0); -- plaintext
            probe_in1   : in  std_logic_vector(127 downto 0); -- key
            probe_out0  : out std_logic_vector(0 downto 0)    -- start_encrypt
        );
    end component;

    -- Component cho ILA
    component ila_aes_debug is
        port (
            clk         : in  std_logic;
            probe0      : in  std_logic_vector(127 downto 0); -- ciphertext_out
            probe1      : in  std_logic_vector(127 downto 0); -- plaintext_in
            probe2      : in  std_logic_vector(127 downto 0); -- key_in
            probe3      : in  std_logic_vector(0 downto 0);   -- data_valid_out
            probe4      : in  std_logic_vector(0 downto 0);   -- keys_ready
            probe5      : in  std_logic_vector(1 downto 0)    -- FSM state
        );
    end component;
    
    -- Tín hiệu để debug FSM trên ILA
    signal fsm_state_debug : std_logic_vector(1 downto 0);

begin

    -- Gán tín hiệu clock và reset (reset tích cực mức cao)
    clk   <= CLK_50M;
    reset <= not SYS_RESET_N;

    -- Khởi tạo AES Core
    aes_core_inst: component aes_rabbit_core
        port map (
            CLK             => clk,
            RESET           => reset,
            KEY_IN          => core_key_in,
            KEY_VALID       => core_key_valid,
            KEYS_READY      => core_keys_ready,
            PLAINTEXT_IN    => core_plaintext_in,
            DATA_VALID_IN   => core_data_valid_in,
            CIPHERTEXT_OUT  => core_ciphertext_out,
            DATA_VALID_OUT  => core_data_valid_out
        );

    -- Khởi tạo VIO
    vio_inst: component vio_aes_input
        port map (
            clk         => clk,
            probe_in0   => vio_plaintext,
            probe_in1   => vio_key,
            probe_out0  => vio_start_encrypt
        );

    -- Khởi tạo ILA
    ila_inst: component ila_aes_debug
        port map (
            clk         => clk,
            probe0      => core_ciphertext_out,
            probe1      => core_plaintext_in,
            probe2      => core_key_in,
            probe3(0)   => core_data_valid_out,
            probe4(0)   => core_keys_ready,
            probe5      => fsm_state_debug
        );

    -- FSM điều khiển quá trình
    fsm_proc: process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                current_state <= S_IDLE;
                core_key_valid <= '0';
                core_data_valid_in <= '0';
                core_key_in <= (others => '0');
                core_plaintext_in <= (others => '0');
            else
                -- Gán mặc định
                core_key_valid <= '0';
                core_data_valid_in <= '0';

                case current_state is
                    when S_IDLE =>
                        -- Chờ nút 'start_encrypt' từ VIO được nhấn
                        if vio_start_encrypt(0) = '1' then
                            current_state <= S_LOAD_KEY;
                        end if;

                    when S_LOAD_KEY =>
                        -- Chờ module key expansion sẵn sàng
                        if core_keys_ready = '1' then
                            -- Nạp khóa từ VIO và kích hoạt valid trong 1 chu kỳ
                            core_key_in <= vio_key;
                            core_key_valid <= '1';
                            current_state <= S_WAIT_KEY;
                        end if;

                    when S_WAIT_KEY =>
                        -- Chờ cho key expansion hoàn tất (keys_ready lên '1' lại)
                        if core_keys_ready = '1' then
                            current_state <= S_LOAD_DATA;
                        end if;

                    when S_LOAD_DATA =>
                        -- Nạp plaintext từ VIO và kích hoạt valid trong 1 chu kỳ
                        core_plaintext_in <= vio_plaintext;
                        core_data_valid_in <= '1';
                        current_state <= S_ENCRYPTING;

                    when S_ENCRYPTING =>
                        -- Chờ cho đến khi có kết quả đầu ra
                        if core_data_valid_out = '1' then
                            current_state <= S_DONE;
                        end if;

                    when S_DONE =>
                        -- Giữ trạng thái này. Để bắt đầu lại, người dùng
                        -- phải tắt và bật lại nút 'start_encrypt' trên VIO,
                        -- hoặc nhấn reset.
                        if vio_start_encrypt(0) = '0' then
                            current_state <= S_IDLE;
                        end if;

                end case;
            end if;
        end if;
    end process fsm_proc;
    
    -- Gán tín hiệu debug cho ILA
    fsm_state_debug <= "00" when current_state = S_IDLE else
                       "01" when current_state = S_LOAD_KEY or current_state = S_WAIT_KEY else
                       "10" when current_state = S_LOAD_DATA or current_state = S_ENCRYPTING else
                       "11"; -- S_DONE

end architecture Behavioral;