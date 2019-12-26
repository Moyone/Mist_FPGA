library ieee;
use ieee.std_logic_1164.all,ieee.numeric_std.all;

entity gravitar_pgm_rom3 is
port (
	clk  : in  std_logic;
	addr : in  std_logic_vector(11 downto 0);
	data : out std_logic_vector(7 downto 0)
);
end entity;

architecture prom of gravitar_pgm_rom3 is
	type rom is array(0 to  4095) of std_logic_vector(7 downto 0);
	signal rom_data: rom := (
		X"00",X"00",X"01",X"00",X"FF",X"00",X"00",X"00",X"01",X"00",X"00",X"00",X"00",X"00",X"81",X"00",
		X"00",X"00",X"01",X"00",X"00",X"00",X"00",X"00",X"81",X"00",X"81",X"00",X"00",X"00",X"01",X"00",
		X"00",X"00",X"01",X"00",X"81",X"00",X"00",X"00",X"01",X"00",X"00",X"01",X"01",X"01",X"01",X"01",
		X"01",X"01",X"01",X"01",X"01",X"01",X"01",X"01",X"01",X"01",X"01",X"00",X"02",X"04",X"06",X"08",
		X"0A",X"0C",X"0E",X"10",X"12",X"14",X"16",X"18",X"1A",X"1C",X"1E",X"FF",X"00",X"FF",X"00",X"01",
		X"FF",X"FF",X"00",X"00",X"00",X"01",X"FF",X"FF",X"00",X"01",X"FF",X"FF",X"00",X"01",X"FF",X"FF",
		X"00",X"FF",X"00",X"00",X"00",X"01",X"FF",X"FF",X"00",X"FF",X"00",X"01",X"FF",X"00",X"00",X"FF",
		X"00",X"FF",X"00",X"FF",X"00",X"01",X"FF",X"FF",X"00",X"00",X"00",X"01",X"FF",X"FF",X"00",X"01",
		X"FF",X"FF",X"00",X"01",X"FF",X"FF",X"00",X"FF",X"00",X"FF",X"00",X"01",X"FF",X"FF",X"00",X"FF",
		X"00",X"FF",X"00",X"01",X"FF",X"FF",X"00",X"01",X"FF",X"FF",X"00",X"FF",X"00",X"00",X"01",X"00",
		X"00",X"00",X"00",X"00",X"01",X"00",X"02",X"00",X"FF",X"00",X"00",X"00",X"01",X"00",X"01",X"00",
		X"01",X"00",X"00",X"00",X"00",X"00",X"01",X"00",X"01",X"00",X"01",X"00",X"00",X"00",X"01",X"00",
		X"02",X"00",X"FF",X"00",X"FF",X"00",X"00",X"00",X"00",X"00",X"01",X"00",X"01",X"00",X"00",X"00",
		X"01",X"00",X"00",X"00",X"01",X"00",X"00",X"00",X"01",X"00",X"00",X"00",X"00",X"00",X"01",X"00",
		X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"01",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
		X"01",X"00",X"00",X"00",X"00",X"00",X"01",X"00",X"81",X"00",X"81",X"00",X"00",X"00",X"00",X"00",
		X"01",X"00",X"01",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"01",X"00",X"01",X"00",X"00",X"00",
		X"01",X"00",X"81",X"00",X"81",X"00",X"81",X"00",X"00",X"00",X"00",X"00",X"01",X"00",X"81",X"00",
		X"00",X"00",X"01",X"00",X"81",X"00",X"01",X"00",X"00",X"00",X"01",X"00",X"00",X"00",X"00",X"00",
		X"01",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"01",X"00",X"00",X"00",X"00",X"00",
		X"00",X"01",X"05",X"04",X"01",X"04",X"04",X"01",X"05",X"04",X"01",X"01",X"03",X"01",X"04",X"01",
		X"01",X"00",X"02",X"0C",X"14",X"16",X"1E",X"26",X"28",X"32",X"3A",X"3C",X"3E",X"44",X"46",X"4E",
		X"50",X"FF",X"00",X"FF",X"00",X"01",X"FF",X"FF",X"00",X"80",X"00",X"80",X"00",X"FF",X"00",X"FF",
		X"00",X"00",X"00",X"01",X"FF",X"FF",X"00",X"FF",X"00",X"01",X"FF",X"FF",X"00",X"01",X"FF",X"FF",
		X"00",X"FF",X"00",X"FF",X"00",X"00",X"00",X"01",X"FF",X"FF",X"00",X"01",X"FF",X"FF",X"00",X"FF",
		X"00",X"00",X"00",X"01",X"FF",X"FF",X"00",X"60",X"FF",X"A0",X"00",X"01",X"FF",X"FF",X"00",X"01",
		X"FF",X"80",X"00",X"80",X"00",X"FF",X"00",X"00",X"00",X"01",X"FF",X"00",X"00",X"FF",X"00",X"00",
		X"00",X"01",X"FF",X"00",X"00",X"FF",X"00",X"FF",X"00",X"00",X"00",X"01",X"FF",X"00",X"00",X"FF",
		X"00",X"00",X"00",X"01",X"FF",X"00",X"00",X"FF",X"00",X"FF",X"00",X"01",X"FF",X"60",X"00",X"A0",
		X"FF",X"00",X"00",X"80",X"00",X"80",X"00",X"A0",X"FF",X"60",X"00",X"00",X"00",X"01",X"FF",X"FF",
		X"00",X"01",X"FF",X"FF",X"00",X"01",X"FF",X"FF",X"00",X"80",X"00",X"80",X"00",X"00",X"00",X"C0",
		X"01",X"00",X"00",X"00",X"01",X"00",X"00",X"C0",X"00",X"00",X"02",X"00",X"00",X"80",X"FD",X"00",
		X"00",X"40",X"FE",X"00",X"00",X"C0",X"01",X"C0",X"01",X"C0",X"00",X"40",X"FE",X"00",X"00",X"00",
		X"01",X"C0",X"00",X"00",X"01",X"00",X"00",X"00",X"01",X"00",X"00",X"00",X"00",X"C0",X"00",X"00",
		X"00",X"60",X"00",X"00",X"00",X"A0",X"00",X"00",X"01",X"00",X"00",X"C0",X"01",X"80",X"00",X"00",
		X"00",X"00",X"00",X"C0",X"00",X"00",X"00",X"60",X"00",X"00",X"00",X"A0",X"01",X"00",X"FF",X"40",
		X"03",X"40",X"FE",X"00",X"00",X"C0",X"00",X"00",X"00",X"60",X"00",X"00",X"00",X"80",X"00",X"20",
		X"01",X"80",X"00",X"00",X"FF",X"00",X"00",X"C0",X"00",X"00",X"00",X"60",X"00",X"80",X"00",X"00",
		X"00",X"80",X"FF",X"A0",X"FF",X"00",X"00",X"80",X"01",X"00",X"00",X"00",X"00",X"C0",X"00",X"00",
		X"00",X"80",X"01",X"00",X"00",X"00",X"00",X"80",X"FF",X"00",X"00",X"C0",X"01",X"00",X"00",X"00",
		X"01",X"00",X"00",X"80",X"01",X"00",X"02",X"00",X"00",X"00",X"00",X"00",X"00",X"C0",X"81",X"00",
		X"00",X"00",X"00",X"C0",X"01",X"C0",X"00",X"C0",X"81",X"00",X"00",X"00",X"01",X"00",X"81",X"00",
		X"01",X"00",X"00",X"00",X"01",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
		X"00",X"00",X"01",X"00",X"81",X"00",X"00",X"C0",X"01",X"00",X"01",X"00",X"00",X"00",X"00",X"00",
		X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"81",X"00",X"01",X"C0",X"81",X"00",
		X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"20",X"01",X"00",X"00",X"00",
		X"81",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"01",X"00",X"00",X"00",X"00",X"00",X"81",X"00",
		X"81",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"80",X"01",X"00",
		X"00",X"00",X"00",X"00",X"81",X"01",X"03",X"02",X"01",X"04",X"04",X"01",X"01",X"06",X"0B",X"09",
		X"09",X"0B",X"04",X"01",X"02",X"00",X"02",X"08",X"0C",X"0E",X"16",X"1E",X"20",X"22",X"2E",X"44",
		X"56",X"68",X"7E",X"86",X"88",X"FF",X"00",X"01",X"FF",X"FF",X"00",X"01",X"FF",X"FF",X"00",X"FF",
		X"00",X"01",X"FF",X"FF",X"00",X"01",X"FF",X"FF",X"00",X"FF",X"00",X"00",X"00",X"01",X"FF",X"FF",
		X"00",X"00",X"00",X"01",X"FF",X"FF",X"00",X"01",X"FF",X"00",X"00",X"FF",X"00",X"01",X"FF",X"FF",
		X"00",X"01",X"FF",X"FF",X"00",X"01",X"FF",X"FF",X"00",X"00",X"00",X"01",X"FF",X"FF",X"00",X"FF",
		X"00",X"00",X"00",X"01",X"FF",X"00",X"00",X"FF",X"00",X"00",X"00",X"01",X"FF",X"00",X"00",X"FF",
		X"00",X"FF",X"00",X"00",X"00",X"01",X"FF",X"00",X"00",X"FF",X"00",X"00",X"00",X"01",X"FF",X"FF",
		X"00",X"00",X"00",X"01",X"FF",X"FF",X"00",X"01",X"FF",X"FF",X"00",X"01",X"FF",X"00",X"00",X"FF",
		X"00",X"FF",X"00",X"01",X"FF",X"FF",X"00",X"01",X"FF",X"FF",X"00",X"01",X"FF",X"FF",X"00",X"01",
		X"FF",X"FF",X"00",X"01",X"FF",X"00",X"FF",X"00",X"01",X"00",X"01",X"00",X"00",X"00",X"01",X"00",
		X"FF",X"00",X"04",X"00",X"01",X"00",X"00",X"00",X"01",X"00",X"00",X"00",X"01",X"00",X"01",X"00",
		X"00",X"00",X"03",X"00",X"01",X"00",X"01",X"00",X"00",X"00",X"01",X"00",X"00",X"00",X"03",X"00",
		X"00",X"FF",X"00",X"FF",X"00",X"FF",X"00",X"00",X"01",X"00",X"02",X"00",X"01",X"00",X"01",X"00",
		X"FF",X"00",X"01",X"00",X"00",X"00",X"01",X"00",X"01",X"00",X"02",X"00",X"FF",X"00",X"02",X"00",
		X"01",X"00",X"00",X"00",X"01",X"00",X"00",X"00",X"02",X"00",X"01",X"00",X"01",X"00",X"00",X"00",
		X"00",X"00",X"01",X"00",X"00",X"00",X"01",X"00",X"01",X"00",X"01",X"00",X"00",X"00",X"01",X"00",
		X"00",X"00",X"01",X"00",X"00",X"00",X"01",X"00",X"00",X"00",X"01",X"00",X"00",X"00",X"01",X"00",
		X"01",X"00",X"01",X"00",X"01",X"00",X"81",X"00",X"01",X"00",X"01",X"00",X"00",X"00",X"01",X"00",
		X"81",X"00",X"01",X"00",X"01",X"00",X"00",X"00",X"01",X"00",X"00",X"00",X"00",X"00",X"01",X"00",
		X"00",X"00",X"00",X"00",X"01",X"00",X"01",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
		X"00",X"00",X"01",X"00",X"01",X"00",X"01",X"00",X"01",X"00",X"81",X"00",X"01",X"00",X"01",X"00",
		X"81",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"01",X"00",X"81",X"00",X"81",X"00",X"01",X"00",
		X"01",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"01",X"00",X"81",X"00",X"00",X"00",
		X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"01",X"00",X"01",X"00",X"00",X"00",X"00",X"00",
		X"00",X"00",X"01",X"00",X"81",X"00",X"01",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"01",X"00",
		X"01",X"00",X"01",X"00",X"01",X"00",X"00",X"00",X"05",X"05",X"06",X"09",X"04",X"09",X"07",X"09",
		X"08",X"02",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"0A",X"14",X"20",X"32",X"3A",X"4C",X"5A",
		X"6C",X"7C",X"00",X"00",X"00",X"FF",X"00",X"FF",X"00",X"01",X"FF",X"FF",X"00",X"01",X"FF",X"FF",
		X"00",X"00",X"00",X"80",X"FF",X"80",X"FF",X"00",X"00",X"FF",X"00",X"00",X"00",X"80",X"FF",X"80",
		X"FF",X"FF",X"00",X"FF",X"00",X"00",X"00",X"01",X"FF",X"00",X"00",X"FF",X"00",X"00",X"00",X"01",
		X"FF",X"00",X"00",X"FF",X"00",X"FF",X"00",X"01",X"FF",X"FF",X"00",X"C0",X"FF",X"40",X"FF",X"00",
		X"00",X"FF",X"00",X"00",X"00",X"01",X"FF",X"FF",X"00",X"00",X"00",X"01",X"FF",X"FF",X"00",X"01",
		X"FF",X"00",X"00",X"FF",X"00",X"FF",X"00",X"00",X"00",X"01",X"FF",X"00",X"00",X"FF",X"00",X"FF",
		X"00",X"00",X"00",X"80",X"FF",X"80",X"FF",X"00",X"00",X"FF",X"00",X"40",X"00",X"C0",X"00",X"00",
		X"00",X"40",X"FF",X"C0",X"FF",X"00",X"00",X"FF",X"00",X"FF",X"00",X"00",X"00",X"01",X"FF",X"00",
		X"00",X"FF",X"00",X"FF",X"00",X"00",X"00",X"C0",X"FF",X"40",X"FF",X"00",X"00",X"FF",X"00",X"FF",
		X"00",X"01",X"FF",X"C0",X"00",X"40",X"00",X"00",X"00",X"01",X"FF",X"FF",X"00",X"00",X"00",X"40",
		X"FF",X"C0",X"FF",X"00",X"00",X"FF",X"00",X"FF",X"00",X"00",X"00",X"80",X"FF",X"80",X"FF",X"00",
		X"00",X"80",X"00",X"80",X"00",X"00",X"00",X"01",X"FF",X"FF",X"00",X"01",X"FF",X"40",X"00",X"C0",
		X"FF",X"00",X"00",X"80",X"00",X"80",X"00",X"00",X"00",X"01",X"FF",X"E0",X"00",X"A0",X"FF",X"80",
		X"FF",X"00",X"00",X"FF",X"00",X"00",X"00",X"00",X"FF",X"00",X"02",X"00",X"00",X"00",X"FF",X"00",
		X"00",X"80",X"00",X"00",X"00",X"80",X"FF",X"00",X"01",X"60",X"00",X"20",X"01",X"80",X"FF",X"00",
		X"00",X"00",X"01",X"00",X"00",X"80",X"00",X"00",X"00",X"E0",X"00",X"A0",X"FF",X"80",X"00",X"00",
		X"01",X"80",X"00",X"00",X"00",X"00",X"00",X"80",X"00",X"E0",X"00",X"40",X"00",X"60",X"FF",X"80",
		X"00",X"00",X"01",X"80",X"00",X"00",X"00",X"00",X"00",X"80",X"00",X"00",X"00",X"00",X"01",X"00",
		X"01",X"80",X"00",X"00",X"00",X"C0",X"00",X"C0",X"00",X"00",X"FF",X"80",X"02",X"00",X"00",X"00",
		X"00",X"C0",X"00",X"80",X"00",X"80",X"FF",X"80",X"01",X"00",X"00",X"00",X"00",X"C0",X"00",X"C0",
		X"00",X"40",X"FF",X"00",X"00",X"80",X"01",X"00",X"00",X"00",X"00",X"C0",X"00",X"00",X"00",X"C0",
		X"00",X"00",X"00",X"00",X"FF",X"00",X"01",X"00",X"00",X"C0",X"00",X"C0",X"00",X"00",X"00",X"00",
		X"00",X"00",X"01",X"C0",X"00",X"00",X"00",X"C0",X"00",X"00",X"00",X"00",X"00",X"00",X"01",X"C0",
		X"00",X"00",X"00",X"C0",X"00",X"00",X"00",X"00",X"01",X"40",X"00",X"80",X"FF",X"80",X"00",X"00",
		X"01",X"80",X"FF",X"80",X"00",X"80",X"01",X"00",X"00",X"00",X"01",X"80",X"FF",X"40",X"00",X"00",
		X"00",X"00",X"01",X"80",X"00",X"80",X"FF",X"80",X"01",X"00",X"00",X"E0",X"00",X"60",X"00",X"80",
		X"FF",X"80",X"01",X"00",X"00",X"00",X"00",X"00",X"81",X"00",X"01",X"00",X"00",X"00",X"81",X"00",
		X"00",X"00",X"00",X"00",X"00",X"00",X"81",X"00",X"00",X"55",X"00",X"55",X"80",X"00",X"81",X"00",
		X"00",X"00",X"01",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"55",X"80",X"55",X"00",X"00",
		X"01",X"00",X"81",X"00",X"00",X"00",X"00",X"00",X"00",X"E0",X"00",X"00",X"01",X"D2",X"80",X"D2",
		X"00",X"00",X"01",X"00",X"81",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"01",X"00",
		X"01",X"00",X"81",X"00",X"00",X"C0",X"00",X"C0",X"80",X"00",X"81",X"00",X"01",X"00",X"00",X"00",
		X"00",X"00",X"00",X"00",X"01",X"00",X"81",X"00",X"01",X"00",X"00",X"00",X"00",X"00",X"01",X"00",
		X"81",X"00",X"81",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
		X"00",X"00",X"00",X"00",X"81",X"00",X"01",X"00",X"00",X"00",X"01",X"00",X"81",X"00",X"00",X"00",
		X"00",X"00",X"00",X"00",X"01",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
		X"01",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"01",X"00",X"81",X"00",X"81",X"00",X"01",X"00",
		X"81",X"00",X"81",X"00",X"01",X"00",X"81",X"00",X"00",X"00",X"01",X"00",X"81",X"00",X"01",X"00",
		X"00",X"00",X"00",X"00",X"01",X"00",X"81",X"00",X"01",X"00",X"00",X"00",X"01",X"00",X"01",X"00",
		X"81",X"00",X"01",X"00",X"00",X"01",X"04",X"0A",X"09",X"09",X"07",X"05",X"06",X"07",X"05",X"06",
		X"06",X"06",X"09",X"09",X"05",X"00",X"02",X"0A",X"1E",X"30",X"42",X"50",X"5A",X"66",X"74",X"7E",
		X"8A",X"96",X"A2",X"B4",X"C6",X"FF",X"00",X"00",X"00",X"01",X"FF",X"FF",X"00",X"01",X"FF",X"FF",
		X"00",X"FF",X"00",X"00",X"00",X"01",X"FF",X"00",X"00",X"FF",X"00",X"01",X"FF",X"FF",X"00",X"FF",
		X"00",X"80",X"FF",X"80",X"00",X"01",X"FF",X"FF",X"00",X"01",X"FF",X"FF",X"00",X"01",X"FF",X"FF",
		X"00",X"00",X"00",X"01",X"FF",X"FF",X"00",X"01",X"FF",X"FF",X"00",X"01",X"FF",X"FF",X"00",X"01",
		X"FF",X"FF",X"00",X"00",X"00",X"01",X"FF",X"FF",X"00",X"01",X"FF",X"80",X"00",X"80",X"FF",X"FF",
		X"00",X"01",X"FF",X"FF",X"00",X"01",X"FF",X"FF",X"00",X"80",X"FF",X"80",X"00",X"FF",X"00",X"00",
		X"00",X"01",X"FF",X"FF",X"00",X"01",X"FF",X"FF",X"00",X"80",X"00",X"80",X"FF",X"FF",X"00",X"00",
		X"00",X"01",X"FF",X"FF",X"00",X"01",X"FF",X"FF",X"00",X"01",X"FF",X"00",X"00",X"FF",X"00",X"FF",
		X"00",X"01",X"FF",X"FF",X"00",X"01",X"FF",X"FF",X"00",X"00",X"00",X"01",X"FF",X"FF",X"00",X"01",
		X"FF",X"00",X"00",X"FF",X"00",X"01",X"FF",X"00",X"FF",X"00",X"03",X"00",X"FE",X"00",X"03",X"00",
		X"01",X"00",X"01",X"00",X"FF",X"00",X"02",X"00",X"02",X"00",X"01",X"80",X"FF",X"80",X"02",X"00",
		X"01",X"00",X"00",X"00",X"01",X"00",X"00",X"00",X"01",X"00",X"02",X"80",X"00",X"80",X"01",X"00",
		X"00",X"00",X"01",X"00",X"01",X"00",X"00",X"00",X"00",X"00",X"05",X"00",X"01",X"00",X"00",X"00",
		X"01",X"00",X"00",X"00",X"FF",X"00",X"05",X"00",X"FF",X"00",X"FF",X"00",X"04",X"00",X"01",X"00",
		X"01",X"00",X"01",X"00",X"02",X"00",X"01",X"00",X"01",X"00",X"02",X"00",X"01",X"00",X"01",X"00",
		X"00",X"00",X"05",X"00",X"01",X"00",X"00",X"00",X"01",X"00",X"00",X"00",X"00",X"00",X"FF",X"00",
		X"00",X"00",X"02",X"00",X"02",X"80",X"00",X"80",X"01",X"00",X"00",X"00",X"01",X"00",X"01",X"00",
		X"00",X"00",X"01",X"00",X"01",X"00",X"02",X"80",X"00",X"80",X"00",X"00",X"02",X"00",X"01",X"00",
		X"01",X"00",X"02",X"00",X"01",X"00",X"01",X"00",X"01",X"00",X"81",X"00",X"00",X"00",X"82",X"00",
		X"03",X"00",X"01",X"00",X"01",X"00",X"81",X"00",X"00",X"00",X"02",X"00",X"00",X"80",X"80",X"80",
		X"00",X"00",X"01",X"00",X"00",X"00",X"02",X"00",X"00",X"00",X"84",X"00",X"02",X"80",X"00",X"80",
		X"80",X"00",X"00",X"00",X"01",X"00",X"81",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"01",X"00",
		X"00",X"00",X"01",X"00",X"00",X"00",X"81",X"00",X"00",X"00",X"81",X"00",X"81",X"00",X"01",X"00",
		X"02",X"00",X"02",X"00",X"01",X"00",X"81",X"00",X"01",X"00",X"01",X"00",X"81",X"00",X"02",X"00",
		X"02",X"00",X"00",X"00",X"00",X"00",X"01",X"00",X"00",X"00",X"01",X"00",X"00",X"00",X"00",X"00",
		X"82",X"00",X"00",X"00",X"00",X"00",X"02",X"80",X"00",X"80",X"80",X"00",X"00",X"00",X"01",X"00",
		X"81",X"00",X"00",X"00",X"01",X"00",X"81",X"00",X"02",X"80",X"00",X"80",X"00",X"80",X"80",X"00",
		X"01",X"00",X"01",X"00",X"02",X"00",X"00",X"00",X"01",X"00",X"01",X"00",X"00",X"00",X"06",X"07",
		X"0B",X"06",X"07",X"07",X"06",X"0B",X"07",X"05",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"0C",
		X"1A",X"30",X"3C",X"4A",X"58",X"64",X"7A",X"88",X"00",X"00",X"00",X"FF",X"00",X"A0",X"FF",X"60",
		X"FF",X"FF",X"00",X"FF",X"00",X"01",X"FF",X"FF",X"00",X"60",X"FF",X"A0",X"FF",X"FF",X"00",X"01",
		X"FF",X"FF",X"00",X"A0",X"FF",X"E0",X"FF",X"E0",X"FF",X"A0",X"FF",X"FF",X"00",X"A0",X"FF",X"60",
		X"FF",X"FF",X"00",X"FF",X"00",X"01",X"FF",X"FF",X"00",X"60",X"FF",X"A0",X"FF",X"FF",X"00",X"E0",
		X"FF",X"A0",X"FF",X"80",X"00",X"00",X"00",X"01",X"FF",X"60",X"00",X"20",X"00",X"20",X"00",X"60",
		X"00",X"FF",X"00",X"01",X"FF",X"80",X"00",X"A0",X"FF",X"E0",X"FF",X"FF",X"00",X"00",X"00",X"01",
		X"FF",X"60",X"00",X"20",X"00",X"20",X"00",X"60",X"00",X"00",X"00",X"A0",X"FF",X"60",X"FF",X"FF",
		X"00",X"FF",X"00",X"01",X"FF",X"60",X"00",X"A0",X"00",X"01",X"FF",X"FF",X"00",X"FF",X"00",X"00",
		X"00",X"01",X"FF",X"60",X"00",X"20",X"00",X"20",X"00",X"60",X"00",X"FF",X"00",X"00",X"00",X"01",
		X"FF",X"60",X"00",X"20",X"00",X"20",X"00",X"60",X"00",X"FF",X"00",X"FF",X"00",X"00",X"00",X"A0",
		X"FF",X"60",X"FF",X"FF",X"00",X"FF",X"00",X"00",X"00",X"01",X"FF",X"60",X"00",X"20",X"00",X"20",
		X"00",X"60",X"00",X"01",X"FF",X"60",X"00",X"A0",X"00",X"01",X"FF",X"FF",X"00",X"00",X"00",X"C0",
		X"00",X"A0",X"00",X"00",X"00",X"00",X"00",X"60",X"01",X"00",X"00",X"60",X"FF",X"40",X"FF",X"00",
		X"00",X"00",X"02",X"00",X"00",X"A0",X"FF",X"C0",X"FF",X"40",X"00",X"60",X"00",X"00",X"00",X"C0",
		X"00",X"A0",X"00",X"00",X"00",X"00",X"00",X"60",X"01",X"00",X"00",X"60",X"FF",X"40",X"FF",X"00",
		X"00",X"40",X"00",X"60",X"00",X"00",X"00",X"60",X"02",X"00",X"00",X"A0",X"FF",X"C0",X"FF",X"40",
		X"00",X"60",X"00",X"00",X"00",X"A0",X"00",X"00",X"00",X"A0",X"FF",X"C0",X"FF",X"00",X"00",X"A0",
		X"00",X"00",X"00",X"A0",X"FF",X"C0",X"FF",X"40",X"00",X"60",X"00",X"80",X"01",X"C0",X"00",X"A0",
		X"00",X"00",X"00",X"00",X"00",X"20",X"02",X"C0",X"00",X"A0",X"00",X"00",X"00",X"00",X"00",X"00",
		X"00",X"00",X"03",X"00",X"00",X"A0",X"FF",X"C0",X"FF",X"40",X"00",X"60",X"00",X"00",X"00",X"A0",
		X"00",X"00",X"00",X"A0",X"FF",X"C0",X"FF",X"40",X"00",X"60",X"00",X"00",X"00",X"00",X"00",X"00",
		X"01",X"C0",X"00",X"A0",X"00",X"00",X"00",X"00",X"00",X"E0",X"00",X"00",X"00",X"A0",X"FF",X"C0",
		X"FF",X"40",X"00",X"60",X"00",X"20",X"00",X"C0",X"00",X"A0",X"00",X"00",X"00",X"00",X"00",X"00",
		X"00",X"00",X"02",X"00",X"01",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"81",X"00",
		X"82",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"81",X"00",X"82",X"00",X"02",X"00",X"01",X"00",
		X"00",X"00",X"02",X"00",X"01",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"81",X"00",
		X"82",X"00",X"00",X"00",X"02",X"00",X"01",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"81",X"00",
		X"82",X"00",X"02",X"00",X"01",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"81",X"00",X"82",X"00",
		X"00",X"00",X"00",X"00",X"00",X"00",X"81",X"00",X"82",X"00",X"02",X"00",X"01",X"00",X"00",X"00",
		X"02",X"00",X"01",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"02",X"00",X"01",X"00",X"00",X"00",
		X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"81",X"00",X"82",X"00",X"02",X"00",X"01",X"00",
		X"00",X"00",X"00",X"00",X"00",X"00",X"81",X"00",X"82",X"00",X"02",X"00",X"01",X"00",X"00",X"00",
		X"00",X"00",X"00",X"00",X"02",X"00",X"01",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
		X"81",X"00",X"82",X"00",X"02",X"00",X"01",X"00",X"00",X"00",X"02",X"00",X"01",X"00",X"00",X"00",
		X"00",X"04",X"05",X"07",X"04",X"05",X"0A",X"05",X"0B",X"05",X"01",X"07",X"07",X"01",X"05",X"0B",
		X"01",X"00",X"08",X"12",X"20",X"28",X"32",X"46",X"50",X"66",X"70",X"72",X"80",X"8E",X"90",X"9A",
		X"B0",X"2C",X"A6",X"CF",X"BD",X"3C",X"01",X"D0",X"20",X"B5",X"88",X"F0",X"1C",X"A6",X"86",X"BD",
		X"34",X"01",X"D0",X"15",X"20",X"90",X"A5",X"A9",X"00",X"85",X"24",X"A9",X"02",X"85",X"41",X"20",
		X"CE",X"BB",X"A5",X"24",X"F0",X"03",X"4C",X"8A",X"BB",X"60",X"20",X"8A",X"A5",X"20",X"C0",X"C8",
		X"20",X"EB",X"E0",X"60",X"A2",X"03",X"20",X"6F",X"BB",X"A2",X"02",X"20",X"6F",X"BB",X"60",X"A9",
		X"03",X"85",X"21",X"A4",X"CF",X"B9",X"3C",X"01",X"D0",X"17",X"A4",X"21",X"B9",X"EC",X"02",X"F0",
		X"0C",X"A2",X"01",X"86",X"22",X"20",X"C2",X"BB",X"A6",X"22",X"CA",X"10",X"F6",X"C6",X"21",X"10",
		X"E9",X"60",X"BD",X"34",X"01",X"D0",X"2B",X"A9",X"02",X"85",X"41",X"20",X"BD",X"BE",X"BD",X"08",
		X"01",X"85",X"3C",X"BD",X"0C",X"01",X"85",X"3D",X"BD",X"14",X"01",X"85",X"3E",X"BD",X"18",X"01",
		X"85",X"3F",X"86",X"22",X"20",X"D2",X"A4",X"A6",X"22",X"A4",X"21",X"B0",X"05",X"E6",X"24",X"20",
		X"08",X"BC",X"60",X"A0",X"03",X"84",X"21",X"A4",X"21",X"B9",X"EC",X"02",X"F0",X"05",X"A6",X"86",
		X"20",X"C2",X"BB",X"C6",X"21",X"10",X"F0",X"60",X"AD",X"0A",X"60",X"09",X"40",X"E0",X"02",X"90",
		X"02",X"A9",X"30",X"9D",X"34",X"01",X"A9",X"00",X"99",X"EC",X"02",X"20",X"4D",X"BC",X"20",X"C0",
		X"C8",X"20",X"EB",X"E0",X"A9",X"00",X"85",X"23",X"A9",X"01",X"85",X"24",X"4C",X"7D",X"C3",X"A9",
		X"03",X"85",X"21",X"A4",X"21",X"B9",X"EC",X"02",X"F0",X"0E",X"A2",X"03",X"86",X"22",X"20",X"C2",
		X"BB",X"A6",X"22",X"CA",X"E0",X"01",X"D0",X"F4",X"C6",X"21",X"10",X"E7",X"60",X"BD",X"08",X"01",
		X"85",X"38",X"BD",X"0C",X"01",X"85",X"39",X"BD",X"14",X"01",X"85",X"3A",X"BD",X"18",X"01",X"85",
		X"3B",X"60",X"20",X"6F",X"A5",X"A2",X"0C",X"BD",X"F0",X"02",X"F0",X"29",X"86",X"21",X"20",X"99",
		X"BC",X"A9",X"00",X"85",X"41",X"20",X"D2",X"A4",X"B0",X"19",X"A5",X"4B",X"D0",X"06",X"A5",X"1D",
		X"29",X"01",X"F0",X"06",X"20",X"B0",X"BC",X"4C",X"93",X"BC",X"20",X"8A",X"A5",X"20",X"C0",X"C8",
		X"20",X"EB",X"E0",X"A6",X"21",X"CA",X"10",X"CF",X"60",X"A6",X"21",X"BD",X"23",X"02",X"85",X"38",
		X"BD",X"0C",X"02",X"85",X"39",X"BD",X"68",X"02",X"85",X"3A",X"BD",X"51",X"02",X"85",X"3B",X"60",
		X"A9",X"70",X"65",X"48",X"85",X"48",X"A6",X"21",X"A9",X"00",X"9D",X"F0",X"02",X"60",X"A9",X"03",
		X"85",X"21",X"A4",X"21",X"B9",X"EC",X"02",X"F0",X"24",X"A2",X"07",X"BD",X"E4",X"02",X"F0",X"1A",
		X"20",X"BD",X"BE",X"20",X"7E",X"BE",X"86",X"22",X"A9",X"FF",X"85",X"41",X"20",X"D2",X"A4",X"A6",
		X"22",X"A4",X"21",X"B0",X"03",X"20",X"53",X"C3",X"A6",X"22",X"CA",X"10",X"DE",X"C6",X"21",X"10",
		X"D1",X"60",X"E0",X"20",X"E0",X"D0",X"E0",X"E0",X"20",X"E0",X"20",X"E0",X"20",X"20",X"E0",X"20",
		X"20",X"20",X"20",X"E0",X"20",X"E0",X"20",X"E0",X"20",X"E0",X"E0",X"20",X"10",X"20",X"10",X"10",
		X"E0",X"20",X"E0",X"20",X"E0",X"20",X"E0",X"20",X"20",X"20",X"E0",X"20",X"00",X"00",X"E0",X"00",
		X"20",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"10",X"10",X"F0",X"00",X"20",X"F0",
		X"00",X"F0",X"E0",X"E0",X"E0",X"E0",X"E0",X"E0",X"E0",X"E0",X"E0",X"00",X"E0",X"E0",X"20",X"20",
		X"E0",X"00",X"E0",X"E0",X"E0",X"20",X"20",X"20",X"E0",X"20",X"20",X"20",X"E0",X"E0",X"20",X"E0",
		X"E0",X"20",X"20",X"E0",X"E0",X"20",X"E0",X"E0",X"20",X"20",X"E0",X"E0",X"20",X"20",X"E0",X"00",
		X"20",X"E0",X"20",X"20",X"20",X"E0",X"E0",X"E0",X"E0",X"E0",X"E0",X"E0",X"20",X"E0",X"20",X"20",
		X"E0",X"20",X"F0",X"10",X"F0",X"F0",X"F0",X"10",X"10",X"10",X"F0",X"F0",X"F0",X"00",X"F0",X"00",
		X"10",X"10",X"20",X"E0",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"00",X"E0",X"20",X"E0",X"E0",
		X"20",X"20",X"20",X"E0",X"20",X"E0",X"E0",X"20",X"20",X"20",X"E0",X"E0",X"20",X"20",X"E0",X"E0",
		X"E0",X"20",X"20",X"20",X"20",X"E0",X"20",X"20",X"E0",X"20",X"E0",X"20",X"20",X"20",X"20",X"20",
		X"E0",X"20",X"A6",X"CF",X"B5",X"4D",X"AA",X"BD",X"31",X"C1",X"29",X"20",X"F0",X"2D",X"A9",X"80",
		X"05",X"F4",X"85",X"F4",X"A9",X"03",X"85",X"21",X"A4",X"21",X"B9",X"EC",X"02",X"F0",X"18",X"20",
		X"BD",X"BE",X"20",X"EC",X"BD",X"A9",X"03",X"85",X"41",X"A9",X"00",X"85",X"22",X"20",X"D2",X"A4",
		X"A4",X"21",X"B0",X"03",X"4C",X"FD",X"BD",X"C6",X"21",X"10",X"DD",X"60",X"A9",X"E0",X"85",X"3C",
		X"A9",X"FE",X"85",X"3D",X"A9",X"20",X"85",X"3E",X"A9",X"02",X"85",X"3F",X"60",X"AD",X"43",X"01",
		X"10",X"2D",X"20",X"F7",X"E0",X"A9",X"00",X"8D",X"43",X"01",X"A9",X"20",X"8D",X"34",X"01",X"8D",
		X"35",X"01",X"A9",X"00",X"99",X"EC",X"02",X"85",X"23",X"A9",X"05",X"85",X"24",X"20",X"7D",X"C3",
		X"A6",X"CF",X"B5",X"F6",X"C9",X"01",X"D0",X"07",X"A9",X"FF",X"85",X"21",X"20",X"E0",X"5A",X"60",
		X"AD",X"3E",X"01",X"30",X"48",X"A5",X"4F",X"29",X"3F",X"D0",X"42",X"F8",X"AD",X"3E",X"01",X"38",
		X"E9",X"01",X"8D",X"3E",X"01",X"D8",X"10",X"35",X"CE",X"3E",X"01",X"A6",X"CF",X"B5",X"4D",X"0A",
		X"65",X"CF",X"A8",X"A9",X"FF",X"99",X"44",X"01",X"B4",X"4D",X"20",X"D0",X"C1",X"20",X"C0",X"C8",
		X"20",X"C0",X"C8",X"20",X"C0",X"C8",X"20",X"EB",X"E0",X"20",X"67",X"54",X"A6",X"CF",X"A9",X"80",
		X"85",X"30",X"A9",X"00",X"95",X"88",X"A9",X"18",X"95",X"00",X"9D",X"3C",X"01",X"60",X"8A",X"A8",
		X"B1",X"76",X"85",X"7B",X"10",X"05",X"A9",X"FF",X"4C",X"8D",X"BE",X"A9",X"00",X"85",X"7C",X"B9",
		X"17",X"02",X"18",X"65",X"7B",X"85",X"3C",X"B9",X"00",X"02",X"65",X"7C",X"85",X"3D",X"B1",X"78",
		X"85",X"7B",X"10",X"05",X"A9",X"FF",X"4C",X"AB",X"BE",X"A9",X"00",X"85",X"7C",X"B9",X"5C",X"02",
		X"18",X"65",X"7B",X"85",X"3E",X"B9",X"45",X"02",X"65",X"7C",X"85",X"3F",X"60",X"B9",X"1F",X"02",
		X"85",X"38",X"B9",X"08",X"02",X"85",X"39",X"B9",X"64",X"02",X"85",X"3A",X"B9",X"4D",X"02",X"85",
		X"3B",X"60",X"A9",X"00",X"8D",X"6E",X"04",X"85",X"4B",X"A6",X"CF",X"B5",X"88",X"F0",X"37",X"A5",
		X"1D",X"29",X"01",X"F0",X"31",X"A6",X"CF",X"B5",X"4D",X"C9",X"03",X"D0",X"07",X"A5",X"10",X"10",
		X"03",X"4C",X"17",X"BF",X"A5",X"11",X"C9",X"20",X"90",X"02",X"49",X"3F",X"C9",X"04",X"A9",X"FF",
		X"85",X"4B",X"20",X"C5",X"C2",X"B0",X"0F",X"A9",X"01",X"8D",X"6E",X"04",X"A6",X"2A",X"DE",X"FB",
		X"02",X"D0",X"03",X"4C",X"41",X"BF",X"60",X"A5",X"11",X"C9",X"20",X"90",X"02",X"49",X"3F",X"C9",
		X"1C",X"4C",X"FE",X"BE",X"60",X"A9",X"00",X"8D",X"6E",X"04",X"85",X"4B",X"A5",X"10",X"F0",X"02",
		X"10",X"0E",X"A6",X"2A",X"BD",X"FB",X"02",X"F0",X"07",X"A5",X"30",X"D0",X"03",X"4C",X"E5",X"BE",
		X"60",X"A5",X"D0",X"F0",X"35",X"F8",X"A4",X"CF",X"A9",X"00",X"18",X"79",X"68",X"01",X"99",X"68",
		X"01",X"B9",X"6A",X"01",X"69",X"25",X"99",X"6A",X"01",X"B9",X"6C",X"01",X"69",X"00",X"99",X"6C",
		X"01",X"C9",X"02",X"90",X"11",X"B9",X"6A",X"01",X"C9",X"50",X"90",X"0A",X"A9",X"50",X"99",X"6A",
		X"01",X"A9",X"00",X"99",X"68",X"01",X"D8",X"4C",X"E7",X"E0",X"60",X"A6",X"86",X"BD",X"34",X"01",
		X"F0",X"23",X"A2",X"0E",X"A9",X"00",X"1D",X"BF",X"03",X"CA",X"10",X"FA",X"AA",X"D0",X"16",X"A2",
		X"05",X"B5",X"80",X"95",X"0B",X"CA",X"10",X"F9",X"A9",X"FF",X"85",X"30",X"20",X"67",X"54",X"A6",
		X"CF",X"A9",X"1A",X"95",X"00",X"60",X"A6",X"CF",X"B5",X"4D",X"AA",X"A5",X"10",X"10",X"08",X"BD",
		X"07",X"C0",X"C5",X"10",X"4C",X"BA",X"BF",X"DD",X"F8",X"BF",X"A4",X"CF",X"90",X"20",X"A9",X"0E",
		X"99",X"00",X"00",X"BD",X"31",X"C1",X"C9",X"A8",X"F0",X"06",X"4C",X"25",X"C0",X"4C",X"DE",X"BF",
		X"AD",X"43",X"01",X"30",X"06",X"4C",X"25",X"C0",X"4C",X"DE",X"BF",X"4C",X"6F",X"C0",X"A5",X"0E",
		X"10",X"08",X"A9",X"00",X"38",X"E5",X"0E",X"38",X"E9",X"01",X"DD",X"16",X"C0",X"90",X"08",X"A9",
		X"0E",X"99",X"00",X"00",X"4C",X"25",X"C0",X"60",X"05",X"05",X"05",X"05",X"03",X"05",X"05",X"05");
begin
process(clk)
begin
	if rising_edge(clk) then
		data <= rom_data(to_integer(unsigned(addr)));
	end if;
end process;
end architecture;