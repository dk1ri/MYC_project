' additional command 254 parameters
'
 Case 5
   If Commandpointer >= 3 Then
      B_temp2 = Command_b(3)
      If B_temp2 < 2 Then
         wireless_active = B_temp2
         wireless_active_eram = wireless_active
      Else_Parameter_error
      Gosub Command_received
   End If