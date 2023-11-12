' annoucements
' 20230722
'
Announce:
'Befehl &H00
'eigenes basic announcement lesen
'basic announcement is read
Data "0;m;DK1RI;QO100_control;V01.0;1;130;1;18;1"
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
Data "3;os,ptt;1;0,off;1,on"
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
Data "5;as,Upconverter temperature;1;120,{1_-20to 99};lin;degC"
'
'Announce6:
'Befehl &H06
'Upconverter Forward
'Upconverter Forward
Data "6;as,Upconverter forward;1,120,{1_0to 199};lin;-"
'
'Announce7:
'Befehl &H07
'Upconverter reverse
'Upconverter reverse
Data "7;as,Upconverter reverse;1,120,{1_0to 199};lin;-"
'
'Announce8:
'Befehl &H08
'Upconverte GPS locked
'Upconverte GPS locked
Data "8;as,Upconverter GPS;1;0,not locked;1,locked"
'
'Announce9
'Befehl &H09
'23cmPA forward
'Kuhne PA reverse
Data "9;ap,13cmPA forward;1;100,{1_0to99};lin;-"
'
'Announce10:
'Befehl &H0A
'PA temperature
'PA temperature
Data "1=;ap,PA temperature;1;1201,{0.1_0to120};lin;degC"
'
'Announce1!:
'Befehl &HF0
'announcement aller Befehle lesen
'read m announcement lines
Data "240;an,ANNOUNCEMENTS;130;18,start at;18,elements;14,CHAPTER,ADMINISTRATION"
'
'Announce12:                                                  '
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
'
'Announce13:                                                  '
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
'Announce14:
'Befehl &HFE :
'eigene Individualisierung schreiben
'write individualization
Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,USB,1;14,CHAPTER,ADMINISTRATION"
'
'Announce15:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,USB,1;14,CHAPTER,ADMINISTRATION"
'

'Announce16:
Data "R $6,$7 If $2=1"
'
Announce17:
Data "R $6,$7 If $4=1"