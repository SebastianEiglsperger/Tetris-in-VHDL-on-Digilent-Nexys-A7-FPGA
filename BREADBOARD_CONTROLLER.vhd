----------------------------------------------------------------------------------
-- Company: OTH Amberg-Weiden
-- Engineer: Sebastian Eiglsperger
-- 
-- Create Date: 06/12/2026 02:01:14 PM
-- Design Name: BREADBOARD_CONTROLLER
-- Module Name: BREADBOARD_CONTROLLER - Behavioral
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
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity BREADBOARD_CONTROLLER is
    Port ( 
        clk : in std_logic;
        
        controller_button_left : out std_logic;
        controller_button_right : out std_logic;
        controller_button_down : out std_logic;
        
        controller_action_right : out std_logic;
        controller_action_left : out std_logic;
        
        pin_head_A2 : in std_logic; -- gelb -> 
        pin_head_A3 : in std_logic; 
        pin_head_A4 : in std_logic;
        pin_head_A7 : in std_logic; -- blau ->
        pin_head_A8 : in std_logic; -- braun ->
        pin_head_A9 : in std_logic; -- orange ->
        pin_head_A10 : in std_logic; -- grau ->
        
        ticks : in std_logic
    );
end BREADBOARD_CONTROLLER;

architecture Behavioral of BREADBOARD_CONTROLLER is
    signal action_left : std_logic := '0';
    signal action_right : std_logic := '0';
    signal button_left : std_logic := '0';
    signal button_right : std_logic := '0';
    signal button_down : std_logic := '0';

begin
    process(clk)
    
    variable reset_counter : integer := 0;
    
    begin
        if rising_edge(clk) then
        
            -- reset nach 3s button halten
            if pin_head_A2 = '1' then
                if ticks = '1' then
                    reset_counter := reset_counter +1;
                end if;
                
                if reset_counter = 1 then
                    action_left <= '1';
                    reset_counter := 0;
                end if;
            else
                action_left <= '0';
                reset_counter := 0;
            end if;
            
            
            if pin_head_A7 = '1' then
                action_right <= '1';
            else
                action_right <= '0';
            end if;
            
            
            if pin_head_A8 = '1' then
                button_left <= '1';
            else
                button_left <= '0';
            end if;
            
            
            if pin_head_A9 = '1' then
                button_down <= '1';
            else
                button_down <= '0';
            end if;
            
            
            if pin_head_A10 = '1' then
                button_right <= '1';
            else
                button_right <= '0';
            end if;
            
        end if; -- rising clk
    end process;
    
    controller_button_left <= button_left;
    controller_button_right <= button_right;
    controller_button_down <= button_down;
    controller_action_left <= action_left;
    controller_action_right <= action_right;
end Behavioral;
