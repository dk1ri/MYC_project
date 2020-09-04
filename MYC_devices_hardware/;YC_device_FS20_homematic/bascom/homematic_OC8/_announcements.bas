' announcements
' 200204
'
Announce:
'Befehl &H00
'eigenes basic announcement lesen
'basic announcement is read
Data "0;m;DK1RI;Homematic_receiver OC8;V06.2;1;145;1;9:1-1"
'
'Announce1:
'Befehl  &H01
'Schaltbefehl Homematic -> MYC
'switch command Homematic -> MYC
Data "1;rr,switch command;1;0,not valid;1;2;3;4;5.6,7,8"
'
'Announce2:
' Befehl &H02
'liest Status aller 8 Modulausgänge
'read status of all 8 modul outputs
Data "2;sa,status of modul ouputs;b"
'
'Announce3:
'Befehl &HF0<n><m>        8'announcement aller Befehle lesen
'read m announcement lines
Data "240;ln,ANNOUNCEMENTS;100;9"
'
'Announce4:                                                  '
'Befehl -
'Liest letzten Fehler
'read last error
Data "250;ia,FEATURE;b,INFO,10"
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
Data "254;ka,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,35,{0 to 127};a,RS232,1;a,USB,1"
'
'Announce8:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;la,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,25,{0 to 127};a,RS232,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;a,USB,1"
'