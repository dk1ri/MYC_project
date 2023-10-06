' annoucements
' 20200616
'
Announce:
'Befehl &H00
'eigenes basic announcement lesen
'basic announcement is read to I2C or output
Data "0;m;DK1RI;Homematic sender EM8;V07.0;1;145;1;8;1-1"
'
'Announce1:
'Befehl &H01
'schaltet Kanäle an / aus
'switch chanals on / off toggle
Data "2;ou,8 switches;1;0,idle;1,switch1;2,switch2;3,switch3;4,switch4;5,switch5;6,switch6;7,switch7;8,switch8"
'
'Announce2:
'Befehl  &H02
'liest Transmiterror
'read Transmiterror
Data "5;as,last command with error;1;0,not defined;1,ok;2,error"
'
'Announce3:
'Befehl &HF0
'announcement aller Befehle lesen
'read m announcement lines
Data "240;an,ANNOUNCEMENTS;175;8,start at;8,elements;14,CHAPTER,ADMINISTRATION"
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
Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,24,{0 to 127};a,RS232,1;a,USB,1;14,CHAPTER,ADMINISTRATION"
'
'Announce12:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,24,{0 to 127};a,RS232,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;a,USB,1;14,CHAPTER,ADMINISTRATION"
'