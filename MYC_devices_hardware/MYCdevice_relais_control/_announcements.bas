' announcements
' 20230621
'
Announce:
'Befehl &H00
'basic annoumement wird gelesen
'basic announcement is read
Data "0;m;DK1RI;4 Relais Bord;V06.0;1;190;1;32;1-1"
'
'Announce1:
'Befehl &H01
'liest digital Wert INP1
'read digital INP1
Data"1;as,INP1;1;0,0;1,1"
'
'Announce2:
'Befehl &H02
'liest digital Wert INP2
'read digital INP2
Data"2;as,INP2;1;0,0;1,1"
'
'Announce3:
'Befehl &H03
'liest digital Wert INP3
'read digital INP3
Data"3;as,INP3;1;0,0;1,1"
'
'Announce4:
'Befehl &H04
'liest digital Wert INP4
'read digital INP4
Data "4;as,INP4;1;0,0;1,1"
'
'Announce5:
'Befehl &H05
'liest digital Wert INP5
'read digital INP5
Data"5;as,INP5;1;0,0;1,1"
'
'Announce6:
'Befehl &H06
'liest digital Wert INP6
'read digital INP6
Data "6;as,INP6;1;0,0;1,1"
'
'Announce7:
'Befehl &H07
'liest digital Wert INP7
'read digital INP7
Data"7;as,INP7;1;0,0;1,1"
'
'Announce8:
'Befehl &H08
'liest digital Wert INP8
'read digital INP8
Data "8;as,INP8;1;0,0;1,1"
'
'Announce9:
'Befehl &H09
'liest digital Wert INP9
'read digital INP9
Data "9;as,INP9;1;0,0;1,1"
'
'Announce10:
'Befehl &H0A
'liest digital Wert INP10
'read digital INP10
Data "10;as,INP10;1;0,0;1,1"
'
'Announce11:
'Befehl &H0B
'liest digital Wert INP11
'read digital INP11
Data "11;as,INP11;1;0,0;1,1"
'
'Announce12:
'Befehl &H0C
'liest analog Wert INP1
'read analog INP1
Data "12;ap,INP1;1;1024;lin;-"
'
'Announce13:
'Befehl &H0D
'liest analog Wert INP2
'read analog INP2
Data "13;ap,INP2;1;1024;lin;-"
'
'Announce14:
'Befehl &H0E
'liest analog Wert INP3
'read analog INP3
Data "14;ap,INP3;1;1024;lin;-"
'
'Announce15:
'Befehl &H0F
'liest analog Wert INP4
'read analog INP4
Data "15;ap,INP4;1;1024;lin;-"
'
'Announce16:
'Befehl &H10
'liest digital alle
'read digital all
Data"16;aa,all;w,{1_0to4095}"
'
'Announce17:
'Befehl &H11
'schaltet Relais1
'switch relais1
Data "17;os,relais1;1;0,off;1,on"
'
'Announce18:
'Befehl &H12
'liest Status Relais1
'read state relais1
Data "18;as,as17"
'
'Announce19:
'Befehl &H13
'schaltet Relais2
'switch relais2
Data "19;os,relais2;1;0,off;1,on"
'
'Announce20:
'Befehl &H14
'liest Status Relais2
'read state relais2
Data "20;as,as19"
'
'Announce21:
'Befehl &H15
'schaltet Relais3
'switch relais3
Data "21;os,relais3;1;0,off;1,on"
'
'Announce22:
'Befehl &H16
'liest Status Relais3
'read state relais3
Data "22;as,as21"
'
'Announce23:
'Befehl &H17
'schaltet Relais4
'switch relais4
Data "23;os, relais4;1;0,off;1,on"
'
'Announce24:
'Befehl &H18
'liest Status Relais4
'read state relais4
Data "24;as,as23"
'
'Announce25:
'Befehl &H19
'schreibt Referenz
'write reference voltage
Data "25;os,reference;1;0,5V;1,1.1V"
'
'Announce26:
'Befehl &H1A
'liest Referenz
'read reference voltage
Data "26;as,as25"
'
'Announce27:
'Befehl &HF0
'announcement aller Befehle lesen
'read announcement lines
Data "240;an,ANNOUNCEMENTS;190;32,start at;32;14,CHAPTER,ADMINISTRATION"
'
'Announce28:
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
'
'Announce29:
'Befehl &HFD
'Geraet aktiv antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
'Announce30:
'Befehl &HFE :
'eigene Individualisierung schreiben
'write individualization
Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,8,{1_0to127};a,SERIAL,1;14,CHAPTER,ADMINISTRATION"
'
'Announce31:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,8,{1_0to127};a,SERIAL,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;14,CHAPTER,ADMINISTRATION"
'
'Announce32:
Data "L;language names;english;deutsch"
'
'Anoounce33:
Data "L;4 relais Bord;4 relais Bord;4 Relais Karte;all;all;alles;relais1;relais1;Relais 1;relais2;relais2;Relais 2;relais3;relais3;Relais 3;relais4;relais4;Relais 4;reference;reference;Referenz"