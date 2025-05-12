LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY de10_lite IS
    PORT(
        CLOCK_50    : IN  std_logic;
        KEY         : IN  std_logic_vector(1 DOWNTO 0);
        SW          : IN  std_logic_vector(9 DOWNTO 0);
        GPIO_24     : IN  std_logic;    -- RX
        GPIO_25     : OUT std_logic;    -- TX
        LEDR        : BUFFER std_logic_vector(9 DOWNTO 0);
        HEX0        : OUT std_logic_vector(6 DOWNTO 0);  -- 7-segment display output for hundreds
        HEX1        : OUT std_logic_vector(6 DOWNTO 0);  -- 7-segment display output for tens
        HEX2        : OUT std_logic_vector(6 DOWNTO 0);  -- 7-segment display output for units
		  GSENSOR_CS_N : OUT std_logic;          -- Chip select for G-Sensor, output
        GSENSOR_INT  : IN  std_logic_vector(1 DOWNTO 0); -- G-Sensor interrupt lines, input
        GSENSOR_SCLK : OUT std_logic;          -- Serial Clock for G-Sensor, output
        GSENSOR_SDI  : INOUT std_logic;        -- Serial Data In/Out for G-Sensor, bidirectional
        GSENSOR_SDO  : INOUT std_logic         -- Serial Data Out for G-Sensor, bidirectional
    );
END de10_lite;

ARCHITECTURE Structural OF de10_lite IS

	COMPONENT debounce IS
		 PORT(
			  Clock       : IN  std_logic;
			  button      : IN  std_logic;
			  debounced   : OUT std_logic
		 );
	END COMPONENT;

	COMPONENT uart IS
		 GENERIC(
			  clk_freq  : integer := 50_000_000;  -- System clock frequency in Hertz
			  baud_rate : integer := 115_200;     -- UART baud rate in bits per second
			  os_rate   : integer := 16;          -- Oversampling rate (samples per baud period)
			  d_width   : integer := 8;           -- Data bus width
			  parity    : integer := 0;           -- 0 for no parity, 1 for parity
			  parity_eo : std_logic := '0'        -- '0' for even, '1' for odd parity
		 );
		 PORT(
			  clk      : IN   std_logic;  -- System clock
			  reset_n  : IN   std_logic;  -- Asynchronous reset
			  tx_ena   : IN   std_logic;  -- Initiate transmission
			  tx_data  : IN   std_logic_vector(d_width-1 DOWNTO 0);  -- Data to transmit
			  rx       : IN   std_logic;  -- Receive pin
			  rx_busy  : OUT  std_logic;  -- Data reception in progress
			  rx_error : OUT  std_logic;  -- Start, parity, or stop bit error detected
			  rx_data  : OUT  std_logic_vector(d_width-1 DOWNTO 0);  -- Data received
			  tx_busy  : OUT  std_logic;  -- Transmission in progress
			  tx       : OUT  std_logic   -- Transmit pin
		 );
	END COMPONENT;

	COMPONENT display_control IS
		 PORT(
			  hex_input : in  std_logic_vector(3 downto 0);
			  seg_output: out std_logic_vector(6 downto 0)
		 );
	END COMPONENT;

	COMPONENT DisplayController is
		 Port (
			  clk       : in  STD_LOGIC;
			  number    : in  STD_LOGIC_VECTOR(7 downto 0);  -- Input number 0-999
			  onesOut   : out STD_LOGIC_VECTOR(6 downto 0);
			  tensOut   : out STD_LOGIC_VECTOR(6 downto 0);
			  hundredsOut: out STD_LOGIC_VECTOR(6 downto 0)
		 );
	END COMPONENT;
	
	COMPONENT reset_delay IS
		PORT( 	iRSTN	: IN std_logic;
			iCLK	: IN std_logic;
			oRST	: OUT	std_logic
		);
	END COMPONENT;

	COMPONENT spi_pll IS
		PORT( 	areset	: IN std_logic;
			inclk0	: IN std_logic;
			c0	: OUT	std_logic;
			c1	: OUT std_logic
		);
	END COMPONENT;

	COMPONENT spi_ee_config IS
		PORT( 	iRSTN		: IN std_logic;
			iSPI_CLK	: IN std_logic;
			iSPI_CLK_OUT	: IN	std_logic;
			iG_INT2		: IN std_logic;
			oDATA_L		: OUT std_logic_vector(7 DOWNTO 0);
			oDATA_H		: OUT std_logic_vector(7 DOWNTO 0);
			SPI_SDIO	: INOUT std_logic;
			oSPI_CSN	: OUT std_logic;
			oSPI_CLK	: OUT std_logic
		);
	END COMPONENT;
	 
	COMPONENT led_driver IS
		PORT( 	iRSTN	: IN std_logic;
			iCLK	: IN std_logic;
			iDIG	: IN std_logic_vector(9 DOWNTO 0);
			iG_INT2	: IN std_logic;
			oLED	: OUT std_logic_vector(9 DOWNTO 0)
		);
	END COMPONENT;

	SIGNAL tx_ena_de10   : std_logic := '1';
	SIGNAL tx_data_de10  : std_logic_vector(7 DOWNTO 0);
	SIGNAL rx_busy_de10  : std_logic;
	SIGNAL rx_error_de10 : std_logic;
	SIGNAL rx_data_de10  : std_logic_vector(7 DOWNTO 0);
	SIGNAL tx_busy_de10  : std_logic;
	SIGNAL key1_db       : std_logic;	
	SIGNAL key1_db_past  : std_logic := '0';
	SIGNAL dly_rst: std_logic;
	SIGNAL spi_clk: std_logic;
	SIGNAL spi_clk_out: std_logic;
	SIGNAL data_x:	std_logic_vector(15 DOWNTO 0);
	SIGNAL LEDR_2: std_logic_vector(9 DOWNTO 0);
	SIGNAL LEDR_2_anterior	: std_logic_vector(9 DOWNTO 0) := (others => '0');

