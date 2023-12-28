' announcements
' 20231006
'
Announce:
'Befehl &H00
'basic annoumement wird gelesen
'basic announcement is read
Data "0;m;DK1RI;RS232_I2C_interface Master;V07.0;1;220;1;11;1-1"
'
'Announce1:
'Befehl &H01 <s>
'string an angeschlossenes device schicken
'write string to device
Data "1;oa,to i2c;250"
'
'Announce2:
'Befehl &H02
'daten von angeschlossenem MYC device lesen
'read data from MYCdevice
Data "2;aa,from (MYC) i2c;1;250"
'
Announce3:
'Befehl &H03
'daten lesen
'read data
Data "3;af,from i2c;1;250"
'
'Announce4:
'Befehl &H04
'Adresse speichern
'write adress
Data "4;oa,I2C adress;b,{1_0to127}"                                               '
'
'Announce5:
'Befehl &H05
'Adresse lesen
'read adress
Data "5;aa,as4"
'
'Announce6:
'Befehl &HF0<n><m>
'liest announcements
'read n announcement lines
Data "240;an,ANNOUNCEMENTS;220;11,start at;11,elements;14,CHAPTER,ADMINISTRATION"
'
'Announce7:                                                 '
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
 '
'Announce8:                                                 '
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
'Announce9:
'Befehl &HFE
'eigene Individualisierung schreiben
'write individualization
Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,SERIAL,1;14,CHAPTER,ADMINISTRATION"
'
'Announce10:
'Befehl &HFF
'eigene Individualisierung lesen
'read individualization
Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,SERIAL,1;b,BAUDRATE,0,19200;3,NUMBER_OF_BITS,8n1;14,CHAPTER,ADMINISTRATION"
'