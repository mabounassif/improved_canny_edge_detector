library ieee; --allows use of the std_logic_vectortype
use ieee.std_logic_1164.all;
--USE ieee.std_logic_arith.all;
use ieee.numeric_std.all;
use work.pack.all;

Entity Directional_Gradients is
  port(
	ROW_0,ROW_1,ROW_2 :in pix_3_row;
  Grad : out std_logic_vector (width+1 downto 0));
end entity Directional_Gradients;

architecture a of Directional_Gradients is

constant H : std_logic_vector (1 downto 0) := "00";
constant V : std_logic_vector (1 downto 0) := "01";
constant DL : std_logic_vector (1 downto 0) := "10";
constant DR : std_logic_vector (1 downto 0) := "11";

signal  EH,EV,EDL,EDR: unsigned (7 downto 0);

begin
	EH <= (ROW_1.pix_2 - ROW_1.pix_0) when (ROW_1.pix_2 > ROW_1.pix_0) else (ROW_1.pix_0 - ROW_1.pix_2); 
	EV <= (ROW_0.pix_1 - ROW_2.pix_1) when (ROW_0.pix_1 > ROW_2.pix_1) else (ROW_2.pix_1 - ROW_0.pix_1); 
	EDL <= (ROW_0.pix_0 - ROW_2.pix_2) when (ROW_0.pix_0 > ROW_2.pix_2) else (ROW_2.pix_2 - ROW_0.pix_0);  
	EDR <= (ROW_0.pix_2 - ROW_2.pix_0) when (ROW_0.pix_2 > ROW_2.pix_0) else (ROW_2.pix_0 - ROW_0.pix_2);  
	
	max_grad : process(EH,EV,EDL,EDR)
	variable TEMP1,TEMP2 : unsigned (7 downto 0); 
	variable TEMP_DIR1,TEMP_DIR2 : std_logic_vector (1 downto 0);
	begin
	  
		if(EDR > EDL) then--EV) then
		  if(EDR > EV) then
		    if(EDR > EH) then
		      Grad(width-1 downto 0) <= std_logic_vector(EDR);
		      grad(width+1 downto width) <= DR; 
		    else
		      Grad(width-1 downto 0) <= std_logic_vector(EH);
		      grad(width+1 downto width) <= H;
		    end if;
		  else
		    if(EV > EH) then
		    		Grad(width-1 downto 0) <= std_logic_vector(EV);
		      grad(width+1 downto width) <= V;
		    else
		      Grad(width-1 downto 0) <= std_logic_vector(EH);
		      grad(width+1 downto width) <= H;
		    end if;
		  end if;
		else
		  if(EDL > EV) then
		    if(EDL > EH) then
		      Grad(width-1 downto 0) <= std_logic_vector(EDL);
		      grad(width+1 downto width) <= DL; 
		    else
		      Grad(width-1 downto 0) <= std_logic_vector(EH);
		      grad(width+1 downto width) <= H;
		    end if;
		  else
		    if(EV > EH) then
		    		Grad(width-1 downto 0) <= std_logic_vector(EV);
		      grad(width+1 downto width) <= V;
		    else
		      Grad(width-1 downto 0) <= std_logic_vector(EH);
		      grad(width+1 downto width) <= H;
		    end if;
		  end if;
		end if;
			--Temp1 := EDR;
			--TEMP_DIR1 := DR;
	--	else
		  --report "hello2" ;
	--		Temp1 := EH;
		--	TEMP_DIR1 := H;
		--end if;
		
		--if(EDL > EV ) then --EDR) then
		--  Temp2 := EDL;
		--	TEMP_DIR2 := DL;
		--else
		  --report "hello" ;
		--	Temp2 := EV;
	--		TEMP_DIR2 := V;
	--	end if;
		
		--if(Temp1 > Temp2) then
		--  Grad(width-1 downto 0) <= std_logic_vector(temp1);
		--  grad(width+1 downto width) <= temp_dir1; 
		--else
		--  Grad(width-1 downto 0) <= std_logic_vector(temp2);
		--  grad(width+1 downto width) <= temp_dir2; 
		--end if;
	end process max_grad;
end a;