' announcements
' 20200603
'
Announce:
'Befehl &H00
'eigenes basic announcement lesen
'basic announcement is read
Data "0;m;DK1RI;FS20 receiver;V06.1;1;145;1;10;1-1"
'
'Announce1:
'Befehl  &H01
'liest Status der 8 Schalter; as info
'read status of 8 switches; as info
Data "1;rr,8 switches;1;0,not valid;1;2;3;4;5.6,7;8"
'
'Announce2:
'Befehl  &H02
'liest Status aller 8 Schalter
'read status of all 8 switches
Data "2;sa,status all switches;b"
'
'Announce3:
'Befehl  &H04
'schaltet ein /aus kurz
'switch on / off short
Data "3;ou, switch short;1;0;1;2;3;4;5;6;7"
'
'Announce4:
'Befehl  &H05
'schaltet ein /aus  lang
'switch on / off long
'Data "4;ou,switch long;1;0;1;2;3;4;5;6;7"
'
'Announce5:
'Befehl &HF0<n><m>
'announcement aller Befehle lesen
'read m announcement lines
Data "240;ln,ANNOUNCEMENTS;145;10"
'
'Announce6:                                                  '
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
'
'Announce7:                                                  '
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
'Announce8:
'Befehl &HFE :
'eigene Individualisierung schreiben
'write individualization
Data "254;ka,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,13,{0 to 127};a,RS232,1;a,USB,1"
'
'Announce9:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;la,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,13,{0 to 127};a,RS232,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;a,USB,1"
'