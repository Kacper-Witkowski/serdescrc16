----------------------------------------------------------------------------------
-- Company: PWr
-- Engineer: Kacper Witkowski
	
-- Module Name:    Serializer
-- Project Name: 	 Nadajnik i odbiornik szeregowy z kontrolą poprawności przesyłu CRC16
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

entity deserializer is
    Port ( reset : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           serial_in : in  STD_LOGIC;
           parallel_out : out  STD_LOGIC_vector(7 downto 0));
end deserializer;

architecture Behavioral of deserializer is

signal cnt : std_logic_vector(2 downto 0);
signal d : std_logic_vector(7 downto 0);

begin

counter : process (reset, clk)
begin
    if reset = '0' then
        cnt <= (others => '1');
    elsif (clk'event and clk = '1') then
        cnt <= cnt + "01";
    end if;        
end process counter;

sipo : process (reset, clk)
begin
    if reset = '0' then
        d <= (others => '0');
    elsif (clk'event and clk = '1') then
        if cnt ="001" then
            parallel_out <= d;
            d(7 downto 0) <= d(6 downto 0) & serial_in;
        else
            d(7 downto 0) <= d(6 downto 0) & serial_in;            
        end if;
    end if;    
end process sipo;

end Behavioral;
