LIBRARY 	ieee;
USE		ieee.std_logic_1164.all, ieee.numeric_std.all;

ENTITY de10litegum IS
	PORT(	
		CLOCK_50	: IN	std_logic;
		KEY		: IN 	std_logic_vector( 1 DOWNTO 0 );
		SW			: IN 	std_logic_vector( 9 DOWNTO 0 );
		GPIO_24	: IN	std_logic;	--RX
		GPIO_25	: OUT std_logic;	--TX
		LEDR		: BUFFER	std_logic_vector( 9 DOWNTO 0 );
		HEX0        : OUT std_logic_vector(6 DOWNTO 0);  -- 7-segment display output for hundreds
	   HEX1        : OUT std_logic_vector(6 DOWNTO 0);  -- 7-segment display output for tens
	   HEX2        : OUT std_logic_vector(6 DOWNTO 0);  -- 7-segment display output for units
	   GSENSOR_CS_N : OUT std_logic;          -- Chip select for G-Sensor, output
	   GSENSOR_INT  : IN  std_logic_vector(1 DOWNTO 0); -- G-Sensor interrupt lines, input
	   GSENSOR_SCLK : OUT std_logic;          -- Serial Clock for G-Sensor, output
	   GSENSOR_SDI  : INOUT std_logic;        -- Serial Data In/Out for G-Sensor, bidirection
		GSENSOR_SDO  : INOUT std_logic 
	);
END de10litegum;

