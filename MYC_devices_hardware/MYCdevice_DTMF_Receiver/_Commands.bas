' additional commands
' 20230715
'
1:
      Tx_time = 1
      Tx_b(1) = &H01
      B_temp1 = 3
      While Dtmf_write_pointer <> Dtmf_read_pointer
         Tx_b(B_temp1) = Dtmf_buffer_b(Dtmf_read_pointer)
         Incr Dtmf_read_pointer
         If Dtmf_read_pointer >= Dtmf_length Then Dtmf_read_pointer = 1
         Incr B_temp1
      Wend
      Tx_Write_pointer = B_temp1
      B_temp1 = B_temp1 - 3
      Tx_b(2) = B_temp1
      'Length
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
Return
'
02:
      If Commandpointer >= 2 Then
         If Command_b(2) < 2 Then
            no_myc = Command_b(2)
            no_myc_eeram = no_myc
         Else_parameter_error
         Gosub Command_received
      End If
Return
'
03:
      Tx_b(1) = &H03
      Tx_b(2) = no_myc
      Tx_write_pointer = 3
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
Return
'