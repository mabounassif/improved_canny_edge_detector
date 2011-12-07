library ieee;
use ieee.std_logic_1164.all;

entity stage1Test is
end stage1Test;

architecture stage1Test_arch of stage1Test is
	signal clk : std_logic;
	constant clk_period : time := 10 ns;
	signal rst_n : std_logic;
	
	component stage1
		port
		(
			clk : IN std_logic;
			rst_n : IN std_logic
		);
	end component;
	
	begin
	
	s1 : stage1 port map
	(
		clk => clk,
		rst_n => rst_n
	);
	
	clk_process : process
		begin
		clk <= '0';
		wait for clk_period/2;  --	for 5 ns the signal is '0'
		clk <= '1';
		wait for clk_period/2;  --	for the next 5 ns the signal is '1'
	end process;
	
	stimulus : process
		begin
		rst_n <= '0';
		wait for 10 ns;
		rst_n <= '1';		
		wait;
	end process;		
end stage1Test_arch;