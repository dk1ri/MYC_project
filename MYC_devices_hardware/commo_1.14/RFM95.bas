' RFM95 functons
' 20251202
'
'======================================
'Transparent mode ok work with serial Interface only
'
'======================================
' Please refer to the relevant manual:
' RFM95 Most values as default:
' MUST use Boost!!! otherwise no output; not documented!!
' frequency: = 434MHz default
' spreading factor: 128 (7)
' Preamble length : longer than default (better for short packages)
' explicite mode (with header)
'
Set_sleep_mode0:
   Spi_out_b(1) = RegOpMode_w0
   Spi_out_b(2) = &H80
   Call Write_spi(2)
   '
   Spi_out_b(1) = RegOpMode_w0
   Spi_out_b(2) = RegOpMode_standby0
   Call Write_spi(2)
Return
'
Read_irq0:
   Spi_out_b(1) = RegIrqFlags0
   Call Read_spi(1)
Return
'
Reset_irq0:
   Spi_out_b(1) = RegIrqFlags_w0
   Spi_out_b(2) = &HFF
   Call Write_spi(2)
   Waitms 1
   Call Write_spi(2)
Return
'
Read_frequency_0:
   Spi_out_b(1) = RegFrMsb0
   Call Read_spi(3)
   D_temp1 = Spi_in_b(1) * 65536
   D_temp2 = Spi_in_b(2) * 256
   D_temp1 = D_temp1 +  D_temp2
   D_temp1 = D_temp1 + Spi_in_b(3)
   Si_temp_w0  =  D_temp1
   Si_temp_w0 = Si_temp_w0 * 32000000
   Si_temp_w0 = Si_temp_w0 / 524288.
   D_temp1 = Si_temp_w0
   D_temp1 = D_temp1 - Radio_frequency_start0
Return
'
Set_frequency_0:
   D_temp1 = D_temp1 + Radio_frequency_start0
   Si_temp_w1 = D_temp1
   Si_temp_w0 = 32000000 / 524288.
   Si_temp_w1 = Si_temp_w1 / Si_temp_w0
   D_temp1 = Si_temp_w1
   Spi_out_b(1) = RegFrMsb_w0
   Spi_out_b(2) = D_temp1_b(3)
   Spi_out_b(3) = D_temp1_b(2)
   Spi_out_b(4) = D_temp1_b(1)
   Call write_spi(4)
Return
'
Set_rx_start0:
   ' clear buffer
   Gosub Set_sleep_mode0
   waitms 1
   Gosub Reset_irq0
   Spi_out_b(1) = RegOpMode_w0
   Spi_out_b(2) = RegOpMode_rx0
   Call Write_spi(2)
Return
'
RFM95_setup0:
   Gosub Set_sleep_mode0
   ' check: RFM95 available?
   Spi_out_b(1) = RegOpMode_w0
   Call Read_spi(3)
   B_temp1 = Spi_in_b(1)
   If B_temp1 <> 129 Then
      Radio_type = 0
      Return
   End If
   '
   ' Must be Boost!!
   Spi_out_b(1) = &H89
   Spi_out_b(2) = &HCF
   Call Write_spi(2)
   '
   ' Preamble
   ' smaller values may be possible, default was not working max value also nok
   Spi_out_b(1) = &HA0
   Spi_out_b(2) = &H03
   Spi_out_b(3) = &Hff
   Call Write_spi(3)
   '
   ' AGC on
   Spi_out_b(1) = &HA6
   Spi_out_b(2) = &H04
   Call Write_spi(2)
   '
   'Regmodemconfig2 with CRC
   Spi_out_b(1) = &H9E
   Spi_out_b(2) = &H74
   Call Write_spi(2)
   '
   ' set FIFO Base address TX  00 is not working"
