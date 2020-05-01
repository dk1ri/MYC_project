' announcements
' 20200422
'
Announce:
'Befehl &H00
'eigenes basic announcement lesen
'basic announcement is read to I2C buffer or output
Data "0;m;DK1RI;Textdisplay;V03.2;1;230;1;17;1-1"
'
'Announce1:
'Befehl &H01
'LCD schreiben
'write LCD
Data "1;oa,write text;32"
'
'Announce2:
'Befehl &H02
'an position schreiben
'goto position and write
Data "2;om,write to position;32;32"
'
'Announce3:
'Befehl  &H03
'gehe zu Cursorposition
' go to Cursorposition
Data "3;op,Cursorposition;32;lin;-"
'
'Announce4:
'Befehl &H04
'LCD schreiben
'write LCD
Data "4;oa,write text;40"
'
'Announce5:
'Befehl &H05
'an position schreiben
'goto position and write
Data "5;om,write to position;40;40"
'
'Announce6:
'Befehl  &H06
'gehe zu Cursorposition
'go to Cursorposition
Data "6;op,Cursorposition;40;lin;-"
'
'Announce7:
'Befehl &H07
'Anzeige löschen
'clear screen
Data "7;ou,CLS;0,CLS"
'
'Announce8:
'Befehl &H08
'Kontrast schreiben
'write Contrast
Data "8;oa,contrast;b"
'
'Announce9:
'Befehl &H09
'Kontrast lesen
'read Contrast
Data "9;oa,contrast;b"
'
'Announce10:
'Befehl &HF0<n><m>
'liest announcements
'read n announcement lines
Data "240;ln,ANNOUNCEMENTS;230;17"
'
'Announce11:                                                  '
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
'
'Announce12:                                                  '
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
'Announce13:
'Befehl &HFE :
'eigene Individualisierung schreiben
'write individualization
Data "254;ka,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,8,{0 to 127};a,SERIAL,1;a,DISPLAYSIZE,0,{16x2,20x2}"
'
'Announce14:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;la,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,8,{0 to 127};a,SERIAL,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;a,DISPLAYSIZE,0,{16x2,20x2}"
'
'Announce15:
Data "R !($1 $2 $3) IF $255&5 = 1"
'
'Announce16:
Data "R !($4 $5 $6) IF $255&5 = 0"
'