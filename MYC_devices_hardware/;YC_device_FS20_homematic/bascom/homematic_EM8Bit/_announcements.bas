' annoucements
' 20200813
'
Announce:
'Befehl &H00
'eigenes basic announcement lesen
'basic announcement is read to I2C or output
Data "0;m;DK1RI;Homematic sender for HM_EM8Bit;V06.2;1;145;1;10"
'
'Announce1:
'Befehl  &H01
'schaltet Kanäle an / aus Toggle kurz
'switch chanals on / off toggle short
Data "2;ou,2 switches short;1;0,idle;1,Kanal1;2,Kanal2"
'
'Announce2:
'Befehl  &H02
'schaltet Kanäle an / aus Toggle lang
'switch chanals on / off toggle long
Data "3;ou,2 switches long;1;0,idle;1,Kanal1;2,Kanal2"
'
Announce3:
'Befehl  &H03
' sendet Daten
'send data
Data "3;oa;send data;a"
'
'Announce4:
'Befehl  &H04
'liest Transmiterror
'read Transmiterror
Data "4;ar,last command with error;1;0,ok,error"
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
Data "254;ka,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,36,{0 to 127};a,RS232,1;a,USB,1"
'
'Announce9:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;la,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,36,{0 to 127};a,RS232,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;a,USB,1"
'