'     Spi_out_b(1) = &H8E
 '    Spi_out_b(2) = &H00
  ' Call Write_spi (2)
   ' RX Base adress is 0 by ddefault
   '
   D_temp1 = Radio_frequency * 1000
   Gosub Set_frequency_0
   '
   ' start rx
 '  Spi_out_b(1) = RegOpMode_w0
  ' Spi_out_b(2) = RegOpMode_rx0
   'Call Write_spi(2)
   Gosub Set_rx_start0
Return
'
RFM95_send0:
    ' used for answers of commands of FU and transparent mode of interface
   ' clear FIFO
   '
   B_temp1 = 100
   '
   Gosub Set_sleep_mode0
   waitms 1
   '
   ' set FIFO start address
   Spi_out_b(1) =&H8D
   Spi_out_b(2) = &H80
   Call Write_spi(2)
   '
   Spi_out_b(1) = Reg_fifo_w0
   Gosub create_send_string
   ' write to FIFO
   Call Write_spi(wireless_tx_length)
   '
   ' set Payload Length  , must be witten in explicite mode
   Spi_out_b(1) = &HA2
   ' -1 due to first byte (register)
   Spi_out_b(2) = wireless_tx_length - 1
   Call Write_spi (2)
   '
   waitms 1
   '
   Spi_out_b(1) = RegOpMode_w0
   Spi_out_b(2) = RegOpMode_tx0
   ' send
   Call Write_spi(2)
   Stop WAtchdog
   B_temp2 = 0
   Do
      Gosub Read_irq0
      B_temp1 = Spi_in_b(1) And &B00001000  ' tx done
      If B_temp1 = &B00001000 Then
         B_temp2 = 250
      End If
      Incr B_temp2
      waitms 100
   Loop Until B_temp2 >= 250
   Start Watchdog
   ' is in standby mode now
   Gosub Reset_irq0
   ' allow  all wireless tranmir again
 ' From_wireless = 0
   '
   ' set FIFO start address may be not necessary
   Spi_out_b(1) =&H8D
   Spi_out_b(2) = &H80
   Call Write_spi(2)
   ' back to RX cont mode
   Gosub Set_rx_start0
   ' no errormessage
   Gosub Command_received

Return
'
RFM95_receive0:
   Gosub Read_irq0
   B_temp1 = Spi_in_b(1)
   If B_temp1 > 0 Then
      'IRQ set
      B_temp2 = B_temp1 AND Payload_crc_error
      B_temp3 = B_temp1 AND Irq_rx_done
      If B_temp2 = Payload_crc_error Then
         Gosub Set_rx_start0
      ElseIf B_temp3 = Irq_rx_done Then
         ' Rx done
         Spi_out_b(1) = RegFifoAddrPtr_w0
         Spi_out_b(2) = Reg_fifo_start_rx0
         Call Write_spi(2)
         '
         Spi_out_b(1) = FifoRxNBBytes0
         Call Read_spi(1)
         B_temp1 = Spi_in_b(1)
         '
         Spi_out_b(1) = Reg_fifo0
         Call  Read_spi(B_temp1)
'
         ' name ok?
         B_temp3 = Len(Radio_name)
         B_temp2 = 1
         For B_temp4 = 1 To B_temp3
            If Radio_name_b(B_temp4) <> Spi_in_b(B_temp4) Then B_temp2 = 0
         Next B_temp4
         If B_temp2 = 1 Then
            'name ok
            Incr B_temp3
            B_temp6 = InterfaceFU
            If B_temp6 = 0 Then
               ' Interface
               For B_temp2 = B_temp3 To B_temp1
                  B_temp4 = Spi_in_b(B_temp2)
                  Printbin B_temp4
               Next B_temp2
            Else
               ' FU
               B_temp4= 1
               Command_pointer = 0
   '            Tx_write_pointer = 1
               For B_temp2 = B_temp3 To B_temp1
                  command_b(B_temp4) = Spi_in_b(B_temp2)
                  Incr Command_pointer
                  Incr B_temp4
               Next B_temp2
               From_wireless = 1
            End If
         End If
         Gosub Set_rx_start0
      End If
   End If
Return
'