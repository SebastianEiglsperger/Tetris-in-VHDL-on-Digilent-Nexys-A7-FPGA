----------------------------------------------------------------------------------
-- Company: OTH Amberg-Weiden
-- Engineer: Sebastian Eiglsperger
-- 
-- Create Date: 05/22/2026 05:15:54 PM
-- Design Name: timer
-- Module Name: timer - Behavioral
-- Project Name: Spielkonsole_VHDL
-- Target Devices: Nexys A7 / Artix-7 100Tcsg324
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- Diese vhd Datei ermöglich die verwendung von simplen Timern
--
-- TODO:
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity timer is
    Port ( 
        clk : in std_logic;
        reset : in std_logic;
        
        ticks : out std_logic;
        tickms : out std_logic
    );
end timer;

architecture Behavioral of timer is
    -- Signals, Types
    signal counters    :   unsigned(26 downto 0) := (others => '0');
    signal counterms   :   unsigned(16 downto 0) := (others => '0');

    -- Constants
    constant CNTs  :   unsigned(24 downto 0) := to_unsigned(25173000-1, 25);
    constant CNTms :   unsigned(14 downto 0) := to_unsigned(25173-1,15);
    
    
begin

process(clk, reset)
begin
    if reset = '1' then
        counters <= (others => '0');
        ticks <= '0';
        
        counterms <= (others => '0');
        tickms <= '0';
    
    elsif rising_edge(clk) then
    
------------------------------------------------------------------------
--- 1sec
------------------------------------------------------------------------
        
        if counters = CNTs then
            counters <= (others => '0');
            ticks <= '1';
            
        else
            counters <= counters+1;
            ticks <= '0';
        end if;
        
------------------------------------------------------------------------
--- 1msec
------------------------------------------------------------------------
        
        if counterms = CNTms then
            counterms <= (others => '0');
            tickms <= '1';
        else
            counterms <= counterms +1;
            tickms <= '0';
        end if;
        
------------------------------------------------------------------------
------------------------------------------------------------------------        
        
    end if;
end process;
end Behavioral;
