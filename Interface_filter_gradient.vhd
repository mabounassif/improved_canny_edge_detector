
-- TODO add rd output
-- TODO 

LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pack.all;
--The VHDL LIBRARY-USE declaration is not required if you use the VHDL Component Declaration.
--LIBRARY lpm;
--USE lpm.lpm_components.fifo;


entity Interface_filter_gradient is
  generic
  (
    WIDTH : natural := 8;    -- MUST be greater than 0
    --WIDTHAD : natural := 17;    -- MUST be greater than 0
    imgW : natural := 360;
    imgH : natural := 280
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
end Interface_filter_gradient;

architecture behav of Interface_filter_gradient is
    
  type interface_state_type is (init,buffer_wr,buffer_wait,read,write,wait_wr,done);
  
  signal current_state, next_state : interface_state_type;
  signal r, next_r : integer range 0 to (imgH - 1);
  signal c,next_c : integer range 0 to (imgW);
  signal rd_c, next_rd_c : integer range 0 to (imgW - 1);
  signal r0,r1,r2 : row_type;
  signal wr_to : integer range 0 to 2;
  signal full,empty : std_logic;
  signal en : std_logic;
  
  
begin
  wr_to <= r mod 3;
  wr_req <= '1' when current_state = read else '0';
  read_row : process (clk,rst_n,en)
  begin
  if(rst_n = '0') then
    for i in 0 to (imgW)+1 loop
      r0(i) <= (others => '0');
      r1(i) <= (others => '0');
      r2(i) <= (others => '0');
    end loop;
    c <= 0;
  elsif (rising_edge(clk)) then
    if(current_state = write or current_state = buffer_wr) then
      if(wr_to = 0) then
        r0(c+1) <= unsigned(dataIn);
      elsif (wr_to = 1) then
        r1(c+1) <= unsigned(dataIn);
      elsif (wr_to = 2) then
        r2(c+1) <= unsigned(dataIn);
      end if;
      c <= (c + 1) mod imgW;
    end if;
    
  end if;
  end process read_row;
  
  row_count : process(clk, c,current_state)
  begin
  if(rst_n = '0') then
    r <= 0;
  elsif (rising_edge(clk)) then
    if(current_state = write or current_state = buffer_wr) then
      if( c = ImgW - 1) then
        --c <= 0;
        r <= (r + 1) mod imgH;
      end if;
    end if;
  end if;
  end process row_count;
  
  output_process : process(wr_to,rd_c)
  begin
    if(wr_to = 1) then
      ROW_2.pix_0 <= r0(rd_c);
      ROW_2.pix_1 <= r0(rd_c+1);
      ROW_2.pix_2 <= r0(rd_c+2);
      
      ROW_1.pix_0 <= r2(rd_c);
      ROW_1.pix_1 <= r2(rd_c+1);
      ROW_1.pix_2 <= r2(rd_c+2);
      
      ROW_0.pix_0 <= r1(rd_c);
      ROW_0.pix_1 <= r1(rd_c+1);
      ROW_0.pix_2 <= r1(rd_c+2);
    elsif (wr_to = 2) then
      ROW_2.pix_0 <= r1(rd_c);
      ROW_2.pix_1 <= r1(rd_c+1);
      ROW_2.pix_2 <= r1(rd_c+2);
      
      ROW_1.pix_0 <= r0(rd_c);
      ROW_1.pix_1 <= r0(rd_c+1);
      ROW_1.pix_2 <= r0(rd_c+2);
      
      ROW_0.pix_0 <= r2(rd_c);
      ROW_0.pix_1 <= r2(rd_c+1);
      ROW_0.pix_2 <= r2(rd_c+2);
    else
      ROW_2.pix_0 <= r2(rd_c);
      ROW_2.pix_1 <= r2(rd_c+1);
      ROW_2.pix_2 <= r2(rd_c+2);
      
      ROW_1.pix_0 <= r1(rd_c);
      ROW_1.pix_1 <= r1(rd_c+1);
      ROW_1.pix_2 <= r1(rd_c+2);
      
      ROW_0.pix_0 <= r0(rd_c);
      ROW_0.pix_1 <= r0(rd_c+1);
      ROW_0.pix_2 <= r0(rd_c+2);
    end if;
    
  end process output_process;
  
  rd_req <= '1' when (next_state = write or next_state = buffer_wr) else '0';
  read_req : process(clk,current_state)
  begin
    if(rising_edge(clk)) then
      if(current_state = read ) then-- add state condition
       rd_c  <= (rd_c + 1) mod imgW;
      end if;
    end if;
  end process read_req;
  
  -- CONTROLLER -----------------------------------
  next_state_process : process(clk, current_state,c,FIFO_empty,rd_c)
  begin
    case current_state is
      when init =>
        if(FIFO_empty = '0') then
          next_state <= buffer_wait;
        end if;
      when buffer_wr =>
        if(FIFO_Empty = '0' and not(((c+1) mod imgW = 0))) then
          next_state <= buffer_wr;
        elsif((c+1) mod imgW = 0) then 
          next_state <= wait_wr;
        else
          next_state <= buffer_wait;
        end if;
      when buffer_wait =>
        if(FIFO_Empty = '0') then
          next_state <= buffer_wr;
        else
          next_state <= buffer_wait;
        end if;
      when write =>
        if(FIFO_Empty = '0' and not(((c+1) mod imgW = 0))) then
          next_state <= write;
        elsif((c+1) mod imgW = 0) then 
          next_state <= read;
        else
          next_state <= wait_wr;
        end if;
      when wait_wr =>
        if(FIFO_Empty = '0') then
          next_state <= write;
        else
          next_state <= wait_wr;
        end if;
      when read =>
        if(((rd_c+1) mod imgW) = 0) then
          next_state <= wait_wr;
        else
          next_state <= read;
        end if;
      when done =>
        next_state <= done;
      end case;    
  end process next_state_process;

  
  SEQ : process (clk, rst_n)
   begin
      if(rst_n = '0') then
       current_state <= init;
      elsif(rising_edge(clk)) then
       Current_State <= Next_State;
      end if;
   end process SEQ;
   
  end behav;