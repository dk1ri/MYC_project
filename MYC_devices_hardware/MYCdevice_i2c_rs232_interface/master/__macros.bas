' additional macros
' 190709
'
Macro I2c_s:
   I2csend Adress_, Command_b(I2c_start), I2c_len
   If Err <> 0 Then
      I2c_error
   End If
End Macro
'
Macro I2c_rec:
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
End Macro
'
Macro I2c_r:
' first byte is command
I2creceive Adress_, I2c_len
' second is length
I2creceive Adress_, I2c_len
If Err = 1 Then
   I2c_error
   I2c_len = 0
End If
End Macro