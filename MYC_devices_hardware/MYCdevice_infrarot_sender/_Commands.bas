' additional commands
'
01:
      If Commandpointer >= 2 Then
         If Command_b(2) < 64 Then
            Rc5send Togglebit, Rc5_adress, Command_b(2)
            Set Ir_led
            'Switch of IR LED
         End If
         Gosub Command_received
      End If
Return
'
02:
      If Commandpointer >= 2 Then
         Rc6send Togglebit, Rc6_adress, Command_b(2)
         Set Ir_led
         'Switch of IR LED
         Gosub Command_received
      End If
Return
'
03:
      If Commandpointer >= 2 Then
         If Command_b(2) < 32 Then
            Rc5_adress = Command_b(2)
         Else
            Parameter_error
         End If
         Gosub Command_received
      End If
Return
'
04:
      Tx_b(1) = &H04
      Tx_b(2) = Rc5_adress
      Tx_write_pointer = 3
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
Return
'
05:
      If Commandpointer >= 2 Then
         Rc6_adress = Command_b(2)
         Gosub Command_received
      End If
Return
'
06:
      tx_b(1) = &H06
      tx_b(2) = Rc6_adress
      Tx_write_pointer = 3
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
Return
'
07:
      If Commandpointer >= 2 Then
         If Command_b(2) < 2 Then
            no_myc = Command_b(2)
            no_myc_eeram = no_myc
         Else
            Parameter_error
         End If
         Gosub Command_received
      End If
Return
'
08:
      Tx_b(1) = &H08
      Tx_b(2) = No_myc
      Tx_write_pointer = 3
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
Return
'