' announcements
' 20231124
'
Announce:
'Befehl &H00
'basic annoumement wird gelesen
'basic announcement is read to I2C
Data "0;m;DK1RI;Rs232_i2c_interface Slave;V07.0;1;200;1;8;1-1"
'
'Announce1:
'Befehl &H01 <s>
'liest Daten von I2C nach RS232
'read data from I2C, write to RS232 (write to device!)
Data "1,oa,to RS232;250"
'
'Announce2:
'Befehl &H02
'liest Daten von RS232 nach I2C
'read data from RS232, write to I2C  (read from device)
Data "2,aa,from RS232;250"
'
'Announce3:
'Befehl &HF0<n><m>
'announcement aller Befehle lesen
'read m announcement lines
Data "240;an,ANNOUNCEMENTS;200;8,start at;8,elements;14,CHAPTER,ADMINISTRATION"
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
Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,1,{1_0to127};14,CHAPTER,ADMINISTRATION"

'Announce7:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,1,{1_0to127};14,CHAPTER,ADMINISTRATION"
'