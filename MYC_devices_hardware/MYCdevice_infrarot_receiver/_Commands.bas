' additional commands
'
01:
      Tx_b(1) = &H01
      b_Temp2 = 3
      'length
      If Rc5_writepointer > 1 Then
      b_Temp2 = 3
         For b_Temp1 = 1 To Rc5_writepointer - 1
            b_Temp3 = Rc5buffer_b(b_Temp1)
            b_Temp3 = b_Temp3 / 10
            b_Temp3 = b_Temp3 + 48
            Tx_b(b_Temp2) = b_Temp3
            Incr b_Temp2
            b_Temp3 = Rc5buffer_b(b_Temp1)
            b_Temp3 = b_Temp3 Mod 10
            b_Temp3 = b_Temp3 + 48
            Tx_b(b_Temp2) = b_Temp3
            Incr b_Temp2
            Tx_b(b_Temp2) = ","
            Incr b_Temp2
         Next b_Temp1
         Tx_b(2) = B_temp2 - 2
         Tx_write_pointer = b_temp2 - 1
         Gosub Reset_rc5buffer
      Else
         Tx_b(2) = 0
         Tx_write_pointer = 3
      End If
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
Return
'
02:
      If Commandpointer >= 2 Then
         b_Temp1 = Command_b(2)
         If b_Temp1 < 32 Then
            Valid_adress = b_Temp1
            Valid_adress_eeram = b_Temp1
         Else_parameter_error
         Gosub Command_received
      End If
Return
'
03:
      Tx_b(1) = &H03
      Tx_b(2) = Valid_adress
      Tx_write_pointer = 3
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
Return
'
04:
      If Commandpointer >= 2 Then
         If Command_b(2) < 2 Then
            no_myc = Command_b(2)
            no_myc_eeram = no_myc
         Else_parameter_error
         Gosub Command_received
      End If
Return
'
05:
      Tx_b(1) = &H05
      Tx_b(2) = no_myc
      Tx_write_pointer = 3
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
Return
'