LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY spi_pll IS
    PORT(
        areset  : IN  std_logic;
        inclk0  : IN  std_logic;
        c0      : OUT std_logic;
        c1      : OUT std_logic
    );
END spi_pll;

ARCHITECTURE behavior OF spi_pll IS
BEGIN
    -- Placeholder logic for PLL clock generation
    c0 <= inclk0 WHEN areset = '0' ELSE '0';
    c1 <= NOT inclk0 WHEN areset = '0' ELSE '0';
END behavior;
