--------------------------------------------------
-- Filename: test_bench.vhd
-- Title: Test bench automatic threshold identifier module
-- Author: Mahmoud Abounassif, McGil University
-- Date: September 2011
-------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

ENTITY datapath_test is
end datapath_test;

ARCHITECTURE arch of datapath_test is
  signal clk : std_logic;
  signal rst_n : std_logic;
  signal start : std_logic;
  signal addr : std_logic_vector(7 downto 0);
  signal done : std_logic;
  signal th, tl : std_logic_vector(7 downto 0);
  
  COMPONENT datapath is
  generic (
    pixels       : integer := 1;
    threshold    : integer := 1);
  port(
    -- Common ports
    rst_n       : in std_logic;
    clk         : in std_logic;
    -- Inputs
    start       : in std_logic;
    addr        : in std_logic_vector(7 downto 0);
    -- Outputs
    done        : out std_logic;
    th          : out std_logic_vector(7 downto 0);
    tl          : out std_logic_vector(7 downto 0)
  );
end COMPONENT;
  
begin
  datapath_cir : datapath generic map (pixels => 250, threshold => 1) port map( clk => clk,
    rst_n => rst_n,
    start => start,
    addr => addr,
    done => done,
    th => th,
    tl => tl);
  
  Clock: process
  begin
    clk <= '0';
    WAIT FOR 5 ns;
    clk <= '1';
    WAIT FOR 5 ns;
  end process;
  
  Set_data: process
  begin
    wait for 5 ns;
    rst_n <= '0';
    start <= '0';
    wait for 20 ns;
    start <= '0';
    rst_n <= '1';
    wait for 10 ns;
    addr <= "00000100";
    start <= '1';
    wait for 100 ns;
    addr <= "00000000";
    start <= '1';
    wait for 100 ns;
    
    addr <= "00000001";
    start <= '1';
    wait for 50 ns;
    
    addr <= "01111000";
    start <= '0';
    wait for 100 ns;
    
    addr <= "01010101";
    start <= '1';
    wait for 50 ns;
    
    addr <= "00000111";
    start <= '0';
    wait for 50 ns;
    
    addr <= "01000111";
    start <= '1';
    
    wait for 10 ns;
    wait for 10000 ns;
  end process;
  
end arch;