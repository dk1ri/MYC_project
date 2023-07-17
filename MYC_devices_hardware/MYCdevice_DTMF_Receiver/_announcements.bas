' announcements
' 20230715
'
Announce:
'Befehl &H00
'eigenes basic announcement lesen
'basic announcement is read to I2C or output
Data "0;m;DK1RI;DTMF receiver;V07.0;1;175;1;9;1-1"
'
'Befehl  &H01
'liest den DTMF-Speicher
'read DTMF buffer
Data "1;aa,DTMF buffer;25"
'
'Befehl  &HEE
'schaltet MYC / no_MYC mode
'switches MYC / no_MYC mode
Data "2;os,no_myc;1;0,MYC;1,no MYC"
'
'Befehl  &HEF
'liest MYC / no_MYC mode
'read MYC / no_MYC mode
Data "3;as,as2"
'
'Befehl &HF0<n><m>
'liest announcements
'read m announcement lines
Data "240;an,ANNOUNCEMENTS;175;9,start at;9,elements;14;CHAPTER,ADMINISTRATION"
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
Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,16,{0 to 127};a,SERIAL,1;14;CHAPTER,ADMINISTRATION"
'
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,16,{0 to 127};a,SERIAL,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;14;CHAPTER,ADMINISTRATION"