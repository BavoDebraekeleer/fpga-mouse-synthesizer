----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.01.2023 10:51:58
-- Design Name: 
-- Module Name: audio - Behavioral
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

entity audio is
    Generic (
        clk_input : integer := 50000000; -- 50MHz clock
        count_sqr_range : integer := 1023;
        N_range : integer := 511
    );  
    
    Port (
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        data_in : in STD_LOGIC_VECTOR (7 downto 0);
        data_out : out STD_LOGIC;
        seg : out STD_LOGIC_VECTOR (6 downto 0);
        an : out bit_vector (3 downto 0)
    );
end audio;

architecture Behavioral of audio is

    constant maxcount: integer := (clk_input/20000);
    
        -- signals for PWM
    signal sqr_wave: std_logic := '0';
    signal count_sqr: integer range 0 to count_sqr_range := 0;
    signal N: integer range 0 to N_range := 0;
    
        -- signals for 7 segment display
    signal counter: unsigned(26 downto 0) := to_unsigned(0,27);
    signal digitmux: bit_vector(3 downto 0):="0111";
    signal Seg0, Seg1, Seg2, Seg3: STD_LOGIC_VECTOR (6 downto 0) := "1000000";
    signal N_input0, N_input1, N_input2, N_input3: integer range 0 to 9 :=0;
    
    component seven_seg
        Port(
           N_input : in integer range 0 to 9;
           seg : out STD_LOGIC_VECTOR (6 downto 0)
        );
    end component;

begin

    seg_0: seven_seg
        Port map(
            N_input => N_input0,
            seg=> Seg0
        );
    
    seg_1: seven_seg
        Port map(
            N_input => N_input1,
            seg=> Seg1
        );
    
    seg_2: seven_seg
        Port map(
            N_input => N_input2,
            seg=> Seg2
        );
    
    seg_3: seven_seg
        Port map(
            N_input => N_input3,
            seg=> Seg3
        );

    data_out <= sqr_wave;
 
    an(3 downto 0) <= digitmux;

    generate_pwm: process(clk, reset)
    begin
        if (reset = '1') then
            sqr_wave <= '0';
            count_sqr <= 0;
            N <= 0;
        else 
            if (rising_edge(clk)) then
                count_sqr <= count_sqr +1;
                if (count_sqr >= 0 and count_sqr < N) then
                    sqr_wave <= '1';
                elsif (count_sqr >= N and count_sqr < count_sqr_range-1) then
                    sqr_wave <= '0';
                elsif (count_sqr >= count_sqr_range-1) then
                    count_sqr <= 0;
                    -- N <= to_integer(unsigned('1' & data_in)); 
                    N <= to_integer(unsigned(data_in & '1')); 
                end if;
            end if;                
        end if;
    end process;

    count_for_rotate_anode_mux: process(clk)
    begin
        if (rising_edge(clk)) then
            if (reset='1' or counter >= maxcount) then
                counter <= (others => '0');
                digitmux<= digitmux ror 1;
            else
                counter <= counter +1;
            end if;
        end if;
    end process;

    digitmux_segment_choose: process(digitmux)
    begin
        if (digitmux(0) = '0') then
            seg <= Seg0;
        elsif (digitmux(1) = '0') then
            seg <= Seg1;
        elsif (digitmux(2) = '0') then
            seg <= Seg2;    
        elsif (digitmux(3) = '0') then
            seg <= Seg3;     
        end if;
    end process;
    
    digit_writer: process(clk)
    begin 
        if (reset = '1') then
            N_input0 <= 0;
            N_input1 <= 0;
            N_input2 <= 0;          
            N_input3 <= 0;
        else 
            if(rising_edge(clk)) then  
                N_input0 <= N mod 10;
                N_input1 <= N/10 mod 10;
                N_input2 <= N/100 mod 10;          
                N_input3 <= N/1000 mod 10;
            end if;
        end if;
    end process;

end Behavioral;
