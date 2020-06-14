' additional commands
'
01:
      Tx_b(1) = &H01
      Tx_b(2) = Rc5_writepointer - 1
      'length
      If Rc5_writepointer > 1 Then
         For b_Temp1 = 1 To Rc5_writepointer - 1
            b_Temp2 = b_Temp1 + 2
            'Rc5buffer start with 1
            Tx_b(b_Temp2) = Rc5buffer_b(b_Temp1)
         Next b_Temp1
         Tx_write_pointer = Rc5_writepointer + 2
         Gosub Reset_rc5buffer
      ELse
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