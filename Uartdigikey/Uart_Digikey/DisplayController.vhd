library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Main module to control the displays
entity DisplayController is
    Port (
        clk       : in  STD_LOGIC;
        number    : in  STD_LOGIC_VECTOR(7 downto 0);  -- Input number 0-999
        onesOut   : out STD_LOGIC_VECTOR(6 downto 0);
        tensOut   : out STD_LOGIC_VECTOR(6 downto 0);
        hundredsOut: out STD_LOGIC_VECTOR(6 downto 0)
    );
end DisplayController;

architecture Behavioral of DisplayController is
    signal ones, tens, hundreds : STD_LOGIC_VECTOR(3 downto 0);
    signal num_int : integer range 0 to 999;
    signal uart_rx_data : std_logic_vector(8 downto 0); -- Declare UART RX data signal

begin
    -- Convert STD_LOGIC_VECTOR to integer
    num_int <= to_integer(unsigned(number));

    -- Conversion to hundreds, tens, and ones
    hundreds <= std_logic_vector(to_unsigned((num_int / 100), 4));
    tens <= std_logic_vector(to_unsigned(((num_int mod 100) / 10), 4));
    ones <= std_logic_vector(to_unsigned((num_int mod 10), 4));

    -- Instantiate Decoder for each digit
    Decoder_ones: entity work.display_control
        port map (
            hex_input => ones,
            seg_output => onesOut
        );

    Decoder_tens: entity work.display_control
        port map (
            hex_input => tens,
            seg_output => tensOut
        );

    Decoder_hundreds: entity work.display_control
        port map (
            hex_input => hundreds,
            seg_output => hundredsOut
        );
end Behavioral;