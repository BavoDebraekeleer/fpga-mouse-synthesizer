----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.01.2023 11:03:43
-- Design Name: 
-- Module Name: pwm_to_7seg - Behavioral
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

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity seven_seg is
    Port ( N_input : in integer range 0 to 9;
           seg : out STD_LOGIC_VECTOR (6 downto 0));
end seven_seg;

architecture Behavioral of seven_seg is
    
    signal output: STD_LOGIC_VECTOR (6 downto 0);
    
begin
    
    seg <= not output;
    
    process(N_input)
    begin
        case N_input is
            when 0=> output <="0111111";
            when 1=> output <="0000110";
            when 2=> output <="1011011";
            when 3=> output <="1001111";
            when 4=> output <="1100110";
            when 5=> output <="1101101";
            when 6=> output <="1111101";
            when 7=> output <="0000111";
            when 8=> output <="1111111";
            when 9=> output <="1101111";
            when others=> output <= (others=>'X');
        end case;
    
    end process;

end Behavioral;
