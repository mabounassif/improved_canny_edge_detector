



-- TODO add rd output
-- TODO 

LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pack.all;
use std.textio.all;
use IEEE.std_logic_textio.all; -- I/O for logic types
use work.txt_util.all;

--use work.txt_util.all;
--The VHDL LIBRARY-USE declaration is not required if you use the VHDL Component Declaration.
--LIBRARY lpm;
--USE lpm.lpm_components.fifo;


entity final_stage_temp is
	generic
	(
		WIDTH : natural := 8;    -- MUST be greater than 0
		imgW : natural := 362;
		imgH : natural := 282;
		imgWBits : natural := 9;
		imgHBits : natural  := 9;
		edgeL    :       string  := "low.txt";
		edgeH    :       string  := "high.txt"
	);	
	port
	(
		clk : in std_logic;
		rst_n : in std_logic;
		FIFO_empty : in std_logic;
		done        : in std_logic;
    th          : in std_logic_vector(7 downto 0);
    tl          : in std_logic_vector(7 downto 0);
    x_pos : in std_logic_vector (imgWBits -1 downto 0);
		y_pos : in std_logic_vector (imgHBits -1 downto 0);
		mag   : in std_logic_vector (7 downto 0);
		rd_req : out std_logic
	);
end final_stage_temp;



architecture a of final_stage_temp is

file low_file: TEXT open write_mode is edgeL;
file high_file: TEXT open write_mode is edgeH;

begin
  
  rd_req <= '1' when FIFO_empty = '0' and done = '1' else '0';
  write_p : process(clk,done,FIFO_empty)
  variable l : line;
  begin
  if(rising_edge(clk) ) then
    if(FIFO_empty = '0' and done = '1') then
      if ( unsigned(mag) > unsigned(th)) then--th and mag > tl) then 
           write(l, str(to_integer(unsigned(x_pos))));
           writeline(high_file, l);
           write(l, str(to_integer(unsigned(y_pos))));
           writeline(high_file, l);
           write(l, str(255));
           writeline(high_file, l);
      end if;
      if (mag < th and  mag > tl) then 
           write(l, str(to_integer(unsigned(x_pos))));
           writeline(low_file, l);
           write(l, str(to_integer(unsigned(y_pos))));
           writeline(low_file, l);
           write(l, str(255));
           writeline(low_file, l);
         end if;
    end if; 
  end if;
  end process write_p;
end a;
        
        
	     
	