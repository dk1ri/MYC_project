' announcements
' 20230704
'
Announce:
'Befehl &H00
'eigenes basic announcement lesen
'basic announcement is read to I2C or output
Data "0;m;DK1RI;morse sender;V05.0;1;190;1;14;1-1"
'
'Announce1:
'Befehl  &H01 <s>
'I2C / serial String als Morse senden
'send I2C / serial String as Morse
Data "1;oa,send morse;250,{.,0x2c,:,0x3b,?,-,_,(,),',=,+,/,@,0to10,atoz,AtoZ}"
'
'Announce2:
'Befehl  &H02 0 to 19
'Geschwindigkeit schreiben
'write speed
Data "2;op,morse speed;1;20,{5_5to100};lin;Wpm"
'
'Announce3:
'Befehl  &H03
'Geschwindigkeit lesen
'read speed
Data "3;ap,as2"
'
'Announce4:
'Befehl  &H04
'Frequenz schreiben 100 - 2000Hz
'write frequency
Data "4;op,morse frequency;1;20,{100_100to2000};lin;Hz"
'
'Announce5:
'Befehl  &H05
'Frequenz lesen
'read frequency
Data "5;ap,as4"
'
'Announce6:
'Befehl  &H06
'Mode einstellen, Myc, direkteingabe, 5er Gruppen
'set mode
Data "6;os,mode;1;0,browser mode;1,myc mode;2,morse input;3,0 to 9;4,a to f;5,g to l;6,m to s;7,t to z;8,special;9,all"
'
'Announce7:
'Befehl  &H07
'Morse mode lesen
'read morse mode
Data "7;as,as6"
'
'Announce8:
'Befehl &HF0<n><m>
'liest announcements
'read n announcement lines
Data "240;an,ANNOUNCEMENTS;190;15,start at;15,lines;14,CHAPTER,ADMINISTRATION"
'
'Announce9:                                                  '
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
'
'Announce10:                                          '
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
'Announce11:
'Befehl &HFE :
'eigene Individualisierung schreiben
'write individualization
Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,18,{1_0to127};a,SERIAL,1;14,CHAPTER,ADMINISTRATION"
'
'Announce12:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,18,{1_0to127};a,SERIAL,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;14,CHAPTER,ADMINISTRATION"
'
'Announce13:
Data "R !* IF !$6&0 OR !$6&1"
'