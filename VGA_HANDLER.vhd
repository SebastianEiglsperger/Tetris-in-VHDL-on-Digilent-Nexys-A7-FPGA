----------------------------------------------------------------------------------
-- Company: OTH Amberg-Weiden
-- Engineer: Sebastian Eiglsperger
-- 
-- Create Date: 04/25/2026 05:14:39 PM
-- Design Name: VGA_handler.vhd
-- Module Name: VGA_handler - Behavioral
-- Project Name: Spielkonsole_VHDL
-- Target Devices: Nexys A7 / Artix-7 100Tcsg324
-- Tool Versions: 
-- Description: 
-- FINGER WEG
--
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Warum nicht 1920x1080?
-- 640 + 16 + 96 + 48 = 800
-- 480 + 11 + 2 + 9 = 524
-- 800 * 524 = 419200 Pixel
-- Jeder Systemtakt ein Pixel bedeutet bei 60Hz:
-- 60 * 419200 = 25152000 Hz
-- Hardware Oszillator von Nexys 7 gibt nur 100 MHz her, für 1920x1080 60 Hz benötigen wir 148 MHz
-- Möglich durch PLL, wird vielleicht noch nachgereicht
    
---------------------------------------------------------------------------------- 


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity VGA_handler is
    Port (
         VGA_R : out std_logic_vector(3 downto 0) := (others => '0');
         VGA_G : out std_logic_vector(3 downto 0) := (others => '0');
         VGA_B : out std_logic_vector(3 downto 0) := (others => '0');
         
         CLK : in std_logic;
         VGA_VS : out std_logic;
         VGA_HS : out std_logic;
         
         reset : in std_logic; -- RESET BUTTON
         
         -- Aufrufbarkeit für andere Dateien
         xPix : out unsigned(10 downto 0);
         yPix : out unsigned(10 downto 0);
         video_on : out std_logic;
         r_in : in std_logic_vector(3 downto 0);
         g_in : in std_logic_vector(3 downto 0);
         b_in : in std_logic_vector(3 downto 0)
    );
end VGA_handler;

architecture Behavioral of VGA_handler is
    -- Signals, Types
    signal V_counter : unsigned (10 downto 0) := (others => '0'); -- 2048
    signal H_counter : unsigned (10 downto 0) := (others => '0'); -- 2048
    signal video_on_i : std_logic := '0'; -- wird gesetzt, wenn ich mich im tatsächlichen Bildbereich befinde
    
    
    -- Constants - VGA 640x480 - 60Hz
    constant HD : integer := 640; -- actual display zone
    constant HF : integer := 16; -- front porch, black
    constant HR : integer := 96; -- refresh = t_HSyncPulse
    constant HB : integer := 48; -- back porch, black
    
    constant VD : integer := 480; -- actual display zone
    constant VF : integer := 10; -- fron porch, black -- von 11 als Fix für "Shadow Lines"
    constant VR : integer := 2; -- refresh = t_VSyncPulse
    constant VB : integer := 33;  -- back porch, black -- von 33 als Fix für "Shadow Lines"
    

begin
    
    main_vga_handler : process (CLK, reset)
    begin
        if reset = '1' then -- warum eigentlich
            V_counter <= (others => '0');
            H_counter <= (others => '0');
            
        elsif rising_edge(CLK) then                
            if H_counter < (HD + HF + HR + HB)-1 then
                H_counter <= H_counter +1;
            
            else
                H_counter <= (others => '0');
                
                if V_counter < (VD + VF + VR + VB)-1 then
                    V_counter <= V_counter +1;
                
                else
                    V_counter <= (others => '0');
                
                end if;
            end if;
        end if;
    end process;
    
    ---------------------------------------------------------------------------
    ---------------------------------------------------------------------------    
    -- VSync und HSync active LOW
    VGA_HS <= '0' when (H_counter >= (HD + HF) and H_counter < (HD + HF + HR)) else '1';
    VGA_VS <= '0' when (V_counter >= (VD + VF) and V_counter < (VD + VF + VR)) else '1';
    video_on_i <= '1' when (H_counter < HD and V_counter < VD) else '0'; -- Sichtbarer Bereich
    
    ---------------------------------------------------------------------------
    ---------------------------------------------------------------------------
    -- Farbverlauf, von extern steuerbar
    VGA_R <= r_in when video_on_i = '1' else "0000";
    VGA_G <= g_in when video_on_i = '1' else "0000";
    VGA_B <= b_in when video_on_i = '1' else "0000";
    
    -- Koordinaten, von extern steuerbar
    xPix <= H_counter;
    yPix <= V_counter;
    video_on <= video_on_i;
    
    
end Behavioral;
