' announcements
' 20230501
'
Announce:
'Befehl &H00
'eigenes basic announcement lesen
'basic announcement is read to I2C buffer or output
Data "0;m;DK1RI;Textdisplay;V04.0;1;230;1;11;1-1"
'
'Announce1:
'Befehl &H01
'LCD schreiben
'write LCD
'*********************************
' for 16x2 Display
'Data "1;oa,write text;32"
'*********************************
' for 20x2 Display
Data "1;oa,write text;40"
'*********************************
'
'Announce2:
'Befehl &H02
'an position schreiben
'goto position and write
'*********************************
' for 16x2 Display
'Data "2;om,write to position;32;32"
'*********************************
' for 20x2 Display
Data "2;om,write to position;40;40"
'*********************************
'
'Announce3:
'Befehl  &H03
'gehe zu Cursorposition
'go to Cursorposition
'*********************************
' for 16x2 Display
Data "3;op,cursorposition;1;32;lin;-"
'*********************************
' for 20x2 Display
'Data "3;op,cursorposition;1;40;lin;-"
'*********************************
'
'Announce4:
'Befehl &H04
'Anzeige loeschen
'clear screen
Data "4;ou,CLS;0,idle;1,clear display"
'
'Announce5:
'Befehl &H05
'Kontrast schreiben
'write Contrast
Data "5;op,contrast;1;256;lin;-"
'
'Announce6:
'Befehl &H06
'Kontrast lesen
'read Contrast
Data "6;ap,as5"
'
'Announce7:
'Befehl &HF0<n><m>
'liest announcements
'read n announcement lines
Data "240;an,ANNOUNCEMENTS;230;11;14,CHAPTER,ADMINISTRATION"
'
'Announce18:                                                  '
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
'
'Announce9:                                                  '
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
'Announce10:
'Befehl &HFE :
'eigene Individualisierung schreiben
'write individualization
Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,8,{1_0to127};a,SERIAL,1;14,CHAPTER,ADMINISTRATION"
'
'Announce11:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,8,{1_0to127};a,SERIAL,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;14,CHAPTER,ADMINISTRATION"
'