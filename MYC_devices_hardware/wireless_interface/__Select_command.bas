' select commands
' 20250816
'
Select_command:
   If Command_b(1) < 240 Then
      If Command_b(1) < 6 Then
         On Command_b(1) Gosub 00,01,02,03,04,05
      Else
         Command_not_found
         Gosub Command_received
      End If
   Else
      B_temp1 = Command_b(1) - 240
      On B_temp1 Gosub FFF0,Ignore,Ignore,Ignore,Ignore,Ignore,FFF6,FFF7,Ignore,Ignore,Ignore,Ignore,FFFC,FFFD,FFFE,FFFF
   End If
Return