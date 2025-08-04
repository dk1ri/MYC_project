' annoucements
' 20231016
'
Announce:
'Befehl &H00
'basic annoumement wird gelesen
'basic announcement is read
Data "0;m;DK1RI;Airsensor;V01.0;1;145;1;32;1-1"
'
'Announce1:
'Befehl &H01
'liest CO2
'read CO2
Data "1;ap,CO2;1;31363;lin;ppm"
'
'Announce2:
'Befehl &H02
'TVOC
'TVOC
Data "2;ap,TVOC;1;29207;lin;ppm"
'
'Announce3:
'Befehl &H03
'Status
'Status
Data "3;aa,status;b;13,CHAPTER,configuration"
'
'Announce4:
'Befehl &H04
'Baseline
'baseline
Data "4;aa,baseline;w;13,CHAPTER,configuration"
'
'Announce5:
'Befehl &H05
'HWID
'hwid
Data "5;aa,hwid;b;13,CHAPTER,configuration"
'
'Announce6:
'Befehl &H06
'HWversion
'hwversion
Data "6;aa,hwversion;b;13,CHAPTER,configuration"
'
'Announce7:
'Befehl &H07
'Bootversion
'Bootversion
Data "7;aa,bootversion;w;13,CHAPTER,configuration"
'
'Announce8:
'Befehl &H08
'Appversion
'appversion
Data "8;aa,appversion;w;13,CHAPTER,configuration"
'
'Announce9:
'Befehl &H09
'internal state
'internal state
Data "9;aa,internal state;b;13,CHAPTER,configuration"
'
'Announce10:
'Befehl &H0A
'error
'error
Data "10;aa,last error;b;13,CHAPTER,configuration"
'
'Announce11:
'Befehl &H0B
'raw data
'raw data
Data "11;aa,raw data;w"
'
'Announce12:
'Befehl &H0C
'mode
'mode
Data "12;os,mode;1;0,idle;1,1s;2,20s;3,60s;14,CHAPTER,ADMINISTRATION"
'
'Announce13
'Befehl &H0D
'mode
'mode
Data "13;as,as12"
'
'Announce14:
'Befehl &H0E
'Radi type
'Radio Type
Data "14;os,radio type;1;0,RFM95 900;1,RFM95 450; 2,RFM95 150;3,nRF24;4,WLAN;5,RYFA689;14,CHAPTER,ADMINISTRATION"
'
'Announce15:
'Befehl &H0F
'Radi type
'Radio Type
Data "15;as,as14"
'
'Announce16:
'Befehl &H10
'Radio Name
'radio name
Data "16;oa,radio name;5,,radi;14,CHAPTER,ADMINISTRATION"  "
'
'Announce17:
'Befehl &H11
'Radio Name
'radio name
Data "17;aa,as16"
'
'Announce18:
'Frequenz 137 175MHz
'frequency
Data "18;op,frequency;1;612903,,{62_137000000to175000000};lin;Hz;14,CHAPTER,ADMINISTRATION"

'
'Announce19:
'Frequenz 137 175MHz
'frequency
Data "19;ap,as18"
'
'Announce20:
'Frequenz 410 525MHz
'frequency
Data "20;op,frequency;1;1854838,{62_410000000to525000000};lin;Hz;14,CHAPTER,ADMINISTRATION"
'
'Announce21:
'Frequenz 410 525MHz
'frequency
Data "21;ap,as20"
'
'Announce22:
'Frequenz 862 1020MHz
'frequency
Data "22;op,frequency;1;1019999,{62_820000000to1020000000};lin;Hz;14,CHAPTER,ADMINISTRATION"

'
'Announce23:
'Frequenz 862 1020MHz
'frequency
Data "23;ap,as22"
'
'Announce24:
'Befehl &HF0
'announcement aller Befehle lesen
'read announcement lines
Data "240;an,ANNOUNCEMENTS;100;31,start;31,elements;14,CHAPTER,ADMINISTRATION"
'
'Announce25:                                                  '
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
'
'Announce26:                                                  '
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
'Announce27:
'Befehl &HFE :
'eigene Individualisierung schreiben
Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,RS232,1;a,USB,1;a,wireless,0;14,CHAPTER,ADMINISTRATION"

'Announce28:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,RS232,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;a,USB,1;a,wireless,0;14,CHAPTER,ADMINISTRATION"
'
'Announce29:
Data "L;language name;english;deutsch"
'
'Announce30:
Data "L;Airsensor;Airsensor;Luftsensor"