' annoucements
' 20230705
'
Announce:
'Befehl &H00
'eigenes basic announcement lesen
'basic announcement is read to I2C or output
Data "0;m;DK1RI;crosspoint;V02.0;1;180;1;22"
'
'Announce1:
'Befehl &H01
'schaltet Ausgang 1
'switch output 2
Data "1;os,out1;1;0,GND;1,1;2,2;3,3;4,4;5,5;6,6;7,7;8,8"
'
'Announce2:
'Befehl &H02
'schaltet Ausgang 2
'switch output 2
Data "2;os,out2;1;0,GND;1,1;2,2;3,3;4,4;5,5;6,6;7,7;8,8"
'
'Announce3:
'Befehl &H03
'schaltet Ausgang 3
'switch output 3
Data "3;os,out3;1;0,GND;1,1;2,2;3,3;4,4;5,5;6,6;7,7;8,8"
'
'Announce4:
'Befehl &H04
'schaltet Ausgang 4
'switch output 4
Data "4;os,out4;1;0,GND;1,1;2,2;3,3;4,4;5,5;6,6;7,7;8,8"
'
'Announce5:
'Befehl &H05
'schaltet Ausgang 5
'switch output 5
Data "5;os,out5;1;0,GND;1,1;2,2;3,3;4,4;5,5;6,6;7,7;8,8"
'
'Announce6:
'Befehl &H06
'schaltet Ausgang 6
'switch output 6
Data "6;os,out6;1;0,GND;1,1;2,2;3,3;4,4;5,5;6,6;7,7;8,8"
'
'Announce7:
'Befehl &H07
'schaltet Ausgang 7
'switch output
Data "7;os,out7;1;0,GND;1,1;2,2;3,3;4,4;5,5;6,6;7,7;8,8"
'
'Announce8:
'Befehl &H08
'schaltet Ausgang 8
'switch output 8
Data "8;os,out8;1;0,GND;1,1;2,2;3,3;4,4;5,5;6,6;7,7;8,8"
'
'Announce9:
'Befehl  &H09
'liest Status der Ausgänge
'read status
Data "9;aa,status;8,{1_0to8}"
'
'Announce10:
'Befehl  &H0A
'schreibt mode
'write mode
Data "10;os,mode;1;0,8x8;1,8x4;2,4x4,1;14,CHAPTER,ADMINISTRATION"
'
'Announce11:
'Befehl  &H0B
'liest mode
'read mode
Data "11;as,as10"
'
'Announce12:
'Befehl  &H0C
'setzt Startbedingung
'set default
Data "12;ou,set default;1;0,idle;1,set"
'
'Announce13:
'Befehl  &H0D
'schreibt Startbedingung
'write default
Data "13;ou,define as default;1;0,idle;1,define"
'
'Announce14:
'Befehl  &H0E
'liest Startbedingung
'read default
Data "14;aa,default;8,GND,{1_1to8}"
'
'Announce15:
'Befehl  &H0F
'reset
'reset
Data "15;ou,reset;1;0,idle;1,reset all"
'
'Announce16:
'Befehl &HF0<n><m>
'announcement aller Befehle lesen
'read m announcement lines
Data "240;an,ANNOUNCEMENTS;180;22,start at;22,lines;14,CHAPTER,ADMINISTRATION"
'
'Announce17:                                                  '
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
'
'Announce18:                                                  '
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
'Announce19:
'Befehl &HFE :
'eigene Individualisierung schreiben
'write individualization
Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,27,{1_0to127};a,RS232,1;a,USB,1;14,CHAPTER,ADMINISTRATION"
'
'Announce20:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,27,{1_0to127};a,RS232,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;a,USB,1;14,CHAPTER,ADMINISTRATION"