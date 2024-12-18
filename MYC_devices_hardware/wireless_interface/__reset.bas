' additional reset
' 20241208
'
Myc_mode = 1
wireless_active_eram = 1
Enable_switch_over_eram = 0
Radio_name_eram = "radi"
'
#If Radiotype = 2
' only if reset: set default and write to radio interface
Gosub Read_id
If Radio_name <> "radi"  Then
   Radio_name = "radi"
   Radio_name_eram = RAdio_name
   Gosub Write_id
End If
#EndIf
#If Radiotype > 0
   Enable_switch_over_eram = 0
#ENDIF