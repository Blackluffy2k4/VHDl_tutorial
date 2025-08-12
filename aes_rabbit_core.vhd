-- File: aes_rabbit_core.vhd


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;
use work.AES_MODE_PK.all;

-- =================================================================
-- KHAI BÁO ENTITY
-- =================================================================
entity AES_RABBIT_CORE is
    port(
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
end entity AES_RABBIT_CORE;

------------------------------------------------------------------
architecture structural of AES_RABBIT_CORE is

    -- 1. KHAI BÁO CÁC COMPONENT (trong architecture)
    component AES_KEY_EXPANSION_128_PIPELINE is
        port (
            CLK            : in  std_logic;
            RESET          : in  std_logic;
            KEY_IN         : in  std_logic_vector(127 downto 0);
            KEY_VALID      : in  std_logic;
            ROUND_KEYS_OUT : out keyblock_128;
            KEYS_READY     : out std_logic
        );
    end component;

  component AES_CONTROL_FSM_PIPELINE is
        generic (PIPELINE_DEPTH : integer := 12);
        port (
            CLK             : in  std_logic;
            RESET           : in  std_logic;
            DATA_VALID_IN   : in  std_logic;
            DATA_VALID_OUT  : out std_logic;
            PIPELINE_ENABLE : out std_logic
        );
    end component;

    component AES_INITIAL_ADDKEY is
        Port (
            DATA_IN  : in  std_logic_vector(127 downto 0);
            KEY_IN   : in  std_logic_vector(127 downto 0);
            DATA_OUT : out std_logic_vector(127 downto 0)
        );
    end component;

    component AES_ROUND_FUNCTION is
        Port (
            DATA_IN      : in  std_logic_vector(127 downto 0);
            ROUND_KEY_IN : in  std_logic_vector(127 downto 0);
            DATA_OUT     : out std_logic_vector(127 downto 0)
        );
    end component;

    component AES_FINAL_ROUND is
        Port (
            DATA_IN      : in  std_logic_vector(127 downto 0);
            ROUND_KEY_IN : in  std_logic_vector(127 downto 0);
            DATA_OUT     : out std_logic_vector(127 downto 0)
        );
    end component;

    -- 2. KHAI BÁO CÁC TÍN HIEU NOI BO (trong architecture)
    signal s_round_keys      : keyblock_128;
    signal s_pipeline_enable : std_logic;

    -- Mang chua du lieu giua các tang pipeline
    type T_PIPE_ARRAY is array (0 to 11) of std_logic_vector(127 downto 0);
    signal pipe_data_in  : T_PIPE_ARRAY;
    signal pipe_data_out : T_PIPE_ARRAY;


begin

    key_exp_inst: component AES_KEY_EXPANSION_128_PIPELINE
        port map (
            CLK             => CLK,
            RESET           => RESET,
            KEY_IN          => KEY_IN,
            KEY_VALID       => KEY_VALID,
            ROUND_KEYS_OUT  => s_round_keys,
            KEYS_READY      => KEYS_READY
        );

    control_fsm_inst: component AES_CONTROL_FSM_PIPELINE
        port map (
            CLK             => CLK,
            RESET           => RESET,
            DATA_VALID_IN   => DATA_VALID_IN,
            DATA_VALID_OUT  => DATA_VALID_OUT,
            PIPELINE_ENABLE => s_pipeline_enable
        );

    -- 4. DATAPATH 
    
    -- Tang ðau vào
    pipe_data_in(0) <= PLAINTEXT_IN;

    -- Tang 0: Initial AddKey
    initial_addkey_inst: component AES_INITIAL_ADDKEY
        port map (
            DATA_IN  => pipe_data_in(0),
            KEY_IN   => s_round_keys(0),
            DATA_OUT => pipe_data_out(0)
        );

    -- Thanh ghi giua tang 0 và 1
    reg_pipe_0_proc: process(CLK)
    begin
        if rising_edge(CLK) then
            pipe_data_in(1) <= pipe_data_out(0);
        end if;
    end process;

    -- T?ng 1 ðen 9
    Gen_Standard_Rounds: for i in 1 to 9 generate
    begin
        round_func_inst: component AES_ROUND_FUNCTION
            port map (
                DATA_IN      => pipe_data_in(i),
                ROUND_KEY_IN => s_round_keys(i),
                DATA_OUT     => pipe_data_out(i)
            );

        reg_pipe_i_proc: process(CLK)
        begin
            if rising_edge(CLK) then
                pipe_data_in(i + 1) <= pipe_data_out(i);
            end if;
        end process;
    end generate Gen_Standard_Rounds;

    -- Tang 10: (không có MixColumns)
    final_round_inst: component AES_FINAL_ROUND
        port map (
            DATA_IN      => pipe_data_in(10),
            ROUND_KEY_IN => s_round_keys(10),
            DATA_OUT     => pipe_data_out(10)
        );

    -- Thanh ghi giua tang 10 và 11
    reg_pipe_10_proc: process(CLK)
    begin
        if rising_edge(CLK) then
            pipe_data_in(11) <= pipe_data_out(10);
        end if;
    end process;


    CIPHERTEXT_OUT <= pipe_data_in(11);


end architecture structural;
