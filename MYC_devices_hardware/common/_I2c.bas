' I2c, End of Loop
' 191016
'
'twint set?
If TWCR.7 = 1 Then
   ' TWSR.0:2 are 0, no blanking with &HF8 necessary
   ' only the following TWSR values will occur (all action use ack, no multiple master / arbitration/ general call):
   ' receive:60/96 -> start read, 80/128 88/136 -> data read, A0/160 -> stop read
   ' transmit: A8/168 -> start, load data, A8/168 B8/184 -> data written, C0/192 -> data with NOTACK (stop)
   ' only two of them require actions (&H80 und &HB8); all (!) others set TWCR only
   B_temp1 = TWSR And &HF7
   ' blank Bit4 -> &H80 &H88
   If B_temp1= &H80 Then
      'I2C receives data
      If I2c_active = 1 Or Command_b(1) = 254 Then
         If Tx_busy = 0 Then
            B_Temp1 = Twdr
            Command_b(Commandpointer) = TWDR
            Command_mode = 2
            Gosub Commandparser
         Else
            'do nothing
            I2c_not_ready_to_receive
         End If
      Else
         I2c_not_ready_to_receive
      End If
   Else
      Twdr = Not_valid_cmd
      B_temp1 = TWSR And &HEF
      ' blank Bit5-> A8 B8
      If B_temp1= &HA8 Then
         'slave send:
         'a slave send command must always be completed (or until timeout)
         'incoming commands are ignored as long as tx is not empty
         'for multi line F0 command tx may be loaded a few times if necessary.
         'multiple announcelines are loaded by line
         If Tx_write_pointer > 1 And I2c_active = 1 Then
            TWDR = Tx_b(Tx_pointer)
            Incr Tx_pointer
            If Tx_pointer > Tx_write_pointer Then
               Gosub Reset_tx
               If Number_of_lines > 0 Then Gosub Sub_restore
            End If
         End If
      End If
   End If
   Watch_twi = 0
   ' TWI enabled again
   Twcr = &B11000100
End If
'
Stop Watchdog                                               '
Goto Loop_