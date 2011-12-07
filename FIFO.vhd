LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pack.all;
use std.textio.all;

entity FIFO is
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
			ACLR : in std_logic;
			--SCLR : in std_logic := '0';
			Q : out std_logic_vector(WIDTH-1 downto 0);
			--USEDW : out std_logic_vector(LPM_WIDTHU-1 downto 0);
			FULL : out std_logic;
			EMPTY : out std_logic
		);

end entity;

architecture a of FIFO is

type queue_type is array (0 to (NUMWORDS)-1) of std_logic_vector(width - 1 downto 0);

signal tail : integer range 0 to (NUMWORDS-1) := 0;
signal head : integer range 0 to (NUMWORDS-1) := 0;
signal saved_words : integer range 0 to (NUMWORDS-1) := 0;
signal queue : queue_type;

begin
  
  EMPTY <= '1' when saved_words = 0 else '0';
  FULL <= '1' when saved_words = (NUMWORDS-1) else '0';
  
  Q <= queue(head);
  
  queue_p : process(RDREQ, clk, aclr,wrReq)
  begin
    --report "process :)";
    if(aclr = '0') then 
      --report "clear";
      head <= 0;
      tail <= 0;
      saved_words <= 0;
   	  for i in 0 to (NUMWORDS)-1 loop
	 	   queue(i) <= (others => '0');
		  end loop;
		elsif rising_edge(clk) then
      --report "I'll check the if condition";
		  if(rdreq = '1' and wrreq = '1') then
		    --print("I am writing and reading" & wrreq & "hmm");
		    -- ASSERT wrreq = '0'            -- assert statement will report nothing because
       -- REPORT "wierd"  -- a /= b evaluates to TRUE
        --SEVERITY WARNING;
		    head <= (head + 1 ) mod NUMWORDS;
        queue(tail) <= data;
        tail <= (tail + 1) mod NUMWORDS;  
		  elsif(wrreq = '1') then
		    --report "I am writing" & wrreq;
		    --print("I am writing" & wrreq & "hmm");
		   -- ASSERT wrreq = '0'            -- assert statement will report nothing because
       -- REPORT "wierd"  -- a /= b evaluates to TRUE
       -- SEVERITY WARNING;
		    queue(tail) <= data;
        tail <= (tail + 1) mod NUMWORDS;  
        saved_words <= saved_words + 1;
		  elsif(rdreq = '1') then
		    head <= (head + 1) mod NUMWORDS;
		    saved_words <= saved_words - 1;
		  end if;
	  end if;
	end process queue_p;
end a;
		      
      
