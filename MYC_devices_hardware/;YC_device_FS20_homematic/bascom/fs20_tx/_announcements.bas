' announcements
' 20230926
'
Announce:
'Befehl &H00
'eigenes basic announcement lesen
'basic announcement is read to I2C or output
Data "0;m;DK1RI;FS20 8 chanal sender;V07.0;1;205;1;21;1-1"
'
'Announce1:
'Befehl &H01
'schreiben 0: 4 / 8 Kanalmode
'write 0: 4 / 8 chanalmode
Data "1;os,chanals;1;0,4;1,8;13,CHAPTER,configuration"
'
'Announce2:
'Befehl &H02
'lesen 4 / 8 Kanalmodemode
'read 4 / 8 chanal mode
Data "2;as,as1"
'
'Announce3:
'Befehl &H03
'schaltet Kanaele, 4 Kanal
'switch chanals,4 chanal mode
Data "3;or,switch;1;0,chanal1;1,chanal2;2,chanal3;3,chanal4"
'
'Announce4:
'Befehl &H04
'start / stop dimmen auf / ab,, 4 Kanal
'start / stop dimming, up /down 4 chanal mode
Data "4;os,start / stop dimming;1;0,chanal1 down;1,chanal1 up;2,chanal2 down;3,chanal2 up;4,chanal3 down;5,chanal3 up;6,chanal4 down;7,chanal4 up"
'
'Announce5:
'Befehl &H05
'Timer fuer 4 Kanal Mode
'Timer for 4 chanal mode
Data "5;ou,timer start/stop;1;0,chanal1;1,chanal2;2,chanal3;3,chanal4"
'
'Announce6:
'Befehl &H06
'schaltet Kanaele an / aus, 8 Kanaele
'switch chanals on / off, 8 chanal mode
Data "6;ou,toggle;1;0,chanal1;1,chanal2;2,chanal3;3,chanal4;4,chanal5;5,chanal6;6,chanal7;7,chanal8"
'
'Announce7:
'Befehl &H07
'dimmt Kanaele  auf/ab, 8 Kanaele
'dims chanals up/down, 8 chanal mode
Data "7;os,dimm up/down;1;0,ch1 stop;1,ch2 stop;2,ch3 stop;3,ch4 stop;4,ch5 stop;5,ch6 stop;6,ch7 stop;7,ch8 stop;8,ch1 start;9,ch2 start;10,ch3 start;11,ch4 start;12,ch5 start;13,ch6 start;14,ch7 start;15,ch8 start"
'
'Announce8:
'Befehl &H08
'Timer fuer 8 Kanal Mode
'Timer for 8 chanal mode
Data "8;ou,Timer start/stop;1;0,chanal1;1,chanal2;2,chanal3;3,chanal4;4,chanal5;5,chanal6;6,chanal7;7,chanal8"
'
'Announce9:
'Befehl &H09
'busy, 1: keine Befehle akzeptiert
'busy, 1: no commands accepted
Data "9;aa,busy;b, "
':
'Announce10:
'Befehl &H0A
'Hauscode eingeben (8 byte 1 - 4)
'housecode (8 byte 1 to 4)
Data "10;oa,housecode;8,{1to4};13,CHAPTER,configuration"
'
'Announce11:
'Befehl &H0B
'Hauscode lesen (8 byte 1 - 4)
'read housecode (8 byte 1 to 4)
Data "11;aa,as10"
'
'Announce12:
'Befehl &H00D
'Modul reset
'modul rset
Data "12;ou,reset;1;0,idle;1,reset;13,CHAPTER,configuration"
'
'Announce13:
'Befehl &HF0
'announcement aller Befehle lesen
'read m announcement lines
Data "240;an,ANNOUNCEMENTS;205;21,start at;21,elements;14,CHAPTER,ADMINISTRATION"
'
'Announce14:                                                  '
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
'
'Announce15:                                                  '
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
'Announce16:
'Befehl &HFE :
'eigene Individualisierung schreiben
'write individualization
Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,12,{1_0to127};a,RS232,1;a,USB,1;14,CHAPTER,ADMINISTRATION"
'
'Announce17:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,12,{1_0to127};a,RS232,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;a,USB,1;14,CHAPTER,ADMINISTRATION"
'
'Announce18:
Data "R !$1 !$3 !$4 !$5 !$6 !$7 !$8 !$10, !12 IF $21 = 1"
'
'Announce19:
Data "R !$3 !$4 !$5 IF $2 = 1"
'
'Announce20:
Data "R !$6 !$7 !$8 IF $2 = 0"
'