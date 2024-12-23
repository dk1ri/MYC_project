' announcements
' 2024041220
'
Announce:
'Befehl &H00
'basic annoumement wird gelesen
'basic announcement is read
Data "0;m;DK1RI;V I sensor;V01.0;1;145;1;13;1-1"
'
'Announce1:
'Befehl &H01
'liest Spannung
'read voltage
Data "1;ap,shunt voltage;1;64000,,{1,-32000to 32000};lin;*10uV"
'
'Announce2:
'Befehl &H02
'liest Spannung
'read voltage
Data "2;ap,bus voltage;1;32000,,{1,0to32000};lin;mV"
'
'Announce3:
'Befehl &H03
'liest Strom
'read currect
Data "3;ap,current;1;32000,,{1,-32000to32000};lin;mA"
'
'Announce4:
'Befehl &H04
'liest Leistung
'read power
Data "4;ap,power;1;64000,;lin;mW"
'
'Announce5:
'Befehl &H05
' Konfiguration
' configuration
Data "5;oa,configuration;1;w;14,CHAPTER,ADMINISTRATION"
'
'Announce6:
'Befehl &H06
' Konfiguration
' read configuration
Data "6;aa,as5"
'
'Announce7:
'Befehl &HF0
'liest announcements
'read m announcement lines
Data "240;an,ANNOUNCEMENTS;145;13,start at;13,elements;14,CHAPTER,ADMINISTRATION"
'
'Announce8:
'Befehl &HF8
'MYC / Interface Mode
'MYC / Interface mode
Data "248;oa,TRANS,transpatent MYC mode / radio name;4;14,CHAPTER,ADMINISTRATION"
'
'Announce9:
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;60,last_error"
'
'Announce10:
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
'Announce11:
'Befehl &HFE <n><data>
'eigene Individualisierung schreiben
'write individualization
Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,0;b,ADRESS,0;a,SERIAL,1;a,RADIO,1;14,CHAPTER,ADMINISTRATION"
'
'Announce12:
'Befehl &HFF <n>
'eigene Individualisierung lesen
'read individualization
Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,0;b,ADRESS,0;a,SERIAL,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;a,RADIO,1;14,CHAPTER,ADMINISTRATION"
'