----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 22.12.2022 14:51:28
-- Design Name: 
-- Module Name: vga_stripes - Behavioral
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_arith.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity vga_stripes is
    Port ( hc : in integer range 0 to 800;
           vc : in integer range 0 to 800;
           vidon : in STD_LOGIC;
           vgaRed : out STD_LOGIC_VECTOR (3 downto 0);
           vgaGreen : out STD_LOGIC_VECTOR (3 downto 0);
           vgaBlue : out STD_LOGIC_VECTOR (3 downto 0)
     );
end vga_stripes;

architecture Behavioral of vga_stripes is

    signal vc_vec: std_logic_vector(9 downto 0);

begin

    vc_vec <= conv_std_logic_vector(vc, 10);
    
    process(vidon, vc_vec)
    begin
        vgaRed <= "0000";
        vgaGreen <= "0000";
        vgaBlue <= "0000";
        
        if vidon= '1' then
            vgaRed <= vc_vec(5) & vc_vec(5) & vc_vec(5)& vc_vec(5);
            vgaGreen <= not(vc_vec(5) & vc_vec(5) & vc_vec(5)& vc_vec(5));
        end if;
    end process;

end Behavioral;
