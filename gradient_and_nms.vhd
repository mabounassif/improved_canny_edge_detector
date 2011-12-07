
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
USE work.pack.all;

entity gradient_and_NMS is
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
end entity;

architecture a of gradient_and_NMS is


component Directional_Gradients is
  port(
	ROW_0,ROW_1,ROW_2 :in pix_3_row;
    Grad : out std_logic_vector (width+1 downto 0));
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
	
	component Interface_filter_gradient is
	generic
	(
		WIDTH : natural := 8;    -- MUST be greater than 0
		--LPM_WIDTHAD : natural := 17;    -- MUST be greater than 0
		imgW : natural := 5;
		imgH : natural := 6
	);	
	port
	(
		dataIn : in std_logic_vector(WIDTH-1 downto 0);
		clk : in std_logic;
		rst_n : in std_logic;
		FIFO_empty : in std_logic;
		rd_req : out std_logic;
		ROW_0,ROW_1,ROW_2 :out pix_3_row;
		wr_req : out std_logic
		--validOut : out std_logic --Discard this - use Empty from FIFO
	);
end component;

component NMS is
  port(
	ROW_0,ROW_1,ROW_2 :in pix_3_row;
	dir : in std_logic_vector (1 downto 0); -- H 00, V 01, LD 10, RD 11
	edge : out std_logic;
  mag : out unsigned (7 downto 0));
end component;

component NMS_Interface is
	generic
	(
		WIDTH : natural := 8;    -- MUST be greater than 0
		--WIDTHAD : natural := 17;    -- MUST be greater than 0
		imgW : natural := 362; --2
		imgH : natural := 282; --2
		imgWBits : natural := 9;
		imgHBits : natural  := 9
	);	
	port
	(
		dataIn : in std_logic_vector(WIDTH+1 downto 0);
		clk : in std_logic;
		rst_n : in std_logic;
		FIFO_empty : in std_logic;
		rd_req : out std_logic;
		ROW_0,ROW_1,ROW_2 :out pix_3_row;		
		dir                :out std_logic_vector(1 downto 0);
		x_pos : out std_logic_vector (imgWBits -1 downto 0);
		y_pos : out std_logic_vector (imgHBits -1 downto 0);
		--validOut : out std_logic --Discard this - use Empty from FIFO
		wr_req : out std_logic
	);
end component;

----------------------------------------------------
---------------------------------------------------

		signal data : std_logic_vector (7 downto 0);
		signal wrreq,rdreq,full,empty2,rdreq2,edge : std_logic;
		signal ROW_0,ROW_1,ROW_2,ROW_00,ROW_01,ROW_02 : pix_3_row;
		signal grad,q : std_logic_vector (width+1 downto 0);
		signal grad_mag: std_logic_vector(width-1 downto 0);
		signal dir : std_logic_vector(1 downto 0);
		signal nms_mag : unsigned(width-1 downto 0);
		signal x_pos : std_logic_vector(imgWBits - 1 downto 0);
		signal y_pos : std_logic_vector(imgHBits - 1 downto 0);
		signal wr_req1,wr_req2 : std_logic;
		signal wr_edge : std_logic;
		------------------------------------------------
------------------------------------------------------
begin
  
  wr_edge <= '1' when wr_req2 = '1' AND edge = '1' else '0';
  rdreq_o <= rdreq; 
  
  interface_gradient : Interface_filter_gradient generic map
  (
    WIDTH  => 8,    -- MUST be greater than 0
    --WIDTHAD : natural := 17;    -- MUST be greater than 0
    imgW => imgW,
    imgH => imgH
  ) port map(dataIn,clk,rst_n,empty,rdreq,ROW_0,ROW_1,ROW_2,wr_req1);
  
  compare : directional_gradients port map(ROW_0,ROW_1,ROW_2,grad);
  
  fifo_gradient : fifo generic map
		(
			WIDTH => 10,  -- MUST be greater than 0
			WIDTHU => 9,    -- MUST be greater than 0
			NUMWORDS => imgW*imgH    -- MUST be greater than 0
			--LPM_SHOWAHEAD : string := "OFF";
			--LPM_TYPE : string := L_FIFO;
			--LPM_HINT : string := "UNUSED");
		)
	port map(grad,clk,wr_req1,rdreq2,rst_n,q,full,empty2);
	
	

	
  fifo_gradient_mag : fifo generic map
		(
			WIDTH => 8,  -- MUST be greater than 0
			WIDTHU => 9,    -- MUST be greater than 0
			NUMWORDS => imgW*(imgH+1)    -- MUST be greater than 0
			--LPM_SHOWAHEAD : string := "OFF";
			--LPM_TYPE : string := L_FIFO;
			--LPM_HINT : string := "UNUSED");
		)
	port map(grad(width-1 downto 0),clk,wr_req1,rdmag,rst_n,grad_mag,full_mag,empty_mag);
  
  grad_mag_out <= grad_mag;
  
  nms_inter :  NMS_Interface generic map
	(
		WIDTH  => 8,    -- MUST be greater than 0
		--WIDTHAD : natural := 17;    -- MUST be greater than 0
		imgW => imgW, --imgW
		imgH => imgH, -- imgH
		imgWBits => 9,
		imgHBits => 9
	)	
	port map
	(q,clk,rst_n,empty2,rdreq2,ROW_00,ROW_01,ROW_02,dir,x_pos,y_pos,wr_req2);


  nms_c : NMS
  port map(
	ROW_00,ROW_01,ROW_02,dir,edge,nms_mag);


  fifo_possible_edges : fifo generic map
		(
			WIDTH => width,  -- MUST be greater than 0
			WIDTHU => 9,    -- MUST be greater than 0
			NUMWORDS => imgH * imgW    -- MUST be greater than 0
			--LPM_SHOWAHEAD : string := "OFF";
			--LPM_TYPE : string := L_FIFO;
			--LPM_HINT : string := "UNUSED");
		)
	port map(std_logic_vector(nms_mag),clk,wr_edge,rd_edge,rst_n,nms_edge,full_nms,empty_nms);
	
	fifo_possible_edges_x : fifo generic map
		(
			WIDTH => imgWBits,  -- MUST be greater than 0
			WIDTHU => 9,    -- MUST be greater than 0
			NUMWORDS => imgH * imgW    -- MUST be greater than 0
			--LPM_SHOWAHEAD : string := "OFF";
			--LPM_TYPE : string := L_FIFO;
			--LPM_HINT : string := "UNUSED");
		)
	port map(x_pos,clk,wr_edge,rd_edge,rst_n,edge_x,full_nms,empty_nms);
	
	fifo_possible_edges_y : fifo generic map
		(
			WIDTH => imgHBits,  -- MUST be greater than 0
			WIDTHU => 9,    -- MUST be greater than 0
			NUMWORDS => imgH * imgW    -- MUST be greater than 0
			--LPM_SHOWAHEAD : string := "OFF";
			--LPM_TYPE : string := L_FIFO;
			--LPM_HINT : string := "UNUSED");
		)
	port map(y_pos,clk,wr_edge ,rd_edge,rst_n,edge_y,full_nms,empty_nms);
end a;


 




