' announcements
' 20200516
'
Announce:
'Befehl &H00
'basic annoumement wird gelesen
'basic announcement is read
Data "0;m;DK1RI;DTMF_sender;V05.1;1;145;1;13;1-1"
'
'Announce1:
'Befehl &H01
'liest string von I2C oder serial und sendet als DTMF
'read string from I2C or serial and send as DTMF
Data "1;oa,send dtmf;250,{0 to 9,*,#,A to D}"
'
'Announce2:
'Befehl &H02
'DTMF Laenge schreiben
'write DTMF length
Data "2;ka,DTMF Duration;b"
'
'Announce3:
'Befehl &H03
'DTMF Laenge lesen
'read DTMF length
Data "3;la,as2"
'
'Announce4:
'Befehl &H04
'Dtmf Pause schreiben
'write DTMF pause
Data "4;ka,DTMF Pause;b"
'
'Announce5:
'Befehl &H05
'Dtmf Pause lesen
'read DTMF pause
Data "5;la,as4"
'
'Announce6:
'Befehl &H06
'nomyc schreiben
'write nomyc
Data "6;ka,no_myc;a"
'
'Announce7:
'Befehl &H07
'nomyc lesen
'read nomyc
Data "7;la,as6"
'
'Announce8:
'Befehl &HF0<n><m>
'announcement aller Befehle lesen
'read m announcement lines
Data "240;ln,ANNOUNCEMENTS;145;13"
'
'Announce9:                                                  '
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
'
'Announce10:                                                  '
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
'Announce11:
'Befehl &HFE <n> <n>
'Individualisierung schreiben
'write indivdualization
Data "254;ka,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,7,{0 to 127};a,SERIAL,1"
'
'Announce12:
'Befehl &HFF
'Individualisierung lesen
'read indivdualization
Data "255;la,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,7,{0 to 127};a,SERIAL,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1"
'