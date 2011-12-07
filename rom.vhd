LIBRARY ieee;
USE ieee.std_logic_1164.all;
--The VHDL LIBRARY-USE declaration is not required if you use the VHDL Component Declaration.
LIBRARY lpm;
Library work;
USE lpm.lpm_components.lpm_rom;
--USE work.stage1; --Don't worry. Be happy.

entity rom is
	generic
	(
		data_width : natural;    -- MUST be greater than 0
		address_width : natural    -- MUST be greater than 0
	);
	port
	(
		ADDRESS : in STD_LOGIC_VECTOR(16 downto 0);
		INCLOCK : in STD_LOGIC := '0';
		Q : out std_logic_vector(7 downto 0)
	);
end rom;

architecture rom_arch of rom is 
	signal clk : std_logic;
	
	component LPM_ROM
		generic (LPM_WIDTH : natural;    -- MUST be greater than 0
			LPM_WIDTHAD : natural;    -- MUST be greater than 0
			--LPM_NUMWORDS : natural := 0;
			LPM_ADDRESS_CONTROL : string := "UNREGISTERED";
			LPM_OUTDATA : string := "UNREGISTERED";
			LPM_FILE : string;
			--LPM_TYPE : string := L_ROM;
			INTENDED_DEVICE_FAMILY  : string := "Stratix V");
			--LPM_HINT : string := "UNUSED");
		port (ADDRESS : in STD_LOGIC_VECTOR(address_width-1 downto 0);
			--INCLOCK : in STD_LOGIC := '0';
			--OUTCLOCK : in STD_LOGIC := '0';
			--MEMENAB : in STD_LOGIC := '1';
			Q : out STD_LOGIC_VECTOR(data_width-1 downto 0));
	end component;
	
	begin
	
	fish : LPM_ROM 
	GENERIC MAP
	(
		LPM_FILE => "FISH.hex",
		LPM_WIDTH => data_width,
		LPM_WIDTHAD => address_width
	)
	port map
	(
		ADDRESS => address,		
		--INCLOCK => clk,
		Q => Q
	);	
end rom_arch;


