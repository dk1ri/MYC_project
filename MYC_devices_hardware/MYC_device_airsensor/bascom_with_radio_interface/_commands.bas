' Commands
' 20250624
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
   Tx_time = 1
   Tx_b(1) = &H01
   Tx_b(2) = High(CO_w)
   Tx_b(3) = Low(CO_w)
   Tx_write_pointer = 4
   Gosub Print_tx
   Gosub Command_received
Return
'
02:
   Tx_time = 1
   Tx_b(1) = &H02
   Tx_b(2) = High(TVOC)
   Tx_b(3) = Low(TVOC)
   Tx_write_pointer = 4
   Gosub Print_tx
   Gosub Command_received
Return
'
03:
   Tx_time = 1
   Tx_b(1) = &H03
   Gosub Read_status
   Tx_b(2) = Ccs_status
   Tx_write_pointer = 3
   Gosub Print_tx
   Gosub Command_received
Return
'
04:
   'baseline
   B_temp1 = &H11
   B_temp3 = 2
   Gosub S
   Gosub R
   Tx_time = 1
   Tx_b(1) = &H04
   Tx_b(2) = Dat(1)
   Tx_b(3) = Dat(2)
   Tx_write_pointer = 4
   Gosub Print_tx
   Gosub Command_received
Return
'
05:
   'hw_Id
   B_temp1 = &H20
   B_temp3 = 1
   Gosub S
   Gosub R
   Tx_time = 1
   Tx_b(1) = &H05
   Tx_b(2) = Dat(1)
   Tx_write_pointer = 3
   Gosub Print_tx
   Gosub Command_received
Return
'
06:
   'hw_version
   B_temp1 = &H21
   B_temp3 = 1
   Gosub S
   Gosub R
   Tx_time = 1
   Tx_b(1) = &H06
   Tx_b(2) = Dat(1)
   Tx_write_pointer = 3
   Gosub Print_tx
   Gosub Command_received
Return
'
07:
   'bootloader version
   B_temp1 = &H23
   B_temp3 = 2
   Gosub S
   Gosub R
   Tx_time = 1
   Tx_b(1) = &H07
   Tx_b(2) = Dat(1)
   Tx_b(3) = Dat(2)
   Tx_write_pointer = 4
   Gosub Print_tx
   Gosub Command_received
Return
'
08:
   'App_version
   B_temp1 = &H24
   B_temp3 = 2
   Gosub S
   Gosub R
   Tx_time = 1
   Tx_b(1) = &H08
   Tx_b(2) = Dat(1)
   Tx_b(3) = Dat(2)
   Tx_write_pointer = 4
   Gosub Print_tx
   Gosub Command_received
Return
'
09:
   'internal state
   B_temp1 = &HA0
   B_temp3 = 1
   Gosub S
   Gosub R
   Tx_time = 1
   Tx_b(1) = &H09
   Tx_b(2) = Dat(1)
   Tx_write_pointer = 3
   Gosub Print_tx
   Gosub Command_received
Return
'
10:
   B_temp1 = &HE0
   B_temp3 = 1
   Gosub S
   Gosub R
   Ccs_error = Dat(1)
   Tx_time = 1
   Tx_b(1) = &H0A
   Tx_b(2) = Ccs_error
   Tx_write_pointer = 3
   Gosub Print_tx
   Gosub Command_received
Return
'
11:
   Tx_time = 1
   Tx_b(1) = &H0B
   Tx_b(2) = High(Ccs_rawdata)
   Tx_b(3) = Low(Ccs_rawdata)
   Tx_write_pointer = 4
   Gosub Print_tx
   Gosub Command_received
Return
'
12:
   If Command_pointer >= 2 Then
      If Command_b(2) < 4 Then
         CCs_mode = Command_b(2)
         CCs_mode_eeram = CCs_mode
         ' Only Mode is used for register 01
         Dat(1) = &H01
         Select Case CCs_mode
            Case 0
               Dat(2) = &B00000000
            Case 1
               Dat(2) = &B00010000
            Case 2
               Dat(2) = &B00100000
            Case 3
               Dat(2) = &B00110000
         End Select
         I2csend I2c_adr, Dat(1), 2
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
13:
   Tx_time = 1
   Tx_b(1) = &H0D
   Tx_b(2) = Ccs_mode
   Tx_write_pointer = 3
   Gosub Print_tx
   Gosub Command_received
Return
'
14:
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
15:
   If Interface_mode = 0 Then
      Tx_time = 1
      Tx_b(1) = &H0F
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
16:
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
17:
   If Interface_mode = 0 Then
      Tx_time = 1
      Tx_b(1) = &H11
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
18:
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
19:
   If Interface_mode = 0 Then
      Tx_time = 1
      Tx_b(1) = &H13
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
20:
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
21:
   If Interface_mode = 0 Then
      Tx_time = 1
      Tx_b(1) = &H15
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
22:
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
23:
   If Interface_mode = 0 Then
      Tx_time = 1
      Tx_b(1) = &H17
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