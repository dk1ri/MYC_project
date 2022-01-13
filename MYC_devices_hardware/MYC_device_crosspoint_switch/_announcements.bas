' annoucements
' 20220113
'
Announce:
'Befehl &H00
'eigenes basic announcement lesen
'basic announcement is read to I2C or output
Data "0;m;DK1RI;crosspoint;V01.3;1;180;1;20"
'
'Announce1:
'Befehl &H01
'schaltet 1 Ausgang 8x8
'switch 1 output 8x8
Data "1;os,8x8;2,out,in;2;0,GND;1;2;3;4;5;6;7;8"
'
'Announce2:
'Befehl  &H02
'schaltet alle Ausgänge 8x8
'switch all outputs 8x8
Data "2;om,8x8;b,{GND,1 To 8};9"
'
'Announce3:
'Befehl &H03
'schaltet 1 Ausgang 8x4
'switch 1 output 8x4
Data "3;os,8x4;2,out,in;2;0,GND;1;2;3;4;5;6;7;8"
'
'Announce4:
'Befehl  &H04
'schaltet alle Ausgänge 8x4
'switch all outputs 8x4
Data "4;om,8x4;b,{GND,1 To 8};4"
'
'Announce5:
'Befehl  &H05
'schaltet 1 Ausgang 4x4
'switch 1 output 4x4
Data "5;os,4x4;2,out,in;2;0,GND;1;2;3;4"
'
'Announce6:
'Befehl  &H06
'schaltet alle Ausgänge 4x4
'switch all outputs 4x4
Data "6;om,4x4;b,{GND,1 To 4};04"
'
'Announce7:
'Befehl  &H07
'liest status für alle Ausgänge
'read status for all outputs
Data "7;am;b,{GND,1 To 8};9"
'
'Announce8:
'Befehl  &H08
'schreibt mode
'write mode
Data "8;ks,mode;1;0,8x8;1,8x4;2,4x4"
'
'Announce9:
'Befehl  &H09
'liest mode
'read mode
Data "9;ls,as8"
'
'Announce10:
'Befehl  &H0A
'schreibt Startbedingung 8x8
'write startcondition 8x8
Data "10;om,startcondition;b,{GND,1 To 8};8"
'
'Announce11:
'Befehl  &H0B
'liest Startbedingung 8x8
'read startcondition 8x8
Data "11;am,as10"
'
'Announce12:
'Befehl &HF0<n><m>
'announcement aller Befehle lesen
'read m announcement lines
Data "240;ln,ANNOUNCEMENTS;180;20"
'
'Announce13:                                                  '
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
'
'Announce14:                                                  '
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
'Announce15:
'Befehl &HFE :
'eigene Individualisierung schreiben
'write individualization
Data "254;ka,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,27,{0 to 127};a,RS232,1;a,USB,1"
'
'Announce16:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;la,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,27,{0 to 127};a,RS232,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;a,USB,1"
'
'Announce17:
Data "R !$1,!$2 If $9 = 1 Or $9 = 2"
'Announce18:
Data "R !$3,!$4 If $9 = 0 Or $9 = 2"
'Announce19:
Data "R !$5,!$6 If $9 = 0 Or $9 = 1"