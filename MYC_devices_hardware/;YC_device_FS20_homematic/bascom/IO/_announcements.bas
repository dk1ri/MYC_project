' announcements
' 20200616
'
Announce:
'Befehl &H00
'eigenes basic announcement lesen
'basic announcement is read
Data "0;m;DK1RI;Homematic_io;V06.2;1;145;1;13:1-1"
'
'Announce1:
'Befehl  &H01
'liest Status der Eingaenge
'read status of inputs
Data "1;aa,status of inputs;8"
'
'Announce2
'Befehl  &H02
'schreibt 4 digitalen Ausgänge kurzer Tastendruck
'write 4 digital outputs short push
Data "2;ou,4 digital outputs short;0,idle;1,switch1;2,switch2;3,switch3;4,switch4"
'
'Announce3:
'Befehl  &H03
'schreibt 4 digitalen Ausgänge langer Tastendruck
'write 4 digital outputs long push
Data "3;ou,4 digital outputs long;0,idle;1,switch1;2,switch2;3,switch3;4,switch4"
'
'Announce4:
'Befehl  &H04
'schreibt 4 analoge Ausgänge
'write 4 analoge outputs
Data "4;om,4 analog outputs;1;w,1_0to1023;4"
'
'Announce5:
'liest Status der 4 analogen Ausgänge
'read status of 4 analog outputs
Data "5;aa,as4"
'
'Announce6:
'Befehl  &H06
'liest Status der 8 Schalter; as info
'read status of 8 switches; as info
Data "6;rr,8 switches;1;0,1;1,2;2,3;3,4;4,5;5,6.6,7,7,8"
'
'Announce7:
'Befehl  &H07
'liest letzte Änderung
'read last change
Data "7;aa,last change;2"
'
'Announce8:
'Befehl &HF0
'announcement aller Befehle lesen
'read m announcement lines
Data "240;an,ANNOUNCEMENTS;175;13,start at;13,elements;14,CHAPTER,ADMINISTRATION" 
'
'Announc9:                                                  '
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
Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,26,{0 to 127};a,RS232,1;a,USB,1"
'
'Announce12:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,26,{0 to 127};a,RS232,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;a,USB,1"
'