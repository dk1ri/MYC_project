' select commands
' 20250705
'
   If Command_b(1) < &HEF Then
      If Command_b(1) < &H2C Then
         On Command_b(1) Gosub 00,01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,20,21,22
      Else
         Command_not_found
         Gosub Command_received
      End If
   Else
      B_temp1 = Command_b(1) - &HF0
      On B_temp1 Gosub FFF0,Ignore,Ignore,Ignore,Ignore,Ignore,Ignore,Ignore,Ignore,Ignore,Ignore,Ignore,FFFC,FFFD,FFFE,FFFF
   End If