library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity display_control is
    port (
        hex_input : in  std_logic_vector(3 downto 0);
        seg_output: out std_logic_vector(6 downto 0)
    );
end entity display_control;

architecture rtl of display_control is
begin
    process(hex_input)
    begin
        case hex_input is
            when "0000" =>
                seg_output <= "0000001"; -- 0
            when "0001" =>
                seg_output <= "1001111"; -- 1
            when "0010" =>
                seg_output <= "0010010"; -- 2
            when "0011" =>
                seg_output <= "0000110"; -- 3
            when "0100" =>
                seg_output <= "1001100"; -- 4
            when "0101" =>
                seg_output <= "0100100"; -- 5
            when "0110" =>
                seg_output <= "0100000"; -- 6
            when "0111" =>
                seg_output <= "0001111"; -- 7
            when "1000" =>
                seg_output <= "0000000"; -- 8
            when "1001" =>
                seg_output <= "0000100"; -- 9
				when "1010" =>
                seg_output <= "0001000"; -- A
            when "1011" =>
                seg_output <= "1100000"; -- b
            when "1100" =>
                seg_output <= "0110001"; -- C
            when "1101" =>
                seg_output <= "1000010"; -- d
            when "1110" =>
                seg_output <= "0110000"; -- E
            when others =>
                seg_output <= "0111000"; -- F	 
        end case;
    end process;
end architecture rtl;




