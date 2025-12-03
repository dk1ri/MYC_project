' Commands
' 20251201
'
00:
   Tx_time = 1
   A_line = 0
   Number_of_lines = 1
   Send_line_gaps = 2
   Gosub Sub_restore
   Gosub Print_tx
   Gosub Command_received
Return
'
01:
   If Commandpointer >= 3 Then
      'never as wireless command
      If From_wireless = 0 Then
         ' config Jumper required
         If Mode_in = 0 Then
            W_temp1 = Command_b(2) * 256
            W_temp1 = W_temp1 + Command_b(3)
            If Radio_type = 1 Then
               If W_temp1 < 1700 Then
                  Radio_frequency = W_temp1
                  Radio_frequency_eeram = Radio_frequency
                  D_temp1 = Radio_frequency * 1000
                  Gosub Set_frequency_0
               Else
                  Parameter_error
               End If
            Else
               Not_valid_at_this_time
            End If
            Gosub Command_received
         Else
            Not_valid_at_this_time
         End If
      Else
         Not_valid_at_this_time
      End If
      From_wireless = 0
      Gosub Command_received
   End If
Return
'
02:
   If Radio_type = 1 Then
      Gosub Read_frequency_0
      Si_temp_w0 = D_temp1
      Si_temp_w0 = Si_temp_w0 / 1000
      Radio_frequency = Si_temp_w0
      Tx_time = 1
      Tx_b(1) = &H02
      w_temp1 = Radio_frequency
      Tx_b(2) = w_temp1_h
      Tx_b(3) = w_temp1_l
      Tx_write_pointer = 4
      Gosub Print_tx
   Else
      Not_valid_at_this_time
   End If
   Gosub Command_received
Return
'
03:
   If Commandpointer >= 2 Then
      'never as wireless command
      If From_wireless = 0 Then
         ' config Jumper required
         If Mode_in = 0 Then
            If Radio_type = 4 Then
               If Command_b(2) < 129 Then
                  Radio_frequency = B_temp1
                  Radio_frequency_eeram = Radio_frequency
                  Gosub Set_frequency_nrf244
               Else
                  Parameter_error
               End If
            Else
               Not_valid_at_this_time
            End If
         Else
            Not_valid_at_this_time
         End If
      Else
         Not_valid_at_this_time
      End If
      Gosub Command_received
   End If
Return
'
04:
   If Radio_type = 4 Then
      Gosub Read_frequency_nrf244
      Radio_frequency = Spi_in_b(1)
      Tx_time = 1
      Tx_b(1) = &H04
      Tx_b(2) = Radio_frequency
      Tx_write_pointer = 3
      Gosub Print_tx
   Else
      Not_valid_at_this_time
   End If
   Gosub Command_received
Return
'