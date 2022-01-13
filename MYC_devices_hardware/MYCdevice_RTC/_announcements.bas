' announcements
' 20220113
'
Announce:
'Befehl &H00
'eigenes basic announcement lesen
'basic announcement is read to I2C or output
Data "0;m;DK1RI;RTC;V03.2;1;145;1;9;1-1"
'
'Announce1:
'Befehl  &H01
'liest Uhrzeit
'read time
Data "1;aa,read time;t"
'
'Announce2:
'Befehl  &H02 <0..14><m>
'schreibt register
'write register
Data "2;om,write register;b;15"
'
'Announce3:
'Befehl  &H03 <0..14>
'liest register
'read register
Data "3;am,as2"
'
'Announce4:
'Befehl &HF0<n><m>
'liest announcements
'read n announcement lines
Data "240;ln,ANNOUNCEMENTS;145;9"
'
'Announce5:                                                  '
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
'
'Announce6:                                                  '
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
'Announce7:
'Befehl &HFE :
'eigene Individualisierung schreiben
'write individualization
Data "254;ka,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,19,{0 to 127};a,SERIAL,1"
'
'Announce8:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;la,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,19,{0 to 127};a,SERIAL,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1"
'