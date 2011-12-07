LIBRARY ieee;
USE ieee.std_logic_1164.all;
--USE IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;
--The VHDL LIBRARY-USE declaration is not required if you use the VHDL Component Declaration.
--LIBRARY lpm;
--USE lpm.lpm_components.fifo;

--TODO: pad the input file with 0s. Done.
--TODO: USE SMALLER IMAGE TO TEST (5x5?) MATLAB OR BY HAND...
--CHECK THAT CORRECT 9 PIXELS ARE GRABBED TO DO MATRIX
--CHECK THAT TIMING AT THE BEGINNING ESPECIALLY - OFF BY 1 CLOCK...
--CHECK FOR EMPTY AND FULL FIFO (need extra state for full)
--TEST INIT AND MULT SEPARATELY?

entity filter is
	generic
	(
		address_width : natural;
		data_width : natural;
		imgW : natural;
		imgH : natural
	);	
	port
	(
		dataIn : in std_logic_vector(data_width-1 downto 0);
		clk : in std_logic;
		rst_n : in std_logic;
		--WRREQ : in std_logic; --REMOVE THIS AS A PORT. How are the formal ports accessible in stage 1 even though they are not listed as ports here?
		RDREQ : in std_logic ;--:= '1'; --Don't worry. Be happy.
		
		address : out std_logic_vector(address_width-1 downto 0);
		Q : out std_logic_vector(data_width-1 downto 0);
		empty : out std_logic
		
		--validOut : out std_logic --Discard this - use Empty from FIFO
	);
end filter;

architecture filter_arch of filter is
	--generic LPM_WIDTH : natural := 8;
	--type pixel is std_logic_vector(7 downto 0); --can this be done?
	signal toFifo, outData : std_logic_vector(data_width-1 downto 0);
	--signal clkSig : std_logic;
	signal cnt : unsigned(address_width-1 downto 0);
	signal nxtCnt : unsigned(address_width-1 downto 0) := to_unsigned((imgW + 1),address_width); --do this in reset starts here due to zero padding
	signal frmInitCnt, nxtFrmInitCnt : unsigned(3 downto 0) := "0000"; --SETTING THIS VARIABLE CAUSED ITERATION LIMIT REACHED
	--signal y : std_logic_vector(7 downto 0);
	--signal h_constant : unsigned(7 downto 0); --the factor in front of the kernel (1/?)
	type state_type is (INIT, MULT, DELAY, SHIFT, BUFFER_FULL, DONE); --give mult maybe 5 clock cycles
	signal state, nxtState : state_type;
	--signal valid : std_logic;
	signal rdFifo : std_logic; --:= '1'; 
	signal wrFifo : std_logic := '0';
	type nextColumn is array(0 to 1) of std_logic_vector(7 downto 0);
	signal col, nxtCol : nextColumn;
	signal tmpToFifo : std_logic_vector(15 downto 0) := (others=>'0');
	signal bfull : std_logic;
	--signal bempty : std_logic;
	
	--signal nrml : unsigned(2 downto 0) := "100";
	
	component LPM_FIFO
		generic
		(
			LPM_WIDTH : natural := data_width;    -- MUST be greater than 0
			LPM_WIDTHU : natural := 17;    -- MUST be greater than 0
			LPM_NUMWORDS : natural := imgW*imgH    -- MUST be greater than 0
			--LPM_SHOWAHEAD : string := "OFF";
			--LPM_TYPE : string := L_FIFO;
			--LPM_HINT : string := "UNUSED");
		);
		port
		(
			DATA : in std_logic_vector(data_width-1 downto 0);
			CLOCK : in std_logic;
			WRREQ : in std_logic;
			RDREQ : in std_logic;
			--ACLR : in std_logic := '0';
			--SCLR : in std_logic := '0';
			Q : out std_logic_vector(data_width-1 downto 0);
			--USEDW : out std_logic_vector(LPM_WIDTHU-1 downto 0);
			FULL : out std_logic;
			EMPTY : out std_logic
		);
	end component;
	
	component FIFO is
		generic
		(
			WIDTH : natural := 8;    -- MUST be greater than 0
			WIDTHU : natural := 9;    -- MUST be greater than 0
			NUMWORDS : natural := imgW*imgH    -- MUST be greater than 0
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
			ACLR : in std_logic;
			--SCLR : in std_logic := '0';
			Q : out std_logic_vector(WIDTH-1 downto 0);
			--USEDW : out std_logic_vector(LPM_WIDTHU-1 downto 0);
			FULL : out std_logic;
			EMPTY : out std_logic
		);

