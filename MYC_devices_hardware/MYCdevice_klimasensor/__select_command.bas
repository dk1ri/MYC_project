' select commands
' 20200422
'
   If Command_b(1) < &HEF Then
      If Command_b(1) < &H10 Then
         On Command_b(1) Gosub 00,01,02,03,04,05,06,07,08,09,0A,0B,0C,0D,0E,0F
      Else
         Gosub Command_received
      End If
   Else
      B_temp1 = Command_b(1) - &HF0
      On B_temp1 Gosub FFF0,Ignore,Ignore,Ignore,Ignore,Ignore,Ignore,Ignore,Ignore,Ignore,Ignore,Ignore,FFFC,FFFD,FFFE,FFFF
   End If