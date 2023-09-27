' announcements
' 20230925
'
Announce:
'Befehl &H00
'eigenes basic announcement lesen
'basic announcement is read
Data "0;m;DK1RI;FS20 receiver;V07.0;1;175;1;13;1-1"
'
'Announce1:
'Befehl  &H01
'liest Status aller 8 Schalter
'read status of all 8 switches
Data "1;aa,status all switches;8"
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
Data "5;rr,8 switches;1;0,1;1,2;2,3;3,4;4,5;5,6.6,7,7,8"
'
'Announce6:
'Befehl  &H06
'liest letzte Änderung
'read last change
Data "6;aa,last change;2"
'
'Announce7:
'Befehl &HF0
'announcement aller Befehle lesen
'read m announcement lines
Data "240;an,ANNOUNCEMENTS;175;13,start at;13,elements;14,CHAPTER,ADMINISTRATION"
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
'Befehl &HFE
'eigene Individualisierung schreiben
'write individualization
Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,13,{1_0to127};a,RS232,1;a,USB,1;14,CHAPTER,ADMINISTRATION"
'
'Announce11:
'Befehl &HFF
'eigene Individualisierung lesen
'read individualization
Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,13,{1_0to127};a,RS232,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;a,USB,1;14,CHAPTER,ADMINISTRATION"
'