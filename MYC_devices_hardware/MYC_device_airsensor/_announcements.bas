' annoucements
' 20231016
'
Announce:
'Befehl &H00
'basic annoumement wird gelesen
'basic announcement is read
Data "0;m;DK1RI;Airsensor;V01.0;1;145;1;18;1-1"
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
'Mode
'mode
Data "4;aa,mode;b;13,CHAPTER,configuration"
'
'Announce5:
'Befehl &H05
'Baseline
'baseline
Data "5;aa,baseline;w;13,CHAPTER,configuration"
'
'Announce6:
'Befehl &H06
'HWID
'hwid
Data "6;aa,hwid;b;13,CHAPTER,configuration"
'
'Announce7:
'Befehl &H07
'HWversion
'hwversion
Data "7;aa,hwversion;b;13,CHAPTER,configuration"
'
'Announce8:
'Befehl &H08
'Bootversion
'Bootversion
Data "8;aa,bootversion;w;13,CHAPTER,configuration"
'
'Announce9:
'Befehl &H09
'Appversion
'appversion
Data "9;aa,appversion;w;13,CHAPTER,configuration"
'
'Announce10:
'Befehl &H0A
'internal state
'internal state
Data "10;aa,internal state;b;13,CHAPTER,configuration"
'
'Announce11:
'Befehl &H0B
'error
'error
Data "11;aa,last error;b;13,CHAPTER,configuration"
'
'Announce12:
'Befehl &H0C
'raw data
'raw data
Data "12;aa,raw data;w;13,CHAPTER,configuration"
'
'Announce13:
'Befehl &H0D
'mode
'mode
Data "13;os,mode;1;0,idle;1,1s;2,20s;3,60s;13,CHAPTER,configuration"
'
'Announce13:
'Befehl &HF0
'announcement aller Befehle lesen
'read announcement lines
Data "240;an,ANNOUNCEMENTS;100;18,start;8,elements;14.CHAPTER,ADMINISTRATION"
'
'Announce14:                                                  '
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
'
'Announce15:                                                  '
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
'Announce16:
'Befehl &HFE :
'eigene Individualisierung schreiben
'write individualization
Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,RS232,1;a,USB,1;14.CHAPTER,ADMINISTRATION"
'
'Announce17:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,RS232,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;a,USB,17;14.CHAPTER,ADMINISTRATION"
'