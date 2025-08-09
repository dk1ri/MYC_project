' announcements
' 2024041220
'
Announce:
'Befehl &H00
'basic annoumement wird gelesen
'basic announcement is read
Data "0;m;DK1RI;V I sensor;V01.0;1;145;1;24;1-1"
'
'Announce1:
'Befehl &H01
'liest Spannung
'read voltage
Data "1;ap,shunt voltage;1;60001,,{0.1_-3000.0to3000.0};lin;mV"
'
'Announce2:
'Befehl &H02
'liest Spannung
'read voltage
Data "2;ap,bus voltage;1;25001,,{1_0to25000};lin;mV"
'
'Announce3:
'Befehl &H03
'liest Strom
'read currect
Data "3;ap,current;1;60000,,{0.1_-3000.0to3000.0};lin;mA"
'
'Announce4:
'Befehl &H04
'liest Leistung
'read power
Data "4;ap,power;1;30001,;lin;mW"
'
'Announce5:
'Befehl &H05
'liest Leistung
'read power
Data "5;ap,power;1;7500000,,{0.01_0to75000.00};lin;mW"
'
'Announce6:
'register
'register
Data "6;oa,INA calibration register;w"

'Announce7:
'register
'register
Data "7;aa,as6"
'
'Announce8:
'Befehl &H08
'Radi type
'Radio Type
Data "8;os,radio type;1;0,RFM95 900;1,RFM95 450; 2,RFM95 150;3,nRF24;4,WLAN;5,RYFA689;14,CHAPTER,ADMINISTRATION"
':
'Befehl &H09
'Radi type
'Radio Type
Data "9;as,as8;14,CHAPTER,ADMINISTRATION"
'
'Announce10:
'Befehl &H09A
'Radio Name
'radio name
Data "10;oa,radio name;5,,radi;14,CHAPTER,ADMINISTRATION"  "
'
'Announce11:
'Befehl &H0b
'Radio Name
'radio name
Data "11;aa,as10;14,CHAPTER,ADMINISTRATION"
'
'Announce12:
'Frequenz 137 175MHz
'frequency
Data "12;op,frequency;1;612903,,{62_137000000to175000000};lin;Hz;14,CHAPTER,ADMINISTRATION"

'
'Announce13:
'Frequenz 137 175MHz
'frequency
Data "13;ap,as12"
'
'Announce14:
'Frequenz 410 525MHz
'frequency
Data "14;op,frequency;1;1854838,{62_410000000to525000000};lin;Hz;14,CHAPTER,ADMINISTRATION"
'
'Announce15:
'Frequenz 410 525MHz
'frequency
Data "15;ap,as14"
'
'Announce16:
'Frequenz 862 1020MHz
'frequency
Data "16;op,frequency;1;1019999,{62_820000000to1020000000};lin;Hz;14,CHAPTER,ADMINISTRATION"
'
'Announce17:
'Frequenz 862 1020MHz
'frequency
Data "17;ap,as16"
'
'Announce18:
'Befehl &HF0
'liest announcements
'read m announcement lines
Data "240;an,ANNOUNCEMENTS;145;24,start at;24,elements;14,CHAPTER,ADMINISTRATION"
'
'Announce19:
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;60,last_error"
'
'Announce20:
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
'Announce21:
'Befehl &HFE :
'eigene Individualisierung schreiben
'write individualization
Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,RS232,1;a,USB,1;a,wireless,0;14,CHAPTER,ADMINISTRATION"
'
'Announce22:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,RS232,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;a,USB,1;a,wireless,0;14,CHAPTER,ADMINISTRATION"
'
'Announce23:
Data "R;!$7 !$8 !$9 !10 !$11 !$12 !$13 !$14 !$14 !$15 !$16 IF $175=1"