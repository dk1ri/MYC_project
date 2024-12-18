' LoRa functons
' 20201025
'
'
Read_fifo:
   Reset SCS
   spiout Register, 1
   spiin  Spi_string, Rx_bytes
   Set SCS
Return
'
Set_sleep_mode:
 'standby mode to set registers in Lora
   Register_b(1) = RegOpMode_w
   Register_b(2) = RegOpMode_lora_sleep
   Gosub Write_register
Return
 '
Set_stand_by_mode:
 'standby mode to set registers in Lora
   Register_b(1) = RegOpMode_w
   Register_b(2) = RegOpMode_lora_standby
   Gosub Write_register
Return
 '
Set_tx_mode:
 'standby mode to set registers in Lora
   Register_b(1) = RegOpMode_w
   Register_b(2) = RegOpMode_lora_tx
   Gosub Write_register
Return
 '
 Set_rx_mode:
   'standby mode to set registers in Lora
   Register_b(1) = RegOpMode_w
   Register_b(2) = RegOpMode_lora_rxcont
   Gosub Write_register
Return
'
Reset_irq:
   Register_b(1) = RegIrqFlags
   Register_b(2) = &HFF
   Gosub Write_register
Return
'
Set_pointer_to_rx_start:
   Register_b(1) = RegFifoAddrptr
   Register_b(2) = Reg_fifo_start_rx
   Gosub Write_register
Return
'
Set_pointer_to_tx_start:
   Register_b(1) = RegFifoAddrptr
   Register_b(2) = Reg_fifo_start_tx
   Gosub Write_register
Return
'
Lora_tx:
   wirelesss_tx_in_progress = 1
   ' Add Name to Tx
   B_temp1 = Len(Radio_name)
   Spi_len = wireless_tx_length + B_temp1
   B_temp2 = Spi_len
   ' shift command by len(name)
   For B_temp3 = wireless_tx_length To 1 Step - 1
      Spi_string_b(B_temp2) = Spi_string_b(B_temp3)
      Decr B_temp2
   Next B_temp3
   ' Add name
   For B_temp3 = 1 To B_temp1
      Spi_string_b(B_temp3) = Radio_name_b(B_temp3)
   Next B_temp3
   Spi_string_b(1) = Reg_fifo_w
   ' length
   Spi_string_b(2) = wireless_tx_length + B_temp1
   '
   Gosub Set_stand_by_mode
   '
   ' start position for write FIFO ;
   Register_b(1) = RegFifoAddrPtr_w
   Register_b(2) = Reg_fifo_start_tx
   Gosub Write_register
   '
   ' Payload_length
   Register_b(1) = RegPayloadLength_w
   Register_b(2) = wireless_tx_length
   Gosub Write_register
   '
   Gosub Set_pointer_to_tx_start
   '
   Gosub Write_wireless_string
   '
   Gosub Set_tx_mode
   '
   Spi_string = string(100,0)
Return
'
Lora_finish_tx:
   ' read Irq
   Register_b(1) = RegIrqFlags
   Gosub Read_register
   B_temp1 = Spi_in_b(1)
   B_temp1 = B_temp1 And &B00001000
   If B_temp1 = &B00001000 Then
      ' tx ready
      ' clear all and back to RX cont mode
      Register_b(1) = RegOPMode
      Register_b(2) = RegOpMode_lora_sleep

      Gosub Reset_irq
      '
      waitms 1
      Gosub Set_stand_by_mode
      '
      Gosub Set_rx_mode
      '
      wirelesss_tx_in_progress = 0
   End If
Return
'
Lora_rx:
   'check LoRa RX
   Register_b(1) = RegIrqFlags
   Gosub Read_register
   '
   B_Temp1 = Spi_in_b(1) And &B01000000
   If B_temp1 = &B01000000 Then
      ' Rx done
      B_temp1 = Spi_in_b(1) And &B00110000
   If B_temp1 = &B10010000 Then
      ' no payload CRC error  valid Header  no timeout
         Register_b(1) = FifoRxBytesNb_Bytes
         Gosub Read_register
         Rx_bytes = Spi_in_b(1)
         '
         Register_b(1) = FifoRxCurrentAddr
         Gosub Read_register
         '
         'set Fifopointer
         Register_b(1) = RegFifoAddrPtr_w
         Register_b(2) = Spi_in_b(1)
         Gosub Write_register
         '
         Gosub Read_fifo
         '
         Gosub Reset_irq

         'name ok?
         B_temp2 = 1
         For B_temp1 = 1 To 4
            If Radio_name_b(B_temp1) = Spi_in_b(B_temp1) Then B_temp2 = 0
         Next B_temp1
         ' shift  left
         B_temp2 = Rx_bytes - 4
         B_temp3 = 5
         For B_temp1 = 1 to B_temp2
            Tx_b(B_temp1) = Spi_in_b(B_temp3)
            Incr B_temp3
         Next B_temp1
         ' send to server (serial only)
         Gosub Print_tx
         '
         Spi_string = string(200,0)
      Else
         Gosub Set_sleep_mode
         Gosub Reset_irq
         Gosub Set_rx_mode
      End If
   End If
Return
'