' Commands
' 20260612
'
00:
Tx_time = 1
   A_line = 0
   Number_of_lines = 1
   Send_line_gaps = 2
   Gosub Sub_restore
   Gosub Print_tx
   Gosub Command_received
Return
'
01:
   Tx_b(1) = &H01
   Tx_b(2) = Frequency_b(2)
   Tx_b(3) = Frequency_b(1)
   Tx_write_pointer = 4
   Gosub Print_tx
   Gosub Command_received
Return
'
02:
   Tx_b(1) = &H02
   Tx_b(2) = Minf_b(2)
   Tx_b(3) = Minf_b(1)
   Tx_write_pointer = 4
   Gosub Print_tx
   Gosub Command_received
Return
'
03:
   Tx_b(1) = &H03
   Tx_b(2) = Maxf_b(2)
   Tx_b(3) = Maxf_b(1)
   Tx_write_pointer = 4
   Gosub Print_tx
   Gosub Command_received
Return
'
04:
   Tx_b(1) = &H04
   Tx_b(2) = Mean_frequency_b(2)
   Tx_b(3) = Mean_frequency_b(1)
   Tx_write_pointer = 4
   Gosub Print_tx
   Gosub Command_received
Return
'
05:
   If Command_b(1) = 1 Then
      Mean_f = 3000
      Minf = 6000
      Maxf = 0
   End If
   Gosub Command_received
Return
'
06:
   If Interface_mode = 0 Then
      If Commandpointer >= 2 Then
         If Command_b(2) < 4 Then
            If Radio_type <> Command_b(2) Then
               Radio_type = Command_b(2)
               Radio_type_eram = Command_b(2)
               Goto Restart
            End If
         Else
            Parameter_error
         End If
         Gosub Command_received
      End If
   Else
      Not_valid_at_this_time
      Gosub Command_received
   End If
Return
'
07:
   If Interface_mode = 0 Then
      Tx_time = 1
      Tx_b(1) = &H07
      Tx_b(2) = Radiotype
      Tx_write_pointer = 3
      Gosub Print_tx
      Gosub Command_received
   Else
      Not_valid_at_this_time
      Gosub Command_received
   End If
Return
'
08:
   If Interface_mode = 0 Then
      If Commandpointer >= 2 Then
         B_temp1 = Command_b(2) + 1
         If B_temp1 <= Name_len Then
            If Commandpointer >= B_temp1 Then
               B_temp2 = 1
               For B_temp1 = 3 To B_temp1
                  Radio_name_b(B_temp2) = Command_b(B_temp1)
                  Incr B_temp2
               Next B_temp1
               Radio_name_eram = Radio_name
               Gosub Command_received
            End If
         Else
            Parameter_error
            Gosub Command_received
         End If
      End If
   Else
      Not_valid_at_this_time
   End If
Return
'
09:
   If Interface_mode = 0 Then
      Tx_time = 1
      Tx_b(1) = &H09
      Tx_b(2) = len(Radio_name)
      B_temp2 = 3
      For B_temp1 = 1 to Tx_b(2)
          Tx_b(B_temp2) = Radio_name_b(B_temp1)
          Incr B_temp2
      Next B_temp1
      Tx_write_pointer = B_temp2
      Gosub Print_tx
      Gosub Command_received
   Else
      Not_valid_at_this_time
      Gosub Command_received
   End If
Return
'
10:
   If Interface_mode = 0 Then
      If Commandpointer >= 3 Then
         Radio_frequency = Command_b(2) * 256
         Radio_frequency = Radio_frequency + Command_b(3)
         If Radio_frequency < 612903 Then
            Radio_frequency = Radio_frequency + 137000000
            Radio_frequency = Radio_frequency * 62
            Radio_frequency_eeram = Radio_frequency
            Select Case Radio_type
               Case 0
                  Gosub Set_radio_f0
            End Select
         Else
            Parameter_error
         End If
      End If
   Else
      Not_valid_at_this_time
      Gosub Command_received
   End If
Return
'
11:
   If Interface_mode = 0 Then
      Tx_time = 1
      Tx_b(1) = &H0B
      D_temp1 = Radio_frequency - 137000000
      D_temp1 = D_temp1 / 62
      Tx_b(2) = D_temp1_b(1)
      Tx_b(3) = D_temp1_b(2)
      Tx_write_pointer = 4
      Gosub Print_tx
      Gosub Command_received
   Else
      Not_valid_at_this_time
      Gosub Command_received
   End If
Return
'
12:
   If Interface_mode = 0 Then
      If Commandpointer >= 4 Then
         Radio_frequency = Command_b(2) * 256
         Radio_frequency = Radio_frequency + Command_b(3)
         If Radio_frequency < 1854838 Then
            Radio_frequency = Radio_frequency + 410000000
            Radio_frequency = Radio_frequency * 62
            Radio_frequency_eeram = Radio_frequency
            Select Case Radio_type
               Case 0
                  Gosub Set_radio_f0
            End Select
         Else
            Parameter_error
         End If
      End If
   Else
      Not_valid_at_this_time
      Gosub Command_received
   End If
Return
'
13:
   If Interface_mode = 0 Then
      Tx_time = 1
      Tx_b(1) = &H0D
      D_temp1 = Radio_frequency - 410000000
      D_temp1 = D_temp1 / 62
      Tx_b(2) = D_temp1_b(1)
      Tx_b(3) = D_temp1_b(2)
      Tx_b(4) = D_temp1_b(3)
      Tx_write_pointer = 5
      Gosub Print_tx
      Gosub Command_received
   Else
      Not_valid_at_this_time
      Gosub Command_received
   End If
Return
'
14:
   If Interface_mode = 0 Then
       If Commandpointer >= 4 Then
          Radio_frequency = Command_b(2) * 256
          Radio_frequency = Radio_frequency + Command_b(3)
          If Radio_frequency < 1019999 Then
             Radio_frequency = Radio_frequency + 820000000
             Radio_frequency = Radio_frequency * 62
             Radio_frequency_eeram = Radio_frequency
             Select Case Radio_type
                Case 0
                   Gosub Set_radio_f0
             End Select
          Else
             Parameter_error
          End If
       End If
   Else
      Not_valid_at_this_time
      Gosub Command_received
   End If
Return
'
15:
   If Interface_mode = 0 Then
      Tx_time = 1
      Tx_b(1) = &H0F
      D_temp1 = Radio_frequency - 820000000
      D_temp1 = D_temp1 / 62
      Tx_b(2) = D_temp1_b(1)
      Tx_b(3) = D_temp1_b(2)
      Tx_b(4) = D_temp1_b(3)
      Tx_write_pointer = 5
      Gosub Print_tx
      Gosub Command_received
   Else
      Not_valid_at_this_time
      Gosub Command_received
   End If
Return
'
16:
   Tx_time = 1
   Tx_b(1) = &H10
   Tx_b(2) = Interface_mode
   Tx_write_pointer = 3
   Gosub Print_tx
   Gosub Command_received
Return
'