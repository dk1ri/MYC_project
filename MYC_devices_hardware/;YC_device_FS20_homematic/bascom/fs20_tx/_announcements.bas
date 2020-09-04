' announcements
' 20200521
'
Announce:
'Befehl &H00
'eigenes basic announcement lesen
'basic announcement is read to I2C or output
Data "0;m;DK1RI;FS20 8 chanal sender;V06.1;1;145;1;30;1-1"
'
'Announce1:
'Befehl &H01
'schaltet Kanaele, 4 Kanal
'switch chanals,4 chanal mode
Data "1;or,Aus / An;1;0,Kanal1;1,Kanal2;2,Kanal3;3,Kanal4"
'
'Announce2:
'Befehl &H02
'start / stop dimmen ab,, 4 Kanal
'start / stop dimming, down 4 chanal mode
Data "2;ou,dimmt ab;1;0,Kanal1;1,Kanal2;2,Kanal3;3,Kanal4"
'
'Announce3:
'Befehl &H03
'start / stop dimmen auf, 4 Kanal
'start / stop dimming, up 4 chanal mode
Data "3;ou,dimmt auf;1;0,Kanal1;1,Kanal2;2,Kanal3;3,Kanal4"
'
'Announce4:
'Befehl &H04
'Timer fuer 4 Kanal Mode
'Timer for 4 chanal mode
Data "4;ou,Timer start/stop;1;0,Kanal1;1,Kanal2;2,Kanal3;3,Kanal4"
'
'Announce5:
'Befehl &H05
'schaltet Kanaele an / aus, 8 Kanaele
'switch chanals on / off, 8 chanal mode
Data "5;ou,Toggle;1;0,Kanal1;1,Kanal2;2,Kanal3;3,Kanal4;4,Kanal5;5,Kanal6;6,Kanal7;7,Kanal8"
'
'Announce6:
'Befehl &H06
'dimmt Kanaele  auf/ab, 8 Kanaele
'dims chanals up/down, 8 chanal mode
Data "6;ou,dimmt auf/ab;1;0,Kanal1;1,Kanal2;2,Kanal3;3,Kanal4;4,Kanal5;5,kanal6;6,Kanal7;7,Kanal8"
'
'Announce7:
'Befehl &H07
'Timer fuer 8 Kanal Mode
'Timer for 8 chanal mode
Data "7;ou,Timer start/stop;1;0,Kanal1;1,Kanal2;2,Kanal3;3,Kanal4;4,Kanal5;5,Kanal6;6,Kanal7;7,Kanal8"
'
'Announce8:
'Befehl &H08
' dimming aktiver Dimmkanal
' activ dim chanal
Data "8;ar,activ dimm chanal;1;b,0,kein,1,Kanal1;2,Kanal2;3,Kanal3;4,Kanal4"
'
'Announce9:
'Befehl&H09                                                                                                                                                                         Data "7;ou,Timer start/stop;1;0,Kanal1;1,Kanal2;2,Kanal3;3,Kanal4;4,Kanal5;5,kanal6;6,Kanal7;7,Kanal8"
'schreiben 0: 4 / 8 Kanalmode
'write 0: 4 / 8 chanalmode
Data "9;os;1;0,4 Kanal;1,8 Kanal"
'
'Announce10:
'Befehl &H0A
'lesen 4 / 8 Kanalmodemode
'read 4 / 8 chanal mode
Data "10,as,as9"
'
'Announce11:
'Befehl &H0B
'einstellen des set: 4 Kanalmode
'install set: 4 chanal mode
Data "11;ka,install set 4 chanal;1;b,{1 to 10}"
'
'Announce12:
'Befehl &H0C
'einstellen des set: 8 Kanalmode
'set: 4 chanal mode
Data "12;ka,install set 8 chanal;1;b,{1 to 10}"
'
'Announce13:
'Befehl &H0D
'busy, 1: keine Befehle akzeptiert
'busy, 1: no commands accepted
Data "13;aa,busy;a"
':
'Announce14:
'Befehl &H0E
'Hauscode eingeben (8 byte 1 - 4)
'housecode (8 byte 1 to 4)
Data "14;ka,housecode;1;8,{1 to 4}"
'
'Announce15:
'Befehl &H0F
'Hauscode lesen (8 byte 1 - 4)
'read housecode (8 byte 1 to 4)
Data "15;la,as14"
'
'Announce16:
'Befehl &H10
'Adresse eingeben fuer Kanal 1 - 4 und set 0 - 9
'adress, for chanal 1 - 4 and set 0 - 9
Data "16;km,adress, 10 sets, chanal 1 - 4;1;4,{1 to 4};10,set;4,chanal"
'
'Announce17:
'Befehl &H11
'Adresse lesen fuer Kanal 1 - 4 und set 0 - 9
'read adress, for chanal 1 - 4 and set 0 - 9
Data "17;lm,as15"
'
'Announce18:
'Befehl &H12
'Adresse eingeben fuer Taste 1 - 8 und set 0 - 9
'adress,for Button 1 - 8 and set 0 - 9
Data "18;km,adress, 10 sets, chanal 1 to 8;1;4,{1 to 4};10,set;8,chanal"
'
'Announce19:
'Befehl &H13
'Adresse lesen fuer Taste 1 - 8 und set 0 - 9
'read adress,for Button 1 - 8 and set 0 - 9
Data "19;lm,as18"
'
'Announce20:
'Befehl &H14
'Modul reset
'modul reset
Data "20;ku,reset;1;0,idle;1,reset"
'
Announce21:
'Befehl &HF0<n><m>
'announcement aller Befehle lesen
'read m announcement lines
Data "240;ln,ANNOUNCEMENTS;145;30"
'
'Announce22:                                                  '
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
'
'Announce23:                                                  '
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
'Announce24:
'Befehl &HFE :
'eigene Individualisierung schreiben
'write individualization
Data "254;ka,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,12,{0 to 127};a,RS232,1;a,USB,1"
'
'Announce25:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;la,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,12,{0 to 127};a,RS232,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;a,USB,1"
'
'Announce26:
Data "R !$1 !$2 !$3 !$4 !$11 IF $10 = 1"
'
'Announce27 :
Data "R !$5 !$6 !$7 !$12 IF $10 = 0"
'
'Announce28 :
Data "R !$1 !$4 !$5 !$7 IF $8 > 0"
'
'Announce29 :
Data "R !$1 !$2 !$3 !$4 !$5 !$6 !$7 !$9 IF $13 = 1"