----------------------------------------------------------
-- Module: AES_CONTROL_FSM_PIPELINE.vhd
----------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity AES_CONTROL_FSM_PIPELINE is
    generic (
        PIPELINE_DEPTH : integer := 11 --  (11 thanh ghi cho AES-128)
    );
    port (
        CLK             : in  std_logic;
        RESET           : in  std_logic;
        DATA_VALID_IN   : in  std_logic; -- B�o c� plaintext 
        DATA_VALID_OUT  : out std_logic; -- B�o c� ciphertext 
        PIPELINE_ENABLE : out std_logic  -- T�n hieu cho ph�p hoat �ong cua c�c thanh ghi
    );
end entity AES_CONTROL_FSM_PIPELINE;

architecture behavioral of AES_CONTROL_FSM_PIPELINE is

    -- Thanh ghi dich 
    signal valid_shifter : std_logic_vector(PIPELINE_DEPTH - 1 downto 0) := (others => '0');

 
    constant ZEROS : std_logic_vector(PIPELINE_DEPTH - 1 downto 0) := (others => '0');

begin

    -- Process ch�nh �e dich chuyen bit valid
    valid_delay_proc: process(CLK, RESET)
    begin
        if RESET = '1' then
            valid_shifter <= (others => '0');
        elsif rising_edge(CLK) then
            -- Dich phai v� ��a bit valid moi v�o
            valid_shifter <= valid_shifter(PIPELINE_DEPTH - 2 downto 0) & DATA_VALID_IN;
        end if;
    end process;

    -- �au ra valid l� bit cuoi c�ng cua thanh ghi dich
    DATA_VALID_OUT <= valid_shifter(PIPELINE_DEPTH - 1);


    PIPELINE_ENABLE <= '1' when valid_shifter /= ZEROS else '0';

end architecture behavioral;