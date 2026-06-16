----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/29/2026 02:05:18 PM
-- Design Name: TETRIS_GRAPHICS
-- Module Name: TETRIS_GRAPHICS - Behavioral
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

----------------------------------------------------------------------------------
------------------------ HOW TO DRAW STRING FROM FONT_PKG ------------------------
----------------------------------------------------------------------------------
--library work; -- Nur einmal in der vhd Datei notwendig
--use work.font_pkg.all; -- Nur einmal in der vhd Datei notwendig
--if draw_string(
--    to_integer(xPix), == DONT CHANGE
--    to_integer(yPix), == DONT CHANGE

--    160, == X POSITION
--    180, == Y POSITION

--    4, == SCALE

--    "GAME OVER" == STRING
--) = '1' then

--    VGA_R <= "1111";
--    VGA_G <= "0000";
--    VGA_B <= "0000";

--end if;



--if draw_number(
--        to_integer(xPix), == DONT CHANGE
--        to_integer(yPix), == DONT CHANGE

--        500, == X POSITION
--        50, == Y POSITION

--        2, == SCALE
--        seconds == NUMER i.e. 123 eq 000123
--   ) = '1' then
--    VGA_R <= "1111";
--    VGA_G <= "1010";
--    VGA_B <= "1010";

--end if;
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.tetris_figures_pkg.all;
use work.font_pkg.all;

entity TETRIS_GRAPHICS is
  Port (
        clk : in std_logic;
        reset : in std_logic;
        xPix    : in unsigned (10 downto 0);
        yPix    : in unsigned (10 downto 0 );
        video_on    : in std_logic;
        VGA_R   : out std_logic_vector(3 downto 0);
        VGA_G   : out std_logic_vector(3 downto 0);
        VGA_B   : out std_logic_vector(3 downto 0);
        
        tickms  : in std_logic;
        ticks   : in std_logic;
        
        -- von TETRIS_LOGIC
        piece_x : in integer;
        piece_y : in integer;
        current_piece : in integer range 0 to 6;
        current_rotation : in integer range 0 to 3;
        next_piece : in integer range 0 to 6;
        board : in board_matrix;
        
        game_over : in std_logic;
        score : in integer;
        current_game_level : in integer;
        
--        joy_square : in std_logic
        con_action_left : in std_logic
   );
   
end TETRIS_GRAPHICS;

architecture Behavioral of TETRIS_GRAPHICS is

    -- Signals, Types
    signal seconds : integer := 0;
    signal string_jumper : std_logic := '0';

------------------------------------------------------------------------------------
         function get_piece_color(piece : integer)
            return std_logic_vector is
        
            variable color : std_logic_vector(11 downto 0);
            
            begin
            
                case piece is
                    -- RRRR GGGG BBBB
                    when 0 => -- I cyan
                        color := "000011111111";
            
                    when 1 => -- O gelb
                        color := "111111110011";
            
                    when 2 => -- L orange
                        color := "111110000001";
            
                    when 3 => -- J dunkelblau
                        color := "001101101010";
            
                    when 4 => -- Z rot
                        color := "111100110011";
            
                    when 5 => -- S gruen
                        color := "011010110010";
            
                    when 6 => -- triangle lila
                        color := "111000001011";
            
                    when others =>
                        color := "000000000000";
            
                end case;
            
            return color;
            end function;  
------------------------------------------------------------------------------------
        
------------------------------------------------------------------------
-- COUNTER / STRING JUMPER
------------------------------------------------------------------------      
begin 
process(clk, reset, con_action_left)
begin
    if reset = '1' or con_action_left = '1' then
        seconds <= 0;
    elsif rising_edge(clk) then
        if ticks = '1' then
            if game_over = '0' then
                seconds <= seconds +1;
            end if;
            if string_jumper = '0' then
                string_jumper <= '1';
            else
                string_jumper <= '0';
            end if;
        end if;
    end if;
end process;


