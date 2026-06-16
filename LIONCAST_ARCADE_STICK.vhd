----------------------------------------------------------------------------------
-- Company: OTH Amberg-Weiden
-- Engineer: Sebastian Eiglsperger
-- 
-- Create Date: 06/03/2026 07:39:41 PM
-- Design Name: LIONCAST_ARCADE_STICK
-- Module Name: LIONCAST_ARCADE_STICK - Behavioral
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

entity LIONCAST_ARCADE_STICK is
    Port ( 
        clk : in std_logic;
        DATA_PIN : in std_logic;
        CLK_PIN : in std_logic;
        
        joy_left : out std_logic;
        joy_right : out std_logic;
        joy_up : out std_logic;
        joy_down : out std_logic;
        
        btn_L1 : out std_logic;
        btn_L2 : out std_logic;
        btn_square : out std_logic;
        btn_cross : out std_logic
    );
end LIONCAST_ARCADE_STICK;

architecture Behavioral of LIONCAST_ARCADE_STICK is
    -- Signal
    signal joy_shiftreg : std_logic_vector(15 downto 0) := (others => '0');
    signal joy_bitcount : integer range 0 to 16 := 0;
    signal joy_frame : std_logic_vector(15 downto 0) := (others => '0');
    signal joy_valid : std_logic := '0';
    
    signal clk_sync0 : std_logic;
    signal clk_sync1 : std_logic;
    signal clk_last : std_logic;
    signal clk_rise : std_logic;
    
begin
    ------------------------------------------------------------------------
    -- READ DATA
    ------------------------------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            clk_sync0 <= CLK_PIN;
            clk_sync1 <= clk_sync0;
            
            clk_rise <= clk_sync1 and not clk_last;
            clk_last <= clk_sync1;
        
        end if; -- CLOCK
        
        if clk_rise = '1' then
        
            joy_shiftreg <= joy_shiftreg(14 downto 0) & DATA_PIN;
            
            if joy_bitcount = 15 then
                joy_frame <= joy_shiftreg(14 downto 0) & DATA_PIN;
                joy_valid <= '1';
                
                joy_bitcount <= 0;
                
            else
                joy_bitcount <= joy_bitcount +1;
                joy_valid <= '0';
            end if;
        end if; -- clk_rise
    end process;
    
    ------------------------------------------------------------------------
    -- DECODE
    ------------------------------------------------------------------------
    process(joy_frame, joy_valid)
    begin
        joy_left <= '0';
        joy_right <= '0';
        joy_up <= '0';
        joy_down <= '0';
        
        btn_L1 <= '0';
        btn_L2 <= '0';
        btn_square <= '0';
        btn_cross <= '0';
        

        if joy_valid = '1' then
    
            case joy_frame is
    
                when "0000001110101101" =>
                    joy_left <= '1';
    
                when "0000001110100010" =>
                    joy_right <= '1';
    
                when "0000001110100100" =>
                    joy_down <= '1';
    
                when "0000001110101010" =>
                    joy_up <= '1';
    
                when "0000011111100111" =>
                    btn_l1 <= '1';
    
                when "0000011111100110" =>
                    btn_l2 <= '1';
    
                when "0000011111101101" =>
                    btn_square <= '1';
    
                when "0000011111100010" =>
                    btn_cross <= '1';
    
                when others =>
                    null;
    
            end case;
    
        end if; -- joy_validf
    end process;
end Behavioral;
