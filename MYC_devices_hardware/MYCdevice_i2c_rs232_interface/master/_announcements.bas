' announcements
' 20200423
'
Announce:
'Befehl &H00
'basic annoumement wird gelesen
'basic announcement is read
Data "0;m;DK1RI;RS232_I2C_interface Master;V06.1;1;120;1;19;1-1"
'
'Announce1:
'Befehl &H01 <s>
'string an angeschlossenes device schicken, Myc_mode = 0
'write string to device
Data "1;oa;250"
'
'Announce2:
'Befehl &H02
'string von angeschlossenem device lesen, Myc_mode = 0
'read string from device
Data "2;aa,as1"
'
'Announce3:
'Befehl &H03
'übersetzes 0 des slave Myc_mode = 1
'translated 0 of slave
Data "3;m;DK1RI;RS232_I2C_interface Slave;V06.0;1;90;1;8;1-1"
'
'Announce4:
'Befehl &H04 <s>
'übersetzes 1 des slave Myc_mode = 1 I2C nach RS232
'translated 1 of slave I2C to RS232
Data "4,oa;250"
'
'Announce5:
'Befehl &H05
'übersetzes 2 des slave Myc_mode = 1 , RS232 nach I2C
'translated 2 of slave, RS232 to I2C
Data "5,aa,as4"
'
'Announce6:
'Befehl &H67
'übersetzes 252 des slave Myc_mode = 1
'translated 252 of slave,
Data "6;aa,LAST ERROR;20,last_error"
'
'Announce7:
'Befehl &H07
'Uebersetzes 253 des slave Myc_mode = 1
'translated 253 of slave,
Data "7;aa,MYC INFO;b,ACTIVE"
'
'Announce8:
'Befehl &H08 <0..127>
'Adresse zum Senden speichern
'write send adress
Data "8;oa,I2C adress;b,{0 to 127}"                                               '
'
'Announce9:
'Befehl &H09
'Adresse zum Senden lesen
'read send adress
Data "9;aa,as8"
'
'Announce10:
'Befehl &H0A 0|1
'no_myc speichern
'write no_myc
Data "10;oa,no_myc;a"                                               '
'
'Announce11:
'Befehl &H0B
'MYC_mode lesen
'read myc_mode
Data "11;aa,as10"
'
'Announce12:
'Befehl &HF0<n><m>
'liest announcements
'read n announcement lines
Data "240;ln,ANNOUNCEMENTS;120;19"
'
'Announce13:                                                 '
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
 '
'Announce14:                                                 '
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
'Announce15:
'Befehl &HFE <n><data>
'eigene Individualisierung schreiben
'write individualization
Data "254;ka,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,0;b,ADRESS,0,{0 to 127};a,SERIAL,1"
'
'Announce16:
'Befehl &HFF <n> :
'eigene Individualisierung lesen
'read individualization
Data "255;la,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,0;b,ADRESS,0,{0 to 127};a,SERIAL,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1"
'
'Announce17:
Data "R !($1 $2) IF $11=1"
'
#Announce18:
Data "R !($3 $4 $5 $6 $7) IF $11=0"