----------------------------------------------------------------------------------
-- Company: OTH Amberg-Weiden
-- Engineer: Sebastian Eiglsperger
-- 
-- Create Date: 05/26/2026 11:53:24 AM
-- Design Name: TETRIS
-- Module Name: TETRIS - Behavioral
-- Project Name: Spielkonsole_VHDL
-- Target Devices: Nexys A7 / Artix-7 100Tcsg324
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- Siehe auch tetris_figures_pkg.vhd
-- zu finden im Sources Fenster, unten Neben Hierarchy und IP Sources steht "Libraries", evtl. muss nach rechts gescrollt werden! Ist leicht zu übersehen.
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
-- TODO:
-- Input (Joystick)
----------------------------------------------------------------------------------



----------------------------------------------------------------------------------

----------------------- HEADER FILE OF GAME : TETRIS -----------------------------

----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.tetris_figures_pkg.all;

entity TETRIS is
    Port(
        clk     : in std_logic;
        p_reset   : in std_logic;
        
        xPix    : in unsigned (10 downto 0);
        yPix    : in unsigned (10 downto 0 );
        video_on    : in std_logic;
        VGA_R   : out std_logic_vector(3 downto 0);
        VGA_G   : out std_logic_vector(3 downto 0);
        VGA_B   : out std_logic_vector(3 downto 0);
        
        tickms  : in std_logic;
        ticks   : in std_logic;
        
        btn_left    : in std_logic;
        btn_right   : in std_logic;
        btn_down    : in std_logic;
        btn_rotate  : in std_logic;
        
        con_move_left : in std_logic;
        con_move_right : in std_logic;
        con_move_down : in std_logic;
        con_action_left : in std_logic;
        con_action_right : in std_logic
        
--        joy_btn_left : in std_logic;
--        joy_btn_right : in std_logic;
--        joy_btn_down : in std_logic;
        
--        joy_btn_cross : in std_logic; -- ROTATE
--        joy_btn_square : in std_logic -- RESET

    );
end TETRIS;

architecture Behavioral of TETRIS is
    -- Signals, Types
    signal s_piece_x : integer;
    signal s_piece_y : integer;
    
    signal s_current_piece : integer range 0 to 6;
    signal s_current_rotation : integer range 0 to 3;
    
    signal s_board    : board_matrix := (others => ( others => 0));
    
    signal s_game_over : std_logic;
    signal s_score : integer range 0 to 999999 := 0;
    signal s_seconds : integer;
    signal s_current_game_level : integer;
    signal s_next_piece : integer;

begin  
    TETRIS_GRAPHICS_INST : entity work.TETRIS_GRAPHICS
        port map(
            clk => clk,
            reset => p_reset,
            xPix => xPix,
            yPix => yPix,
            video_on => video_on,
            
            piece_x => s_piece_x,
            piece_y => s_piece_y,
            
            current_rotation => s_current_rotation,
            current_piece => s_current_piece,
            next_piece => s_next_piece,
            
            board => s_board,
            
            VGA_R => VGA_R,
            VGA_G => VGA_G,
            VGA_B => VGA_B,
            
            tickms => tickms,
            ticks => ticks,
            
            game_over => s_game_over,
            score => s_score,
            current_game_level => s_current_game_level,
            
--            joy_square => joy_btn_square -- RESET
            con_action_left => con_action_left
        );
        
    TETRIS_LOGIC_INST : entity work.TETRIS_LOGIC
        port map(
            clk => clk,
            reset => p_reset, -- änder enoch auf button CENTER oderso
            
            piece_x_out => s_piece_x,
            piece_y_out => s_piece_y,
            
            current_rotation_out => s_current_rotation,
            current_piece_out => s_current_piece,
            next_piece_out => s_next_piece,
            
            board => s_board,
            
            tickms => tickms,
            ticks => ticks,
            
            btn_left => btn_left,
            btn_right => btn_right,
            btn_down => btn_down,
            btn_rotate => btn_rotate,
            
            game_over_out => s_game_over,
            score => s_score,
            current_game_level_out => s_current_game_level,
            
--            joy_left => joy_btn_left,
--            joy_right => joy_btn_right,
--            joy_down => joy_btn_down,
            
--            joy_cross => joy_btn_cross,
--            joy_square => joy_btn_square

            move_left => con_move_left,
            move_right => con_move_right,
            move_down => con_move_down,
            action_left => con_action_left,
            action_right => con_action_right
        );


end Behavioral;
