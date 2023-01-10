----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01.12.2022 20:45:03
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
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Top is
    Port (
        clk_100 : in STD_LOGIC;
        reset : in STD_LOGIC; -- SW14

        -- Sound
        sw : in STD_LOGIC_VECTOR (11 downto 0); -- SW0 -> SW8
        vol : in STD_LOGIC_VECTOR (1 downto 0); -- SW12 -> 13
        octave : in STD_LOGIC; -- SW15
        
        wave_out : out STD_LOGIC; -- JA2
           
        i2s_mclk_adc : out STD_LOGIC;
        i2s_bclk_adc : out STD_LOGIC;
        i2s_lr_adc : out STD_LOGIC;
        --i2s_din : in STD_LOGIC;
        i2s_mclk_dac : out STD_LOGIC;
        i2s_bclk_dac : out STD_LOGIC;
        i2s_lr_dac : out STD_LOGIC;
        i2s_dout : out STD_LOGIC;
           
        -- VGA
        vgaRed : out STD_LOGIC_VECTOR (3 downto 0);
        vgaGreen : out STD_LOGIC_VECTOR (3 downto 0);
        vgaBlue : out STD_LOGIC_VECTOR (3 downto 0);
        Hsync : out STD_LOGIC;
        Vsync : out STD_LOGIC;
           
        -- USB Mouse
        PS2Clk : inout STD_LOGIC;
        PS2Data : inout STD_LOGIC
    );
end Top;

architecture Behavioral of Top is

    component clk_wiz_0 is
        Port(
            clk_in1     : in STD_LOGIC;
            reset       : in STD_LOGIC;
            clk_out1    : out STD_LOGIC;
            clk_out2    : out STD_LOGIC;
            locked      : out STD_LOGIC);
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
    
    component Wave_Generator is
        Port(
            Trigger     : in STD_LOGIC;                       -- Key press
            Freq_Cnt    : in STD_LOGIC_VECTOR(15 downto 0);   -- Counter value = 100MHz / (Note Frequency*64 Divisions of Sine Wave) (round to nearest num)
            wavegenCLK  : in STD_LOGIC;                       -- Basys3 100MHz CLK
            WaveOut     : out STD_LOGIC_VECTOR(9 downto 0));  -- Signed amplitude of wave
    end component;
    
    component pwm_generator
    Port (
        CLK             : in STD_LOGIC; -- 100MHz
        input           : in STD_LOGIC_VECTOR (9 downto 0);
        output          : out STD_LOGIC);
    end component;

    component Two_Octave_Synth is
        Port(
            CLK      : in STD_LOGIC; 
            O4       : in STD_LOGIC_VECTOR(11 downto 0);
            O5       : in STD_LOGIC_VECTOR(12 downto 0);
            output   : out STD_LOGIC);
    end component;
    
    component audiosystem is 
        Port(
            clk         : in std_logic;
            
            l_filter     : in STD_LOGIC_VECTOR (1 downto 0);
            r_filter     : in STD_LOGIC_VECTOR (1 downto 0);
            
            l_vol        : in STD_LOGIC_VECTOR (1 downto 0);
            r_vol        : in STD_LOGIC_VECTOR (1 downto 0);
            
            i2s_mclk_adc : out std_logic;
            i2s_bclk_adc : out std_logic;
            i2s_lr_adc   : out std_logic;
            i2s_din      : in std_logic;
            
            i2s_mclk_dac : out std_logic;
            i2s_bclk_dac : out std_logic;
            i2s_lr_dac   : out std_logic;
            i2s_dout     : out std_logic
        );
    end component;
    
    component vga_controller is
        Port (
            clk_25 : in STD_LOGIC; -- 25MHz
            clr : in STD_LOGIC;
            vgaRed : out STD_LOGIC_VECTOR (3 downto 0);
            vgaGreen : out STD_LOGIC_VECTOR (3 downto 0);
            vgaBlue : out STD_LOGIC_VECTOR (3 downto 0);
            Hsync : out STD_LOGIC;
            Vsync : out STD_LOGIC
        );
    end component;
    
    signal clk_50, clk_25 : STD_LOGIC;
    signal pllsreset: std_logic := '0';
    
    signal wave_to_pwm_gen : STD_LOGIC_VECTOR (9 downto 0);
    signal octave_4 : STD_LOGIC_VECTOR (11 downto 0);
    signal octave_5 : STD_LOGIC_VECTOR (12 downto 0);
    signal i2s_din : STD_LOGIC;
    signal audio_wave : STD_LOGIC;
    
    signal vid_on : STD_LOGIC;
    
    signal mouse_data : STD_LOGIC_VECTOR (23 downto 0);
    signal mouse_data_new: STD_LOGIC;

begin

    process(octave, sw)
    begin
        case octave is
            when '0' =>
                octave_4 <= sw;
                octave_5 <= "0000000000000";
            when '1' =>
                octave_4 <= "000000000000";
                octave_5 <= std_logic_vector(resize(unsigned(sw), 13));
        end case;
    end process;
    
    wave_out <= audio_wave;
    i2s_din <= audio_wave;
    

    clock: clk_wiz_0
        Port map(
            clk_in1 => clk_100,
            reset => reset,
            clk_out1 => clk_25,
            clk_out2 => clk_50,
            locked => open
        );
        
    mouse: ps2_mouse
        Port map(
            clk => clk_50,
            reset_n => reset,
            ps2_clk => PS2Clk,
            ps2_data => PS2Data,
            mouse_data => mouse_data,
            mouse_data_new => mouse_data_new
        );

    tone: Wave_Generator
        Port map(
            Trigger => sw(0),
            Freq_Cnt => X"1755", 
            wavegenCLK => clk_100, 
            signed(WaveOut) => wave_to_pwm_gen --5973, 261.63 Hz
        );
        
    pwm_gen: pwm_generator
        Port map(
            CLK => clk_100,
            input => wave_to_pwm_gen,
            output => audio_wave
        );
    
    synth: Two_Octave_Synth
        Port map(
            CLK => clk_100,
            O4 => octave_4,
            O5 => octave_5,
            output => open
        );
    
     audiomodule: audiosystem
        Port map(
            clk => clk_50,
            
            l_filter => "00",
            r_filter => "00",
            
            l_vol => vol,
            r_vol => vol,
            
            i2s_mclk_adc => i2s_mclk_adc,
            i2s_bclk_adc => i2s_bclk_adc,
            i2s_lr_adc => i2s_lr_adc,
            i2s_din => i2s_din,    
            i2s_mclk_dac => i2s_mclk_dac,
            i2s_bclk_dac => i2s_bclk_dac,
            i2s_lr_dac => i2s_lr_dac,
            i2s_dout => i2s_dout
        );
        
    vga: vga_controller
        Port map(
            clk_25 => clk_25,
            clr => reset,
            vgaRed => vgaRed,
            vgaGreen => vgaGreen,
            vgaBlue => vgaBlue,
            Hsync => Hsync,
            Vsync => Vsync
        );
        
end Behavioral;