end component;
	type kernelType is record
		h0 : std_logic_vector(7 downto 0);
		h1 : std_logic_vector(7 downto 0);
		h2 : std_logic_vector(7 downto 0);
		h3 : std_logic_vector(7 downto 0);
		h4 : std_logic_vector(7 downto 0);
		h5 : std_logic_vector(7 downto 0);
		h6 : std_logic_vector(7 downto 0);
		h7 : std_logic_vector(7 downto 0);
		h8 : std_logic_vector(7 downto 0);		
	end record;
	
	type frameType is record
		x0 : std_logic_vector(7 downto 0);
		x1 : std_logic_vector(7 downto 0);
		x2 : std_logic_vector(7 downto 0);
		x3 : std_logic_vector(7 downto 0);
		x4: std_logic_vector(7 downto 0);
		x5 : std_logic_vector(7 downto 0);
		x6: std_logic_vector(7 downto 0);
		x7: std_logic_vector(7 downto 0);
		x8: std_logic_vector(7 downto 0);
	end record;
	
	signal kernel : kernelType;
	signal frame, nxtFrame : frameType;
	
	begin
	
	kernel.h0 <= "00000010";
	kernel.h1 <= "00000001";
	kernel.h2 <= "00000010";
	kernel.h3 <= "00000001";
	kernel.h4 <= "00000100";
	kernel.h5 <= "00000001";
	kernel.h6 <= "00000010";
	kernel.h7 <= "00000001";
	kernel.h8 <= "00000010";
	
	output : LPM_FIFO port map
	(
		DATA => toFifo,
		CLOCK => clk,
		WRREQ => wrFifo,
   	RDREQ => RDREQ,
		FULL => bfull,
		EMPTY => empty,
		Q => outData
	);
	
	--output : FIFO port map
	--	(
	--		toFIFO, clk, wrFIFO,rdFIFO,rst_n,Q,bfull,empty
		--);

	process(clk, rst_n)
		begin
		if (rst_n = '0') then --reset asserted
			--ADD MORE SIGNALS!!!
			state <= INIT; --default state
			cnt <= unsigned(imgW + to_unsigned(1, address_width));
			frmInitCnt <= (others => '0');
			--valid <= '0';
			--wrFifo <= '0';
			col <= (others => (others => '0'));			
		elsif rising_edge(clk) then --assign next signal
			cnt <= nxtCnt;
			frmInitCnt <= nxtFrmInitCnt;
			state <= nxtState;
			frame <= nxtFrame;
			col <= nxtCol;
			--tmpA <= nxt_tmpA; 
			--tmpB <= nxt_tmpB;
			--k <= nxt_K;
			--state <= nxt_state;
		end if;
	end process;
	
	process(state, cnt, frmInitCnt, frame, bfull)
		begin

		nxtState <= INIT; --initial state
				
		case state is
			when INIT =>
				if (frmInitCnt = 8) then 
					nxtState <= MULT;
				end if;
			when MULT =>
				if (bfull = '1') then
					nxtState <= BUFFER_FULL;
				else
					nxtState <= DELAY;
				end if;
			when DELAY =>
				if (cnt = (imgW*imgH - imgW - 2)) then
					report "Happened in delay bitches";
					nxtState <= DONE;
				else
					nxtState <= SHIFT;
				end if;
			when SHIFT =>
				if (cnt = (imgW*imgH - imgW - 2)) then
					report "Happened in shift bitches";
					nxtState <= DONE;
				elsif ((cnt mod imgW) = imgW - 2) then
					report "going to init.";
					nxtState <= INIT;
				else
					nxtState <= MULT;	
				end if;
			when BUFFER_FULL =>
				if (bfull = '1') then
					nxtState <= BUFFER_FULL;
				else
					nxtState <= DELAY;
				end if;
			when DONE =>
				nxtState <= DONE;
				assert False report "Done" severity warning;
			when others =>
				nxtState <= INIT; --default state
		end case;
	end process;
	
	nxtFrame.x0 <= frame.x1 when state = SHIFT else --can't be in SHIFT at end of line - handled in delay state?
					dataIn when state = INIT and frmInitCnt = "0000" else
					frame.x0;
	nxtFrame.x1 <= frame.x2 when state = SHIFT else
					dataIn when state = INIT and frmInitCnt = "0001" else
					frame.x1;
	nxtFrame.x2 <= dataIn when state = INIT and frmInitCnt = "0010" else
					col(0) when state = SHIFT else
					frame.x2; --BUFFER PIXEL AT MULT? Done.
	nxtFrame.x3 <= frame.x4 when state = SHIFT else
					dataIn when state = INIT and frmInitCnt = "0011" else
					frame.x3;
	nxtFrame.x4 <= frame.x5 when state = SHIFT else
					dataIn when state = INIT and frmInitCnt = "0100" else
					frame.x4;	
	nxtFrame.x5 <= dataIn when state = INIT and frmInitCnt = "0101" else
					col(1) when state = SHIFT else
					frame.x5; --BUFFER PIXEL AT DELAY? Done.
	nxtFrame.x6 <= frame.x7 when state = SHIFT else 
					dataIn when state = INIT and frmInitCnt = "0110" else
					frame.x6;
	nxtFrame.x7 <= frame.x8 when state = SHIFT else 
					dataIn when state = INIT and frmInitCnt = "0111" else
					frame.x7;	
	nxtFrame.x8 <= dataIn when (state = INIT and frmInitCnt = "1000") or state = SHIFT else
					frame.x8; --GRAB PIXEL AT SHIFT? Done.
				
	nxtCol(0) <= dataIn when state = MULT else
					col(0);
					
	nxtCol(1) <= dataIn when state = DELAY else
					col(1);	
	
	nxtCnt <= (others => '0') when cnt = (imgW*imgH - 1) else
			cnt + 3 when ((cnt mod imgW) = (imgW - 2)) else
			cnt + 1 when state = DELAY else
			cnt;
				
	nxtFrmInitCnt <= (others => '0') when rst_n = '0' else
					frmInitCnt + 1 when state = INIT else 
					(others => '0') when frmInitCnt = "1001" else
					frmInitCnt;
				
	address <= std_logic_vector(cnt - (imgW + 1)) when state = INIT and frmInitCnt = "0000" else
				std_logic_vector(cnt - imgW) when state = INIT and frmInitCnt = "0001" else
				std_logic_vector(cnt - (imgW - 1)) when state = INIT and frmInitCnt = "0010" else
				std_logic_vector(cnt - 1) when state = INIT and frmInitCnt = "0011" else
				std_logic_vector(cnt) when state = INIT and frmInitCnt = "0100" else
				std_logic_vector(cnt + 1) when state = INIT and frmInitCnt = "0101" else
				std_logic_vector(cnt + (imgW - 1)) when state = INIT and frmInitCnt = "0110" else
				std_logic_vector(cnt + (imgW)) when state = INIT and frmInitCnt = "0111" else
				std_logic_vector(cnt + (imgW + 1)) when state = INIT and frmInitCnt = "1000" else
				std_logic_vector(cnt - (imgW - 2)) when state = MULT else
				std_logic_vector(cnt + 2) when state = DELAY else
				std_logic_vector(cnt + (imgW + 1)) when state = SHIFT else --+1 because we increment cnt at SHIFT?
				(others => '0');
	
		--may take multiple clock cycles (for multiplication)
		--RHS needs to be 8 bits (discard msb)
	tmpToFifo <= std_logic_vector((unsigned(kernel.h0)*unsigned(frame.x0) + unsigned(kernel.h1)*unsigned(frame.x1) + 
				unsigned(kernel.h2)*unsigned(frame.x2) + unsigned(kernel.h3)*unsigned(frame.x3) + 
				unsigned(kernel.h4)*unsigned(frame.x4) + unsigned(kernel.h5)*unsigned(frame.x5) + 
				unsigned(kernel.h6)*unsigned(frame.x6) + unsigned(kernel.h7)*unsigned(frame.x7) + 
				unsigned(kernel.h8)*unsigned(frame.x8)) srl 4); --make this variable bigger to accomodate the large
				--mult-acc value? Done.		
	
	toFifo <= tmpToFifo(7 downto 0);
	
	wrFifo <= '1' when state = DELAY else
				'0';
				
	Q <= outData;
				
	--bfull <= FULL;
	
	--DATA <= y;

	--Discard this. Use empty signal from FIFO
	--valid <= '1' when state = DELAY else --check this to ensure timing is OK with stage 2
				--'0'; --consider changing this to indicate that the FIFO has data (keep asserted while true)
end filter_arch;