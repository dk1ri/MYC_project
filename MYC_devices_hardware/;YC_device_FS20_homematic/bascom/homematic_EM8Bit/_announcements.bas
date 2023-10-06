' annoucements
' 20230929
'
Announce:
'Befehl &H00
'eigenes basic announcement lesen
'basic announcement is read to I2C or output
Data "0;m;DK1RI;Homematic sender for HM_EM8Bit;V07.0;1;145;1;10;1-1"
'
'Announce1:
'Befehl  &H01
'schaltet Kanäle an / aus kurz
'switchchanals on / off short
Data "1;ou,switch short;1;0,idle;1,switch1;2,switch2"
'
'Announce2:
'Befehl  &H02
'schaltet Kanäle an / aus lang
'switch chanals on / off long
Data "2;ou,switch long;1;0,idle;1,switch1;2,switch2"
'
'Announce3:
'Befehl  &H03
'schaltet Kanäle an / aus lang
'switch chanals on / off long
Data "3;ou,learn;1;0,idle;1,switch1;2,switch2:3,data;13,CHAPTER,configuration"
'
Announce4:
'Befehl  &H04
' sendet Daten
'send data
Data "4;oa,send 1 byte;b"
'
'Announce5:
'Befehl  &H05
'liest Transmiterror
'read Transmiterror
Data "5;ar,last command;1;0,not defined;1,ok;2,error"
'
'Announce5:
'Befehl &HF0<n><m>
'announcement aller Befehle lesen
'read m announcement lines
Data "240;an,ANNOUNCEMENTS;145;10;13,start at;10,elements;10,CHAPTER,ADMINISTRATION"
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
Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,36,{0 to 127};a,RS232,1;a,USB,1;14,CHAPTER,ADMINISTRATION"
'
'Announce9:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,36,{0 to 127};a,RS232,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;a,USB,1;14,CHAPTER,ADMINISTRATION"
'