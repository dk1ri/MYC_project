' announcements
' 20230812
'
Announce:
'Befehl &H00
'eigenes basic announcement lesen
'basic announcement is read
Data "0;m;DK1RI;Homematic_receiver RE8;V07.0;1;175;1;13:1-1"
'
'Announce1:
'Befehl  &H01
'liest Status der EIngaenge
'read status of inputs
Data "1;aa,status of inputs;8"
'
'Announce2:
'Befehl  &H02
'schaltet ein / aus kurz
'switch on / off short
Data "2;ou,switch;1;0,idle;1,1;2,2;3,3;4,4;5,5;6,6;7,7;8,8"
'
'Announce3:
'Befehl  &H03
'schaltet ein / aus  lang
'switch on / off long
Data "3;ou,learn;1;0,idle;1,1;2,2;3,3;4,4;5,5;6,6;7,7;8,8;13,CHAPTER,configuration"
'
'Announce4:
'Befehl &H04
'busy, 1: keine Befehle akzeptiert
'busy, 1: no commands accepted
Data "4;aa,busy;a;13,CHAPTER,configuration"
'
'Announce5:
'Befehl  &H05
'liest Status der 8 Schalter; as info
'read status of 8 switches; as info
Data "4;rr,8 switches;1;0,1;1,2;2,3;3,4;4,5;5,6.6,7,7,8"
'
'Announce6:
'Befehl  &H05
'liest letzte Änderung
'read last change
Data "6;aa,last change;2"
'
'Announce7:
'Befehl &HF0
'liest announcement Befehle
'read announcement lines
Data "240;an,ANNOUNCEMENTS;175;13,start at;13,elements;14,CHAPTER,ADMINISTRATION"
'
'Announce8:                                                  '
'Befehl -
'Liest letzten Fehler
'read last error
Data "250;ia,FEATURE;b,INFO,10"
'
'Announce9:                                                  '
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
Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,25,{0 to 127};a,RS232,1;a,USB,1;14,CHAPTER,ADMINISTRATION"
'
'Announce12:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,25,{0 to 127};a,RS232,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;a,USB,1;14,CHAPTER,ADMINISTRATION"
'