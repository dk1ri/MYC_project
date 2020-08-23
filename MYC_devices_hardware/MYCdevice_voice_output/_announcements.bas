' _announcements
' 20200822
'
Announce:
'Befehl &H00
'basic annoumement wird gelesen
'basic announcement is read
Data "0;m;DK1RI;Sprachausgabe;V04.1;1;145;1;9;1-1"
'
'Announce1:
'Befehl &H01 0 to 9
'spielt Sprache/Musik
'play voice/music
Data "1;ou,,sound;1;0,idle;1;2;3;4;5;6;7;8;9;10"
'
'Announce2:
'Befehl &H02 0 to 9
'spielt Playliste
'play playlist
Data "2;ou,playlist;1;0,idle;1;2;3;4;5;6;7;8;9;10"
'
'Announce3:
'Befehl &H03 0 to 8
'Modi
'set modes
Data "3;ou,mode;1;0,idle;1,1+3;2.1+4;3,1+5;4,1+6;5,1+7;6,1+8;7,1+9;8,1+10;9,2+3;10,2+4;11,2+7;12,2+8;13,2+9;14,2+10"
'
'Announce4:
'Befehl &HF0<n><m>
'liest announceme4ts
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
Data "254;ka,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,20,{0 to 127};,SERIAL,1"
'
'Announce8:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;la,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,20,{0 to 127};a,SERIAL,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1"
'