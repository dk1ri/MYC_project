' nRF24 Subs
' 20251203
' tesetd with Adafruit and Soldered Hardwar
' The application note of MCS was used when creating these subs
'
nRF24_setup4:
   ' CE pin: no RX, acces rgister
   Reset Reset_ce
   Reset Scs
   '
   ' check: nrf24 present?
   Spi_out_b(1) = EN_AA4
   Call Read_spi (1)
   B_temp1 = Spi_in_b(1)
   If B_temp1 <> 63 Then
      Radio_type = 0
      Return
   End If
   '
   Gosub Clear_int4
   '
   Gosub Write_name_4
   '
   Spi_out_b(1) = EN_AA_w4                             'Enable auto ACK for all pipes
   Spi_out_b(2) = &H01
   Call write_spi(2)
   Spi_out_b(1) = EN_RXADDR_w4                          'Enable RX adress for pipe0
   Spi_out_b(2) = &H01
   Call write_spi(2)
   Spi_out_b(1) = RF_CH_w4                              'Set RF channel
   Spi_out_b(2) = Radio_frequency
   Call write_spi(2)
   Spi_out_b(1) =RX_PW_P0_w4                             'Set RX pload width for pipe0
   Spi_out_b(2) = 32
   Call write_spi(2)
   Spi_out_b(1) = RF_Setup_w4                           'Setup RF-> Output power 0dbm, datarate 2Mbps and LNA gain on
   Spi_out_b(2) = &H0B                                   'modified 0F -> 0B
   Call write_spi(2)
   Spi_out_b(1) = DYNPD_w4                               ' enable dpl for pipe0
   Spi_out_b(2) = &B00000001
   Call write_spi(2)
   Spi_out_b(1) = Feature_w4
   Spi_out_b(2) = &B00000100                             ' enable dpl
   Call write_spi(2)
   Spi_out_b(1) = Config_w4
   Spi_out_b(2) = Config_Rx_up
   Call write_spi(2)
   set Reset_ce
Return
'
Cmd_Flush_RX4:
   Spi_out_b(1) = FLUSH_RX4
   Call Write_spi (1)
Return
'
Cmd_Flush_TX4:
   Spi_out_b(1) = FLUSH_TX4
   Call Write_spi (1)
Return
'
Clear_int4:
   Spi_out_b(1) = STATUS_w4
   Spi_out_b(2) = &H70
   Call Write_spi (2)
Return
'
Set_frequency_nrf244:
   Reset Reset_ce
   Spi_out_b(1) = RF_CH_w4
   Spi_out_b(2) = Radio_frequency
   Call Write_spi (2)
Return
'
Read_frequency_nrf244:
   Reset Reset_ce
   Spi_out_b(1) = RF_CH4
   Call Read_spi (1)
Return
'
Write_name_4:
   Reset Reset_ce
   Spi_out = String(6,0)
   B_temp3 = len(Radio_name)
   B_temp2 = 2
   For B_temp1 = 1 To B_temp3
      Spi_out_b(B_temp1 + 1) = Radio_name_b(B_temp1)
   Next B_temp1
   Spi_out_b(1) = RX_ADDR_P0_w4
   Call Write_spi (6)
   Spi_out_b(1) = TX_ADDR_P0_w4
   call Write_spi (6)
Return
'
nRF24_send4:
   ' CE pin: no RX, access rgister
   Reset Reset_ce
   Gosub Cmd_Flush_TX4
   Gosub Clear_int4
   Spi_out_b(1) = Config_w4
   Spi_out_b(2) = Config_TX_up
   Call Write_spi (2)
   ' write data to FIFO
   ' split for wireless_tx_length > 32
   ' datapointer:
   B_temp2 = 1
   B_temp6 = InterfaceFU
   'marker for last loop:
   B_temp5 = 0
   Do
      'B_temp4 is actual length
      If wireless_tx_length > 32 Then
         B_temp4 = 32
      Else
         B_temp4 = wireless_tx_length
         B_temp5 = 1
      End If
      Spi_out_b(1) = W_TX_PAYLOAD4
      'Pointer for Output:
      B_temp3 = 2
      For B_temp1 = B_temp2 To B_temp2 + B_temp4
            If B_temp6 = 0 Then
               Spi_out_b(B_temp3) = Command_b(B_temp1)
            Else
               Spi_out_b(B_temp3) = Tx_b(B_temp1)
            End If
         Incr B_temp3
      Next B_temp1
      call Write_spi (B_temp4 + 1)
      '
      Waitms 2
      Set Reset_ce
      Waitms 1
      Reset Reset_ce
      'counter:
      B_temp3 = 0
      Do
         Spi_out_b(1) = STATUS4
         Call Read_spi (1)
         B_temp1 = Spi_in_b(1) And &B01110000
         If B_temp1 <> &B00100000 Then
            Waitms 1
            Incr B_temp3
         End If
      Loop Until B_temp3 > 50 Or B_temp1 = &B00100000
      ' in case of error no further transmission
      If B_temp3 > 50 Then B_temp5 = 1
      B_temp2 = B_temp2 + B_temp4
      wireless_tx_length = wireless_tx_length - B_temp4
      '  receiver requires > 10ms to receive again!
      If B_temp5 = 0 Then waitms 20
   Loop Until B_temp5 = 1
   ' RX again
   ' after successdull send there is not much time to switch to RX!!!
   Gosub Clear_int4
   Spi_out_b(1) = Config_w4
   Spi_out_b(2) = Config_Rx_up
   Call Write_spi (2)
   Set Reset_ce
Return
'
nRF24_receive4:
   Spi_out_b(1) = FIFO_STATUS4
   Call Read_spi (1)
   If  Spi_in_b(1).0 = 0 Then
      ' data available
      Reset Reset_ce
      Reset ScS
      'rx length
      Spi_out_b(1) = R_RX_PL_WID4
      Call Read_spi(1)
      B_temp1 = Spi_in_b(1)
      Spi_out_b(1) = R_RX_PAYLOAD4
      B_temp6 = InterfaceFU
      If B_temp6 = 0 Then
         ' Interface
         Call Read_spi(B_temp1)
         For B_temp2 = 1 To B_temp1
            B_temp4 = Spi_in_b(B_temp2)
            Printbin B_temp4
         Next B_temp2
      Else
         Reset ScS
         spiout Spi_out_b(1), 1
         spiin  Command_b(1), B_temp1
         Set ScS
         Command_pointer = B_temp1
      End If
      Gosub Clear_int4
      Gosub Cmd_flush_rx4
      Set Reset_ce
   End If
Return