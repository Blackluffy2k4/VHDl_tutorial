----------------------------------------------------------
-- Author: Do Manh Hung Copyright HTP, 2020
-- Module: aes_rcon.vhd   
-- Begin Date: 20/09/2020
-- Revision History Date Author Comments
-- 10/10/2020 Do Manh Hung Created
-- 22/10/2020 Do Manh Hung edit style code 
----------------------------------------------------------
-- Purpose:
-- This is the aes_rcon design of the aes 128 192 256 design
----------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity AES_RCON is
    port ( 
        RCON_I : in std_logic_vector(3 downto 0);
        RCON_O : out std_logic_vector(7 downto 0)
        );
end entity;
architecture dataflow of AES_RCON is

begin
---------------------Bang tra RCON---------------------------------
    with RCON_I select
        RCON_O <= x"00" when "0000",
            x"01" when "0001",
            x"02" when "0010",
            x"04" when "0011",
            x"08" when "0100",
            x"10" when "0101",
            x"20" when "0110",
            x"40" when "0111",
		    x"80" when "1000",
		    x"1b" when "1001",
		    x"36" when "1010",
            x"00" when others;
-----------------------------------------------------------------             
end architecture;             
                 
                   