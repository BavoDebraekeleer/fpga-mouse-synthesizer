----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 22.12.2022 14:52:57
-- Design Name: 
-- Module Name: vga_controller - Behavioral
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

entity vga_controller is
    Port (
        clk_25 : in STD_LOGIC; -- 25MHz
        clr : in STD_LOGIC;
        vgaRed : out STD_LOGIC_VECTOR (3 downto 0);
        vgaBlue : out STD_LOGIC_VECTOR (3 downto 0);
        vgaGreen : out STD_LOGIC_VECTOR (3 downto 0);
        Hsync : out STD_LOGIC;
        Vsync : out STD_LOGIC
    );
end vga_controller;

architecture Behavioral of vga_controller is

    component vga_640x480 is
        Port (
            clk : in STD_LOGIC;
            clr : in STD_LOGIC;
            hc : out integer range 0 to 800;
            vc : out integer range 0 to 800;
            Hsync : out STD_LOGIC;
            Vsync : out STD_LOGIC;
            vidon : out STD_LOGIC
        );
    end component;
    
    component vga_stripes is
        Port (
            hc : in integer range 0 to 800;
            vc : in integer range 0 to 800;
            vidon : in STD_LOGIC;
            vgaRed : out STD_LOGIC_VECTOR (3 downto 0);
            vgaGreen : out STD_LOGIC_VECTOR (3 downto 0);
            vgaBlue : out STD_LOGIC_VECTOR (3 downto 0)
        );
    end component;
    
    signal hc, vc : integer range 0 to 800;
    signal vidon : STD_LOGIC;

begin

    syncronization: vga_640x480
        Port map(
            clk => clk_25,
            clr => clr,
            hc => hc,
            vc => vc,
            Hsync => Hsync,
            Vsync => Vsync,
            vidon => vidon
        );
    
    channels: vga_stripes
        Port map(
            hc => hc,
            vc => vc,
            vidon => vidon,
            vgaRed => vgaRed,
            vgaGreen => vgaGreen,
            vgaBlue => vgaBlue
        );

end Behavioral;
