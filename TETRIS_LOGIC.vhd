----------------------------------------------------------------------------------
-- Company: OTH Amberg-Weiden
-- Engineer: Sebastian Eiglsperger
-- 
-- Create Date: 05/26/2026 11:53:24 AM
-- Design Name: TETRIS_LOGIC
-- Module Name: TETRIS_LOGIC - Behavioral
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
-- TODO:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.tetris_figures_pkg.all; -- Hier befinden sich auch einige Konstanten

entity TETRIS_LOGIC is
  Port (
        clk     : in std_logic;
        reset   : in std_logic;
        
        tickms  : in std_logic;
        ticks   : in std_logic;
        
        btn_left    : in std_logic;
        btn_right   : in std_logic;
        btn_down    : in std_logic;
        btn_rotate  : in std_logic;
        
        piece_x_out : out integer;
        piece_y_out : out integer;
        current_piece_out : out integer range 0 to 6;
        current_rotation_out : out integer range 0 to 3;
        next_piece_out : out integer;
        board : out board_matrix;
        
        game_over_out : out std_logic;
        score : out integer := 0;
        
        current_game_level_out : out integer range 1 to 9 := 1;
        
--        joy_left : in std_logic;
--        joy_right : in std_logic;
--        joy_down : in std_logic;
        
--        joy_cross : in std_logic; -- ROTATE
--        joy_square : in std_logic -- RESET
        move_left : in std_logic;
        move_right : in std_logic;
        move_down : in std_logic;
        
        action_left : in std_logic;
        action_right : in std_logic
  );
end TETRIS_LOGIC;

architecture Behavioral of TETRIS_LOGIC is

        
    -- Signals, Types
        signal piece_x : integer range 0 to GRID_W-1 := PIECE_X_KICKOFF;
        signal piece_y : integer range 0 to GRID_H-1 := PIECE_Y_KICKOFF;
        
        signal game_tick_counter : unsigned(23 downto 0) := (others => '0'); -- reset nach 500ms
        signal game_tick : std_logic := '0';
        signal control_tick : std_logic := '0';
        signal control_tick_counter : unsigned(23 downto 0) := (others => '0'); -- reset nach 500ms
        
        signal current_piece : integer range 0 to 6 := 0;
        signal current_rotation : integer range 0 to 3 := 0;
        
        --signal local_board : board_matrix := (others => (others => 0 ));
        
        signal game_over : std_logic := '0';
        signal next_piece : integer range 0 to 6 := 1;
        
        signal s_score : integer range 0 to 999999 := 0;
        signal game_tick_val : integer; 
        signal current_game_level : integer range 1 to 9 := 1;

------------------------------------------------------------------------------------
        function check_collision(
            test_x : integer;
            test_y : integer;
            test_rotation : integer;
            test_piece : integer;
            game_board : board_matrix
        ) return std_logic is
        begin
            -- Gehe durch alle 4x4 Felder des Tetrominos
            for ty in 0 to 3 loop
                for tx in 0 to 3 loop
        
                    -- Nur gesetzte Blöcke prüfen
                    if TETROMINOS(test_piece)(test_rotation)(ty, tx) = '1' then
        
                        ----------------------------------------------------------------
                        -- LINKER RAND
                        ----------------------------------------------------------------
                        if test_x + tx < 0 then
                            return '1';
        
                        ----------------------------------------------------------------
                        -- RECHTER RAND
                        ----------------------------------------------------------------
                        elsif test_x + tx >= GRID_W then
                            return '1';
        
                        ----------------------------------------------------------------
                        -- UNTERER RAND
                        ----------------------------------------------------------------
                        elsif test_y + ty >= GRID_H then
                            return '1';
        
                        ----------------------------------------------------------------
                        -- BLOCK-KOLLISION
                        ----------------------------------------------------------------
                        elsif test_y + ty >= 0 then
                            if game_board(test_y + ty, test_x + tx) /= 0 then
                                return '1';
                            end if;
                        end if;
        
                    end if;
        
                end loop;
            end loop;
        
            ------------------------------------------------------------------------
            -- KEINE KOLLISION
            ------------------------------------------------------------------------
            return '0';
        
        end function;  
------------------------------------------------------------------------------------

begin

