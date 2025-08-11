----------------------------------------------------------
-- Author: Do Manh Hung Copyright HTP, 2020
-- Module: AES_SUBBYTES.vhd   
-- Begin Date: 07/10/2020
-- Revision History Date Author Comments
-- 10/10/2020 done
----------------------------------------------------------
-- Purpose:
-- This is the block subbytes of the  aes 128 192 256 design
----------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library work;
use work.AES_MODE_PK.all;

entity AES_SUBBYTES is 
    port (
        DATA_IN_SUB  : in std_logic_vector(DATA_WIDTH - 1 downto 0 );
        DATA_OUT_SUB : out std_logic_vector(DATA_WIDTH - 1 downto 0 )
        );
end entity;

architecture behaviour of AES_SUBBYTES is
    component AES_SBOX is
        port (
            SBOX_IN  : in  std_logic_vector(7 downto 0);
            SBOX_OUT : out std_logic_vector(7 downto 0)
        );
    end component;
BEGIN
    sbox_gen0: for i in 0 to 15 generate
        sbox_inst0: component AES_SBOX -- Sửa ở đây
            port map (
                SBOX_IN  => data_in_sub(8*i+7 downto 8*i),
                SBOX_OUT => data_out_sub(8*i+7 downto 8*i)
            );
    end generate sbox_gen0;
    ------------------------------------------------------- 
end architecture;        
         
     