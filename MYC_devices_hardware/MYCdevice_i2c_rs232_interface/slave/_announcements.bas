' announcements
' 20200423
'
Announce:
'Befehl &H00
'basic annoumement wird gelesen
'basic announcement is read to I2C
Data "0;m;DK1RI;Rs232_i2c_interface Slave;V06.1;1;200;1;8;1-1"
'
'Announce1:
'Befehl &H01 <s>
'Sendet Daten von I2C nach RS232
'read data from I2C, write to RS232 (write to device)
Data "1,oa;250"
'
'Announce2:
'Befehl &H02
'liest Daten von RS232 nach I2C
'read data from RS232, write to I2C  (read from device)
Data "2,aa,250"
'
'Announce3:
'Befehl &HF0<n><m>
'announcement aller Befehle lesen
'read m announcement lines
Data "240;ln,ANNOUNCEMENTS;200;8"
'
'Announce4:                                                  '
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
'
'Announce5:                                                  '
'Befehl &HFD
'Geraet aktiv antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
'Announce6:
'Befehl &HFE :
'eigene Individualisierung schreiben
'write individualization
Data "254;ka,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,1,{0 to 127};a,SERIAL,0"

'Announce7:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;la,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,1,{0 to 127};a,SERIAL,0;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1"
'