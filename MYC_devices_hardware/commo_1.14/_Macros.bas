' Macros
' 191228
'
Macro Command_not_found:
   Error_no = 0
   Error_cmd_no = Command_no
End Macro
'
Macro I2c_error:
   Error_no = 1
   Error_cmd_no = Command_no
End Macro
'
Macro Watchdog_reset:
   Error_no = 2
   Error_cmd_no = Command_no
End Macro
'
Macro Command_watchdog:
   Error_no = 3
   Error_cmd_no = Command_no
End Macro
'
Macro Parameter_error:
   Error_no = 4
   Error_cmd_no = Command_no
End Macro
'
Macro Else_Parameter_error:
   Else
      Error_no = 4
      Error_cmd_no = Command_no
   End If
End Macro
'
Macro Tx_time_too_long:
   Error_no = 5
   Error_cmd_no = Command_no
End Macro
'
Macro Not_valid_at_this_time:
   Error_no = 6
   Error_cmd_no = Command_no
End Macro
'
Macro I2c_buffer_overflow:
   Error_no = 7
   Error_cmd_no = Command_no
End Macro
'
Macro I2c_not_ready_to_receive:
   Error_no = 8
   Error_cmd_no = Command_no
End Macro
'
Macro Answer1:
Tx_time = 1
Tx_b(1) = Command_b(1)
Tx_write_pointer = 3
Gosub Print_tx
Gosub Command_received
End Macro
'
$include "__macros.bas"