--------------------------------------------------
-- Filename: datapath.vhd
-- Title: Automatic threshold identifier module
-- Author: Mahmoud Abounassif, McGil University
-- Date: September 2011
-------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.all;

ENTITY datapath is
  generic (
    pixels       : integer := 1;
    width        : integer := 8;
    threshold    : integer := 1);
  port(
    -- Common ports
    rst_n       : in std_logic;
    clk         : in std_logic;
    -- Inputs
    start       : in std_logic;
    addr        : in std_logic_vector(width-1 downto 0);
    -- Outputs
    done        : out std_logic;
    th          : out std_logic_vector(width-1 downto 0);
    tl          : out std_logic_vector(width-1 downto 0)
  );
end datapath;

ARCHITECTURE datapath_arch of datapath is
-- Memory array
type mem_type is array(0 to (2**addr'length)-1) of std_logic_vector(31 downto 0);
-- Declare a signal as the memory
signal mem : mem_type;
signal counter : std_logic_vector(width-1 downto 0);
signal count : std_logic_vector(31 downto 0);
signal continue, continue2, start_diff : std_logic;

begin  
  -- ===================================================== 
  -- Process that takes care of representing the histogram
  -- in memory.  
  -- =====================================================                 
  PROCESS(clk, rst_n) is
    -- Accumulated data value
  variable accu : std_logic_vector (31 downto 0);
  -- Counter keeping track of number of pixels
  variable cnter : std_logic_vector(31 downto 0);
  variable next_start_diff, cont_v : std_logic;
  begin
      if rst_n = '0' then -- Reset condition
        -- What should happen when reset is triggered
        mem <= (OTHERS => (OTHERS => '0'));
        --mem <= (OTHERS => "00000000000000000000000000000000");
        count <= conv_std_logic_vector(pixels, 32);
        start_diff <= '0';
        continue <= '1';
      elsif rising_edge(clk) then -- Running configuration
        if (start = '1') and (count > "0000000") and (continue = '1') and (continue2 = '0')then -- If allowed to run
          -- Increment value by one at each memory address
          accu := 1 + mem(to_integer(ieee.numeric_std.unsigned(addr)));
          cnter := count - 1 ;
          cont_v := '1';
          next_start_diff := '0';
        elsif (count = "0000000") then
          accu := mem(to_integer(ieee.numeric_std.unsigned(addr)));
          next_start_diff := '1';
          cont_v := '0';
        elsif (start = '0') then
          accu := mem(to_integer(ieee.numeric_std.unsigned(addr)));
          cnter := count;
          next_start_diff := '0';
          cont_v := '1'; 
        else -- Avoid latches
          accu := mem(to_integer(ieee.numeric_std.unsigned(addr)));
          cnter := count;
          next_start_diff := '0';
          cont_v := '0';
        end if;  
        continue <= cont_v;
        count <= cnter;
        start_diff <= next_start_diff;
        mem(to_integer(ieee.numeric_std.unsigned(addr))) <= accu;  
      else
        null;  
      end if;
      
  end PROCESS;
  
  -- ===================================================== 
  -- Process that takes care of getting the thresholds 
  -- from the difference histogram.  
  -- =====================================================  
  PROCESS(clk, rst_n, start_diff) is
    -- Counter of process
  variable cnter : std_logic_vector (width-1 downto 0);
  variable register1, register2, output : ieee.numeric_std.signed (31 downto 0);
  variable cont_v : std_logic;
  begin
    if rst_n = '0' then -- Reset condition
      counter <= (OTHERS => '0');
      cont_v := '0';
      th <= (OTHERS => '0');
      tl <= (OTHERS => '0');
      done <= '0';
    elsif rising_edge(clk) then -- Running condition
      if (counter <= "11111111") and (continue2 = '1') then
        register1 := ieee.numeric_std.signed(mem(to_integer(ieee.numeric_std.unsigned(cnter))));
        register2 := ieee.numeric_std.signed(mem(to_integer(ieee.numeric_std.unsigned(cnter+1))));
        output := register2 - register1;
        output := abs(output);
        if (to_integer(output) > threshold) then
          --mem(to_integer(ieee.numeric_std.unsigned(cnter))) <= conv_std_logic_vector(to_integer(output), 32);
          --mem(to_integer(ieee.numeric_std.unsigned(cnter))) <= conv_std_logic_vector(ieee.numeric_std.unsigned(output),32);
          cont_v := '1';
          cnter := cnter + 1 ;
          done <= '0';
        else
          th <= counter;
          tl <= std_logic_vector( ieee.numeric_std.unsigned(cnter) srl 1 );
          done <= '1';
          cont_v := '0';
          cnter := (OTHERS => '1') ;
        end if;
      elsif (counter = "11111111") then
        cnter := counter;     
        cont_v := '0';
        done <= '1'; 
      elsif (start_diff = '1') then
        cnter := counter;
        cont_v := '1';
        done <= '0';
      else
        done <= '0';
        cnter := counter;
        cont_v := '0';
        th <= (OTHERS => '0');
        tl <= (OTHERS => '0');
      end if;
      counter <= cnter;
      continue2 <= cont_v;
    else
      null;
    end if;
  end PROCESS;
end ARCHITECTURE datapath_arch;

