' Command255
'1.7.0, 190512
'
   Case 255
      If Commandpointer >= 2 Then
         Tx_busy = 2
         Tx_time = 1
         Tx_b(1) = &HFF
         Tx_b(2) = Command_b(2)
         Select Case Command_b(2)
            Tx_write_pointer = 0
            Case 0
               'Will send &HFF0000 for empty string
               b_Temp3 = Len(Dev_name)
               Tx_b(3) = b_Temp3
               Tx_write_pointer = 4
               b_Temp2 = 1
               While b_Temp2 <= b_Temp3
                  Tx_b(Tx_write_pointer) = Dev_name_b(b_Temp2)
                  Incr Tx_write_pointer
                  Incr b_Temp2
               Wend
            Case 1
               Tx_b(3) = Dev_number
               Tx_write_pointer = 4
            Case 2
               Tx_b(3) = I2c_active
               Tx_write_pointer = 4
            Case 3
               b_Temp2 = Adress / 2
               Tx_b(3) = b_Temp2
               Tx_write_pointer = 4
            Case 4
               Tx_b(3) = Serial_active
               Tx_write_pointer = 4
            Case 5
               Tx_b(3) = 0
               Tx_write_pointer = 4
            Case 6
               Tx_b(3) = 3
               Tx_b(4) = "8"
               Tx_b(5) = "N"
               Tx_b(6) = "1"
               Tx_write_pointer = 7
'
            $include "__command255.bas"
'
            Case Else
               Parameter_error
               Gosub Reset_tx
         End Select
         If Tx_write_pointer > 0 Then
            If Command_mode = 1 Then Gosub Print_tx
         End If
         Gosub Command_received
      Else_Incr_Commandpointer