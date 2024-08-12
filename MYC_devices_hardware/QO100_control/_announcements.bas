' annoucements
' 20240711
'
Announce:
'Befehl &H00
'eigenes basic announcement lesen
'basic announcement is read
Data "0;m;DK1RI;QO100_control;V01.4;1;130;1;32;1"
'
'Announce1:
'Befehl &H01
'NB/WB/DATV_Rx
'NB/WB
Data "1;os,NB/WB;1;0,off;1,NB;2,WB;3,DATV_RX"
'
'Announce2:
'Befehl &H02
'NB/WB
'NB/WB
Data "2;as,as1"
'
'Announce3:
'Befehl &H03
'ptt
'ptt
Data "3;os,PTT;1;0,off;1,on"
'
'Announce4:
'Befehl &H04
'ptt
'ptt
Data "4;as,as3"
'
'Announc5:
'Befehl &H05
'Upconverter Temp
'Upconverter Temp
Data "5;ap,Upconverter temperature;1;80;lin;degC"
'
'Announce6:
'Befehl &H06
'Upconverter Forward
'Upconverter Forward
Data "6;ap,Upconverter forward;1;120,,{1_0to199};lin;-"
'
'Announce7:
'Befehl &H07
'Upconverter reflected
'Upconverter reflected
Data "7;ap,Upconverter reflected;1;120,,{1_0to199};lin;-"
'
'Announce8:
'Befehl &H08
'Upconverte GPS locked
'Upconverte GPS locked
Data "8;as,Upconverter GPS;1;0,not locked;1,locked"
'
'Announce9
'Befehl &H09
'13cmPA forward
'13cmPA forward
Data "9;ap,PA forward;1;100,{1_0to99};lin;-"
'
'Announce10:
'Befehl &H0A
'PA temperature
'PA temperature
Data "10;ap,PA temperature;1;150,;lin;degC"
'
'Announce11:
'Befehl &H0B
'R
'R
Data "11;ap,R;1;1024;lin;-;8,CHAPTER,addition"
'
'Announce12:
'Befehl &H0C
'F
'F
Data "12;ap,F;1;1024;lin;-;8,CHAPTER,addition"
'
'Announce13:
'Befehl &H0D
'T
'T
Data "13;as,T;1;0,off;1,on;8,CHAPTER,addition"
'
'Announce14:
'Befehl &H0E
'K_err
'K_err
Data "14;as,K_err;1;0,off;1,on;8,CHAPTER,addition"
'
'Announce15:
'Befehl &H0F
'SWR
'SWR
Data "15;ap,SWR;1;1024;lin;-;8,CHAPTER,addition"
'
'Announce16:
'Befehl &H10
'PA1
'PA1
Data "16;as,PA1;1;0,off;1,on;8,CHAPTER,addition"
'
'Announce17:
'Befehl &H11
'PA2_1
'PA2_1
Data "17;as,PA2_1;1;0,off;1,on;8,CHAPTER,addition"
'
'Announce18:
'Befehl &H12
'PA2_2
'PA2_2
Data "18;as,PA1_2;1;0,off;1,on;8,CHAPTER,addition"
'
'Announce19:
'Befehl &H13
'Abschalttemperatur
'switch off temperature
Data "19;op,switch off temperature;1;71,{1_30to100};lin;degC"
'
'Announce20:
'Befehl &H14
'Abschalttemperatur
'switch off temperature
Data "20;ap,as19"
'
'Announce21:
'Befehl &H15
'Uebertemperatur
'Over temperature
Data "21;as,over temperature;1;0,ok;1,too high"
'
'Announce21:
'Befehl &HF0
'announcement aller Befehle lesen
'read m announcement lines
Data "240;an,ANNOUNCEMENTS;130;32,start at;32,elements;14,CHAPTER,ADMINISTRATION"
'
'Announce22:                                                  '
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
'
'Announce23:                                                  '
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
'Announce24:
'Befehl &HFE :
'eigene Individualisierung schreiben
'write individualization
Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,USB,1;14,CHAPTER,ADMINISTRATION"
'
'Announce25:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,USB,1;14,CHAPTER,ADMINISTRATION"
'
 'Announce26;
Data "L;original;english;deutsch"
'
'Announce27;
Data "L;QO100_control;QO100_control;QO100 Steuerung;Upconverter temperature;Upconverter temperature;Upconverter Temperatur;"

'Announce28:
Data "L;PA temperature;PA temperature;PA Temperatur"
'Announce22:
Data "R ?$6,$7 IF $4=1 AND $2=0"
'
'Announce29:
Data "R ?$9 IF $4=1 AND $2=1"
'
'Announce30:
Data "R ?$5 IF $2=1"
'
Announce31:
Data "R ?$9 IF $2=2"