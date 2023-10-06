' announcements
' 20230812
'
Announce:
'Befehl &H00
'eigenes basic announcement lesen
'basic announcement is read
Data "0;m;DK1RI;Homematic_receiver OC8;V07.0;1;175;1;12:1-1"
'
'Announce1:
'Befehl  &H01
'liest Status
'read status
Data "1;ar,8 switches;1;0,1;1,2;2,3;3,4;4,5.5,6,6,7;7,8"
'
'Announce2:
'Befehl  &H02
'schaltet ein / aus kurz
'switch on / off short
Data "2;ou,switch;1;0,idle;1,1;2,2;3,3;4,4;5,5;6,6;7,7;8,8"
'
'Announce3:
'Befehl &H03
'busy, 1: keine Befehle akzeptiert
'busy, 1: no commands accepted
Data "3;aa,busy;a;13,CHAPTER,configuration"
'
'Announce4:
'Befehl  &H04
'liest Status der 8 Schalter; as info
'read status of 8 switches; as info
Data "4;rr,8 switches;1;0,1;1,2;2,3;3,4;4,5;5,6.6,7,7,8"
'
'Announce5:
'Befehl  &H05
'liest letzte Änderung
'read last change
Data "5;aa,last change;2"
'
'Announce6:
'Befehl &HF0
'liest announcement Befehle
'read announcement lines
Data "240;an,ANNOUNCEMENTS;175;12,start at;12,elements;14,CHAPTER,ADMINISTRATION"
'
'Announce7:                                                  '
'Befehl -
'Liest letzten Fehler
'read last error
Data "250;ia,FEATURE;b,INFO,10"
'
'Announce8:                                                  '
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
'
'Announce9:                                                  '
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
'Announce10:
'Befehl &HFE :
'eigene Individualisierung schreiben
'write individualization
Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,25,{0 to 127};a,RS232,1;a,USB,1;14,CHAPTER,ADMINISTRATION"
'
'Announce11:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,25,{0 to 127};a,RS232,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;a,USB,1;14,CHAPTER,ADMINISTRATION"
'