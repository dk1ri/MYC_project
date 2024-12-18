' wireless Setup
' 20201211
'
CONFIG SPI = HARD, INTERRUPT= OFF, DATA_ORDER = MSB , MASTER = YES , POLARITY = LOW , PHASE = 0 , CLOCKRATE = 128 , NOSS=0
'
'Config Spi = Soft , Din = PinD.2 , Dout = PortD.3 , Ss = PortD.5 , Clock = PortD.4
'
 spiinit
'
'additional variables; also used by client
Dim Register As String * 2
Dim Register_b(2) As Byte At Register Overlay
Dim SPI_string As String * 200
Dim Spi_string_b(200) As Byte At Spi_string Overlay
Dim Spi_len As Byte
Dim Spi_in As String * 100
Dim Spi_in_b(100) As Byte At Spi_in Overlay
Dim Send_wireless As Byte
Dim Rx_bytes As Byte
Dim Commandpointer_old As Byte
Dim wireless_serial_rx_count As Byte
Dim wireless_rx_length As Byte
Dim wireless_tx_length As Byte
Dim Wait_for_rx_ready As Byte
'
Spi_len = 0
Send_wireless = 0
Rx_bytes = 0
Commandpointer_old = 0
wireless_serial_rx_count = 0
Radio_type = Radiotype
wireless_rx_length = 0
Wait_for_rx_ready = 0