ARCHITECTURE Structural OF de10litegum IS	
	
	component gumnut_with_mem IS
		generic( 
			IMem_file_name	: string 	:= "gumnutproyecto_text.dat";
			DMem_file_name : string 	:= "gumnutproyecto_data.dat";
         debug 			: boolean	:= false 
		);
		port( 
			clk_i 			: in 	std_logic;
         rst_i 			: in 	std_logic;
         -- I/O port bus
         port_cyc_o 		: out	std_logic;
         port_stb_o 		: out std_logic;
         port_we_o 		: out std_logic;
         port_ack_i 		: in 	std_logic;
         port_adr_o 		: out unsigned(7 downto 0);
         port_dat_o 		: out std_logic_vector(7 downto 0);
         port_dat_i 		: in 	std_logic_vector(7 downto 0);
         -- Interrupts
         int_req 			: in std_logic;
         int_ack 			: out std_logic
		);
	end component gumnut_with_mem;
	
	COMPONENT uart IS
		GENERIC(
			clk_freq  	: integer    := 50_000_000;  	--frequency of system clock in Hertz
			baud_rate 	: integer    := 115_200;     	--data link baud rate in bits/second
			os_rate   	: integer    := 16;          	--oversampling rate to find center of receive bits (in samples per baud period)
			d_width   	: integer    := 8;           	--data bus width
			parity    	: integer    := 0;           	--0 for no parity, 1 for parity
			parity_eo	: std_logic  := '0'				--'0' for even, '1' for odd parity
		);        
		PORT(
			clk      	: IN  std_logic;                             --system clock
			reset_n		: IN  std_logic;                             --ascynchronous reset
			tx_ena   	: IN  std_logic;                             --initiate transmission
			tx_data  	: IN  std_logic_vector(d_width-1 DOWNTO 0);  --data to transmit
			rx       	: IN  std_logic;                             --receive pin
			rx_busy  	: OUT std_logic;                             --data reception in progress, LEDR(9)
			rx_error 	: OUT std_logic;                             --start, parity, or stop bit error detected
			rx_data  	: OUT std_logic_vector(d_width-1 DOWNTO 0);  --data received
			tx_busy  	: OUT std_logic;                             --transmission in progress, LEDR(8)
			tx       	: OUT	std_logic										--transmit pin
		);                            
	END COMPONENT;

	COMPONENT debounce IS
		PORT(	
			Clock			: IN		std_logic;
			button		: IN		std_logic;
			debounced	: BUFFER	std_logic
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
	
	SIGNAL clk_i, rst_i				: std_logic; 
	SIGNAL port_cyc_o, port_stb_o	: std_logic;
	SIGNAL port_we_o, port_ack_i	: std_logic;
	SIGNAL int_req, int_ack			: std_logic;
	SIGNAL port_adr_o					: unsigned(7 DOWNTO 0);
	SIGNAL port_dat_o, port_dat_i	: std_logic_vector(7 DOWNTO 0);
	
	SIGNAL tx_ena_de10						: std_logic	:= '1';
	SIGNAL tx_data_de10, rx_data_de10	: std_logic_vector(7 DOWNTO 0);
	SIGNAL rx_busy_de10, rx_error_de10	: std_logic;
	SIGNAL tx_busy_de10						: std_logic;
	SIGNAL dly_rst: std_logic;
	SIGNAL spi_clk: std_logic;
	SIGNAL spi_clk_out: std_logic;
	SIGNAL data_x:	std_logic_vector(15 DOWNTO 0);
	
	SIGNAL key1_db			: std_logic;
	SIGNAL switch_inp    : std_logic_vector(7 DOWNTO 0);
	SIGNAL key1_inp		: std_logic_vector(7 DOWNTO 0);
	SIGNAL led_inp			: std_logic_vector(7 DOWNTO 0);
	SIGNAL acc_inp			: std_logic_vector(7 DOWNTO 0);
	SIGNAL dec_inp			: std_logic_vector(3 DOWNTO 0);
	CONSTANT ADDR_TX_DATA: unsigned(7 DOWNTO 0) := "00000000";
   CONSTANT ADDR_TX_START: unsigned(7 DOWNTO 0) := "00000001";

	
BEGIN
	rst_i	<= not KEY( 0 );
	
	gumnut		: gumnut_with_mem 
						PORT MAP(
								CLOCK_50, 
								rst_i, 
								port_cyc_o, 
								port_stb_o, 
								port_we_o, 
								'1', 
								port_adr_o,
								port_dat_o, 
								port_dat_i,
								int_req, 
								int_ack
						);

	uart_de10	: uart 		
						PORT MAP( 
								CLOCK_50, 
								KEY(0), 
								tx_ena_de10, 
								tx_data_de10, 
								GPIO_24, 
								rx_busy_de10, 
								rx_error_de10, 
								rx_data_de10, 
								tx_busy_de10, 
								GPIO_25 
						);
	
	button_de10	: debounce	
						PORT MAP( 
								CLOCK_50, 
								KEY(1), 
								key1_db 
						);
						
	reset : reset_delay 
						PORT MAP(
							 iRSTN => KEY(0),
							 iCLK  => CLOCK_50,
							 oRST  => dly_rst
						);

	pll : spi_pll 
						PORT MAP(
							 areset => dly_rst,
							 inclk0 => CLOCK_50,
							 c0     => spi_clk,
							 c1     => spi_clk_out
						);
	
	
	spi_config : spi_ee_config 
						PORT MAP(
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



    -- Instance of DisplayController
    display_ctrl : DisplayController 
						 PORT MAP(
							  clk        => CLOCK_50,
							  number     => rx_data_de10,
							  onesOut    => HEX0,
							  tensOut    => HEX1,
							  hundredsOut=> HEX2
							  
							 
						 );
						 
	 led : led_driver 
						 PORT MAP(
							 iRSTN   => NOT dly_rst,
							 iCLK    => CLOCK_50,
							 iDIG    => data_x(9 DOWNTO 0),
							 iG_INT2 => GSENSOR_INT(1),
							 oLED    => LEDR(9 DOWNTO 0)
						);

	
	-- Output => TX_DATA -> data memory address: 0x00
	PROCESS (CLOCK_50, rst_i)
    BEGIN
        IF rst_i = '1' THEN
            tx_data_de10 <= (OTHERS => '0');
        ELSIF rising_edge(CLOCK_50) THEN
            IF port_adr_o = ADDR_TX_DATA AND port_cyc_o = '1' AND port_stb_o = '1' AND port_we_o = '1' THEN
                tx_data_de10 <= port_dat_o;
            END IF;
        END IF;
   END PROCESS;

    -- Triggering TX_START at address 0x01
   PROCESS (CLOCK_50, rst_i)
		BEGIN
		  IF rst_i = '1' THEN
				tx_ena_de10 <= '1';
		  ELSIF rising_edge(CLOCK_50) THEN
				IF port_adr_o = ADDR_TX_START AND port_cyc_o = '1' AND port_stb_o = '1' AND port_we_o = '1' THEN
					 tx_ena_de10 <= port_dat_o(0);
				END IF;
		  END IF;
   END PROCESS;
	
	
	
	PROCESS (CLOCK_50, rst_i)
		BEGIN
			 IF rst_i = '1' THEN
				  key1_inp <= (OTHERS => '0'); -- Reset data input to 0 on reset
			 ELSIF rising_edge(CLOCK_50) THEN 
				  IF port_adr_o = "00000010" AND  -- Address for the second port
					  port_cyc_o = '1' AND        -- Control signals for I/O
					  port_stb_o = '1' AND 
					  port_we_o  = '0'            -- 'read' operation
				  THEN    
						key1_inp <= "0000000" & key1_db;
				END IF;
			 END IF;
	END PROCESS;
	
	
	PROCESS (CLOCK_50, rst_i)
		BEGIN
			 IF rst_i = '1' THEN
				  switch_inp <= (OTHERS => '0'); -- Reset data input to 0 on reset
			 ELSIF port_adr_o = "00000011" AND  -- Address for the switches input
					  port_cyc_o = '1' AND         -- Control signals for I/O
					  port_stb_o = '1' AND
					  port_we_o  = '0' 
				  THEN
						switch_inp <= SW(7 DOWNTO 0); -- Reading switch SW(0)
			 END IF;
	END PROCESS;

	PROCESS (CLOCK_50, rst_i)
		BEGIN
			 IF rst_i = '1' THEN
				  acc_inp <= (OTHERS => '0'); -- Reset data input to 0 on reset
		 
			 ELSIF port_adr_o = "00000100" AND  -- Address for the switches input
					  port_cyc_o = '1' AND         -- Control signals for I/O
					  port_stb_o = '1' AND
					  port_we_o  = '0'
					  
				  THEN
						acc_inp <= LEDR(7 DOWNTO 0);
			 END IF;
	END PROCESS;
	
	PROCESS(clk_i)
		BEGIN
			IF rising_edge( clk_i ) THEN 
				IF (port_cyc_o = '1' and port_stb_o = '1' and port_we_o = '1' and port_adr_o = "00000101") THEN	
					-- Se actualiza el display en función de los datos recibidos del componente
						 CASE port_dat_o(3 DOWNTO 0) IS
							  WHEN "0000" => HEX0(7 DOWNTO 0) <= "00000001";
							  WHEN "0001" => HEX0(7 DOWNTO 0) <= "01001111";
							  WHEN "0010" => HEX0(7 DOWNTO 0) <= "00010010";
							  WHEN "0011" => HEX0(7 DOWNTO 0) <= "00000110";
							  WHEN "0100" => HEX0(7 DOWNTO 0) <= "01001100";
							  WHEN "0101" => HEX0(7 DOWNTO 0) <= "00100100";
							  WHEN "0110" => HEX0(7 DOWNTO 0) <= "00100000";
							  WHEN "0111" => HEX0(7 DOWNTO 0) <= "00001111";
							  WHEN "1000" => HEX0(7 DOWNTO 0) <= "00000000";
							  WHEN "1001" => HEX0(7 DOWNTO 0) <= "00000100";
							  WHEN OTHERS => HEX0(7 DOWNTO 0) <= "11111111";
						 END CASE;
				END IF;
			END IF;	
	END PROCESS;
	
	PROCESS( clk_i )
	BEGIN
		IF rising_edge( clk_i ) THEN
			IF (port_adr_o = "000000110" and port_cyc_o = '1' and port_stb_o = '1' and port_we_o = '0') THEN
				dec_inp <= rx_data_de10(3 DOWNTO 0);
			END IF;
		END IF;
	END PROCESS;
	
	WITH port_adr_o SELECT
			
			port_dat_i <=  switch_inp WHEN "00000011",
								key1_inp WHEN "00000010",
								acc_inp WHEN "00000100",
								UNAFFECTED WHEN OTHERS;
		
END Structural;