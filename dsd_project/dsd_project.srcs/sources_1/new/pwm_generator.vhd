----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 22.12.2022 13:51:37
-- Design Name: 
-- Module Name: pwm_generator - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity pwm_generator is
    Port (
        CLK : in STD_LOGIC; -- 100MHz
        input : in STD_LOGIC_VECTOR (9 downto 0);
        output : out STD_LOGIC);
end pwm_generator;

architecture Behavioral of pwm_generator is

    signal positiveWaveSum : STD_LOGIC_VECTOR(9 downto 0); --unsigned 0 to 1023, for use in PWM generator
    signal ping_length : unsigned (9 downto 0) := unsigned(positiveWaveSum);
    signal PWM : unsigned (9 downto 0) := to_unsigned(0, 10);

begin

 
---------make sine wave positive for pwm---------------------
    positiveWaveSum <= not input(9) & input(8 downto 0);
    
-------------PWM generator---------------------
    process(CLK)
        begin
            if (rising_edge(CLK)) then
                    if (PWM < ping_length) then
                        output <= '1';
                    else
                        output <= '0';
                    end if;
                    PWM <= PWM + 1;
                    ping_length <= unsigned(positiveWaveSum);
            end if;
        end process;

end Behavioral;
