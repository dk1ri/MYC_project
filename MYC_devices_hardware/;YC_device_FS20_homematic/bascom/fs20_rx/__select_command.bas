' select commands
' 20230925
'
   If Command_b(1) < &HF0 Then
      If Command_b(1) < &H07 Then
         On Command_b(1) Gosub 00,01,02,03,04,05,06
      Else
         Command_not_found
         Gosub Command_received
      End If
   Else
      B_temp1 = Command_b(1) - &HF0
      On B_temp1 Gosub FFF0,Ignore,Ignore,Ignore,Ignore,Ignore,Ignore,Ignore,Ignore,Ignore,Ignore,Ignore,FFFC,FFFD,FFFE,FFFF
   End If