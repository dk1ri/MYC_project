' announcements
' 20230715
'
Announce:
'Befehl &H00
'eigenes basic announcement lesen
'basic announcement is read to I2C or output
Data "0;m;DK1RI;DTMF_transceiver;V07.0;1;175;1;10;1-1"
'
'Befehl  &H01
'liest den DTMF-Lesespeicher
'read the read DTMF buffer
Data "1;aa,DTMF buffer;80"
'
'Befehl  &H02
'gibt DTMF Signal aus
'send DTMF tones
Data "2;oa,send dtmf;252"
'
'Befehl  &H03
'schaltet MYC / no_MYC mode
'switches MYC / no_MYC mode
Data "3;os,no_myc;1;0,MYC;1,no MYC"
'
'Befehl  &H04
'liest MYC / no_MYC mode
'read MYC / no_MYC mode
Data "4;as,as3"
':
'Befehl &HF0
'liest announcements
'read m announcement lines
Data "240;an,ANNOUNCEMENTS;175;10,start at;10,elements;14,CHAPTER,ADINISTRATION"
'
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
'
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
'Befehl &HFE :
'eigene Individualisierung schreiben
'write individualization
Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,17,{0 to 127};a,SERIAL,1;14,CHAPTER,ADINISTRATION"
'
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,17,{0 to 127};a,SERIAL,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;14,CHAPTER,ADINISTRATION"
'