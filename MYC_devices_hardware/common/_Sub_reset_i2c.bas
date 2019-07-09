'Sub_reset_i2c
'1.7.0, 190708
'
Reset_i2c:
Watch_twi = 0
Twsr = 0
'status und Prescaler auf 0
Twdr = Not_valid_cmd
Twar = Adress
'Slaveadress
Twcr = &B11000100
Return