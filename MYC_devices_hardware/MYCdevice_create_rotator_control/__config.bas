' additional configs
' 190711
'
Config Pinc.2 = Input
Portc.2 = 1
Not_limit Alias Pinc.2
' Limit  0 activ
Config Portb.0 = Output
Controlon Alias Portb.0
Config Portb.1 = Output
Motor_cw Alias Portb.1
Config Portb.2 = Output
Motor_ccw Alias Portb.2
'
Config Adc = Single , Prescaler = Auto , Reference = Internal