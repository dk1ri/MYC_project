' announcements
' 20200614
'
Announce:
'Befehl &H00
'eigenes basic announcement lesen
'basic announcement is read to I2C or output
Data "0;m;DK1RI;IR_sender;V05.0;1;145;1;14;1-1"
'
'Announce1:
'Befehl &H01   0-63
'als RC5 Signal senden 1 Zeichen
'send 1 IR signal
Data "1;oa,send RC5;b,{&H00 to &H3F}"
'
'Announce2:
'Befehl &H02   0-255
'als RC6 Signal senden, 8 bit
'send as RC6 signal, 8 bit
Data "2;oa,send RC6;b"
'
'Announce3:
'Befehl &H03   0-31
'RC5 Adresse schreiben
'write RC5 adress
Data "3;oa,rc5adress;b,{0 to 31}"
'
'Announce4:
'Befehl &H04
'RC5 Adresse lesen
'read RC5 adress
Data "4;aa,as3"
'
'Announce5:
'Befehl &H05   0-255
'RC6 Adresse schreiben, 8 bit
'write RC6 adress, 8 bit
Data "5;oa,rc6adress;b"
'
'Announce6:
'Befehl &H06
'RC6 Adresse lesen
'read RC6 adress
Data "6;oa,as5"
'
'Announce7:
'Befehl &H07  0,1
'no_myc schreiben
'write no_myc
Data "7;oa,write no_myc;a"
'
'Announce8:
'Befehl &H08
'no_myc lesen
'read no_myc
Data "8;aa,as7"
'
'Announce9:
'Befehl &HF0<n><m>
'announcement aller Befehle lesen
'read m announcement lines
Data "240;ln,ANNOUNCEMENTS;145;14"
'
'Announce10:
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
'
'Announce11:
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
'Announce12:
'Befehl &HFE :
'eigene Individualisierung schreiben
'write individualization
Data "254;ka,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,5,{0 to 127};a,SERIAL,1"
'
'Announce13:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;la,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,5,{0 to 127};a,SERIAL,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1"
'