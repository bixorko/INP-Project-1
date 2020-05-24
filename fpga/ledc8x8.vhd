-- Autor reseni: Peter Vinarcik, xvinar00

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity ledc8x8 is
port (
	SMCLK, RESET: in std_logic;
	ROW: out std_logic_vector (7 downto 0);
	LED: out std_logic_vector (7 downto 0)
);
end ledc8x8;

architecture main of ledc8x8 is
	signal cnt: std_logic_vector (7 downto 0) := (others => '0');
	signal leds, rows: std_logic_vector (7 downto 0);
	signal disabled: std_logic_vector (1 downto 0) := "00";
	signal tochange: std_logic_vector (21 downto 0) := (others => '0');
begin
	counter: process(RESET, SMCLK, cnt)
	begin
		if (RESET = '1') then
			cnt <= (others => '0');
		elsif SMCLK'event and SMCLK = '1' then
			cnt <= cnt + 1;
		end if;
	end process counter;

	change_state: process(RESET, SMCLK, disabled, tochange, cnt)
	begin
		if (RESET = '1') then
			cnt <= (others => '0');
		elsif SMCLK'event and SMCLK = '1' then
			tochange <= tochange + 1;
			if (tochange = "1110000100000000000000") then	-- 0,5 sec, change status
				disabled <= disabled + 1;		-- condition for toggle on/off [0,5s - 1s]
				if disabled = "11" then
					disabled <= disabled - 1;	-- infinite loop (never turn off again)
				end if;
				tochange <= (others => '0');		-- set tochange to 0 to find next state
			end if;
		end if;
	end process change_state;

	dekoder: process(rows, disabled, leds)
	begin
		if disabled = "00" then
			case rows is
				when "10000000" => leds <= "11011111";
				when "01000000" => leds <= "10101111";
				when "00100000" => leds <= "01110111";
				when "00010000" => leds <= "01110110";
				when "00001000" => leds <= "11111110";
				when "00000100" => leds <= "11111000";
				when "00000010" => leds <= "11111010";
				when "00000001" => leds <= "11111000";
				when others     => leds <= "11111111";
			end case;

		elsif disabled = "01" then
			case rows is
				when "10000000" => leds <= "11111111";
				when "01000000" => leds <= "11111111";
				when "00100000" => leds <= "11111111";
				when "00010000" => leds <= "11111111";
				when "00001000" => leds <= "11111111";
				when "00000100" => leds <= "11111111";
				when "00000010" => leds <= "11111111";
				when "00000001" => leds <= "11111111";
				when others     => leds <= "11111111";
			end case;

		else
			case rows is
				when "10000000" => leds <= "11011111";
				when "01000000" => leds <= "10101111";
				when "00100000" => leds <= "01110111";
				when "00010000" => leds <= "01110110";
				when "00001000" => leds <= "11111110";
				when "00000100" => leds <= "11111000";
				when "00000010" => leds <= "11111010";
				when "00000001" => leds <= "11111000";
				when others     => leds <= "11111111";
			end case;
		end if;
	end process dekoder;

	row_rotation: process (RESET, SMCLK, rows)
	begin
		if RESET = '1' then
			rows <= "00000001";
		elsif SMCLK'event and SMCLK = '1' then
				case rows is
					--when "00000011" => rows <= "00000001"; tried to avoid blink at first row
					when "00000001" => rows <= "00000010";
					when "00000010" => rows <= "00000100";
					when "00000100" => rows <= "00001000";
					when "00001000" => rows <= "00010000";
					when "00010000" => rows <= "00100000";
					when "00100000" => rows <= "01000000";
					when "01000000" => rows <= "10000000";
					when "10000000" => rows <= "00000001";
					when others     => rows <= "11111111";
				end case;
		end if;
	end process row_rotation;

	ROW <= rows;
	LED <= leds;
end main;

-- ISID: 75579
