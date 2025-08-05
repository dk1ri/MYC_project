' announcements
' 20250503
'
Announce:
'Befehl &H00
'basic annoumement wird gelesen
'basic announcement is read
Data "0;m;DK1RI;50Hz sensor;V01.0;1;145;1;23;1-1"
'
'Announce1:
'Befehl &H01
'liest Frequenz
'read frequency
Data "1;ap,frequency;1;6001,,{1_47000to53000};lin;mHz"
'
'
'Announce2:
'Befehl &H02
'liest Frequenz
'read frequency
Data "2;ap,min;1;6001,,{1_47000to53000};lin;mHz"
'
'
'Announce3:
'Befehl &H03
'liest Frequenz
'read frequency
Data "3;ap,max;1;6001,,{1_47000to53000};lin;mHz"
'
'Announce4:
'Befehl &H04
'liest Mittelwert
'read mean
Data "4;ap,mean;1;6001,,{1_47000to53000};lin;mHz"
'
'Announce5:
'Befehl &H04
'reset
'reset
Data "5;ou,reset;1;0,idle; 1,reset"
'
'Announce6:
'Befehl &H06
'Radi type      7    7
'Radio Type
Data "6;os,radio type;1;0,RFM95 900;1,RFM95 450; 2,RFM95 150;3,nRF24;4,WLAN;5,RYFA689;14,CHAPTER,ADMINISTRATION"
'
'Announce7:
'Befehl &H07
'Radi type
'Radio Type
Data "7;as,as6;14,CHAPTER,ADMINISTRATION"  "
'
'Announce8:
'Befehl &H08
'Radio Name
'radio name
Data "8;oa,radio name;5,,radi;14,CHAPTER,ADMINISTRATION"  "
'
'Announce9:
'Befehl &H09
'Radio Name
'radio name
Data "9;aa,as8;14,CHAPTER,ADMINISTRATION"
'
'Announce10:
'Frequenz 137 175MHz
'frequency
Data "10;op,frequency;1;612903,,{62_137000000to175000000};lin;Hz;14,CHAPTER,ADMINISTRATION"

'
'Announce11:
'Frequenz 137 175MHz
'frequency
Data "11;ap,as10"
'
'Announce12:
'Frequenz 410 525MHz
'frequency
Data "12;op,frequency;1;1854838,{62_410000000to525000000};lin;Hz;14,CHAPTER,ADMINISTRATION"

'
'Announce13:
'Frequenz 410 525MHz
'frequency
Data "13;ap,as12"
'
'Announce14:
'Frequenz 862 1020MHz
'frequency
Data "14;op,frequency;1;1019999,{62_820000000to1020000000};lin;Hz;14,CHAPTER,ADMINISTRATION"

'
'Announce15:
'Frequenz 862 1020MHz
'frequency
Data "15;ap,as14"
'
'Announce16:
'Befehl &HF0
'liest announcements
'read m announcement lines
Data "240;an,ANNOUNCEMENTS;145;22,start at;22,elements;14,CHAPTER,ADMINISTRATION"
'
'Announce17:
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;60,last_error"
'
'Announce18:
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
'Announce19:
'Befehl &HFE :
'eigene Individualisierung schreiben
'write individualization
Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,RS232,1;a,USB,1;a,wireless,0;a,I2Cactiv,1;b,I2caddress,41;14,CHAPTER,ADMINISTRATION"
'
'Announce20:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,RS232,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;a,USB,1;a,wireless,0;a,I2Cactiv,1;b,I2caddress,41;14,CHAPTER,ADMINISTRATION"
'
'Announce21:
Data "R;!4 !$5 !$6 !$7 !$8 !$9 !$10 !$11 !$12 !$12 IF $14=1"