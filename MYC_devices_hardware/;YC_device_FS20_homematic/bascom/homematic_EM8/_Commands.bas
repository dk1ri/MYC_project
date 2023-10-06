' commands
' 20230817
'
01:
   If Commandpointer >= 2 Then
      If Command_b(2) < 9 Then
         Switch = Command_b(2)
         K = T_short
         Gosub Switch_on
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'