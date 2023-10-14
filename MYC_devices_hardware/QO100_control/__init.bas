' additional init
' 20231012
' require 2 s to accept commands
Gosub Upconverter_on
'
NB_WB_pin_ = NB_WB_pin
'initial NB_WB state : NB
NB_WB_pin_old_ = NB_WB_pin_
Ptt_pin_ = Ptt_pin
' initial ptt_state
Ptt_pin_old_ = Ptt_pin_
' external PTT must be switched to GND to be activ
Blocked = 0
Block_request = 0
Up_temp = 0
Up_f = 0
Up_r = 0
Up_locked = 0
' 0: start 1: after 3 sec to start upconverter 2: ready 3: wait sfter change to NB
Started = 0
Timer_store = 0
Tcnt1 = Timer1_stop
Start Timer1
Set Led