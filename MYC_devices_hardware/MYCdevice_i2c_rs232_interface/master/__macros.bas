' additional macros
' 190709
'
Macro I2c_s:
For B_Temp2 = 1 To I2c_len
B_Temp1 = Command_b(I2c_start)
   I2csend Adress, B_temp1
   Incr I2c_start
   If Err <> 0 Then
      I2c_error
      I2c_len = 0
   End If
Next B_temp2
End Macro
'
Macro I2c_rec:
For B_Temp2 = 1 To I2c_len
   I2creceive Adress, B_temp1
   If Err = 0 Then
      Printbin B_temp1
   Else
      Printbin &H80
      I2c_error
      I2c_len = 0
   End If
   Incr I2c_start
Next B_temp2
End Macro
'
Macro I2c_r:
' first byte is command
I2creceive Adress, I2c_len
' second is length
I2creceive Adress, I2c_len
If Err = 1 Then
   I2c_error
   I2c_len = 0
End If
End Macro