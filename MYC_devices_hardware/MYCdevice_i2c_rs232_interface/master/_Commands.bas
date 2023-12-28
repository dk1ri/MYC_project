' Commands
' 20231007
'
01:
If Commandpointer >= 2 Then
   If Command_b(2) > 0 Then
      If Command_b(2) > Stringlength Then
         Parameter_error
         Gosub Command_received
      Else
         I2c_len = Command_b(2) + 2
         If Commandpointer >= I2c_len Then
            'string finished
            I2c_len = I2c_len - 2
            ' send string
            I2csend Adress_, Command_b(3), I2c_len
            If Err <> 0 Then
               I2c_error
            End If
            Gosub Command_received
         End If
      End If
   End If
End If
Return
'
02:
' get length
I2creceive Adress_, Rx(1), 0, 2
If Err = 0 Then
    I2c_len = Rx(2)
    I2creceive Adress_, Rx(1), 0, I2c_len
    If Err = 0 Then
       Printbin &H02
       Printbin I2c_len
       For B_temp1 = 1 To I2c_len
         B_temp2 = Rx(B_temp1)
         Printbin B_temp2
       Next B_temp1
    Else
       I2c_error
    End If
Else
   I2c_error
End If
Gosub Command_received
Return
'
03:
If Commandpointer >= 2 Then
   If Command_b(2) < Stringlength Then
      B_temp3 = Command_b(2)
      I2creceive Adress_, Rx(1), 0, B_temp3
      If Err = 0 Then
         For B_temp1 = 1 To B_temp3
            B_temp2 = Rx(B_temp1)
            Printbin B_temp2
         Next B_temp1
      Else
         I2c_error
      End If
   End If
   Gosub Command_received
End If
Return
'
04:                   '
If Commandpointer >= 2 Then
   If Command_b(2) < 128 And Command_b(2) > 0 Then
      'i2csen i2c_receive use the 8bit adress even figures!
      Adress_ = Command_b(2) * 2
      Adress__eeram = Adress_
   Else
      Parameter_error
   End If
   Gosub Command_received
End If
Return
'
05:
   Tx_time = 1
   Tx_b(1) = &H05
   B_temp1 = Adress_ / 2
   Tx_b(2) =  B_temp1
   Tx_write_pointer = 3
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return                           '
'                    '