' additional configs
' 190711
'
' Limit  0 activ  
Not_limit Alias Pinc.2
Config Not_limit = Input
Portc.2 = 1
Controlon Alias PortD.2
Config Controlon = Output
Motor_cw Alias PortD.3
Config Motor_cw = Output
Motor_ccw Alias PortD.4
Config Motor_ccw = Output
'
Config Adc = Single , Prescaler = Auto , Reference = Internal