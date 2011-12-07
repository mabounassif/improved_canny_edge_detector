
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
USE work.pack.all;

entity TB_gradient is
end entity;

architecture a of TB_gradient is


component Directional_Gradients is
  port(
	ROW_0,ROW_1,ROW_2 :in pix_3_row;
    Grad : out gradient);
end component;


signal ROW_0,ROW_1,ROW_2 : pix_3_row;
signal Grad : gradient;
begin
  
  grad_c : Directional_Gradients port map(ROW_0,ROW_1,ROW_2,Grad);

  Test : process
  variable r00 : integer := 120;
  begin
    ROW_0.pix_0 <= to_UNSIGNED(r00,8);
    ROW_0.pix_1 <= to_unsigned(0,8);
    ROW_0.pix_2 <= to_unsigned(100,8);

    ROW_1.pix_0 <= to_unsigned(7,8);
    ROW_1.pix_1 <= to_unsigned(255,8);
    ROW_1.pix_2 <= to_unsigned(5,8);
    
    ROW_2.pix_0 <= to_unsigned(10,8);
    ROW_2.pix_1 <= to_unsigned(5,8);
    ROW_2.pix_2 <= to_unsigned(60,8);        
    wait for 100 ns;
  end process test;
  
end a;
 


