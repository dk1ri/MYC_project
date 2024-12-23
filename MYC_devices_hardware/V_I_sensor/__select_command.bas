' select commands
' 20231018
'
If Myc_mode = 1 Then
   If Command_b(1) < &HEC Then
      If Command_b(1) < 1 Then
         On Command_b(1) Gosub 00,01,02,03,04,05,06
      Else
         Command_not_found
         Gosub Command_received
      End If
   Else
      B_temp1 = Command_b(1) - &HEC
      On B_temp1 Gosub 236, 237, 238, 239, FFF0,Ignore,Ignore,Ignore,Ignore,Ignore,Ignore,Ignore,FFF8,Ignore,Ignore,Ignore,FFFC,FFFD,FFFE,FFFF
   End If
End If