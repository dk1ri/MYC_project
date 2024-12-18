' A7129 Setup
' 20241205
' all registers are mentioned here
'
7129_setup:
   Config PinB.1 = Input
   Gio1 Alias PinB.1
   '
   Spi_len = 3
   const Sytemclock_r = &H80
   const Sytemclock = &H0
   const Sytemclock_d1   = &H08
   Const Sytemclock_d2   = &H23
   Spi_string_b(1) = Sytemclock
   Spi_string_b(2) = Sytemclock_d1
   Spi_string_b(3) = Sytemclock_d2
   Gosub Write_wireless_string
   '
   Const Pll1 = &H01
   const Pll1_d1 = &H0A
   Const Pll1_d2 = &H21
   'data rate 12m / 128 / (64 + 1) = 1.442k
   Spi_string_b(1) = Pll1
   Spi_string_b(2) = Pll1_d1
   '433MHz
   Spi_string_b(3) = Pll1_d2
   Gosub Write_wireless_string
   '
   Const Pll2 = &H02
   Const Pll2_d1 = &HDA
   Const Pll2_d2 = &H05
   Spi_string_b(1) = Pll2
   Spi_string_b(2) = Pll2_d1
   '433MHz
   Spi_string_b(3) = Pll2_d2
   Gosub Write_wireless_string
   '
   Const Pll3 = &H03
   Const Pll3_d1 = &H00
   Const Pll3_d2 = &H00
   Spi_string_b(1) = Pll3
   Spi_string_b(2) = Pll3_d1
   '433MHz
   Spi_string_b(3) = Pll3_d2
   Gosub Write_wireless_string
   '
   Const Pll4 = &H04
   Const Pll4_d1 = &H0E
   Const Pll4_d2 = &H20
   Spi_string_b(1) = Pll4
   Spi_string_b(2) = Pll4_d1
   Spi_string_b(3) = Pll4_d2
   Gosub Write_wireless_string
   '
   Const Pll5 = &H05
   Const Pll5_d1 = &H00
   Const Pll5_d2 = &H24
   Spi_string_b(1) = Pll5
   Spi_string_b(2) = Pll5_d1
   Spi_string_b(3) = Pll5_d2
   Gosub Write_wireless_string
   '
   Const Pll6 = &H06
   Const Pll6_d1 = &H00
   Const Pll6_d2 = &H00
   Spi_string_b(1) = Pll6
   Spi_string_b(2) = Pll6_d1
   Spi_string_b(3) = Pll6_d2
   Gosub Write_wireless_string
   '
   Const Crystalx = &H07
   Const Crystal_d1 = &H00
   Const Crystal_d2 = &H11
   ' Crystal enabled high current
   Spi_string_b(1) = Crystalx
   Spi_string_b(2) = Crystal_d1
   Spi_string_b(3) = Crystal_d2
   Gosub Write_wireless_string
   '
   Const PA0_ = &H08
   Const PB0_ = &H09
   '
   Const Rx1 = &H0A
   Const Rx1_d1 = &H08
   Const Rx1_d2 = &HD0
   Spi_string_b(1) = Rx1
   Spi_string_b(2) = Rx1_d1
   Spi_string_b(3) = Rx1_d2
   Gosub Write_wireless_string
   '
   Const Rx2 = &H0B
   Const Rx2_d1 = &H70
   ' 16 bit preamble
   Const Rx2_d2 = &H09
   Spi_string_b(1) = Rx2
   Spi_string_b(2) = Rx2_d1
   Spi_string_b(3) = Rx2_d2
   Gosub Write_wireless_string
   '
   Const ADC_ = &H0C
   Const Adc_d1 = &H40
   Const Adc_d2 = &H00
   Spi_string_b(1) = Adc_
   Spi_string_b(2) = Adc_d1
   Spi_string_b(3) = Adc_d2
   Gosub Write_wireless_string
   '
   Const Pin_control = &H0D
   Const Pin_control_d1_s = &H08
   'strobe Mode
   Const Pin_control_d2 = &H00
   Spi_string_b(1) = Pin_control
   Spi_string_b(2) = Pin_control_d1_s
   Spi_string_b(3) = Pin_control_d2
   Gosub Write_wireless_string
   '
   Const Calibration = &H0E
   Const Calibration_d1 = &H4C
   Const Calibration_d2 = &H45
   Spi_string_b(1) = Calibration
   Spi_string_b(2) = Calibration_d1
   Spi_string_b(3) = Calibration_d2
   Gosub Write_wireless_string
   '
   Const Modecontrol = &H0F
   Const Modecontrol_d1 = &H20
   Const Modecontrol_d2 = &HC0
   'fifo mode; crystal on
   Spi_string_b(1) = Modecontrol
   Spi_string_b(2) = Modecontrol_d1
   Spi_string_b(3) = Modecontrol_d2
   Gosub Write_wireless_string
   '
   '
   ' Page A
   B_temp2 = &H08
   B_temp5 = 0
   ' Tx1
   ' Fdev = 18.75kHz
   B_temp1 = &H00
   B_temp3 = &HF6
   B_temp4 = &H06
   Gosub Write_page_register
   '
   ' WOR1
   B_temp1 = &H10
   B_temp3 = &H00
   B_temp4 = &H00
   Gosub Write_page_register
   '
   ' WOR2
   B_temp1 = &H20
   B_temp3 = &HF8
   B_temp4 = &H00
   Gosub Write_page_register
   '
   ' rfi
   'Enable Tx Ramp up/down
   B_temp1 = &H30
   B_temp3 = &H19
   B_temp4 = &H07
   Gosub Write_page_register
   '
   ' PM
   'CST=1
   B_temp1 = &H40
   B_temp3 = &H9B
   B_temp4 = &H70
   Gosub Write_page_register
   '
   ' rth
   B_temp1 = &H50
   B_temp3 = &H03
   B_temp4 = &H02
   Gosub Write_page_register
   '
   'AGC1
   B_temp1 = &H60
   B_temp3 = &H40
   B_temp4 = &H0F
   Gosub Write_page_register
   '
   ' AGC2
   B_temp1 = &H70
   B_temp3 = &H0A
   B_temp4 = &HC0
   Gosub Write_page_register
   '
   ' GIO
   B_temp1 = &H80
   ' GIO2=WTR, GIO1=FSYNC
   'B_temp3 = &H00
   'B_temp4 = &H45
   ' GIO2: SDO GIO1: Valid packet
   B_temp3 = &H06
   B_temp4 = &H71
   Gosub Write_page_register
   '
   ' CKO
   B_temp1 = &H90
   B_temp3 = &HD1
   B_temp4 = &H81
   Gosub Write_page_register
   '
   'VCO
   B_temp1 = &HA0
   B_temp3 = &H00
   B_temp4 = &H04
   Gosub Write_page_register
   '
   'CHG1
   '430MHz
   B_temp1 = &HB0
   B_temp3 = &H0A
   B_temp4 = &H21
   Gosub Write_page_register
   '
   ' CHG2
   ' 435 MHz
   B_temp1 = &HC0
   B_temp3 = &H00
   B_temp4 = &H22
   Gosub Write_page_register
   '
   ' FIFO
   ' FEP=63+1=64bytes
   B_temp1 = &HD0
   B_temp3 = &H00
   B_temp4 = &H3F
   Gosub Write_page_register
   '
   ' Code
   ' Preamble=4bytes, ID=4bytes
   B_temp1 = &HE0
   B_temp3 = &H15
   B_temp4 = &H07
   Gosub Write_page_register
   '
   ' Wcal
   B_temp1 = &HF0
   B_temp3 = &H00
   B_temp4 = &H00
   Gosub Write_page_register
   '
   ' Page B
   B_temp2 = &H09
   ' Tx2
   B_temp1 = &H00
   B_temp3 = &H03
   B_temp4 = &H37
   B_temp5 = &H00
   Gosub Write_page_register
   '
   'IF1
   B_temp1 = &H00
   B_temp3 = &H82
   B_temp4 = &H00
   B_temp5 = &H80
   Gosub Write_page_register
   '
   'IF2
   B_temp1 = &H01
   B_temp3 = &H00
   B_temp4 = &H00
   B_temp5 = &H00
   Gosub Write_page_register
   '
   ' ACK
   B_temp1 = &H01
   B_temp3 = &H00
   B_temp4 = &H00
   B_temp5 = &H80
   Gosub Write_page_register
   '
   ' ART
   B_temp1 = &H02
   B_temp3 = &H00
   B_temp4 = &H00
   B_temp5 = &H00
   Gosub Write_page_register
   '
   Const Id_code_r = &B10100000
   Const Id_code_w = &B00100000
   Const Fifo_r =  &B11000000
   Const Fifo = &B01000000
   Const Softwarereset = &H70
   Const Tx_fofo_pointer_reset =  &H60
   Const Rx_fofo_pointer_reset =  &HE0
   Const Standby =  &H14
   Const Rx_mode = &H18
   Const Tx_mode = &H1A
'
Return