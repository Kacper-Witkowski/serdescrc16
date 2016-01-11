----------------------------------------------------------------------------------
-- Company: PWr
-- Engineer: Kacper Witkowski
	
-- Module Name:    Serializer
-- Project Name: 	 Nadajnik i odbiornik szeregowy z kontrolą poprawności przesyłu CRC16
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use work.PCK_CRC16_D1.all;

entity deserializer is
    Port ( reset : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           serial_in : in  STD_LOGIC;
			  serial_out : out std_logic;
           parallel_out : out  STD_LOGIC_vector(7 downto 0));
end deserializer;

architecture Behavioral of deserializer is

signal cnt : std_logic_vector(2 downto 0):= (others => '0');
signal d : std_logic_vector(7 downto 0):= (others => '0');
signal so : std_logic_vector(2 downto 0) := (others => '0');
signal transmission_running : std_logic := '0'; -- czy transmisja działa? generowane po sygnale 0x7e
signal crc_running : std_logic := '0'; -- crc, liczone bo odebraniu 0x7e
signal pckg_cnt : std_logic_vector(4 downto 0) := (others => '0'); --licznik odebranych bajtów
signal newCRC : std_logic_vector(15 downto 0) := (others => '0'); -- wektor wartosci crc

begin

counter : process (reset, clk)
begin
    if reset = '0' then
        cnt <= (others => '0');
    elsif (clk'event and clk = '1') then
        if transmission_running = '1' then
				cnt <= cnt + "01";
				if cnt = "111" and pckg_cnt = "10010" then
					pckg_cnt <= "00000";
				elsif cnt = "111" then
					pckg_cnt <= pckg_cnt + "01";
				end if;
		  end if;
    end if;        
end process counter;

transmission_control : process(reset, clk)
begin
	if reset='0' then
		crc_running <= '0';
		transmission_running <= '0';
	elsif clk'event and clk = '1' then
		if d = "01111110" and pckg_cnt = "00000" then
			crc_running <= '1';
			transmission_running <= '1';
		elsif pckg_cnt = "10001" and cnt = "111" then
			crc_running <= '0';
		elsif cnt = "111" and pckg_cnt = "10010" then
			transmission_running <= '0';
		end if;
	end if;
end process transmission_control;

crc_calc : process(reset, clk)
begin
	if clk'event and clk = '1' then
		if crc_running = '1' then
			newCRC <= nextCRC16(d(0), newCRC);
		end if;
	end if;
end process crc_calc;

sipo : process (reset, clk)
begin
    if reset = '0' then
       d <= (others => '0');
    elsif (clk'event and clk = '1') then
		 d(7 downto 0) <= d(6 downto 0) & serial_in;
		 if transmission_running = '1' and pckg_cnt < "10000" and cnt = "111" then
					parallel_out <= d;
		 end if;
    end if;    
end process sipo;

crcso : process(reset, clk)
begin
	if reset = '0' then
		so <= (others => '0');
	elsif (clk'event and clk = '1') then
		if pckg_cnt = "10010" and cnt = "000" then
			if newCRC = "0000000000000000" then
				so <= "111";
			else
				so <= "101";
			end if;
		else
			so(2 downto 0) <= so(1 downto 0) & '0';
		end if;
	end if;
end process crcso;

serial_out <= so(2);

end Behavioral;
