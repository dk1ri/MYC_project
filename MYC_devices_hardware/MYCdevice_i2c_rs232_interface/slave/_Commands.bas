' Commands
' 20231127
'
01:
If Commandpointer > 1 Then
   If Command_b(2) = 0 Then
      Gosub Command_received
   Else
      If Command_b(2) > 252  Then
         Parameter_error
         Gosub Command_received
      Else
         B_temp1 = Command_b(2) + 2
         If Commandpointer >= B_temp1 Then
         'string finished
            For B_temp2 = 3 To Commandpointer
               B_temp3 = Command_b(B_temp2)
               Printbin B_temp3
            Next B_temp2
            Gosub Command_received
         End If
      End If
   End If
End If
Return
'
02:
Tx_b(1) = &H02
Tx_b(2) = Rs232_pointer
Tx_write_pointer = 3
If Rs232_pointer > 0 Then
   For B_temp2 = 1 To Rs232_pointer
      Tx_b(Tx_write_pointer) = Rs232_in_b(B_temp2)
      Incr Tx_write_pointer
   Next B_temp2
   Rs232_pointer = 0
End If
'all bytes transfered
Gosub Command_received
Return