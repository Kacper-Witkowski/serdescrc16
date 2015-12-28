library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

entity serializer is
Port (
           parallel_in : in  STD_LOGIC_vector(7 downto 0);
           serial_out : out  STD_LOGIC;
           clk : in  STD_LOGIC;
           reset : in  STD_LOGIC
           );
end serializer;

architecture Behavioral of serializer is

signal c : std_logic_vector(2 downto 0);
signal d : std_logic_vector(7 downto 0);

begin

licznik: process (reset, clk)
begin
    if reset='0' then
        c <= ( others => '0' );
    elsif (clk'event and clk ='1') then
            if c="111" then
                c <= (others => '0');
            else
                c <= c + "01";
            end if;
    end if;        
end process licznik;

rejestr: process (reset, clk)
begin
    if reset='0' then
        d <= (others => '0');
    elsif (clk'event and clk = '1') then
        if c="000" then
            d <= parallel_in;
        else
            d(7 downto 0) <= d(6 downto 0) & '1';
        end if;
    end if;
end process rejestr;

serial_out <= d(7);

end Behavioral;
