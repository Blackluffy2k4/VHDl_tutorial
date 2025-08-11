----------------------------------------------------------
-- Author: Do Manh Hung Copyright HTP, 2020
-- Module: AES_XTIME.vhd   
-- Begin Date: 07/10/2020
-- Revision History Date Author Comments
-- 10/10/2020 done
----------------------------------------------------------
-- Purpose:
-- This is the block Xtime of the aes 128 192 256 design
----------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity AES_XTIME is
    port ( 
        XTIME_IN  : in std_logic_vector(7 downto 0);
        XTIME_OUT : out std_logic_vector(7 downto 0)
        );
end entity;

architecture rtl of AES_XTIME is
    signal temp : std_logic_vector(7 downto 0);

BEGIN

  temp <= XTIME_IN(6 downto 0) & '0';
  with XTIME_IN(7) select
      XTIME_OUT <= temp xor x"1b" when '1' ,
                   temp           when others;
                       
end architecture;                       