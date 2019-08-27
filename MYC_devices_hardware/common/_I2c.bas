' I2c, End of Loop
' 190706
'
'twint set?
If TWCR.7 = 1 Then
B_temp1 = TWSR
print B_temp1
   ' TWSR.0:2 are 0, no blanking with &HF8 necessary
   ' only the following TWSR values will occur (all action use ack, no multiple master / arbitration):
   ' 60 -> start read, 80-> data read, A0 -> stop read
   ' A8 -> start, load data, B8 -> data written, C8 -> stop
   ' only two of them require actions (&H80 und &HA8)
   If TWSR = &H80 Then
      'I2C receives data
      If I2c_active = 1 Or Command_b(1) = 254 Then
         If Tx_busy = 0 Then
            B_Temp1 = Twdr
            Command_b(Commandpointer) = B_temp1
            Command_mode = 2
            Gosub Commandparser
         Else
            'do nothing
            I2c_not_ready_to_receive
         End If
      Else
         I2c_not_ready_to_receive
      End If
   Elseif TWSR = &HB8 Then
      'slave send:
      'a slave send command must always be completed (or until timeout)
      'incoming commands are ignored as long as tx is not empty
      'for multi line F0 command tx may be loaded a few times if necessary.
      'multiple announcelines are loaded by line
      If Tx_write_pointer = 1 Or I2c_active = 0 Then
         'nothing to send
         Twdr = Not_valid_cmd
      Else
         If Tx_pointer < Tx_write_pointer Then
            'continue sending
            TWDR = Tx_b(Tx_pointer)
            Incr Tx_pointer
            If Tx_pointer >= Tx_write_pointer Then
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