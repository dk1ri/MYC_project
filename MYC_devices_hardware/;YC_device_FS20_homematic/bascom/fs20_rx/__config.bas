' additional configs
' 20200504
'
Config PortA.7 = Output
Ta1 Alias PortA.7     'INH Taster Eingang 1
Config PortA.6 = Output
Ta2 Alias portA.6     'ING Taster Eingang 2
Config PortA.5 = Output
Ta3 Alias PortA.4     'INF Taster Eingang 3
Config PortA.4 = Output
Ta4 Alias PortA.4     'INE Taster Eingang 4
Config PortA.3 = Output
Ta5 Alias PortA.3     'IND Taster Eingang 5
Config PortA.2 = Output
Ta6 Alias PortA.2     'INC Taster Eingang 6
Config PortA.1 = Output
Ta7 Alias PortA.1     'INB Taster Eingang 7
Config PortA.0 = Output
Ta8 Alias PortA.0     'INA Taster Eingang 8
Porta = &HFF
'
Sch1 Alias Pinc.7
Config Sch1 = Input '1 Modul Output_1
Sch1 = 1
Sch2 Alias Pinc.6
Config Sch2 = Input '2 Modul Output_2
Sch2 = 1
Sch3 Alias PinC.5
Config Sch3 = Input '3 Modul Output_3
Sch3 = 1
Sch4 Alias Pinc.4
Config Sch4 = Input '4 Modul Output_4
Sch4 = 1
Sch5 Alias PinC.3
Config Sch5 = Input '5 Modul Output_5
Sch5 = 1
Sch6 Alias Pinc.2
Config Sch6 = Input '6 Modul Output_6
Sch6 = 1
Sch7 Alias PinD.7
Config Sch7 = Input '7 Modul Output_7
Sch7 = 1
Sch8 Alias Pind.6
Config Sch8 = Input '8 Modul Output 8
Sch8 = 1
'
Config Timer1 = Timer, Prescale = 1024
Stop Timer1