------------------------------------------------------------------------
-- DISPLAY / RENDERING
------------------------------------------------------------------------
process(xPix, yPix, video_on, board, piece_x, piece_y)
    variable v_draw_piece : std_logic; -- Zeichne Block
    variable v_draw_board : std_logic; -- Zeichne gesetzte Blöcke
    
    variable x : integer; -- Gegenstueck zu xPix
    variable y : integer; -- Gegenstueck zu yPix
    
    variable local_x : integer; -- coloring Dummy
    variable local_y : integer; -- coloring Dummy
    variable next_block_local_x : integer;
    variable next_block_local_y : integer;
    variable color : std_logic_vector (11 downto 0); -- zum färben der bewerglichen Blöcke
    variable board_color : integer range 0 to 7; -- zum färben der unbeweglichen Blöcke
    
    

begin
    VGA_R <= "0000";
    VGA_G <= "0000";
    VGA_B <= "0000";
    
    v_draw_piece := '0';
    v_draw_board := '0';
    
    x := to_integer(xPix); -- Signale ändern sich erst nach vollendung des gesamten Prozesses
    y := to_integer(yPix); -- Variablen ändern sich direkt, also bei mehrfacher Abfrage -> Variablen verwenden


    local_x := x - (GAME_OFFSET_X +((x - GAME_OFFSET_X) / BLOCK_SIZE) * BLOCK_SIZE);
    local_y := y - (GAME_OFFSET_Y +((y - GAME_OFFSET_Y) / BLOCK_SIZE) * BLOCK_SIZE);
            
    if video_on = '1' then -- brauch ich eigentlich gar nicht, da xPix nur was macht wenn vid_on = 1
        
        ------------------------------------------------------------------------
        -- PIXEL SHADOW GRID
        ------------------------------------------------------------------------
        if x >= GAME_OFFSET_X and
           x < GAME_OFFSET_X + GRID_W * BLOCK_SIZE and
           y >= GAME_OFFSET_Y and
           y < GAME_OFFSET_Y + GRID_H * BLOCK_SIZE then
        
            -- obere Linie jedes Feldes
            if local_y = 0 or local_y = 1 then
        
                VGA_R <= "0010";
                VGA_G <= "0010";
                VGA_B <= "0010";
        
            -- linke Linie jedes Feldes
            elsif local_x = 0 or local_x = 1 then
        
                VGA_R <= "0100";
                VGA_G <= "0100";
                VGA_B <= "0100";
        
            end if;
        
        end if;
        
        ------------------------------------------------------------------------
        -- DRAW NEXT BLOCK BOX
        ------------------------------------------------------------------------
        if (
            x >= 48 and x < 146 and
            y >= 174 and y < 276
           ) then
        
            --------------------------------------------------------------------
            -- RAHMEN
            --------------------------------------------------------------------
            if x < 52 or
               x >= 142 or
               y < 178 or
               y >= 272 then
        
                VGA_R <= "1101";
                VGA_G <= "1110";
                VGA_B <= "1001";
        
            --------------------------------------------------------------------
            -- GRID IM 4x4 INNENBEREICH
            --------------------------------------------------------------------
            else
        
                --next_block_local_x := (x - 66) mod BLOCK_SIZE;
                --next_block_local_y := (y - 196) mod BLOCK_SIZE;
                
                next_block_local_x := (x - 66) - ((x - 66) / BLOCK_SIZE) * BLOCK_SIZE;
                next_block_local_y := (y - 196) - ((y - 196) / BLOCK_SIZE) * BLOCK_SIZE;
        
                if next_block_local_y = 0 or
                   next_block_local_y = 1 then
        
                    VGA_R <= "0010";
                    VGA_G <= "0010";
                    VGA_B <= "0010";
        
                elsif next_block_local_x = 0 or
                      next_block_local_x = 1 then
        
                    VGA_R <= "0100";
                    VGA_G <= "0100";
                    VGA_B <= "0100";
        
                end if;
        
            end if;
        end if;
        
        -- BESCHRIFTUNG
        if draw_string(
            to_integer(xPix),
            to_integer(yPix),
            50,
            135,
            3,
            "Next"
        ) = '1' then
        
            VGA_R <= "1101";
            VGA_G <= "1110";
            VGA_B <= "1001";
        
        end if;
        
        -- NEXT TETROMINO INSIDE BOX
        for ty in 0 to 3 loop
            for tx in 0 to 3 loop
            
                next_block_local_x := x - (66 + tx * BLOCK_SIZE);
                next_block_local_y := y - (196 + ty * BLOCK_SIZE);
        
                if TETROMINOS(next_piece)(0)(ty,tx) = '1' then
        
                    if (
                        x >= 66 + tx * BLOCK_SIZE and
                        x <  66 + (tx+1) * BLOCK_SIZE and
                        y >= 196 + ty * BLOCK_SIZE and
                        y <  196 + (ty+1) * BLOCK_SIZE
                       ) then
        
                        color := get_piece_color(next_piece);
                        
                        ------------------------------------------------------------------------
                        -- HELLER RAND OBEN + LINKS
                        ------------------------------------------------------------------------
                        if next_block_local_x <= 1 or
                           next_block_local_y <= 1 then
                           
                           VGA_R <= '1' & color(11 downto 9);
                           VGA_G <= '1' & color(7 downto 5);
                           VGA_B <= '1' & color(3 downto 1);
                        ------------------------------------------------------------------------
                        -- DUNKLER RAND UNTEN + RECHTS
                        ------------------------------------------------------------------------
                        elsif next_block_local_x >= BLOCK_SIZE - 2 or
                              next_block_local_y >= BLOCK_SIZE - 2 then
                              
                           VGA_R <= '0' & color(11 downto 9);
                           VGA_G <= '0' & color(7 downto 5);
                           VGA_B <= '0' & color(3 downto 1);
                        
                        
                        ------------------------------------------------------------------------
                        -- INNENFLÄCHE
                        ------------------------------------------------------------------------
                        else
                
                           VGA_R <= color(11 downto 8);
                           VGA_G <= color(7 downto 4);
                           VGA_B <= color(3 downto 0);   
                                                                
                        end if;
        
                    end if;
        
                end if;
        
            end loop;
        end loop;

        
        
        
        ------------------------------------------------------------------------
        -- CATCH FALLING BLOCK
        ------------------------------------------------------------------------     
            v_draw_piece := '0';
            
            for ty in 0 to 3 loop
                for tx in 0 to 3 loop
            
                    if TETROMINOS(current_piece)(current_rotation)(ty,tx) = '1' then
            
                        if(
                            x >= GAME_OFFSET_X + (piece_x + tx) * BLOCK_SIZE and
                            x <  GAME_OFFSET_X + (piece_x + tx + 1) * BLOCK_SIZE and
                            y >= GAME_OFFSET_Y + (piece_y + ty) * BLOCK_SIZE and
                            y <  GAME_OFFSET_Y + (piece_y + ty + 1) * BLOCK_SIZE
                        ) then
            
                            v_draw_piece := '1';
            
                        end if;
            
                    end if;
            
                end loop;
            end loop;

        ------------------------------------------------------------------------
        -- DRAW STORED BLOCKS
        ------------------------------------------------------------------------
        v_draw_board := '0';
        
        for py in 0 to GRID_H-1 loop
            for px in 0 to GRID_W-1 loop
        
                if board(py,px) /= 0 then
        
                    if( x >= GAME_OFFSET_X + px*BLOCK_SIZE and
                        x <  GAME_OFFSET_X + (px+1)*BLOCK_SIZE and
                        y >= GAME_OFFSET_Y + py*BLOCK_SIZE and
                        y <  GAME_OFFSET_Y + (py+1)*BLOCK_SIZE ) then
                        
                        v_draw_board := '1';
                        board_color := board(py, px);
        
                    end if;
                end if;
            end loop;
        end loop;
        
        ------------------------------------------------------------------------
        -- GAME BOARDER
        ------------------------------------------------------------------------

        if(( x >= GAME_OFFSET_X - 10 and
             x < GAME_OFFSET_X) --linker Spielfeldbalken
             or
           ( x >= GAME_OFFSET_X + GRID_W * BLOCK_SIZE and
             x < GAME_OFFSET_X + GRID_W * BLOCK_SIZE + 10) --rechter Spielfeldbalken 
             or
           ( x >= GAME_OFFSET_X - 10 and
             x < GAME_OFFSET_X + GRID_W * BLOCK_SIZE + 10 and
             --y >= GAME_OFFSET_Y - 6 and
             y < GAME_OFFSET_Y) -- oberer Spielfeldbalken
             or
           ( x >= GAME_OFFSET_X - 10 and
             x < GAME_OFFSET_X + GRID_W * BLOCK_SIZE + 10 and
             y >= GAME_OFFSET_Y + GRID_H * BLOCK_SIZE ) )
             --y < GAME_OFFSET_Y + 6 + GRID_H * BLOCK_SIZE) ) -- unterer Spielfeldbalken 
             then 

            VGA_R <= "1101";
            VGA_G <= "1110";
            VGA_B <= "1001";
            
            -- MUSTER
            if xPix(1 downto 0) = "00" or yPix(1 downto 0) = "00" then
                VGA_R <= "0000";
                VGA_G <= "0000";
                VGA_B <= "0000";
                
            end if;
            
        ------------------------------------------------------------------------
        -- DRAW ACTIVE PIECE
        ------------------------------------------------------------------------
        elsif v_draw_piece = '1' then
            color := get_piece_color(current_piece);
            
            ------------------------------------------------------------------------
            -- HELLER RAND OBEN + LINKS
            ------------------------------------------------------------------------
            if local_x <= 1 or
               local_y <= 1 then
               
               VGA_R <= '1' & color(11 downto 9);
               VGA_G <= '1' & color(7 downto 5);
               VGA_B <= '1' & color(3 downto 1);
            ------------------------------------------------------------------------
            -- DUNKLER RAND UNTEN + RECHTS
            ------------------------------------------------------------------------
            elsif local_x >= BLOCK_SIZE - 2 or
                  local_y >= BLOCK_SIZE - 2 then
                  
               VGA_R <= '0' & color(11 downto 9);
               VGA_G <= '0' & color(7 downto 5);
               VGA_B <= '0' & color(3 downto 1);
            
            
            ------------------------------------------------------------------------
            -- INNENFLÄCHE
            ------------------------------------------------------------------------
            else

               VGA_R <= color(11 downto 8);
               VGA_G <= color(7 downto 4);
               VGA_B <= color(3 downto 0);   
                                                    
            end if;
            
        ------------------------------------------------------------------------
        -- DRAW STORED BLOCKS
        ------------------------------------------------------------------------
        elsif v_draw_board = '1' then
        
            color := get_piece_color(board_color - 1);
            
            ------------------------------------------------------------------------
            -- HELLER RAND OBEN + LINKS
            ------------------------------------------------------------------------
            if local_x <= 1 or
               local_y <= 1 then
               
               VGA_R <= '1' & color(11 downto 9);
               VGA_G <= '1' & color(7 downto 5);
               VGA_B <= '1' & color(3 downto 1);
            ------------------------------------------------------------------------
            -- DUNKLER RAND UNTEN + RECHTS
            ------------------------------------------------------------------------
            elsif local_x >= BLOCK_SIZE - 2 or
                  local_y >= BLOCK_SIZE - 2 then
                  
               VGA_R <= '0' & color(11 downto 9);
               VGA_G <= '0' & color(7 downto 5);
               VGA_B <= '0' & color(3 downto 1);
            
            
            ------------------------------------------------------------------------
            -- INNENFLÄCHE
            ------------------------------------------------------------------------
            else

               VGA_R <= color(11 downto 8);
               VGA_G <= color(7 downto 4);
               VGA_B <= color(3 downto 0);   
                                                    
            end if;
        end if; -- Game Boarder, stored blocks, etc.
       
        ------------------------------------------------------------------------
        -- OTH LOGO
        ------------------------------------------------------------------------
        if draw_string(
                to_integer(xPix),
                to_integer(yPix),
                
                10,
                1,
                4,
                "OTH"
                ) = '1' then
                                
                VGA_R <= "1111";
                VGA_G <= "0111";
                VGA_B <= "0000";
        end if;
        if draw_string(
                to_integer(xPix),
                to_integer(yPix),
                
                110,
                5,
                2,
                "Amberg"
                ) = '1' then
                                
                VGA_R <= "1001";
                VGA_G <= "1001";
                VGA_B <= "1001";
        end if;
        if draw_string(
                to_integer(xPix),
                to_integer(yPix),
                
                110,
                30,
                2,
                "Weiden"
                ) = '1' then
                                
                VGA_R <= "1001";
                VGA_G <= "1001";
                VGA_B <= "1001";
        end if;
        
        ------------------------------------------------------------------------
        -- Time
        ------------------------------------------------------------------------
        
        if draw_string(
                to_integer(xPix),
                to_integer(yPix),
                
                440,
                80,
                2,
                "Time"
                ) = '1' then
                                
                VGA_R <= "1101";
                VGA_G <= "1110";
                VGA_B <= "1001";
        end if;
        
        if draw_number(
                to_integer(xPix),
                to_integer(yPix),
        
                440,--470,
                105,
        
                2,
                seconds
            ) = '1' then
            
                VGA_R <= "1101";
                VGA_G <= "1110";
                VGA_B <= "1001";    
        end if;  
              
        ------------------------------------------------------------------------
        -- Score
        ------------------------------------------------------------------------
        
        if draw_string(
                to_integer(xPix),
                to_integer(yPix),
                
                440,
                140,
                2,
                "Score"
                ) = '1' then
                                
                VGA_R <= "1101";
                VGA_G <= "1110";
                VGA_B <= "1001";
        end if;
        
        if draw_number(
                to_integer(xPix),
                to_integer(yPix),
        
                440,
                165,
        
                2,
                score
           ) = '1' then
           
                VGA_R <= "1101";
                VGA_G <= "1110";
                VGA_B <= "1001";
        end if;

        
        ------------------------------------------------------------------------
        -- Current Level
        ------------------------------------------------------------------------
        if draw_string(
                to_integer(xPix),
                to_integer(yPix),
                
                440,
                200,
                2,
                "Level"
                ) = '1' then
                                
                VGA_R <= "1101";
                VGA_G <= "1110";
                VGA_B <= "1001";
        end if;
        
        if draw_number(
                to_integer(xPix),
                to_integer(yPix),
        
                440,--470,
                225,
        
                2,
                current_game_level
            ) = '1' then
            
                VGA_R <= "1101";
                VGA_G <= "1110";
                VGA_B <= "1001";    
        end if; 
        
        ------------------------------------------------------------------------
        -- GAME OVER SCREEN
        ------------------------------------------------------------------------
        if game_over = '1' then
            if string_jumper = '1' then
                if draw_string(
                    to_integer(xPix),
                    to_integer(yPix),
                    160,
                    180,
                    4,
                    "GAME OVER"
                    ) = '1' then
                
                    VGA_R <= "1111";
                    VGA_G <= "1111";
                    VGA_B <= "1111";
                    end if;
            else
                if draw_string(
                    to_integer(xPix),
                    to_integer(yPix),
                    160,
                    180,
                    4,
                    "GAME OVER"
                    ) = '1' then
                
                    VGA_R <= "1111";
                    VGA_G <= "0000";
                    VGA_B <= "0000";
                            
            
                end if;
            end if;
        end if;
       
    end if; -- video on
end process;

end Behavioral;