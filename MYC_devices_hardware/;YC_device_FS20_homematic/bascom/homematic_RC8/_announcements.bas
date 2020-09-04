' annoucements
' 20200616
'
Announce:
'Befehl &H00
'eigenes basic announcement lesen
'basic announcement is read to I2C or output
Data "0;m;DK1RI;Homematic sender for HMIP-MOD-RC8;V06.2;1;145;1;13"
'
'Announce1:
'Befehl &H01
'schaltet Kanäle aus / an
'switch chanals off / on
Data "1;or, 2 switches;1;0,Kanal1;1,Kanal2;2,Kanal3;3,Kanal4"
'
'Announce2:
'Befehl &H02
'schaltet Kanäle an / aus Toggle
'switch chanals on / off toggle
Data "2;ou,8 switches toggle;1;0,idle;1,Kanal1;2,Kanal2;3,Kanal3;4,Kanal4;5,Kanal5;6,kanal7;7,Kanal7;8,Kanal8"
'
'Announce3:
'Befehl  &H03
'liest Transmiterror
'read Transmiterror
Data "3;ar,last command with error;1;0,ok,error"
'
'Announce4:
'Befehl  &H004
'schreibt mode 0 default: an /aus, 1: Toggle
'write mode 0 default:on / off, Toggle,
Data "4;ks,scanmode;1;0,off / on;1,togglemode"
'
'Announce5:
'Befehl  &H05
'liest mode
'read mode
Data "5;ls,as4"
'
'Announce6:
'Befehl &HF0<n><m>
'announcement aller Befehle lesen
'read m announcement lines
Data "240;ln,ANNOUNCEMENTS;145;13"
'
'Announce7:                                                  '
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
'
'Announce8:                                                  '
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
'Announce9:
'Befehl &HFE :
'eigene Individualisierung schreiben
'write individualization
Data "254;ka,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,34,{0 to 127};a,RS232,1;a,USB,1"
'
'Announce10:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;la,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS 34,{0 to 127};a,RS232,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;a,USB,1"
'
'Announce11:
Data "R !$1 If $5 = 1"
'Announce12:
Data "R !$2 IF $5 = 0"