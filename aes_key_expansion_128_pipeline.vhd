-- File: aes_key_expansion_128_pipeline.vhd

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.AES_MODE_PK.all;

--!
--!  AES‑128 key expansion with simple pipeline.
--!  The original version iterated round by round using an FSM.
--!  Here we split the design into a purely combinational chain and
--!  pipeline registers so that all 10 round keys are produced in
--!  parallel after 10 clock cycles.
--!
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

architecture rtl of AES_KEY_EXPANSION_128_PIPELINE is

    --------------------------------------------------------------------
    --  Components
    --------------------------------------------------------------------
    component AES_SBOX is
        port (
            SBOX_IN  : in  std_logic_vector(7 downto 0);
            SBOX_OUT : out std_logic_vector(7 downto 0)
        );
    end component;

    --------------------------------------------------------------------
    --  Constant Rcon values for rounds 1..10
    --------------------------------------------------------------------
    type rcon_array_t is array (0 to 9) of std_logic_vector(7 downto 0);
    constant RCON_VALUES : rcon_array_t := (
        x"01", x"02", x"04", x"08", x"10",
        x"20", x"40", x"80", x"1B", x"36"
    );

    --------------------------------------------------------------------
    --  Pipeline register bank and valid shift register
    --------------------------------------------------------------------
    signal round_keys_reg : keyblock_128 := (others => (others => '0'));
    signal valid_shreg    : std_logic_vector(10 downto 0) := (others => '0');

    --------------------------------------------------------------------
    --  Signals for combinational stages
    --------------------------------------------------------------------
    type word_array is array (0 to 9) of std_logic_vector(31 downto 0);
    type key_array  is array (0 to 9) of std_logic_vector(127 downto 0);

    signal rot_word    : word_array;
    signal sub_word    : word_array;
    signal temp_word   : word_array;
    signal next_w0     : word_array;
    signal next_w1     : word_array;
    signal next_w2     : word_array;
    signal next_w3     : word_array;
    signal next_key    : key_array;

begin
    --------------------------------------------------------------------
    --  Combinational expansion for each pipeline stage
    --------------------------------------------------------------------
    stage_gen : for i in 0 to 9 generate
        -- Extract previous words from register bank
        constant W0_H : integer := 127;
        constant W0_L : integer := 96;
        constant W1_H : integer := 95;
        constant W1_L : integer := 64;
        constant W2_H : integer := 63;
        constant W2_L : integer := 32;
        constant W3_H : integer := 31;
        constant W3_L : integer := 0;
    begin
        -- RotWord
        rot_word(i) <= round_keys_reg(i)(W3_L+23 downto W3_L) &
                       round_keys_reg(i)(W3_H downto W3_H-7);

        -- SubWord using four SBOXes
        sbox_gen : for j in 0 to 3 generate
            sbox_inst : AES_SBOX
                port map (
                    SBOX_IN  => rot_word(i)(8*j+7 downto 8*j),
                    SBOX_OUT => sub_word(i)(8*j+7 downto 8*j)
                );
        end generate;

        -- Rcon xor
        temp_word(i) <= sub_word(i) xor (RCON_VALUES(i) & x"000000");

        -- Next words
        next_w0(i) <= round_keys_reg(i)(W0_H downto W0_L) xor temp_word(i);
        next_w1(i) <= round_keys_reg(i)(W1_H downto W1_L) xor next_w0(i);
        next_w2(i) <= round_keys_reg(i)(W2_H downto W2_L) xor next_w1(i);
        next_w3(i) <= round_keys_reg(i)(W3_H downto W3_L) xor next_w2(i);

        -- Concatenate for next round key
        next_key(i) <= next_w0(i) & next_w1(i) & next_w2(i) & next_w3(i);
    end generate stage_gen;

    --------------------------------------------------------------------
    --  Sequential pipeline register updates
    --------------------------------------------------------------------
    process (CLK)
    begin
        if rising_edge(CLK) then
            if RESET = '1' then
                round_keys_reg <= (others => (others => '0'));
                valid_shreg    <= (others => '0');
            else
                -- load initial key when valid
                if KEY_VALID = '1' then
                    round_keys_reg(0) <= KEY_IN;
                end if;

                -- propagate through pipeline when data valid
                for k in 0 to 9 loop
                    if valid_shreg(k) = '1' then
                        round_keys_reg(k+1) <= next_key(k);
                    end if;
                end loop;

                -- shift valid register
                valid_shreg(0) <= KEY_VALID;
                for k in 1 to 10 loop
                    valid_shreg(k) <= valid_shreg(k-1);
                end loop;
            end if;
        end if;
    end process;

    ROUND_KEYS_OUT <= round_keys_reg;
    KEYS_READY     <= valid_shreg(10);

end architecture rtl;

