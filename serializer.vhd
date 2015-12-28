----------------------------------------------------------------------------------
-- Company: PWr
-- Engineer: Kacper Witkowski
	
-- Module Name:    Serializer
-- Project Name: 	 Nadajnik i odbiornik szeregowy z kontrolą poprawności przesyłu CRC16
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use work.PCKG_CRC16.all;

entity serializer is
Port (
           parallel_in : in  STD_LOGIC_vector(7 downto 0); --dane wejściowe
           serial_out : out  STD_LOGIC;
           clk : in  STD_LOGIC;
           reset : in  STD_LOGIC);
end serializer;

architecture Behavioral of serializer is

signal cnt : std_logic_vector(2 downto 0):= "000"; -- licznik
signal d : std_logic_vector(7 downto 0) := (others => '0'); -- rejestr danych
signal transmission_running : std_logic := '0'; -- czy transmisja działa? generowane po sygnale 0x7e
signal dataregister_running : std_logic := '0'; -- po przesłaniu całego pakietu kontrolnego, działa zapisywanie bitów do data_all
signal pckg_cnt : std_logic_vector(3 downto 0) := (others => '0'); --licznik wysłanych pakietów
signal data_all : std_logic_vector(127 downto 0) := (others => '0'); -- rejestr CRC przechowujący i następnie przeliczający wszystkie bity
signal newCRC : std_logic_vector(15 downto 0) := (others => '0');

begin

counter : process (reset, clk)
begin
    if reset='0' then
        cnt <= ( others => '0' );
    elsif (clk'event and clk ='1') then
		  if transmission_running = '1' then
				cnt <= cnt + "01";
				if cnt = "111" then
					pckg_cnt <= pckg_cnt + "01";
				elsif cnt = "111" and pckg_cnt = "1001" then
					pckg_cnt <= "0000";
				end if;
		  end if;
	 end if;        
end process counter;

transmission_control : process(reset, clk)
begin
	if reset='0' then
		transmission_running <= '0';
		dataregister_running <= '0';
	elsif clk'event and clk = '1' then
		if parallel_in = "01111110" then
			transmission_running <= '1';
		end if;
		if transmission_running = '1' and cnt = "111" then
			dataregister_running <= '1';
		end if;
	end if;
end process transmission_control;

crc_calc : process(reset, clk)
begin
	if clk'event and clk = '1' then
		if dataregister_running = '1' and pckg_cnt < "1000" then
			data_all(127 downto 0) <= data_all(126 downto 0) & d(7);
			newCRC <= nextCRC16(data_all, newCRC);
		end if;
	end if;
end process crc_calc;

piso : process (reset, clk)
begin
    if reset='0' then
        d <= (others => '0');
    elsif (clk'event and clk = '1') then
        if cnt="000" and transmission_running = '1' then
				if pckg_cnt = "1000" then
					 d <= newCRC(15 downto 0);
				elsif pckg_cnt = "1001" then
					 d <= newCRC(7 downto 0);
				else
					 d <= parallel_in;
				end if;
        else
            d(7 downto 0) <= d(6 downto 0) & '1';
        end if;
    end if;
end process piso;

serial_out <= d(7);

end Behavioral;
