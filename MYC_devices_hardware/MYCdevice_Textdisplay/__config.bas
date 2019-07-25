' additional configs
' 190725
'
Config Lcdpin = Pin, Db4 = PortD.4, Db5 = PortD.5, Db6 = PortD.6, Db7 = PortD.7, E = PortB.0, Rs = PortC.3
Config Timer1 = Pwm , Pwm = 8 , Compare_A_Pwm = Clear_Up , Compare_B_Pwm = DISCONNECT , Prescale = 1
'LCD r/w pin!
Config PortC.0 = Output
Reset PortC.0