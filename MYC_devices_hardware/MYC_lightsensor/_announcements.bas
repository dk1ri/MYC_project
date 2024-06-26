' annoucements
' 20240624
'
Announce:
'Befehl &H00
'basic annoumement wird gelesen
'basic announcement is read
Data "0;m;DK1RI;6 chanal lightsensor;V01.0;1;145;1;32;1-1"
'
'Announce1:
'Befehl &H01
'liest alle Farben
'read all colors
Data "1;aa,raw data all colors;36"
'
'Announce2:
'Befehl &H02
'liest Violet
'read Violet
Data "2;ap,violet;1;65535;lin;uW/squarecm"
'
'Announce3:
'Befehl &H03
'liest blau
'read   blue
Data "3;ap,blue;1;65535;lin;uW/squarecm"
'
'Announce4:
'Befehl &H04
'liest gruen
'read   green
Data "4;ap,green;1;65535;lin;uW/squarecm"
'
'Announce5:
'Befehl &H05
'liest gelb
'read   yellow
Data "5;ap,yellow;1;65535;lin;uW/squarecm"
'
'Announce6:
'Befehl &H06
'liest orange
'read   orange
Data "6;ap,orange;1;65535;lin;uW/squarecm"
'
'Announce7:
'Befehl &H07
'liest rot
'read   red
Data "7;ap,red;1;65535;lin;uW/squarecm"
'
'Announce8:
'Befehl &H08
'Status
'Status
Data "8;aa,status;b;13,CHAPTER,configuration"
'
'Announc9:
'Befehl &H09
'control register
'control register
Data "9;aa,mode;b;13,CHAPTER,configuration"
'
'Announce10:
'Befehl &H0A
'Bank
'bank
Data "10;os,bank;1;0,0;1,1;2,2;3,3;13,CHAPTER,configuration"
'
'Announce11:
'Befehl &H0B
'Bank
'bank
Data "11;as,as10"
'
'Announce12:
'Befehl &H0C
'HWID
'hwid
Data "12;aa,HW version;10;13,CHAPTER,configuration"
'
'Announce13:
'Befehl &H0D
'FWversion
'FWversion
Data "13;aa,FW version;12;13,CHAPTER,configuration"
'
'Announce14:
'Befehl &H0E
'Integrationszeit
'integration time
Data "14;op,integration time;1;586,,1_1to586;lin;ms;13,CHAPTER,configuration"
'
'Announce15:
'Befehl &H0F
'Integrationszeit
'integration time
Data "15;ap,as14"
'
'Announce16:
'Befehl &H10
'Temperatur
'temperature
Data "16;ap,temperature;1;100,;lin;degC"
'
'Announce17:
'Befehl &H11
'LED Strom
'LED current
Data "17;os,LED current mA;1;0,0,1,12.5;2,25;3,50;4,100"
'
'Announce18:
'Befehl &H12
'LED Strom
'LED current
Data "18;as,as17"
'
'Announce19:
'Befehl &H13
'LED ind Strom
'LED ind current
Data "19;os,LED ind current mA;1;0,0;1,1;2,2,3,4;4,8"
'
'Announce20:
'Befehl &H14
'LED ind Strom
'LED ind current
Data "20;as,as19"
'
'Announce21:
'Befehl &H15
'Verstarkung
'gain
Data "21;os,gain;1;0,1;1,2.7;2,16;3,64;13,CHAPTER,configuration"
'
'Announce22:
'Befehl &H16
'Verstarkung
'gain
Data "22;as,as21"
'
'Announce23:
'Befehl &HF0
'announcement aller Befehle lesen
'read announcement lines
Data "240;an,ANNOUNCEMENTS;100;32,start;32,elements;14,CHAPTER,ADMINISTRATION"
'
'Announce24:                                                  '
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
'
'Announce25:                                                  '
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
'Announce26:
'Befehl &HFE :
'eigene Individualisierung schreiben
'write individualization
Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,RS232,1;a,USB,1;14,CHAPTER,ADMINISTRATION"
'
'Announce27:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,RS232,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;a,USB,17;14,CHAPTER,ADMINISTRATION"
'
'Announce28:
Data "L;language name;english;deutsch"
'
'Announce29:
Data "L;6 chanal lightsensor;6 chanal lightsensor;6 Kanal Lichtsensor;raw data all colors;raw data all colors;Originaldaten alle Farben;"
'
'Announce30:
Data "L;blue;blue;blau;green;green;gruen;yellow;yellow;gelb;red;red;rot;integration time;integration time;Integrations Zeit;"
'
'Announce31:
Data "temperature;temperature;Temperatur;LED current mA;LED current mA;LED Strom mA;LED ind current mA;LED ind current mA;LED ind Strom mA;gain;gain;Verstaerkung"