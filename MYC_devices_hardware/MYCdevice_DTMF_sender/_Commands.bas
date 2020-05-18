' additional commands
' 20200516
'
01:
   If Commandpointer >= 2 Then
      If Command_b(2) = 0 Then
         Gosub Command_received
      Else
         B_temp1 = Command_b(2) + 2
         'Length
         If Commandpointer >= B_temp1 Then
            'string finished
            Stop Watchdog
            For B_temp2 = 3 To B_temp1
               Dtmf_char = Command_b(B_temp2)
               Gosub Send_dtmf
            Next B_temp2
            Start Watchdog
            Gosub Command_received
         End If
      End If
   End If
Return
'
02:
   If Commandpointer >= 2 Then
      Dtmf_duration = Command_b(2)
      Dtmf_duration_eeram = Dtmf_duration
      Gosub Command_received
   End If
Return
'
03:
   Tx_time = 1
   Tx_b(1) = &H03
   Tx_b(2) = Dtmf_duration
   Tx_write_pointer = 3
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'                                          l
04:
   If Commandpointer >= 2 Then
      Dtmf_pause = Command_b(2)
      Dtmf_pause_eeram = Dtmf_pause
      Gosub Command_received
   End If
Return
'
05:
   Tx_time = 1
   Tx_b(1) = &H05
   Tx_b(2) = Dtmf_pause
   Tx_write_pointer = 3
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
06:
   If Commandpointer >= 2 Then
      If Command_b(2) < 2 Then
         no_myc = Command_b(2)
         no_myc_eeram = no_myc
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
07:
   Tx_time = 1
   Tx_b(1) = &H07
   Tx_b(2) = no_myc
   Tx_write_pointer = 3
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'