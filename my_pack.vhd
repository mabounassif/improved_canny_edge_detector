LIBRARY ieee;
USE ieee.std_logic_1164.all;
--USE ieee.std_logic_arith.all;
use ieee.numeric_std.all;


PACKAGE pack IS 

	constant imgW : natural := 359; -- 362 --need to create a package? Don't worry.
	constant imgH : natural := 280; -- 282--how to reference these from other files? Be happy.
	constant width : natural := 8;
	
	--type Direction_Type is (V,H,DL,DR);
  
	type gradient is record
		dir : std_logic_vector (1 downto 0);
		mag : unsigned (7 downto 0);
	end record;
  
	type pix_3_row is record
		pix_0 : unsigned (7 downto 0);
		pix_1 : unsigned (7 downto 0);
		pix_2 : unsigned (7 downto 0);
	end record;
	
	type row_type is array (0 to (imgW)+1) of unsigned(width - 1 downto 0);
	type gradient_row_type is array (0 to (imgW)+1) of unsigned((width + 1) downto 0);
	
	type possible_edge is record
		mag : unsigned (7 downto 0);
		x_pos : unsigned (8 downto 0);
		y_pos : unsigned (8 downto 0);
	end record;
	
END pack;
