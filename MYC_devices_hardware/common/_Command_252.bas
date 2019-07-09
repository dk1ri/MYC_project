' Command252 start
'1.7.0, 190512
'
   Case 252
      Tx_busy = 2
      Tx_time = 1
      Select Case Error_no
         Case 0
            Tx = ": command not found: "
         Case 1
            Tx = ": I2C error: "
         Case 2
            Tx = ": watchdog reset: "
         Case 3
            Tx = ": command watchdog: "
         Case 4
            Tx = ": parameter error: "
         Case 5
            Tx = ": tx time too long: "
         Case 6
            Tx = ": not valid at that time: "
         Case 7
            Tx = ": i2c_buffer overflow: "
         Case 8
            Tx = "I2c not ready to receive: "
'
	$include "__command252.bas"

         Case 255
            Tx = ": no error: "
         Case Else
            Tx = ": other error: "
      End Select
      b_Temp3 = Len (Tx)
      For b_Temp2 = b_Temp3 To 1 Step - 1
         Tx_b(b_Temp2 + 5) = Tx_b(b_Temp2)
      Next b_Temp2
      Tx_b(1) = &HFC
      Tx_b(2) = &H20
      Tx_b(3) = &H20
      Tx_b(4) = &H20
      Tx_b(5) = &H20
      Temps = Str(Command_no)
      b_Temp4 = Len (Temps)
      For b_Temp2 = 1 To b_Temp4
         Tx_b(b_Temp2 + 2) = Temps_b(b_Temp2)
      Next b_Temp2
      Tx_write_pointer = b_Temp3 + 6
      Temps = Str(Error_cmd_no)
      b_Temp4 = Len (Temps)
      For b_Temp2 = 1 To b_Temp4
         Tx_b(Tx_write_pointer) = Temps_b(b_Temp2)
         Incr Tx_write_pointer
      Next b_Temp2
      b_Temp3 = b_Temp3 + 3
      Tx_b(2) = b_Temp3 + b_Temp4
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received