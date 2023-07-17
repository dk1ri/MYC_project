' additional commands
' 20230715
'
1:
   Tx_time = 1
   Tx_b(1) = &H01
   'read ringbuffer Dtmf_buffer from Dtmf_in_readpointer to Dtmf_in_writepointer - 1
   Tx_write_pointer = 3
   While Dtmf_in_readpointer <> Dtmf_in_writepointer
      Tx_b(Tx_write_pointer) = Dtmf_buffer_b(Dtmf_in_readpointer)
      Incr Dtmf_in_readpointer
      If Dtmf_in_readpointer >= Dtmf_length Then Dtmf_in_readpointer = 1
      Incr Tx_write_pointer
   Wend
   Tx_b(2) = Tx_write_pointer - 3
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
2:
   If Commandpointer > 1 Then
      B_temp1 = Command_b(2)
      If B_temp1 = 0 Or B_temp1 > Dtmf_length Then
         Parameter_error
         Gosub command_received
      Else
         B_temp1 = Command_b(2) + 2
         If Commandpointer >= B_temp1 Then
            'string finished
            If Dtmf_send_started = 0 Then
               'adds to ringbuffer Dtmf_buffer_out,
               'overwrite old data, if buffer is full
               Dtmf_buffer_out_writepointer = 1
               For B_temp2 = 3 To B_temp1
                  Dtmf_buffer_out_b(Dtmf_buffer_out_writepointer) = Command_b(B_temp2)
                  Incr Dtmf_buffer_out_writepointer
               Next B_temp2
               Dtmf_time = 1
               Dtmf_send_started = 1
               Dtmf_buffer_out_readpointer = 1
               Gosub Command_received
            Else
               Parameter_error
            End If
         End If
      End If
   End If
Return
'
3:
   If Commandpointer = 2 Then
      If Command_b(2) < 2 Then
         no_myc = Command_b(2)
         no_myc_eeram = no_myc
         Dtmf_buffer_out_writepointer = 1
         Dtmf_buffer_out_readpointer = 1
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
4:
   Tx_time = 1
   Tx_b(1) = &H04
   Tx_b(2) = no_myc
   Tx_write_pointer = 3
   If Command_mode = 1 Then Gosub Print_Tx
   Gosub Command_received
Return
'