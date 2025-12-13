' Commands
' 20251201
'
00:
   Gosub Print_basic
   Gosub Print_tx
   Gosub Command_received
Return
'
01:
   If Commandpointer >= 3 Then
      Old_commandpointer = Commandpointer
      'never as wireless command
      If Command_origin <> 4 Then
         ' config Jumper required
         If Mode_in = 0 Then
            W_temp1 = Command_b(2) * 256
            W_temp1 = W_temp1 + Command_b(3)
            If W_temp1 < 1700 Then
               Radio_frequency0 = W_temp1
               Radio_frequency0_eeram = Radio_frequency0
               D_temp1 = Radio_frequency0 * 1000
               Gosub Set_frequency_0
            Else
               Parameter_error
            End If
            Gosub Command_received
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
02:
   Old_commandpointer = Commandpointer
   if Radio_type = 1 Then Gosub Read_frequency_0
   Tx_b(1) = &H02
   w_temp1 = Radio_frequency0
   print w_temp1
   Tx_b(2) = w_temp1_h
   Tx_b(3) = w_temp1_l
   Tx_write_pointer = 4
   Gosub Print_tx
Return
'
03:
   If Commandpointer >= 2 Then
      Old_commandpointer = Commandpointer
      'never as wireless command
      If Command_origin <> 4 Then
         ' config Jumper required
         If Mode_in = 0 Then
            If Command_b(2) < 129 Then
               Radio_frequency4 = B_temp1
               Radio_frequency4_eeram = Radio_frequency4
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
      Gosub Command_received
   End If
Return
'
04:
   Old_commandpointer = Commandpointer
   If Radio_type = 4 Then Gosub Read_frequency_nrf244
   Tx_b(1) = &H04
   Tx_b(2) = Radio_frequency4
   Tx_write_pointer = 3
   Gosub Print_tx
Return
'
05:
   Old_commandpointer = Commandpointer
   Tx_b(1) = &H05
   If Mode_in = 0 Then
      Tx_b(2) = 1
   Else
      Tx_b(2) = 0
   End If
   Tx_write_pointer = 3
   Gosub Print_tx
Return