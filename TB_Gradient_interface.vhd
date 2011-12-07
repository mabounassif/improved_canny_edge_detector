library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
USE work.pack.all;

entity TB_gradient_interface is
end entity;

architecture a of TB_gradient_interface is


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
		ROW_0,ROW_1,ROW_2 :out pix_3_row
		
		--validOut : out std_logic --Discard this - use Empty from FIFO
	);
end component;

		signal data,q : std_logic_vector (7 downto 0);
		signal clk,wrreq,rdreq,full,empty,rst_n: std_logic;
		signal ROW_0,ROW_1,ROW_2 : pix_3_row;
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
	
  interface : Interface_filter_gradient port map(q,clk,rst_n,empty,rdreq,ROW_0,ROW_1,ROW_2);
  
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
 



