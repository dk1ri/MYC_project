' announcements
' 20200511
'
Announce:
'Befehl &H00
'eigenes basic announcement lesen
'basic announcement is read to I2C or output
Data "0;m;DK1RI;morse sender;V04.2;1;190;1;15;1-1"
'
'Announce1:
'Befehl  &H01 <s>
'I2C / serial String als Morse senden
'send I2C / serial String as Morse
Data "1;oa,send morse;250,{.,\,,:,\;,?,-,_,(,),',=,+,/,@,0 to 10,a to z, A to Z}"
'
'Announce2:
'Befehl  &H02 0 to 19
'Geschwindigkeit schreiben
'write speed
Data "2;op,morse speed;1;20,{5 to 100};lin;Wpm"
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
Data "4;op,morse frequency;1;20,{100 to 2000};lin;Hz"
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
Data "6;os,mode;1;0,myc mode;1,morse input;2,0 to 9;3,a to f;4,g to l;5,m to s;6,t to z;7,special;8,all"
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
Data "240;ln,ANNOUNCEMENTS;190;15"
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
Data "254;ka,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,18,{0 to 127};a,SERIAL,1"
'
'Announce12:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;la,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,18,{0 to 127};a,SERIAL,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1"
'
'Announce13:
Data "R !* IF $6&1"
'
'Announce14:
Data "R &6 IF $6&1"
'