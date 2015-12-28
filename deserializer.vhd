library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity deserializer is
    Port ( reset : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           serial_in : in  STD_LOGIC;
           parallel_out : out  STD_LOGIC_vector(7 downto 0));
end deserializer;

architecture Behavioral of deserializer is

signal c : std_logic_vector(2 downto 0);
signal d : std_logic_vector(7 downto 0);

begin

counter : process (reset, clk)
begin
    if reset = '0' then
        c <= (others => '1');
    elsif (clk'event and clk = '1') then
        if c = "111" then
            c <= "000";
        else
            c <= c + "01";
        end if;
    end if;        
end process counter;

deser_p : process (reset, clk)
begin
    if reset = '0' then
        d <= (others => '0');
    elsif (clk'event and clk = '1') then
        if c ="000" then
            parallel_out <= d;
            d(7 downto 0) <= d(6 downto 0) & serial_in;
        else
            d(7 downto 0) <= d(6 downto 0) & serial_in;            
        end if;
    end if;    
end process deser_p;
end Behavioral;
