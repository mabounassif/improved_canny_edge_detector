LIBRARY ieee;
USE ieee.std_logic_1164.all;

entity stage1 is
	port
	(
		clk : IN std_logic;
		rst_n : IN std_logic
	);
end stage1;

architecture stage1_arch of stage1 is
	constant address_width : natural := 17; --need to create a package? Don't worry.
	constant data_width : natural := 8; --how to reference these from other files? Be happy.
	
	constant imgW : natural := 362; --need to create a package? Don't worry.
	constant imgH : natural := 282; --how to reference these from other files? Be happy.

	
	component rom
		generic
		(
			data_width : natural;    -- MUST be greater than 0
			address_width : natural    -- MUST be greater than 0
		);
		port
		(
			ADDRESS : in STD_LOGIC_VECTOR(address_width-1 downto 0);
			INCLOCK : in STD_LOGIC;
			
			Q : out std_logic_vector(data_width-1 downto 0)
		);
	end component;
	
	component final_stage_temp is
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
end component;

component datapath is
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
end component;

	component filter
		generic (
			address_width : natural := address_width;
			data_width : natural := data_width;
			imgW : natural := imgW;
			imgH : natural := imgH
		);
		port (
			dataIn : in std_logic_vector(data_width-1 downto 0);
			clk : in std_logic;
			--WRREQ : in std_logic;
			RDREQ : in std_logic;
			rst_n : in std_logic;
			address : out std_logic_vector(address_width-1 downto 0);
		
			empty : out std_logic;
			Q : out std_logic_vector(data_width-1 downto 0)	
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
		signal nms_edge : std_logic_vector (7 downto 0);
		signal wrreq,rdreq,full,empty: std_logic;
		
		signal rdmag,full_mag,filter_queue_empty,full_nms,empty_nms,rd_edge,empty_mag : std_logic;
		signal edge_x,edge_y : std_logic_vector (8 downto 0);
		
		signal address : std_logic_vector(address_width-1 downto 0);
	 signal data : std_logic_vector(data_width-1 downto 0);

	
	 signal output : std_logic_vector(data_width-1 downto 0);
	 signal rdFifo : std_logic;
	 signal bempty : std_logic;
	 signal start : std_logic;
	 signal done        :  std_logic;
    signal th          :  std_logic_vector(7 downto 0);
    signal tl          :  std_logic_vector(7 downto 0);
	begin
	
	g_nms_c : gradient_and_NMS
  generic map
	(
	  width => 8,
		imgW => 359,
		imgH => 280,
		imgWBits => 9,
		imgHBits => 9
	)
		port map
	(
	   clk,rst_n,output,bempty,start,rd_edge,rdFifo,grad_mag_out,full_mag,empty_mag,full_nms,
	   empty_nms,nms_edge,edge_x,edge_y); 

	mem : rom 
	generic map
	(
		data_width => data_width,   -- MUST be greater than 0
		address_width => address_width    -- MUST be greater than 0
	)
	port map
	(	
		ADDRESS => address,
		INCLOCK => clk,
		Q => data
	);
	
	gaussian : filter port map
	(
		dataIn => data,
		clk => clk,
		--WRREQ => wrFifo, --why do these have to be exposed? rd for sure for Mohamed, but... can't drive them from inside module?
		RDREQ => rdFifo, --Don't worry. Be happy.
		Q => output,
		rst_n => rst_n,
		empty => bempty,
		address => address
	);	
	
	start <= '1' when empty_mag = '0' and done = '0' else '0';
	
	threshol : datapath
  generic map (
    pixels      => 100000,
    width        => 8,
    threshold    => 1)
  port map(
    rst_n,clk,start,grad_mag_out,done,th,tl);

  final_stage :  final_stage_temp port map
	(clk,rst_n,empty_nms,done,th,tl,edge_x,edge_y,nms_edge,rd_edge);

end stage1_arch;