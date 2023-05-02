' Commands
' 191227
'
01:
  If Commandpointer >= 2 Then
     If Command_b(2) = 0 Or Command_b(2) > 250 Then
        Gosub Command_received
     Else
        L = Command_b(2) + 2
        If Commandpointer >= L Then
           'string finished
           b_Temp1 = Command_b(2) + 2
           For b_Temp2 = 3 To b_Temp1
              b_Temp3 = Command_b(b_Temp2)
              Gosub Send_morse_code
              If b_Temp2 < b_Temp1 Then Waitms Dash_time_ms
           Next b_Temp2
           Gosub Command_received
        End If
     End If
  End If
Return
'
02:
   If Commandpointer >= 2 Then
      If Command_b(2) < 20 Then
         Speed = Command_b(2)
         Speed_eeram = Speed
         Gosub Set_speed_frequency
      Else_Parameter_error
      Gosub Command_received
   End If
Return
'
03:
   Tx_b(1) = &H03
   Tx_b(2) = Speed
   Tx_write_pointer = 3
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
04:
   If Commandpointer >= 2 Then
      If Command_b(2) < 20 Then
         Frequ = Command_b(2)
         Frequ_eeram = Frequ
         Gosub Set_speed_frequency
      Else_Parameter_error
      Gosub Command_received
   End If
Return
'
05:
   Tx_b(1) = &H05
   Tx_b(2) = Frequ
   Tx_write_pointer = 3
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
   '
06:
   If Commandpointer >= 2 Then
      If Command_b(2) < 9 Then
         Morse_buffer_pointer = 1
         Morse_mode = Command_b(2)
         Morse_mode_eeram = Morse_mode
         Group = 1
         Select Case Morse_mode
            Case 2 :
               Char_num = 10
               'figures
               Adder = 0
            Case 3 :
               Char_num = 6
               'a-f
               Adder = 10
            Case 4:
               Char_num = 6
               'g-l
              Adder = 15
            Case 5 :
               Char_num = 7
               'm-s
               Adder = 21
            Case 6 :
               Char_num = 7
               't-z
              Adder = 28
            Case 7 :
               Char_num = 14
               'special
               Adder = 35
            Case 8 :
               Char_num = 50
               'all
               Adder = 0
            Case Else
         End Select
      Else_Parameter_error
      Gosub Command_received
   End If
Return
'
07:
   Tx_b(1) = &H07
   Tx_b(2) = Morse_mode
   Tx_write_pointer = 3
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'