process(clk, reset, action_left)
    -- Kollision durch Gametick
    variable collision : std_logic; 
    
    -- Kollision durch Playermovement
    variable collision_left : std_logic; 
    variable collision_right : std_logic;
    variable collision_down : std_logic;
    
    variable next_rotation : integer range 0 to 3;
    
    -- scoring system
    variable full_row : std_logic;
    variable local_board : board_matrix := (others => (others => 0 ));
    
    
begin
    if reset = '1' or action_left = '1' then
        piece_x <= PIECE_X_KICKOFF;
        piece_y <= PIECE_Y_KICKOFF;
        game_tick_counter <= (others => '0');
        game_tick <= '0';
        control_tick_counter <= (others => '0');
        control_tick <= '0';
        local_board := (others => (others => 0));
        
        piece_x_out <= piece_x;
        piece_y_out <= piece_y;
        current_piece_out <= current_piece;
        current_rotation_out <= current_rotation;
        
        -- Current game level
        game_tick_val <= game_level_1;
        current_game_level <= 1;
        
        s_score <= 0;
        --score <= 0;
        
        game_over <= '0';
        
    ------------------------------------------------------------------------
    -- GAME SPEED
    ------------------------------------------------------------------------
    elsif rising_edge(clk) then
        game_tick <= '0';
        control_tick <= '0';
        collision := '0';
        if game_over = '0' then
            if tickms = '1' then
                
                -- GAME TICK
                case current_game_level is
                    when 1 =>
                        game_tick_val <= game_level_1;
                    when 2 =>
                        game_tick_val <= game_level_2;
                    when 3 =>
                        game_tick_val <= game_level_3;
                    when 4 =>
                        game_tick_val <= game_level_4;
                    when 5 =>
                        game_tick_val <= game_level_5;
                    when 6 =>
                        game_tick_val <= game_level_6;
                    when 7 =>
                        game_tick_val <= game_level_7;
                    when 8 =>
                        game_tick_val <= game_level_8;
                    when 9 =>
                        game_tick_val <= game_level_9;
                    when others =>
                        game_tick_val <= game_level_1;
                end case;
                if game_tick_counter = game_tick_val then
                    game_tick_counter <= (others => '0');
                    game_tick <= '1';
            
                else
                    game_tick_counter <= game_tick_counter + 1;
                    
                end if;
               
                -- CONTROL TICK
                if control_tick_counter = 100 then
                    control_tick_counter <= (others => '0');
                    control_tick <= '1';
                    
                else
                    control_tick_counter <= control_tick_counter +1;
                    
                end if;
     
            end if;
            ------------------------------------------------------------------------
            -- GAME CONTROLS
            ------------------------------------------------------------------------
            if control_tick = '1' then
            
                ------------------------------------------------------------------------
                -- BUTTON ROTATE
                ------------------------------------------------------------------------
                if btn_rotate = '1' or action_right = '1' then
                    if current_rotation = 3 then
                        next_rotation := 0;
                    else
                        next_rotation := current_rotation + 1;
                    end if;
                    
                   if check_collision(
                        piece_x,
                        piece_y,
                        next_rotation,
                        current_piece,
                        local_board
                        ) = '0' then
                        current_rotation <= next_rotation;
                    end if;
                end if;
                
                ------------------------------------------------------------------------
                -- BUTTON LEFT
                ------------------------------------------------------------------------
                if btn_left = '1' or move_left = '1' then 
                   if check_collision(
                        piece_x -1,
                        piece_y,
                        current_rotation,
                        current_piece,
                        local_board
                        ) = '0' then
                        piece_x <= piece_x - 1;
                    end if;
                end if;
                
                ------------------------------------------------------------------------
                -- BUTTON RIGHT
                ------------------------------------------------------------------------
                if btn_right = '1' or move_right = '1' then 
                   if check_collision(
                        piece_x + 1,
                        piece_y,
                        current_rotation,
                        current_piece,
                        local_board
                        ) = '0' then
                        piece_x <= piece_x + 1;
                    end if;
                end if;
                
                ------------------------------------------------------------------------
                -- BUTTON DOWN
                ------------------------------------------------------------------------
                if btn_down = '1' or move_down = '1' then
                   if check_collision(
                        piece_x,
                        piece_y + 1,
                        current_rotation,
                        current_piece,
                        local_board
                        ) = '0' then
                        piece_y <= piece_y + 1;
                    end if;
                end if;
            end if;
         
            ------------------------------------------------------------------------
            -- LET BLOCKS FALL & COLLIDE
            ------------------------------------------------------------------------
            if game_tick = '1' then
            
                ------------------------------------------------------------------------
                -- CHECK GAME CAUSED COLLISION
                ------------------------------------------------------------------------
                   if check_collision(
                        piece_x,
                        piece_y + 1,
                        current_rotation,
                        current_piece,
                        local_board
                        ) = '0' then
                        -- FALLEN
                        piece_y <= piece_y + 1;
                    
                    else
                        
                        -- PLATZIEREN
                        for ty in 0 to 3 loop
                            for tx in 0 to 3 loop
                
                                if TETROMINOS(current_piece)(current_rotation)(ty, tx) = '1' then
                
                                    local_board(piece_y + ty, piece_x + tx) := current_piece + 1;
                
                                end if;
                
                            end loop;
                        end loop;
                    ------------------------------------------------------------------------
                    -- CHECK FULL ROWS
                    ------------------------------------------------------------------------
                    for py in GRID_H-1 downto 0 loop
                    
                        full_row := '1';
                    
                        -- komplette Reihe prüfen
                        for px in 0 to GRID_W-1 loop
                    
                            if local_board(py, px) = 0 then
                                full_row := '0';
                            end if;
                    
                        end loop;
                    
                        --------------------------------------------------------------------
                        -- ROW IS FULL -> DELETE
                        --------------------------------------------------------------------
                        if full_row = '1' then
                    
                            -- alles darüber nach unten schieben
                            for move_y in py downto 1 loop
                    
                                for px in 0 to GRID_W-1 loop
                                    local_board(move_y, px) := local_board(move_y - 1, px);
                                end loop;
                    
                            end loop;
                    
                            -- oberste Reihe leeren
                            for px in 0 to GRID_W-1 loop
                                local_board(0, px) := 0;
                            end loop;
                            
                            s_score <= s_score + 10;
                            if s_score >= 999999 then
                                s_score <= 999999;
                            elsif s_score < 50 then
                                current_game_level <= 1;
                            elsif s_score < 100 then
                                current_game_level <= 2;
                            elsif s_score < 150 then
                                current_game_level <= 3;
                            elsif s_score < 200 then
                                current_game_level <= 4;
                            elsif s_score < 250 then
                                current_game_level <= 5;
                            elsif s_score < 300 then
                                current_game_level <= 6;
                            elsif s_score < 350 then
                                current_game_level <= 7;
                            elsif s_score < 400 then
                                current_game_level <= 8;
                            elsif s_score >= 400 then
                                current_game_level <= 9;      
                                
                            end if;

                        end if;
                    
                    end loop;
                    
                        --------------------------------------------------------------------
                        -- NEW PIECE
                        -- CHECK IF GAME_OVER
                        --------------------------------------------------------------------
                        if check_collision(
                            PIECE_X_KICKOFF,
                            PIECE_Y_KICKOFF,
                            0,
                            next_piece, --(current_piece + 1) mod 7,
                            local_board
                        ) = '1' then
                        
                            game_over <= '1';
                        
                        else
                        
                            -- Erst jetzt neuen Stein aktivieren
                            --current_piece <= (current_piece + 1) mod 7;
                            current_rotation <= 0;
                            piece_x <= PIECE_X_KICKOFF;
                            piece_y <= PIECE_Y_KICKOFF;
                            
                            current_piece <= next_piece;
                            
                            if next_piece = 6 then
                                next_piece <= 0;
                            else 
                                next_piece <= next_piece + 1;
                            end if;
                        
                        end if;
                                            
                    end if;
            end if; -- game_tick
        end if; -- game_over
    end if; -- reset, rising_edge(clk)
    
    game_over_out <= game_over;
    score <= s_score;
    piece_x_out <= piece_x;
    piece_y_out <= piece_y;
    current_piece_out <= current_piece;
    current_rotation_out <= current_rotation;
    board <= local_board;
    current_game_level_out <= current_game_level;
    next_piece_out <= next_piece;
    

end process;

end Behavioral;
