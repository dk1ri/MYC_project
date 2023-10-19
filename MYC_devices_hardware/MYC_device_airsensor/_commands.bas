' Commands
' 20231018
'
00:
Return
'
01:
   Tx_time = 1
   Tx_b(1) = &H01
   Tx_b(2) = High(CO_w)
   Tx_b(3) = Low(CO_w)
   Tx_write_pointer = 4
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
02:
   Tx_time = 1
   Tx_b(1) = &H02
   Tx_b(2) = High(TVOC)
   Tx_b(3) = Low(TVOC)
   Tx_write_pointer = 4
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
03:
   Tx_time = 1
   Tx_b(1) = &H03
   Tx_b(2) = Ccs_status
   Tx_write_pointer = 3
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
04:
   'mode
   B_temp1 = &H01
   B_temp3 = 1
   Gosub S
   Gosub R
   Tx_time = 1
   Tx_b(1) = &H04
   Tx_b(2) = Dat(1)
   Tx_write_pointer = 3
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
05:
   'baseline
   B_temp1 = &H11
   B_temp3 = 2
   Gosub S
   Gosub R
   Tx_time = 1
   Tx_b(1) = &H05
   Tx_b(2) = Dat(1)
   Tx_b(3) = Dat(2)
   Tx_write_pointer = 4
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
06:
   'hw_Id
   B_temp1 = &H20
   B_temp3 = 1
   Gosub S
   Gosub R
   Tx_time = 1
   Tx_b(1) = &H06
   Tx_b(2) = Dat(1)
   Tx_write_pointer = 3
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
07:
   'hw_version
   B_temp1 = &H21
   B_temp3 = 1
   Gosub S
   Gosub R
   Tx_time = 1
   Tx_b(1) = &H07
   Tx_b(2) = Dat(1)
   Tx_write_pointer = 3
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
08:
   'bootloader version
   B_temp1 = &H23
   B_temp3 = 2
   Gosub S
   Gosub R
   Tx_time = 1
   Tx_b(1) = &H08
   Tx_b(2) = Dat(1)
   Tx_b(3) = Dat(2)
   Tx_write_pointer = 4
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
09:
   'App_version
   B_temp1 = &H24
   B_temp3 = 2
   Gosub S
   Gosub R
   Tx_time = 1
   Tx_b(1) = &H09
   Tx_b(2) = Dat(1)
   Tx_b(3) = Dat(2)
   Tx_write_pointer = 4
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
10:
   'internal state
   B_temp1 = &HA0
   B_temp3 = 1
   Gosub S
   Gosub R
   Tx_time = 1
   Tx_b(1) = &H0A
   Tx_b(2) = Dat(1)
   Tx_write_pointer = 3
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
11:
   If Ccs_error_flag = 1 Then
      B_temp1 = &HE0
      B_temp3 = 1
      Gosub S
      Gosub R
      Ccs_error = Dat(1)
      Ccs_error_flag = 0
   End If
   Tx_time = 1
   Tx_b(1) = &H0B
   Tx_b(2) = Ccs_error
   Tx_write_pointer = 3
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
12:
   Tx_time = 1
   Tx_b(1) = &H0C
   Tx_b(2) = High(Ccs_rawdata)
   Tx_b(3) = Low(Ccs_rawdata)
   Tx_write_pointer = 4
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
13:
   If Command_pointer >= 2 Then
      If Command_b(2) < 4 Then
         B_temp1 = &H01
         B_temp3 = 1
         Gosub S
         Gosub R
         B_temp1 =  B_temp1  AND &B10001100
         Dat(1) = &H01
         Select Case Command_b(2)
            Case 0
               Dat(2) = B_temp1  OR &B00000000
            Case 1
               Dat(2) = B_temp1  OR &B00010000
            Case 2
               Dat(2) = B_temp1  OR &B00100000
            Case 3
               Dat(2) = B_temp1  OR &B00110000
         End Select
         waitms 100
         I2csend I2c_adr, Dat(1), 2
      Else
         Parameter_error
      End If
      Gosub Command_received
      Start Watchdog
   End If
Return