----------------------------------------------------------
-- Author: Do Manh Hung Copyright HTP, 2020
-- Module: AES_ADDROUNDKEY.vhd   
-- Begin Date: 07/10/2020
-- Revision History Date Author Comments
-- 10/10/2020 done
----------------------------------------------------------
-- Purpose:
-- This is the block addroundkey of the Inv aes 128 192 256 design
----------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library work;
use work.AES_MODE_PK.all;

entity AES_ADDROUNDKEY is
    Port (
        DATA_IN  : in std_logic_vector (DATA_WIDTH - 1 downto 0);-- block du lieu 128 bit dau vao 
        KEY_IN   : in std_logic_vector (DATA_WIDTH - 1 downto 0);-- khoa 128 bit dau vao
        DATA_OUT : out std_logic_vector(DATA_WIDTH - 1 downto 0)-- block du lieu ra sau khi AddRoundKey
        );
end entity;

architecture dataflow of AES_ADDROUNDKEY  is
begin

     DATA_OUT <= DATA_IN xor KEY_IN; -- block vao xor voi khoa 128 bit
     
end architecture;     