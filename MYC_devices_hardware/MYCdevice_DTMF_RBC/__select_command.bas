' select commands
' 20200422
'
   If Command_b(1) < &HF0 Then
      If Command_b(1) < &H020 Then
         On Command_b(1) Gosub 00,01,02,03,04,05,06,07,08,09,0A,0B,0C,0D,0E,0F,10,11,12,13,14,15,16,17,18,19,1A,1B,1C,1D,1E,1F
      Else
         If Command_b(1) < &H38 Then
            B_temp1 = Command_b(1) - &H20
            On B_temp1 Gosub 20,21,22,23,24,25,26,27,28,29,2A,2B,2C,2D,2E,2F,30,31,32,33,34,35,36,37
         Else
            Command_not_found
            Gosub Command_received
         End If
      End If
   Else
      B_temp1 = Command_b(1) - &HF0
      On B_temp1 Gosub FFF0,Ignore,Ignore,Ignore,Ignore,Ignore,Ignore,Ignore,Ignore,Ignore,Ignore,Ignore,FFFC,FFFD,FFFE,FFFF
   End If