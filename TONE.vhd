----------------------------------------------------------------------------------
-- Company: OTH Amberg-Weiden
-- Engineer: Sebastian Eiglsperger
-- 
-- Create Date: 06/12/2026 03:20:12 PM
-- Design Name: TONE
-- Module Name: TONE - Behavioral
-- Project Name: Spielekonsole_VHDL
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
----------------------------------------------------------------------------------
-- SIMPLE 8-BIT ARCADE MUSIC PLAYER
-- FPGA Clock: 100 MHz
-- Output: Piezo Buzzer
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TONE is
    Port (
        clk    : in  std_logic;
        reset  : in  std_logic;
        
        buzzer : out std_logic;
        
        tone_ON : in std_logic -- Switch ganz links
    );
end TONE;

architecture Behavioral of TONE is

    ------------------------------------------------------------------------------
    -- NOTES (100 MHz Divider Values)
    ------------------------------------------------------------------------------
    type melody_t is array(0 to 31) of integer;

    constant MELODY : melody_t := (

        -- E5 B4 C5 D5
        75873,
        101215,
        95602,
        85179,

        -- C5 B4 A4 A4
        95602,
        101215,
        113636,
        113636,

        -- C5 E5 D5 C5
        95602,
        75873,
        85179,
        95602,

        -- B4 C5 D5 E5
        101215,
        95602,
        85179,
        75873,

        -- C5 A4 A4 REST
        95602,
        113636,
        113636,
        0,

        -- D5 F5 A5 G5
        85179,
        71633,
        56818,
        63775,

        -- F5 E5 C5 E5
        71633,
        75873,
        95602,
        75873,

        -- D5 C5 B4 REST
        85179,
        95602,
        101215,
        0
    );

    ------------------------------------------------------------------------------
    -- 250 ms per Note @100 MHz
    ------------------------------------------------------------------------------
    constant NOTE_TIME : integer := 25000000;

    ------------------------------------------------------------------------------
    -- Signals
    ------------------------------------------------------------------------------
    signal note_index   : integer range 0 to 31 := 0;
    signal note_timer   : integer := 0;

    signal tone_divider : integer := 75873;
    signal tone_counter : integer := 0;

    signal buzzer_reg   : std_logic := '0';

begin

    ------------------------------------------------------------------------------
    -- NOTE PLAYER
    ------------------------------------------------------------------------------
    process(clk, reset)
    begin
        if reset = '1' then

            note_index <= 0;
            note_timer <= NOTE_TIME;
            tone_divider <= MELODY(0);

        elsif rising_edge(clk) then

            if note_timer = 0 then
            
                if note_index = 31 then
            
                    note_index <= 0;
                    tone_divider <= MELODY(0);
            
                else
            
                    note_index <= note_index + 1;
                    tone_divider <= MELODY(note_index + 1);
            
                end if;
            
                note_timer <= NOTE_TIME;
            
            else
            
                note_timer <= note_timer - 1;
            
            end if;

        end if;
    end process;

    ------------------------------------------------------------------------------
    -- TONE GENERATOR
    ------------------------------------------------------------------------------
    process(clk, reset)
    begin
        if reset = '1' then

            tone_counter <= 0;
            buzzer_reg <= '0';

        elsif rising_edge(clk) and tone_ON = '1' then

            if tone_divider = 0 then

                buzzer_reg <= '0';
                tone_counter <= 0;

            else

                if tone_counter >= tone_divider then

                    tone_counter <= 0;
                    buzzer_reg <= not buzzer_reg;

                else

                    tone_counter <= tone_counter + 1;

                end if;

            end if;

        end if;
    end process;

    ------------------------------------------------------------------------------
    -- OUTPUT
    ------------------------------------------------------------------------------
    buzzer <= buzzer_reg;

end Behavioral;