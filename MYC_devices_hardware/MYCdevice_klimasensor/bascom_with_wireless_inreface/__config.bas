' additional configs
' 20250804
'
'Config SDA = PortC.1
'Config SCL = PORTC.0
'I2cinit
Config TWI = 100000
TWCR = &B00000100       'Enable TWI
enable Interrupts
enable TWI