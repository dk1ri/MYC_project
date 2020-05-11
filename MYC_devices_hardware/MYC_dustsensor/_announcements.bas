' announcements
' 20200504
'
Announce:
'Befehl &H00
'basic annoumement wird gelesen
'basic announcement is read
Data "0;m;DK1RI;Feinstaubsensor;V01.0;1;50;1;29;1-1"
'
'Announce1:
'Befehl &H01
'liest Konzentration 1.0
'read concentration 1.0
Data "1;an,read mass concentration 1.0;1;w,ug/cbm;770"
'
'Announce2:
'Befehl &H02
'liest Konzentration 2.5
'read concentration 2.5
Data "2;an,read mass concentration 2.5;1;w,ug/cbm;770"
'
'Announce3:
'Befehl &H02
'liest Konzentration 4.0
'read concentration 4.0
Data "3;an,read mass concentration 4.0;1;w,ug/cbm;770"
'
'Announce4:
'Befehl &H04
'liest Konzentration 10
'read concentration 10
Data "4;an,read mass concentration 10;1;w,ug/cbm;770"
'
'Announce5:
'Befehl &H05
'liest Konzentration 0.5
'read concentration 0.5
Data "5;an,read number concentration 0.5;1;w,/cbcm;770"
'
'Announce6:
'Befehl &H06
'liest Konzentration 1.0
'read concentration 1.0
Data "6;an,read number concentration 1.0;1;w,/cbcm;770"
'
'Announce7:
'Befehl &H07
'liest Konzentration 2.5
'read concentration 2.5
Data "7;an,read number concentration 2.5;1;w,/cbcm;770"
'
'Announce8:
'Befehl &H08
'liest Konzentration 4.0
'reed concentration 4.0
Data "8;an,read number concentration 4.0;1;w,/cbcm;770"
'
'Announce9:
'Befehl &H09
'liest Konzentration 10
'read concentration 10
Data "9;an,read number concentration 10;1;w,/cbcm;770"
'
'Announce10:
'Befehl &H0A
'typische Grösse
'typical size
Data "10;an,typical size;1;w,um;770"
'
'Announce11:
'Befehl &H0B
'Messintervall
'measunring time
Data "11;os,measunring time;1;0,3s;1,10s;2,30s;3;1min;4,10min;5,30min;6,60min"
'
'Announce12:
'Befehl &H0C
'Messintervall
'measunring time
Data "12;as,as11"
'
'Announce13:
'Befehl &H0D
'start / beendet Messung
'start /stop measurement
Data "13;os,'start / stop measurement;1;0,off;1,on"
'
'Announce14:
'Befehl &H0E
'Reinigung Intervall
'cleaning interval
Data "14;op,cleaning interval;1;700000,s"
'
'Announce15:
'Befehl &H0F
'Reinigung Intervall
'cleaning time
Data "15;aa,as14"
'
'Announce16:
'Befehl &H10
'startet Reinigung
'start cleaning
Data "16;ou,start cleaning;0,,idle;1,start"
'
'Announce17:
'Befehl &H11
'Product Name
'Product Name
Data "17;aa,Product Name;1,31"
'
'Announce18:
'Befehl &H12
'Version
'Version
Data "18;aa,Version;1,31"
'
'Announce19:
'Befehl &H13
'Serial Number
'Serial Number
Data "19;aa,PSerial Number;1,31"
'
'Announce20:
'Befehl &H14
'alle Originaldaten
'all original data
Data "20;oa,all data;1;50"
'
'Announce21:
'Befehl &H15
'Reset
'reset
Data "21;ot,reset;1;0,idle;1,reset"
'
'Announce22:
'Befehl &H16
'Status Register
'status register
Data "22;aa,status register;1;10"
'
'Announce23:
'Befehl &HF0<n><m>
'liest announcements
'read m announcement lines
Data "240;ln,ANNOUNCEMENTS;145;29"
'
'Announce24:
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;40,last_error"
'
'Announce25:
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
'Data "253;aa,MYC INFO;b,ACTIVE"
'
'Announce26:
'Befehl &HFE <n><data>
'eigene Individualisierung schreiben
'write individualization
Data "254;ka,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,28,{0 to 127};a,SERIAL,1"
'
'Announce27:
'Befehl &HFF <n>
'eigene Individualisierung lesen
'read individualization
Data "255;la,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,28,{0 to 127};a,SERIAL,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1"
'
'Announce28:
Data "R !($1 TO $10) IF ($1 TO $10)&1 > 127"
'