----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.01.2023 10:55:04
-- Design Name: 
-- Module Name: top - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top is
    Port (
        clk_100 : in STD_LOGIC;
        reset : in STD_LOGIC;
        
        -- Audio
        sw : in STD_LOGIC_VECTOR (7 downto 0);
        sw_audio_input : in STD_LOGIC;
        led_pwm : out STD_LOGIC;
        led : out STD_LOGIC_VECTOR(7 downto 0);
        audio_out : out STD_LOGIC;
        seg : out STD_LOGIC_VECTOR (6 downto 0);
        an : out bit_vector (3 downto 0);
           
        -- PS2 USB Mouse
        PS2Clk : inout STD_LOGIC;
        PS2Data : inout STD_LOGIC
    );
end top;

architecture Behavioral of top is

    component clk_wiz_0 is
        Port(
            clk_in1     : in STD_LOGIC;
            reset       : in STD_LOGIC;
            clk_out1    : out STD_LOGIC;
            clk_out2    : out STD_LOGIC;
            locked      : out STD_LOGIC);
     end component;

    component audio is
        Port ( clk : in STD_LOGIC;
               reset : in STD_LOGIC;
               data_in : in STD_LOGIC_VECTOR (7 downto 0);
               data_out : out STD_LOGIC;
               seg : out STD_LOGIC_VECTOR (6 downto 0);
               an : out bit_vector (3 downto 0));
    end component;
    
    component ps2_mouse is
      Generic(
          clk_freq                  : INTEGER := 50_000_000; --system clock frequency in Hz
          ps2_debounce_counter_size : INTEGER := 8);         --set such that 2^size/clk_freq = 5us (size = 8 for 50MHz)
      Port(
          clk            : IN     STD_LOGIC;                     --system clock input
          reset_n        : IN     STD_LOGIC;                     --active low asynchronous reset
          ps2_clk        : INOUT  STD_LOGIC;                     --clock signal from PS2 mouse
          ps2_data       : INOUT  STD_LOGIC;                     --data signal from PS2 mouse
          mouse_data     : OUT    STD_LOGIC_VECTOR(23 DOWNTO 0); --data received from mouse
          mouse_data_new : OUT    STD_LOGIC);                    --new data packet available flag
    end component;
    
    signal clk_50, clk_25 : STD_LOGIC;
    
    signal pwm_sig : STD_LOGIC;
    signal audio_input : STD_LOGIC_VECTOR (7 downto 0);
   
    signal mouse_data_input : STD_LOGIC_VECTOR(23 DOWNTO 0);
    signal mouse_data_new_input : STD_LOGIC;

begin

    clock: clk_wiz_0
        Port map(
            clk_in1 => clk_100,
            reset => reset,
            clk_out1 => clk_25,
            clk_out2 => clk_50,
            locked => open
        );
        
    audio_pwm : audio
        Port map(
            clk => clk_50,
            reset => reset,
            data_in => audio_input,
            data_out => pwm_sig,
            seg => seg,
            an => an
        );
        
    mouse: ps2_mouse
        Port map(
            clk => clk_50,
            reset_n => reset,
            ps2_clk => PS2Clk,
            ps2_data => PS2Data,
            mouse_data => mouse_data_input,
            mouse_data_new => mouse_data_new_input
        );
        
    pwm_to_led_and_audio_out : process(pwm_sig)
    begin
        audio_out <= pwm_sig;
        led_pwm <= pwm_sig;
    end process;
    
    audio_input_selection : process (clk_50, sw_audio_input, sw, mouse_data_input)
    begin
        if (sw_audio_input = '0') then
            audio_input <= sw;
        elsif (mouse_data_new_input = '1') then
            audio_input <= mouse_data_input(15 downto 8);
        end if;
        
        led <= audio_input;
    end process;


end Behavioral;
