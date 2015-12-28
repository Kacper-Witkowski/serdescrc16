----------------------------------------------------------------------------------
-- Company: PWr
-- Engineer: Kacper Witkowski
	
-- Module Name:    Test Bench
-- Project Name: 	 Nadajnik i odbiornik szeregowy z kontrolą poprawności przesyłu CRC16
----------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
ENTITY serdes_tb IS
END serdes_tb;
 
ARCHITECTURE behavior OF serdes_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT serdes
    PORT(
         we : IN  std_logic_vector(7 downto 0);
         clk : IN  std_logic;
         reset : IN  std_logic;
         wy : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal we : std_logic_vector(7 downto 0) := (others => '0');
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';

 	--Outputs
   signal wy : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: serdes PORT MAP (
          we => we,
          clk => clk,
          reset => reset,
          wy => wy
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      wait for clk_period;    
      we <= "01111110";
      wait for clk_period;
      reset <= '1';
      wait for clk_period*8;
      we <= "10001010";
      wait for clk_period*8;
		we <= "11101011";
      wait for clk_period*8;
      we <= "10001010";
      wait for clk_period*8;
		we <= "11101011";
      wait for clk_period*8;
		we <= "10101011";
      wait for clk_period*8;
      we <= "10001010";
      wait for clk_period*8;
		we <= "11101011";
      wait for clk_period*8;
		we <= "01101011";
      wait for clk_period*36;
		
      assert false severity failure;
   end process;

END;
