' announcements
' 20230712
'
Announce:
'Befehl &H00
'eigenes basic announcement lesen
'basic announcement is read to I2C or output
Data "0;m;DK1RI;Infrared (RC5) receiver;V07.0;1;170;1;11;1-1"
'
'Announce1:
'Befehl  &H01
'kopiert RC5 Daten in den Ausgang
'copies RC5 data to output
Data "1;aa,RC5 buffer;80"
'
'Announce2:
'Befehl &H02   0-31
'RC5 Adresse schreiben
'write RC5 adress
Data "2;op,rc5adress;1;32,;lin;-"
'
'Announce3:
'Befehl &H03
'RC5 Adresse lesen
'read RC5 adress
Data "3;ap,as2"
'
'Announce4:
'Befehl  &H04
'schaltet MYC / no_MYC mode
'switches MYC / no_MYC mode
Data "4;os,myc;1;0,MYC;1,no MYC"
'
'Announce5:
'Befehl  &H05
'liest MYC / no_MYC mode
'read MYC / no_MYC mode
Data "5;as,as4"
'
'Announce6:
'Befehl &HF0<n><m>
'announcement aller Befehle lesen
'read m announcement lines
Data "240;an,ANNOUNCEMENTS;170;11,start at;11,lines;14,CHAPTER,ADMINISTRATION"
'
'Announce7:
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
'
'Announce8:
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
'Announce9:
'Befehl &HFE :
'eigene Individualisierung schreiben
'write individualization
Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,6,{0 to 127};a,SERIAL,1;14,CHAPTER,ADMINISTRATION"
'
'Announce10:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,6,{0 to 127};a,SERIAL,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;14,CHAPTER,ADMINISTRATION"
'