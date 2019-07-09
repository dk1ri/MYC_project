' serial without no_myc
'1.7.0, 190616
'
'RS232 got data?
Serial_in = Ischarwaiting()
If Serial_in = 1 Then
   Serial_in = Inkey()
   If Serial_active = 1 Or Command_b(1) = 254 Then
      If Tx_busy = 0 Then
         Command_b(Commandpointer) = Serial_in
         Command_mode = 1
         Gosub Commandparser
      Else
         'do nothing
         Not_valid_at_this_time
      End If
   Else
      'do nothing
      Not_valid_at_this_time
   End If
End If