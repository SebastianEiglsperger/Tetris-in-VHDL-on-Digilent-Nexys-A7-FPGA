----------------------------------------------------------------------------------
-- Company: OTH Amberg-Weiden
-- Engineer: Sebastian Eiglsperger
-- 
-- Create Date: 04/26/2026 06:32:27 PM
-- Design Name: TOP.vhd
-- Module Name: TOP - Behavioral
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
-- Top-Layer-Datei: Hier werden alle .vhd Dateien mit dem VGA_Handler verbunden
-- Das heißt, hier kommen alle port maps hin
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TOP is
    Port(
        CLK100MHZ : in std_logic;
        
        BTNC : in std_logic;
        BTNR : in std_logic;
        BTNL : in std_logic;
        BTNU : in std_logic;
        BTND : in std_logic;
        
        VGA_HS : out std_logic;
        VGA_VS : out std_logic;
        
        VGA_R : out std_logic_vector(3 downto 0);
        VGA_G : out std_logic_vector(3 downto 0);
        VGA_B : out std_logic_vector(3 downto 0);
        
        SW15 : in std_logic; -- erster Switch ganz links, beide States haben eigenen Port
        
        -- Pmod Header Pin 1 - 4 // 5=GND 6=3V3 // 7 - 10 // 11=GND 12=3V3
        JA1 : out std_logic; -- C17 /Pin 1 -> GRÜN / PWM TONE
        JA2 : in std_logic; -- D18 / DATA - Lioncast -> GELB
        JA3 : in std_logic; -- E18
        JA4 : in std_logic; -- G17
        JA7 : in std_logic; -- D17 -> BLAU
        JA8 : in std_logic; -- E17 -> BRAUN
        JA9 : in std_logic; -- F18 / CLOCK PIN - Lioncast -> ORNAGE
        JA10 : in std_logic -- G18 /Pin 10 -> GRAU
    );
end TOP;

architecture Behavioral of TOP is
    -- CLOCK WIZARD für echte ~25.175MHz
    component clk_wiz_0
        port (
            clk_out1 : out std_logic;
            reset    : in  std_logic;
            locked   : out std_logic;
            clk_in1  : in  std_logic
        );
    end component;
    
    
    -- Signals, Types
    signal px : unsigned (10 downto 0);
    signal py : unsigned (10 downto 0);
    signal vid_on :std_logic;
    signal r, g, b : std_logic_vector(3 downto 0);
    
    signal ticks : std_logic;
    signal tickms : std_logic;
    
    signal CLK_WIZ : std_logic;
    
--    signal s_joy_left : std_logic;
--    signal s_joy_right : std_logic;
--    signal s_joy_up : std_logic;
--    signal s_joy_down : std_logic;
    
--    signal s_button_L1 : std_logic;
--    signal s_button_L2 : std_logic;
--    signal s_button_square : std_logic;
--    signal s_button_cross : std_logic;

    signal s_con_button_left : std_logic;
    signal s_con_button_right : std_logic;
    signal s_con_button_down : std_logic;
    
    
    signal s_con_action_right : std_logic;
    signal s_con_action_left : std_logic;
    
    -- Constants
    
    
begin

    CLK_INST : clk_wiz_0
    port map(
        clk_out1 => CLK_WIZ,
        reset    => '0',
        locked   => open,
        clk_in1  => CLK100MHZ
    );


    VGA_HANDLER_instantiate : entity work.VGA_handler -- FINGER WEG
        port map(
            CLK => CLK_WIZ,
            reset => BTNC,
            VGA_HS => VGA_HS,
            VGA_VS => VGA_VS,
            VGA_R => VGA_R,
            VGA_G => VGA_G,
            VGA_B => VGA_B,
            xPix => px,
            yPix => py,
            video_on => vid_on,
            r_in => r,
            g_in => g,
            b_in => b
        );
        
    TIMER_INST: entity work.timer
        port map(
            clk => CLK_WIZ,
            reset => BTNC,
            
            ticks => ticks,
            tickms => tickms
        );
        
     BREADBOARD_CONTROLLER_INST : entity work.BREADBOARD_CONTROLLER
        port map(
            clk => CLK_WIZ,
            controller_button_left => s_con_button_left,
            controller_button_right => s_con_button_right,
            controller_button_down => s_con_button_down,
            
            ticks => ticks,
            
            controller_action_right => s_con_action_right,
            controller_action_left => s_con_action_left,
            
            pin_head_A2 => JA2,
            pin_head_A3 => JA3,
            pin_head_A4 => JA4,
            pin_head_A7 => JA7,
            pin_head_A8 => JA8,
            pin_head_A9 => JA9,
            pin_head_A10 => JA10
        );
        
--    LIONCAST_ARCADE_STICK_INST: entity work.LIONCAST_ARCADE_STICK
--        port map(
--            clk => CLK_WIZ,
--            DATA_PIN => JA2,
--            CLK_PIN => JA9,
            
--            joy_left => s_joy_left,
--            joy_right => s_joy_right,
--            joy_up => s_joy_up,
--            joy_down => s_joy_down,
            
--            btn_L1 => s_button_L1,
--            btn_L2 => s_button_L2,
--            btn_square => s_button_square,
--            btn_cross => s_button_cross
--        );

    TONE_INST : entity work.TONE
        port map(
            clk => CLK100MHZ,
            reset => BTNC,
            
            buzzer => JA1,
            
            tone_ON => SW15
        );
        
        
    TETRIS_INST : entity work.TETRIS
        port map(
            clk => CLK_WIZ,
            p_reset => BTNC,
            
            xPix => px,
            yPix => py,
            video_on => vid_on,
            VGA_R => r,
            VGA_G => g,
            VGA_B => b,
            
            ticks => ticks,
            tickms => tickms,
            
            btn_left => BTNL,
            btn_right => BTNR,
            btn_down => BTND,
            btn_rotate => BTNU,
            
--            joy_btn_left => s_joy_left,
--            joy_btn_right =>  s_joy_right,
--            joy_btn_down =>  s_joy_down,
            
--            joy_btn_cross => s_button_cross,
--            joy_btn_square => s_button_square
            
            con_move_left => s_con_button_left,
            con_move_right => s_con_button_right,
            con_move_down => s_con_button_down,
            con_action_right => s_con_action_right,
            con_action_left => s_con_action_left
        );
        

        
            
    -- Aktuell muss das Spiel in dem Bitstream "gewählt" werden, indem man es hier eben austauscht/ausklammert.
    -- Später soll das verallgemeinert werden und in GAME_SELECTOR.vhd per Buttonclick gewählt werden.
    -- Dadurch können alle Spiele in einem einzigen Bitstream übertragen werden.
--    GAME_GRAPHICS_EXAMPLE_instantiate : entity work.GAME_GRAPHICS_EXAMPLE
--        port map(
--            xPix => px,
--            yPix => py,
--            video_on => vid_on,
--            VGA_R => r,
--            VGA_G => g,
--            VGA_B => b,
            
--            ticks => ticks,
--            tickms => tickms,
--            clk => CLK100MHZ
--        );
                
end Behavioral;
