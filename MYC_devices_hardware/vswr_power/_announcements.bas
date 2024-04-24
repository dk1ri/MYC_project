' announcements
' 20240420
'
Announce:
'Befehl &H00; 1 byte / 1 byte + string
'eigenes basic announcement lesen
'basic announcement is read to I2C or output
Data "0;m;DK1RI;VSWR / power meter;V01.0;1;145;1;18;1-1"
'
'Announce1:
'Befehl &H01
'lese forward
'read forward
Data "1;ap,forward;1;1600,,{0.1_-60to100.0};lin;dBm"
 '
'Announce2:
'Befehl &H02
'liest reflected
'read reflected
Data "2;ap,reflected;1;1600,,{0.1_-60to100.0};lin;dBm"
'
'Announce3:
'Befehl &H03
'liest VSWR
'read VSWR
Data "3;ap,VSWR;1;251,,{0.1_0.000to25.0};lin;-"
'
'Announce4:
'Befehl &H04
'schreibt Daempfung forward
'write attenuation forward
Data "4;op,attenuation forward;1;1000,,{0.1_0to100.0;lin;dB"
'
'Announce5:
'Befehl &H05
'liest Daempfung forward
'read attenuation forward
Data "5;ap,as4"
'
'Announce6:
'Befehl &H06
'schreibt Daempfung reflected
'write attunuation reflected
Data "5;op,attenuation reflected;1;1000,,{0.1_0to100.0;lin;dB"
'
'Announce7:
'Befehl &H07
'liest Daempfung reflected
'read attenuation reflected
Data "7;ap,as6"
'
'Announce8
'liest Temperatur
'read temperature
Data "8;op,temperature forward;1;801,,{0.1_0to80.0};lin;deg"
'
'Announce9
'liest Temperatur
'read temperature
Data "8;op,temperature reflected;1;801,,{0.1_0to80.0};lin;deg"
'
'Announce10:
'Befehl &HF0
'liest announcements
'read m announcement lines
Data "240;an,ANNOUNCEMENTS;145;18,start at;18;14,CHAPTER,ADMINISTRATION"
'
'Announce11:
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
'
'Announce12:
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
'Announce13:
'Befehl &HFE
'eigene Individualisierung schreiben
'write individualization
Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,21,{1_0to127};a,SERIAL,1;14,CHAPTER,ADMINISTRATION"
'
'Announce14:
'Befehl &HFF
'eigene Individualisierung lesen
'read individualization
Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,21,{1_0to127};a,SERIAL,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;14,CHAPTER,ADMINISTRATION"
'
'Announce15
Data "L:english;deutsch"
'
'Announce16
Data "VSWR / power meter;VSWR /Leistngs Messgeraet;forward;vorwaerts;reflected;reflektiert;attenuation forward;Daempfung vorwaerts;"
'
'Announce 17:
Data "attenuation reflected;Daempfung reflektiert;temperature forward;Temperatur  vorwaerts;temperature reflected;Temperatur reflektiert"