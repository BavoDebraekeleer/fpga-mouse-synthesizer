----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 22.12.2022 14:51:28
-- Design Name: 
-- Module Name: vga_640x480 - Behavioral
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

entity vga_640x480 is
    Port ( clk : in STD_LOGIC;
           clr : in STD_LOGIC;
           hc : out integer range 0 to 800;
           vc : out integer range 0 to 800;
           Hsync : out STD_LOGIC;
           Vsync : out STD_LOGIC;
           vidon : out STD_LOGIC);
end vga_640x480;

architecture Behavioral of vga_640x480 is

    constant hpixels: integer := 800;
    constant vlines: integer := 521;
    constant hbp: integer := 144;
    constant hfp: integer := 784;
    constant vbp: integer := 31;
    constant vfp: integer := 511;
    signal hcs, vcs: integer range 0 to 800;
    signal vsenable: std_logic;

begin
    process(clk, clr)
    begin
        if clr= '1' then
        hcs<= 0;
        elsif(clk'event and clk= '1') then
            if hcs= hpixels-1 then
            hcs<= 0;vsenable<= '1';
            else
            hcs<= hcs+ 1;
            vsenable<= '0';
            end if;
        end if;
    end process;
    
    Hsync <= '0' when hcs < 96 else '1';
    
    process(clk, clr, vsenable)
    begin
        if clr= '1' then
        vcs<= 0;
        elsif(clk'event and clk= '1' and vsenable='1') then
            if vcs= vlines-1 then
            vcs<= 0;
            else
            vcs<= vcs+ 1;
            end if;
        end if;
    end process;
    
    Vsync <= '0' when vcs < 2 else '1';
    
    vidon<= '1' when (((hcs< hfp) and (hcs>= hbp))
        and ((vcs< vfp) and (vcs>= vbp))) else '0';
    
    hc<= hcs;
    vc<= vcs;

end Behavioral;
