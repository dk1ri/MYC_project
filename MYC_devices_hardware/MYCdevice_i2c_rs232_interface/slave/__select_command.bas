' select commands
' 20200422
'
   If Command_b(1) < &HEF Then
      If Command_b(1) < &H03 Then
         On Command_b(1) Gosub 00,01,02
      Else
         Gosub Command_received
      End If
   Else
      B_temp1 = Command_b(1) - &HF0
      On B_temp1 Gosub FFF0,Ignore,Ignore,Ignore,Ignore,Ignore,Ignore,Ignore,Ignore,Ignore,Ignore,Ignore,FFFC,FFFD,FFFE,FFFF
   End If