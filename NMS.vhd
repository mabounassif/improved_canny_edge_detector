library ieee; --allows use of the std_logic_vectortype
use ieee.std_logic_1164.all;
--USE ieee.std_logic_arith.all;
use ieee.numeric_std.all;
use work.pack.all;

Entity NMS is
  port(
	ROW_0,ROW_1,ROW_2 :in pix_3_row;
	dir : in std_logic_vector (1 downto 0); -- H 00, V 01, LD 10, RD 11
	edge : out std_logic;
  mag : out unsigned (7 downto 0));
end entity NMS;

architecture a of NMS is

signal  EH,EV,EDL,EDR,temp: unsigned (7 downto 0);

begin
  
  with dir select temp <=
    EH when "01", -- 01
    EV when "00", -- 00
    EDL when "11", -- 11
    EDR when "10", -- 10
    "11111111" when others;
    
	EH <= (ROW_1.pix_2 - ROW_1.pix_0) when (ROW_1.pix_2 > ROW_1.pix_0) else (ROW_1.pix_0 - ROW_1.pix_2); 
	EV <= (ROW_0.pix_1 - ROW_2.pix_1) when (ROW_0.pix_1 > ROW_2.pix_1) else (ROW_2.pix_1 - ROW_0.pix_1); 
	EDL <= (ROW_0.pix_0 - ROW_2.pix_2) when (ROW_0.pix_0 > ROW_2.pix_2) else (ROW_2.pix_2 - ROW_0.pix_0);  
	EDR <= (ROW_0.pix_2 - ROW_2.pix_0) when (ROW_0.pix_2 > ROW_2.pix_0) else (ROW_2.pix_0 - ROW_0.pix_2);  
	
	edge <= '1' when temp < 4 else '0';
  mag <=  ROW_1.pix_1 when temp < 4 else "00000000";
end a;

