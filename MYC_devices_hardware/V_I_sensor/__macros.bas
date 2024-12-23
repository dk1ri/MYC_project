' additional macros
'
' additional macros
' 20200318
'
Macro Wrong_data_length :
   Error_no = 9
   Error_cmd_no = Command_no
End Macro
'
Macro Unknown_command  :
   Error_no = 10
   Error_cmd_no = Command_no
End Macro
'
Macro Illegal_command_parameter  :
   Error_no = 11
   Error_cmd_no = Command_no
End Macro
'
Macro Internal_function_argument_out_of_range  :
   Error_no = 12
   Error_cmd_no = Command_no
End Macro
'
Macro Command_not_allowed_in_current_state  :
   Error_no = 13
   Error_cmd_no = Command_no
End Macro
'
Macro No_data_available
   Error_no = 14
   Error_cmd_no = Command_no
End Macro
'