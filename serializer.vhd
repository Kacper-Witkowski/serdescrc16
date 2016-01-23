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

entity serializer is
Port (
           parallel_in : in  STD_LOGIC_vector(7 downto 0); --dane wejściowe
           serial_out : out  STD_LOGIC;
			  serial_in : in std_logic;
           clk : in  STD_LOGIC;
           reset : in  STD_LOGIC);
end serializer;

architecture Behavioral of serializer is

signal cnt : std_logic_vector(2 downto 0):= "000"; -- licznik
signal d : std_logic_vector(7 downto 0) := (others => '0'); -- rejestr danych
signal transmission_running : std_logic := '0'; -- czy transmisja działa? generowane po sygnale 0x7e
signal crc_running : std_logic := '0'; -- po przesłaniu całego pakietu kontrolnego, działa crc
signal pckg_cnt : std_logic_vector(4 downto 0) := (others => '0'); --licznik wysłanych pakietów
signal newCRC : std_logic_vector(15 downto 0) := (others => '0'); -- wektor aktualnej wartosci crc

begin

counter : process (reset, clk)
begin
    if reset='0' then
        cnt <= ( others => '0' );
    elsif (clk'event and clk ='1') then
		  if transmission_running = '1' then
				cnt <= cnt + "01"; -- licznik bitów
				if cnt = "111" and pckg_cnt = "10010" then -- po wysłaniu wszystkiego wraz z CRC
					pckg_cnt <= "00000";
				elsif cnt = "111" then 
					pckg_cnt <= pckg_cnt + "01"; -- licznik bajtów
				end if;
		  end if;
	 end if;        
end process counter;

transmission_control : process(reset, clk, d)
begin
	if reset='0' then
		transmission_running <= '0';
		crc_running <= '0';
	elsif clk'event and clk = '1' then
		if d = "01111110" or (pckg_cnt = "00000" and serial_in = '1') then -- wystartuj dopiero po 0x7e
			transmission_running <= '1';
		end if;
		if transmission_running = '1' and cnt = "111" and pckg_cnt = "00000" then
			crc_running <= '1'; -- zacznij liczyć crc po wysłaniu nagłówka
		elsif pckg_cnt = "10001" and cnt = "000" then
			crc_running <= '0'; -- skończ liczyć crc po 16 bajtach
		elsif (cnt = "111" and pckg_cnt = "10010") then -- zatrzymaj się i wyzeruj crc po wysłaniu wszystkiego
			transmission_running <= '0';
		end if;
	end if;
end process transmission_control;

crc_calc : process(reset, clk)
begin
	if clk'event and clk = '1' then
		if crc_running = '1' then
			newCRC <= nextCRC16(d(7), newCRC); -- obliczanie crc
		elsif pckg_cnt = "10010" and cnt = "111" then
			newCRC <= (others => '0');
		end if;
	end if;
end process crc_calc;

piso : process (reset, clk)
begin
    if reset='0' then
        d <= (others => '0');
    elsif (clk'event and clk = '1') then
        if cnt = "000" then  -- zareaguj dopiero na 0x7e lub potwierdzenie zgodnosci crc
				if pckg_cnt = "10001" then
					 d <= newCRC(14 downto 7); -- wyslij pierwszą połowę crc
				elsif pckg_cnt = "10010" then
					 d <= newCRC(7 downto 0);					 -- wyślij drugą połowę crc
				else
					 d <= parallel_in; -- wyślij to co na wejściu
				end if;
        else
            d(7 downto 0) <= d(6 downto 0) & '0'; -- rejestr wysyłanych danych
        end if;
    end if;
end process piso;

serial_out <= d(7); -- wyślij

end Behavioral;
