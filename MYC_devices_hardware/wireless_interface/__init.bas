' additional init
' 20241208
'
Myc_mode = 0
wireless_active = wireless_active_eram
Enable_switch_over = Enable_switch_over_eram
Radio_name = Radio_name_eram
If Mode_in = 0 Then Myc_mode = 1
Const Myc_string = "{238}{032}9d,?sz9_+w5.,d6;t8*<32ksy(e$fhN6"
Command = String(250,0)
#If Radiotype > 0
  Spi_in = String(100,0)
  Spi_string =String(200,0)
  wirelesss_tx_in_progress = 0
#ENDIF
'
#IF Radiotype = 2
   'set rx Mode
   Spi_string_b(1) = Rx_mode
   Spi_len = 1
   Gosub Write_wireless_string
#ENDIF