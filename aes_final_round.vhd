----------------------------------------------------------
-- Module: AES_FINAL_ROUND.vhd
-- Dua trên thiet ke cua: Do Manh Hung
-- Purpose:
-- (SubBytes -> ShiftRows -> AddRoundKey).
----------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;
use work.AES_MODE_PK.all;

entity AES_FINAL_ROUND is
    Port (
        DATA_IN        : in  std_logic_vector(DATA_WIDTH - 1 downto 0); 
        ROUND_KEY_IN   : in  std_logic_vector(DATA_WIDTH - 1 downto 0); 
        DATA_OUT       : out std_logic_vector(DATA_WIDTH - 1 downto 0) 
    );
end entity AES_FINAL_ROUND;
architecture structural of AES_FINAL_ROUND is
	
	-- 1. Khai báo các component 
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
	 
	component AES_ADDROUNDKEY is
		port (
			DATA_IN  : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
            KEY_IN   : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
            DATA_OUT : out std_logic_vector(DATA_WIDTH - 1 downto 0)
        );
    end component;
	
	-- 2 khai báo dây 
	signal sub_to_shift_wire   : std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal shift_to_add_wire   : std_logic_vector(DATA_WIDTH - 1 downto 0);
	
begin
	
	sub_inst: component AES_SUBBYTES
			port map(
				DATA_IN_SUB => DATA_IN,
				DATA_OUT_SUB => sub_to_shift_wire
			);
		
	shift_inst: component AES_SHIFTROWS
        port map (
            DATA_IN_SHIFT  => sub_to_shift_wire,
            DATA_OUT_SHIFT => shift_to_add_wire
        );
	
	addkey_inst: component AES_ADDROUNDKEY
        port map (
            DATA_IN  => shift_to_add_wire,
            KEY_IN   => ROUND_KEY_IN,
            DATA_OUT => DATA_OUT
        );
end architecture;