' announcements
' 20200614
'
Announce:
'Befehl &H00
'eigenes basic announcement lesen
'basic announcement is read to I2C or output
Data "0;m;DK1RI;philips_tv_2908;V05.2;1;145;1;47;1-1"
'
'Announce1:
'Befehl &H01
'an / aus
'on / off
Data "1;ou,An/Aus;0;1,An/Aus"
'
'Announce2:
'Befehl &H02
'o
'o
'Data "2;ou,o;0;1,o"
'
'Announce3:
'Befehl &H03
'||
'||
Data "3;ou,||;0;1,||"
'
'Announce4:
'Befehl &H04
'<<
'<<
Data "4;ou,<<;0;1,<<"
'
'Announce5:
'Befehl &H05
'>
'>
Data "5;ou,>;0;1,>"
'
'Announce6:
'Befehl &H06
'>>
'>>
Data "6;ou,>>;0;1,>>"
'
'Announce7:                           07
'Befehl &H07
'source
'source
Data "7;ou,source;0;1,source"
'
'Announce8:
'Befehl &H08
'tv
'tv
Data "8;ou,tv;0;1,tv"
'
'Announce9:
'Befehl &H09
'format
'format
Data "9;ou,format;0;1,format"
'
'Announce10:
'Befehl &H0A
'home
'home
Data "10;ou,home;0;1,home"
'
'Announce11:
'Befehl &H0B
'list
'list
Data "11;ou,list;0;1,list"
'
'Announce12:
'Befehl &H0C
'info
'info
Data "12;ou,info;0;1,info"
'
'Announce13:
'Befehl &H0D
'adjust
'adjust
Data "13;ou,adjust;0;1,adjust"
'
'Announce14:
'Befehl &H0E
'options
'options
Data "14;ou,options;0;1,options"
'
'Announce15:
'Befehl &H0F
'auf
'up
Data "15;ou,up;0;1,up"
'
'Announce16:
'Befehl &H10
'links
'left
Data "16;ou,left;0;1,left"
'
'Announce17:
'Befehl &H11
'rechts
'right
Data "17;ou,right;0;1,right"
'
'Announce18:
'Befehl &H12
'ab
'down
Data "18;ou,down;0;1,down"
'
'Announce19:
'Befehl &H13
'zurueck
'back
Data "19;ou,back;0;1,back"
'
'Announce20:
'Befehl &H14
'ch-
'ch-
Data "20;ou,ch-;0;1,ch-"
'
'Announce21:
'Befehl &H15
'ch+
'ch+
Data "21;ou,ch+;0;1,ch+"
'
'Announce22:
'Befehl &H16
'laut-
'loud-
Data "22;ou,loud-;0;1,loud-"
'
'Announce23:
'Befehl &H17
'Ton aus
'loud off
Data "23;ou,loud off;0;1,loud off"
'
'Announce24:
'Befehl &H18
'laut+
'loud+
Data "24;ou,loud+;0;1,loud+"
'
'Announce25:
'Befehl &H19
'rot
'red
Data "25;ou,red;0;1,red"
'
'Announce26:
'Befehl &H1A
'gruen
'green
Data "26;ou,green;0;1,green"
'
'Announce27:
'Befehl &H1B
'gelb
'yellow
Data "27;ou,yellow;0;1,yellow"
'
'Announce28:
'Befehl &H1C
'blau
'blue
Data "28;ou,blue;0;1,blue"
'
'Announce29:
'Befehl &H1D
'1
'1
Data "29;ou,1;0;1,1"
'
'Announce30:
'Befehl &H1E
'2
'2
Data "30;ou,2;0;1,2"
'
'Announce31:
'Befehl &H1F
'3
'3
Data "31;ou,3;0;1,3"
'
'Announce32:
'Befehl &H20
'4
'4
Data "32;ou,4;0;1,4"
'
'Announce33:
'Befehl &H21
'5
'5
Data "33;ou,5;0;1,5"
'
'Announce34:
'Befehl &H22
'6
'6
Data "34;ou,6;0;1,6"
'
'Announce35:
'Befehl &H23
'7
'7
Data "35;ou,7;0;1,7"
'
'Announce36:
'Befehl &H24
'8
'8
Data "36;ou,8;0;1,8"
'
'Announce37:
'Befehl &H25
'9
'9
Data "37;ou,9;0;1,9"
'
'Announce38:
'Befehl &H26
'0
'0
Data "38;ou,0;0;1,0"
'
'Announce39:
'Befehl &H27
'subtitle
'subtitle
Data "39;ou,0;subtitle;1,subtitle"
'
'Announce40:
'Befehl &H28
'text
'text
Data "40;ou,0;text;1,text"
'
'Announce41:
'Befehl &H29                                                           25
'ok
'ok
Data "41;ou,0;ok;1,ok"
'
'Announce42:                                              '
'Befehl &HF0<n><m>
'announcement aller Befehle lesen
'read m announcement lines
Data "240;ln,ANNOUNCEMENTS;145;47"
'
'Announce43:                                                  '
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
'
'Announce44:
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
'Announce45:
'Befehl &HFE :
'eigene Individualisierung schreiben
'write individualization
Data "254;ka,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,15,{0 to 127};a,SERIAL,1"
'
'Announce46:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;la,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,15,{0 to 127};a,SERIAL,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1"
'