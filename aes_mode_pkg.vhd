----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/16/2020 08:58:25 AM
-- Design Name: 
-- Module Name: AES_MODE_PK - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library IEEE;
use IEEE.std_logic_1164.all;

package AES_MODE_PK is

	constant SHIFT_VALID_READY : integer := 4;
    constant SHIFT_VALID_KEY   : integer := 26;
    constant SHIFT_VALID_DONE  : integer := 21;
    constant ROUND_256         : integer := 14;
    constant ROUND_192         : integer := 12;
    constant ROUND_128         : integer := 10;
    constant DATA_WIDTH        : integer := 128;
    constant KEY_WIDTH         : integer := 256;
    constant MODE_128 : std_logic_vector(1 downto 0) := "00";
    constant MODE_192 : std_logic_vector(1 downto 0) := "01";
    constant MODE_256 : std_logic_vector(1 downto 0) := "10";
    
	type keyblock  is array (ROUND_256  downto 0) of std_logic_vector(DATA_WIDTH - 1 downto 0);
	type datablock is array (ROUND_256 downto 0)  of std_logic_vector(DATA_WIDTH - 1 downto 0);
	type keyblock_128 is array (10 downto 0) of std_logic_vector(DATA_WIDTH - 1 downto 0);
	
	component  AES_INV_SUBBYTES is 
    port (
          DATA_IN_INVSUB  : in std_logic_vector (DATA_WIDTH - 1 downto 0);
          DATA_OUT_INVSUB : out std_logic_vector(DATA_WIDTH - 1 downto 0)
          );
    end component;
    
    component AES_INV_SHIFTROWS is
    port (
          DATA_IN_INVSHIFT  : in std_logic_vector (DATA_WIDTH - 1 downto 0);
          DATA_OUT_INVSHIFT : out std_logic_vector (DATA_WIDTH - 1 downto 0)
          );
    end component;
    
    component AES_INV_MIXCOLUM is
    port(
        DATA_IN_INVMIXCOL  : in std_logic_vector (DATA_WIDTH - 1 downto 0);
        DATA_OUT_INVMIXCOL : out std_logic_vector (DATA_WIDTH - 1 downto 0)
        );
    end component;
    
    component AES_INV_ADDROUNDKEY is
    port (
          DATA_IN  : in std_logic_vector (DATA_WIDTH - 1 downto 0);
          KEY_IN   : in std_logic_vector (DATA_WIDTH - 1 downto 0);
          DATA_OUT : out std_logic_vector (DATA_WIDTH - 1 downto 0)
          );
    end component;
    
         component  AES_SUBBYTES is 
        port (
              DATA_IN_SUB  : in std_logic_vector (DATA_WIDTH - 1 downto 0 );
              DATA_OUT_SUB : out std_logic_vector (DATA_WIDTH - 1 downto 0 ));
    end component;
    
    component AES_SHIFTROWS is
        port (
              DATA_IN_SHIFT  : in std_logic_vector(DATA_WIDTH - 1 downto 0 );
              DATA_OUT_SHIFT : out std_logic_vector(DATA_WIDTH - 1 downto 0 ));
    end component;
    
    component  AES_MIXCOLUMNS is
        port (
            DATA_IN_MIXCOL  : in std_logic_vector (DATA_WIDTH - 1 downto 0 );
            DATA_OUT_MIXCOL : out std_logic_vector (DATA_WIDTH - 1 downto 0 )
            );
    end component;
    
    component AES_ADDROUNDKEY is
        port ( 
           DATA_IN  : in std_logic_vector (DATA_WIDTH - 1 downto 0);
           KEY_IN   : in std_logic_vector (DATA_WIDTH - 1 downto 0);
           DATA_OUT : out std_logic_vector (DATA_WIDTH - 1 downto 0));
    end component;
    
end package AES_MODE_PK;
