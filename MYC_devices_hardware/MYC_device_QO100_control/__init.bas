' additional init
' 20231204
Gosub Upconverter_on
'
NB_WB_pin_ = NB_WB_pin
'initial NB_WB state : NB
NB_WB_pin_old_ = NB_WB_pin_
Ptt_pin_ = Ptt_pin
' initial ptt_state
Ptt_pin_old_ = Ptt_pin_
' external PTT must be switched to GND to be activ
Up_temp = 0
Up_f = 0
Up_r = 0
Up_locked = 0
Set Led