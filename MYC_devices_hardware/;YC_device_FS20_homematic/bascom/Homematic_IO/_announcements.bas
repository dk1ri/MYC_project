' announcements
' 20200616
'
Announce:
'Befehl &H00
'eigenes basic announcement lesen
'basic announcement is read
Data "0;m;DK1RI;Homematic_io;V06.2;1;145;1;12:1-1"
'
'Announce1:
'Befehl  &H01
'Status der 8 Modulausgänge; as command
'status of 8 modul ouputs; as command
Data "1;rr,8 modul ouputs;1;0,not valid;1;2;3;4;5.6,7;8"
'
'Announce2:
'Befehl  &H02
'liest Status aller 8 Modulausgänge
'read status of all 8 modul outputs
Data "2;sa,status all modul ouputs;b"
'
'Announce3:
'schreibt 4 digitalen Ausgänge kurzer Tastendruck
'write 4 digital outputs short push
Data "3;ou,4 digital outputs short push;0,idle;1;2;3;4"
'
'Announce4:
'schreibt 4 digitalen Ausgänge langer Tastendruck
'write 4 digital outputs long push
Data "4;ou,4 digital outputs long push;0,idle;1;2;3;4"
'
'Announce5:
'schreibt 4 analoge Ausgänge
'write 4 analoge outputs
Data "5;om,4 analog outputs;1;w,0 To 1023;4"
'
'Announce6:
'liest Status der 4 analogen Ausgänge
'read status of 4 analog outputs
Data "6;aa,as5"
'
'Announce7:
'Befehl &HF0<n><m>
'announcement aller Befehle lesen
'read m announcement lines
Data "240;ln,ANNOUNCEMENTS;100;13"
'
'Announce8:                                                  '
'Befehl -
'
Data "250;ia,FEATURE;2b,INFO,10"
'
'Announce:                                                  '
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
'
'Announce10:                                                  '
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
'Announce11:
'Befehl &HFE :
'eigene Individualisierung schreiben
'write individualization
Data "254;ka,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,26,{0 to 127};a,RS232,1;a,USB,1"
'
'Announce12:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;la,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,26,{0 to 127};a,RS232,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;a,USB,1"
'