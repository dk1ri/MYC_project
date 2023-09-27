' additional configs
' 20230926
'
' default input (off -> high) modul has pullup
' set to output  if low
Ta1 Alias PortA.7     'INH Taster Eingang 1
Ta2 Alias portA.6     'ING Taster Eingang 2
Ta3 Alias PortA.4     'INF Taster Eingang 3
Ta4 Alias PortA.4     'INE Taster Eingang 4
Ta5 Alias PortA.3     'IND Taster Eingang 5
Ta6 Alias PortA.2     'INC Taster Eingang 6
Ta7 Alias PortA.1     'INB Taster Eingang 7
Ta8 Alias PortA.0     'INA Taster Eingang 8
'
Out1 Alias Pinc.7
Config Out1 = Input '1 Modul Output_1
Set portc.7
Out2 Alias Pinc.6
Config Out2 = Input '2 Modul Output_2
Set portc.6
Out3 Alias PinC.5
Config Out3 = Input '3 Modul Output_3
Set portC.5
Out4 Alias Pinc.4
Config Out4 = Input '4 Modul Output_4
Set Portc.4
Out5 Alias PinC.3
Config Out5 = Input '5 Modul Output_5
Set portc.3
Out6 Alias Pinc.2
Config Out6 = Input '6 Modul Output_6
Set portc.2
Out7 Alias PinD.7
Config Out7 = Input '7 Modul Output_7
Set portd.7
Out8 Alias Pind.6
Config Out8 = Input '8 Modul Output 8
Set portd.6
'
Config Timer1 = Timer, Prescale = 1024
Stop Timer1