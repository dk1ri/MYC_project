' additional init
' 190825
'
Config_at_start = 2
Gosub Control_sound_off
'set Power (idle deactivated) mode (1+9)
Time_ = T_10s
Voicea = 1
Voiceb = 9
10s_loops = 5
Gosub Control_sound