' _announcements
' 20230725
'
Announce:
'Befehl &H00
'basic annoumement wird gelesen
'basic announcement is read
Data "0;m;DK1RI;Sprachausgabe;V05.0;1;220;1;10;1-1"
'
'Announce1:
'Befehl &H01
'spielt Sprache/Musik
'play voice/music
Data "1;ou,sound;1;0,idle;1,1;2,2;3,3;4,4;5,5;6,6;7,7;8,8;9,9;10,10"
'
'Announce2:
'Befehl &H02
'spielt Playliste
'play playlist
Data "2;ou,playlist;1;0,idle;1,1;2,2;3,3;4,4;5,5;6,6;7,7;8,8;9,9;10,10"
'
'Announce3:
'Befehl &H03
'Modi
'set modes
Data "3;ou,mode;1;0,idle;1,version;2,autoplay;3,idle+sleep;4,sleep;5,idle;6,aplifier;7,no idle;8,update;9,normal mode;10,with retrigger;11,play_to_end;12,random_and_row;13,random_and_row_to_end;14,factory default"
'
'Announce4:
'Befehl $H04
'ready
'ready
Data "4;as,initialisation;1;0,not ready;1,ready"
'
'Announce5:
'Befehl &HF0
'liest announceme4ts
'read n announcement lines
Data "240;an,ANNOUNCEMENTS;220;10,start at;10,elements;14,CHAPTER,ADMINISTRATION"
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
Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,20,{0 to 127};a,SERIAL,1;14,CHAPTER,ADMINISTRATION"
'
'Announce9:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,20,{0 to 127};a,SERIAL,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;14,CHAPTER,ADMINISTRATION"
'