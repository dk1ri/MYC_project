' RFM95 functons
' 20250528
'
' Please refer to the relevant manual:
' RFM95 all values as default:
' frequency: = 434MHz (?) (High) -> RFM
' spreading factor: 128 (7)
' Coding Rate :? RegTxCfg1 not found, see page 25
' Bandwidth ?
' Preamble length : 12 (8)
' explicite mode (with header) RxPayloadCrcOn off
'
'
'
Set_sleep_mode0:
   Register_b(1) = &B10000001
   Register_b(2) = RegOpMode_sleep0
   Gosub Write_register
Return
'
Set_stand_by_mode0:
   Register_b(1) = RegOpMode_w0
   Register_b(2) = RegOpMode_standby0
   Gosub Write_register
Return
'
Set_tx_mode0:
   Register_b(1) = RegOpMode_w0
   Register_b(2) = RegOpMode_tx0
   Gosub Write_register
Return
'
Set_rx_mode0:
   Register_b(1) = RegOpMode_w0
   Register_b(2) = RegOpMode_rx0
   Gosub Write_register
Return
'
Reset_irq0:
   Register_b(1) = RegIrqFlags0
   Register_b(2) = &HFF
   Gosub Write_register
Return
'
Set_pointer_to_rx_start0:
   Register_b(1) = RegFifoAddrptr0
   Register_b(2) = Reg_fifo_start_rx0
   Gosub Write_register
Return
'
Set_pointer_to_tx_start0:
   Register_b(1) = RegFifoAddrptr0
   Register_b(2) = Reg_fifo_start_tx0
   Gosub Write_register
Return
'
Tx_wireless_start0:
   ' used for answers of commands of FU and transparent mode of interface
   Gosub Set_stand_by_mode0
   '
   ' start position for write FIFO ;
   Register_b(1) = RegFifoAddrPtr_w0
   Register_b(2) = Reg_fifo_start_tx0
   Gosub Write_register
   '
   Gosub Write_register
   If Interface_FU = 0 Then
      wireless_tx_length = Command_pointer - 1
   Else
      wireless_tx_length = Tx_pointer - 1
   End If
   B_temp2 = 1
   wirelesss_tx_in_progress = 1
   ' Add Name to Tx
   B_temp1 = Len(Radio_name)
   Spi_len = wireless_tx_length + B_temp1
   B_temp2 = Spi_len
   If Interface_FU = 0 Then
      ' shift command by len(name)
      For B_temp3 = wireless_tx_length To 1 Step - 1
         Tx_b(B_temp2) = command_b(B_temp3)
         Decr B_temp2
      Next B_temp3
      ' Add name
   Else
      For B_temp3 = wireless_tx_length To 1 Step - 1
         Tx_b(B_temp2) = Tx_b(B_temp3)
         Decr B_temp2
      Next B_temp3
   End If
   ' Add name
   For B_temp3 = 1 To B_temp1
      Tx_b(B_temp3) = Radio_name_b(B_temp3)
   Next B_temp3
   Tx_b(1) = Reg_fifo_w0
   ' length
   Tx_b(2) = wireless_tx_length + B_temp1
   '
   Gosub Write_wireless_string

   ' Payload_length
   Register_b(1) = RegPayloadLength_w0
   Register_b(2) = wireless_tx_length
   Gosub Write_register

   Gosub Set_pointer_to_tx_start0
   '
   Gosub Set_tx_mode0
   '
   Command = string(250,0)
Return
'
Finish_tx0:
   ' read Irq
   Register_b(1) = RegIrqFlags0
   Gosub Read_register
   B_temp1 = Spi_in_b(1)
   B_temp1 = B_temp1 And &B00001000
   If B_temp1 = &B00001000 Then
      ' tx ready
      ' clear all and back to RX cont mode
      Register_b(1) = RegOPMode0
      Register_b(2) = RegOpMode_sleep0

      Gosub Reset_irq0
      '
      waitms 1
      Gosub Set_stand_by_mode0
      '
      Gosub Set_rx_mode0
      '
      wirelesss_tx_in_progress = 0
   End If
Return
'
Receive_wireless0:
   'check RX
   Register_b(1) = RegIrqFlags0
   Spi_len = 1
   Gosub Read_register
   '
   B_Temp1 = Spi_in_b(1) And &B01000000
   If B_temp1 = &B01000000 Then
      ' Rx done
      B_temp1 = Spi_in_b(1) And &B00110000
      If B_temp1 = &B10010000 Then
         ' no payload CRC error  valid Header  no timeout
         Register_b(1) = FifoRxBytesNb_Bytes0
         Gosub Read_register
         Rx_bytes = Spi_in_b(1)
         '
         'Register_b(1) = FifoRxCurrentAddr0
         'Gosub Read_register0
         '
         'set Fifopointer
         Register_b(1) = RegFifoAddrPtr_w0
         ' set to start
         Register_b(2) = 0
         Gosub Write_register
         '
         Gosub Read_fifo
         '
         'name ok?
         B_temp2 = 1
         For B_temp1 = 1 To 4
            If Radio_name_b(B_temp1) = Spi_in_b(B_temp1) Then B_temp2 = 0
         Next B_temp1
         ' shift  left
         B_temp2 = Rx_bytes - 4
         B_temp3 = 5
         Command_pointer = 1
         For B_temp1 = 1 to B_temp2
            If Interface_FU = 1 Then
               ' FU
               command_b(B_temp1) = Spi_in_b(B_temp3)
               Incr Command_pointer
            Else
               ' Interface
               Tx_b(B_temp1) = Spi_in_b(B_temp3)
            End If
            Incr B_temp3
         Next B_temp1
         If Interface_FU = 0 Then
            ' send to server
            Gosub Print_tx
         End If
         '
      End If
      'continous mode: only irq must be resetted and read pointer resetted
      Gosub Reset_irq0
      Register_b(1) = RegFifoaddrptr0
      Register_b(2) = 0
      Gosub Write_register
   End If
Return
'
Rfm95_setup0:
 ' Gosub Set_rx_mode0
Return
'
Set_radio_f0:
   Gosub Set_sleep_mode0
   Register_b(1) = RegFrMsb_w0
   Register_b(2) = Radio_frequency_b(2)
   Gosub write_register
   Register_b(1) = RegFrMid_w0
   Register_b(2) = Radio_frequency_b(3)
   Gosub write_register
   Register_b(1) = RegFrlsb_w0
   Register_b(2) = Radio_frequency_b(4)
   Gosub write_register
   Gosub Set_rx_mode0
Return
'
Read_frequency_0:
   Gosub Set_sleep_mode0
   Register_B(1) = RegFrMsb0
   Spi_len = 3
   Gosub Read_register
   Si_temp_w0 = Spi_in_b(1) * 65525
   Si_temp_w1 = Spi_in_b(2) * 256
   Si_temp_w0 = Si_temp_w0 + Si_temp_w1
   Si_temp_w0 = Si_temp_w0 + Spi_In_b(3)
   Radio_frequency = Si_temp_w0
   Gosub Set_rx_mode0
   Return
'