BEGIN

	 LEDR <= LEDR_2;
	 reset : reset_delay PORT MAP(
		 iRSTN => KEY(0),
		 iCLK  => CLOCK_50,
		 oRST  => dly_rst
	);

	pll : spi_pll PORT MAP(
		 areset => dly_rst,
		 inclk0 => CLOCK_50,
		 c0     => spi_clk,
		 c1     => spi_clk_out
	);
	
	
	spi_config : spi_ee_config PORT MAP(
		 iRSTN        => NOT dly_rst,
		 iSPI_CLK     => spi_clk,
		 iSPI_CLK_OUT => spi_clk_out,
		 iG_INT2      => GSENSOR_INT(1),
		 oDATA_L      => data_x(7 DOWNTO 0),
		 oDATA_H      => data_x(15 DOWNTO 8),
		 SPI_SDIO     => GSENSOR_SDI,
		 oSPI_CSN     => GSENSOR_CS_N,
		 oSPI_CLK     => GSENSOR_SCLK
	);
	
	led : led_driver PORT MAP(
		 iRSTN   => NOT dly_rst,
		 iCLK    => CLOCK_50,
		 iDIG    => data_x(9 DOWNTO 0),
		 iG_INT2 => GSENSOR_INT(1),
		 oLED    => LEDR_2
	);



    -- Instance of DisplayController
    display_ctrl : DisplayController PORT MAP(
        clk        => CLOCK_50,
        number     => rx_data_de10,
        onesOut    => HEX0,
        tensOut    => HEX1,
        hundredsOut=> HEX2
		  
		  --
	 );

    uart_0      : uart PORT MAP(
        CLOCK_50, KEY(0), tx_ena_de10, tx_data_de10, GPIO_24, rx_busy_de10, rx_error_de10, rx_data_de10, tx_busy_de10, GPIO_25
    );
	 
    button_0    : debounce PORT MAP(
        CLOCK_50, KEY(1), key1_db
    );
	 
	 
	-- Process to transmit data according to the interface inputs
	PROCESS( CLOCK_50, SW )
		BEGIN
			 IF rising_edge(CLOCK_50) THEN
				  IF key1_db = '1' and key1_db_past = '0' THEN 
						tx_ena_de10 <= '0';
						tx_data_de10 <= "00000001";  -- Button pressed signal
				  ELSIF SW(0) = '1' THEN
						tx_ena_de10 <= '0';
						tx_data_de10 <= "00000010";  -- Switch 0 activated
				  ELSIF SW(1) = '1' THEN
						tx_ena_de10 <= '0';
						tx_data_de10 <= "00000011";  -- Switch 1 activated
				  ELSIF SW(2) = '1' THEN
						tx_ena_de10 <= '0';
						tx_data_de10 <= "00000100";  -- Switch 2 activated
				  ELSIF SW(3) = '1' THEN
						tx_ena_de10 <= '0';
						tx_data_de10 <= "00000101";  -- Switch 3 activated
				  ELSIF SW(4) = '1' THEN
						tx_ena_de10 <= '0';
						tx_data_de10 <= "00000001";
						IF LEDR >= "0010000000" THEN
							tx_ena_de10 <= '0';
							tx_data_de10 <= "00000110";
						ELSIF LEDR <= "0000000100" THEN
							tx_ena_de10 <= '0';
							tx_data_de10 <= "00000111";
						END IF;
				  ELSIF SW(5)= '1' THEN
						tx_ena_de10 <= '0';
						tx_data_de10 <= "00000101";
						IF LEDR >= "0010000000" THEN
							tx_ena_de10 <= '0';
							tx_data_de10 <= "00001000";
						ELSIF LEDR >= "0000000100" THEN
							tx_ena_de10 <= '0';
							tx_data_de10 <= "00001001";
						END IF;
				  ELSE
						tx_ena_de10 <= '1';
						tx_data_de10 <= "00000000";  -- No action

				 key1_db_past <= key1_db;
				 END IF;
			 END IF;
		END PROCESS;
		


END Structural;






	