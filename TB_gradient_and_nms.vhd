
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
USE work.pack.all;

entity TB_gradient_and_nms is
end entity;

architecture a of TB_gradient_and_nms is


component Directional_Gradients is
  port(
	ROW_0,ROW_1,ROW_2 :in pix_3_row;
    Grad : out gradient);
end component;

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
	
	
  component gradient_and_NMS is
  generic
	(
	  width : natural := 8;
		imgW : natural := 7;
		imgH : natural := 6;
		imgWBits : natural := 9;
		imgHBits : natural  := 9
	);	
		port
	(
	   clk,rst_n : in std_logic;
	   dataIn : in std_logic_vector(width-1 downto 0);
	   empty : in std_logic;
	   rdmag : in std_logic;
	   rd_edge : in std_logic;
	           
     rdreq_o : out std_logic; 
        
	   grad_mag_out : out std_logic_vector(width-1 downto 0);
	   full_mag : out std_logic;
	   empty_mag : out std_logic;
	   --filter_queue_empty : in std_logic;
	   
	   
	   full_nms : out std_logic;
	   empty_nms : out std_logic;
	   nms_edge : out std_logic_vector (width-1 downto 0);
	   edge_x : out std_logic_vector (imgWBits -1 downto 0);
	   edge_y : out std_logic_vector (imgHBits -1 downto 0)
	   
	   );
  end component;

    signal grad_mag_out : std_logic_vector (7 downto 0);
		signal data,q,nms_edge : std_logic_vector (7 downto 0);
		signal clk,wrreq,rdreq,full,empty,rst_n: std_logic;
		signal ROW_0,ROW_1,ROW_2 : pix_3_row;
		
		signal rdmag,full_mag,filter_queue_empty,full_nms,empty_nms,rd_edge,empty_mag : std_logic;
		signal edge_x,edge_y : std_logic_vector (8 downto 0);
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
	
  gradient_and_nms_c : gradient_and_nms port map(clk,rst_n,q,empty,rdmag,rd_edge,rdreq,grad_mag_out,full_mag,
                                                        empty_mag,full_nms,empty_nms,nms_edge,edge_x,edge_y);
  
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
		
			data <= std_logic_vector(to_unsigned(200,8));
		wait for 10 ns;
		
		data <= std_logic_vector(to_unsigned(200,8));
		wait for 10 ns;
		
		data <= std_logic_vector(to_unsigned(133,8));
		wait for 10 ns;
		
		data <= std_logic_vector(to_unsigned(66,8));
		wait for 10 ns;
		
		data <= std_logic_vector(to_unsigned(0,8));
		wait for 10 ns;
		
		data <= std_logic_vector(to_unsigned(0,8));
		wait for 10 ns;
		
		data <= std_logic_vector(to_unsigned(0,8));
		wait for 10 ns;
		
		data <= std_logic_vector(to_unsigned(200,8));
		wait for 10 ns;
		
		data <= std_logic_vector(to_unsigned(200,8));
		wait for 10 ns;
		
		data <= std_logic_vector(to_unsigned(133,8));
		wait for 10 ns;
		
		data <= std_logic_vector(to_unsigned(66,8));
		wait for 10 ns;
		
		data <= std_logic_vector(to_unsigned(0,8));
		wait for 10 ns;
		
		data <= std_logic_vector(to_unsigned(0,8));
		wait for 10 ns;
		
		data <= std_logic_vector(to_unsigned(0,8));
		wait for 10 ns;
		
		data <= std_logic_vector(to_unsigned(200,8));
		wait for 10 ns;
		
		data <= std_logic_vector(to_unsigned(200,8));
		wait for 10 ns;
		
		data <= std_logic_vector(to_unsigned(133,8));
		wait for 10 ns;
		
		data <= std_logic_vector(to_unsigned(66,8));
		wait for 10 ns;
		
		data <= std_logic_vector(to_unsigned(0,8));
		wait for 10 ns;
		
		data <= std_logic_vector(to_unsigned(0,8));
		wait for 10 ns;
		
		data <= std_logic_vector(to_unsigned(0,8));
		wait for 10 ns;
		
		data <= std_logic_vector(to_unsigned(200,8));
		wait for 10 ns;
		
		data <= std_logic_vector(to_unsigned(200,8));
		wait for 10 ns;
		
		data <= std_logic_vector(to_unsigned(133,8));
		wait for 10 ns;
		
		data <= std_logic_vector(to_unsigned(66,8));
		wait for 10 ns;
		
		data <= std_logic_vector(to_unsigned(0,8));
		wait for 10 ns;
		
		data <= std_logic_vector(to_unsigned(0,8));
		wait for 10 ns;
		
		data <= std_logic_vector(to_unsigned(0,8));
		wait for 10 ns;
		
		data <= std_logic_vector(to_unsigned(200,8));
		wait for 10 ns;
		
		data <= std_logic_vector(to_unsigned(200,8));
		wait for 10 ns;
		
		data <= std_logic_vector(to_unsigned(133,8));
		wait for 10 ns;
		
		data <= std_logic_vector(to_unsigned(66,8));
		wait for 10 ns;
		
		data <= std_logic_vector(to_unsigned(0,8));
		wait for 10 ns;
		
		data <= std_logic_vector(to_unsigned(0,8));
		wait for 10 ns;
		
		data <= std_logic_vector(to_unsigned(0,8));
		wait for 10 ns;
		
		data <= std_logic_vector(to_unsigned(0,8));
		wait for 10 ns;
		
		data <= std_logic_vector(to_unsigned(0,8));
		wait for 10 ns;
		
		data <= std_logic_vector(to_unsigned(0,8));
		wait for 10 ns;
		
		data <= std_logic_vector(to_unsigned(0,8));
		wait for 10 ns;
		
		data <= std_logic_vector(to_unsigned(0,8));
		wait for 10 ns;
		
		data <= std_logic_vector(to_unsigned(0,8));
		wait for 10 ns;
		
		data <= std_logic_vector(to_unsigned(0,8));
		wait for 10 ns;
		
		wait for 3000 ns;
		
	end process test;
  
end a;
 


