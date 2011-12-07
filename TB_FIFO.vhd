
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
USE work.pack.all;

entity TB_FIFO is
end entity;

architecture a of TB_FIFO is

  component FIFO
    generic
    (
      WIDTH : natural := 8;    -- MUST be greater than 0
      WIDTHU : natural := 9;    -- MUST be greater than 0
      NUMWORDS : natural := 512    -- MUST be greater than 0
      --LPM_SHOWAHEAD : string := "OFF";
      --LPM_TYPE : string := L_FIFO;
      --LPM_HINT : string := "UNUSED");
    );
    port
    (
      DATA : in std_logic_vector(WIDTH-1 downto 0);
      clk : in std_logic;
      WRREQ : in std_logic;
      RDREQ : in std_logic;
      ACLR : in std_logic := '0';
      --SCLR : in std_logic := '0';
      Q : out std_logic_vector(WIDTH-1 downto 0);
      --USEDW : out std_logic_vector(LPM_WIDTHU-1 downto 0);
      FULL : out std_logic;
      EMPTY : out std_logic
    );
  end component;
 
    signal data,q: std_logic_vector (7 downto 0);
    signal clk,wrreq,rdreq,full,empty,rst_n: std_logic;

begin
  
  fifo_c : fifo generic map
    (
      WIDTH => 8,  -- MUST be greater than 0
      WIDTHU => 9,    -- MUST be greater than 0
      NUMWORDS => 128    -- MUST be greater than 0
      --LPM_SHOWAHEAD : string := "OFF";
      --LPM_TYPE : string := L_FIFO;
      --LPM_HINT : string := "UNUSED");
    )
  port map(data,clk,wrreq,rdreq,rst_n,Q,full,empty);
  
  Clock: process
  begin
    clk <= '0';
    WAIT FOR 5 ns;
    clk <= '1';
    WAIT FOR 5 ns;
  end process;
  
  Test : process

  begin
    rst_n <= '0';
    wait for 1 ns;
    
    rst_n <= '1';
    wrreq <= '1';
    rdreq <= '0';
    
    data <= std_logic_vector(to_unsigned(100,8));
    wait for 10 ns;
    
    data <= std_logic_vector(to_unsigned(5,8));
    wait for 10 ns;
    
    data <= std_logic_vector(to_unsigned(200,8));
    wait for 10 ns;
    
    wrreq <= '0';
    rdreq <= '1';
    data <= std_logic_vector(to_unsigned(10,8));
    wait for 10 ns;
    
    data <= std_logic_vector(to_unsigned(50,8));
    wait for 10 ns;
    
    wrreq <= '1';
    data <= std_logic_vector(to_unsigned(20,8));
    wait for 10 ns;
    
    data <= std_logic_vector(to_unsigned(50,8));
    wait for 10 ns;
    
    data <= std_logic_vector(to_unsigned(70,8));
    wait for 10 ns;
    
    data <= std_logic_vector(to_unsigned(10,8));
    wait for 10 ns;
    
    data <= std_logic_vector(to_unsigned(110,8));
    wait for 10 ns;
    
    data <= std_logic_vector(to_unsigned(70,8));
    wait for 10 ns;
    
    data <= std_logic_vector(to_unsigned(66,8));
    wait for 10 ns;
    
    data <= std_logic_vector(to_unsigned(72,8));
    wait for 10 ns;
    
    data <= std_logic_vector(to_unsigned(55,8));
    wait for 10 ns;
    
    data <= std_logic_vector(to_unsigned(10,8));
    wait for 10 ns;
    
    data <= std_logic_vector(to_unsigned(20,8));
    wait for 10 ns;
    
    data <= std_logic_vector(to_unsigned(10,8));
    wait for 10 ns;
    
    data <= std_logic_vector(to_unsigned(50,8));
    wait for 10 ns;
    
    data <= std_logic_vector(to_unsigned(60,8));
    wait for 10 ns;
    
    data <= std_logic_vector(to_unsigned(70,8));
    wait for 10 ns;
    
    data <= std_logic_vector(to_unsigned(10,8));
    wait for 10 ns;
    
    data <= std_logic_vector(to_unsigned(1,8));
    wait for 10 ns;
    
    data <= std_logic_vector(to_unsigned(2,8));
    wait for 10 ns;
    
    data <= std_logic_vector(to_unsigned(5,8));
    wait for 10 ns;
    
    data <= std_logic_vector(to_unsigned(6,8));
    wait for 10 ns;
    
    data <= std_logic_vector(to_unsigned(10,8));
    wait for 10 ns;
    
    data <= std_logic_vector(to_unsigned(1,8));
    wait for 10 ns;
    
    data <= std_logic_vector(to_unsigned(2,8));
    wait for 10 ns;
    
    data <= std_logic_vector(to_unsigned(5,8));
    wait for 10 ns;
    
    data <= std_logic_vector(to_unsigned(6,8));
    wait for 10 ns;
    
    wait for 400 ns;
    
    data <= std_logic_vector(to_unsigned(10,8));
    wait for 10 ns;
    
    data <= std_logic_vector(to_unsigned(1,8));
    wait for 10 ns;
    
    data <= std_logic_vector(to_unsigned(2,8));
    wait for 10 ns;
    
    data <= std_logic_vector(to_unsigned(5,8));
    wait for 10 ns;
    
    data <= std_logic_vector(to_unsigned(6,8));
    wait for 10 ns;
    
    data <= std_logic_vector(to_unsigned(70,8));
    wait for 10 ns;
    
    data <= std_logic_vector(to_unsigned(10,8));
    wait for 10 ns;
    
    data <= std_logic_vector(to_unsigned(1,8));
    wait for 10 ns;
    
    data <= std_logic_vector(to_unsigned(2,8));
    wait for 10 ns;
    
    data <= std_logic_vector(to_unsigned(5,8));
    wait for 10 ns;
    
    wait for 100 ns;
    
  end process test;
  
end a;
 


