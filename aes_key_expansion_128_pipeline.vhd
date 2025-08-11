-- File: aes_key_expansion_128_pipeline.vhd


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.AES_MODE_PK.all;

entity AES_KEY_EXPANSION_128_PIPELINE is
    port (
        CLK            : in  std_logic;
        RESET          : in  std_logic;
        KEY_IN         : in  std_logic_vector(127 downto 0);
        KEY_VALID      : in  std_logic;
        ROUND_KEYS_OUT : out keyblock_128;
        KEYS_READY     : out std_logic
    );
end entity AES_KEY_EXPANSION_128_PIPELINE;

architecture behavioral of AES_KEY_EXPANSION_128_PIPELINE is

    component AES_SBOX is
        port ( SBOX_IN : in std_logic_vector(7 downto 0); SBOX_OUT : out std_logic_vector(7 downto 0) );
    end component;
    component AES_RCON is
        port ( RCON_I : in std_logic_vector(3 downto 0); RCON_O : out std_logic_vector(7 downto 0) );
    end component;

    type T_FSM_STATE is (S_IDLE, S_CALC);
    signal current_state : T_FSM_STATE;

    signal round_counter  : integer range 0 to 11;
    signal round_keys_reg : keyblock_128;

    -- Tín hi?u cho logic t? h?p
    signal temp_word, rot_word, sub_word_out : std_logic_vector(31 downto 0);
    signal rcon_out       : std_logic_vector(7 downto 0);
    signal rcon_in_signal : std_logic_vector(3 downto 0);
    signal prev_w0, prev_w1, prev_w2, prev_w3 : std_logic_vector(31 downto 0);
    signal next_w0, next_w1, next_w2, next_w3 : std_logic_vector(31 downto 0);

begin
    -- Gán ðau ra truc tiep tu thanh ghi
    ROUND_KEYS_OUT <= round_keys_reg;

    -- =============================================================
    -- 1.(COMBINATIONAL LOGIC)
    -- =============================================================
    -- Lay các word cua khóa vong trýoc ðó tu thanh ghi
    prev_w0 <= round_keys_reg(round_counter - 1)(127 downto 96) when round_counter > 0 else (others => '0');
    prev_w1 <= round_keys_reg(round_counter - 1)(95 downto 64)  when round_counter > 0 else (others => '0');
    prev_w2 <= round_keys_reg(round_counter - 1)(63 downto 32)  when round_counter > 0 else (others => '0');
    prev_w3 <= round_keys_reg(round_counter - 1)(31 downto 0)   when round_counter > 0 else (others => '0');

    -- RotWord
    rot_word <= prev_w3(23 downto 0) & prev_w3(31 downto 24);

    -- SubWord
    sbox_gen: for i in 0 to 3 generate
        sbox_inst: component AES_SBOX port map (rot_word(8*i + 7 downto 8*i), sub_word_out(8*i + 7 downto 8*i));
    end generate;

    -- Rcon
    rcon_in_signal <= std_logic_vector(to_unsigned(round_counter, 4));
    rcon_inst: component AES_RCON port map (rcon_in_signal, rcon_out);

    -- temp_word
    temp_word <= sub_word_out xor (rcon_out & x"000000");

    -- Tính các word tiep theo
    next_w0 <= prev_w0 xor temp_word;
    next_w1 <= prev_w1 xor next_w0;
    next_w2 <= prev_w2 xor next_w1;
    next_w3 <= prev_w3 xor next_w2;


    -- =============================================================
    -- 2. (SEQUENTIAL LOGIC)
    -- =============================================================
    -- Process này xu ly tat ca các thanh ghi và trang thái cua FSM.
    fsm_proc: process(CLK)
    begin
        if rising_edge(CLK) then
            if RESET = '1' then
                current_state  <= S_IDLE;
                KEYS_READY     <= '1';
                round_counter  <= 0;
                round_keys_reg <= (others => (others => '0'));
            else
                case current_state is
                    when S_IDLE =>
                        KEYS_READY <= '1';
                        if KEY_VALID = '1' then
                            -- nap khóa goc và chuyen trang thái
                            round_keys_reg(0) <= KEY_IN;
                            round_counter     <= 1;
                            KEYS_READY        <= '0';
                            current_state     <= S_CALC;
                        end if;

                    when S_CALC =>
                        -- Lýu khóa vong vua ðýoc tính toán 
                        round_keys_reg(round_counter) <= next_w0 & next_w1 & next_w2 & next_w3;

                        -- Kiem tra 
                        if round_counter = 10 then
                            current_state <= S_IDLE;
                          
                        else
                            round_counter <= round_counter + 1;
                        end if;
                end case;
            end if;
        end if;
    end process fsm_proc;

end architecture behavioral;