' announcements
' 20230412
'
Announce:
'Befehl &H00
'basic annoumement wird gelesen
'basic announcement is read
Data "0;m;DK1RI;Feinstaubsensor;V01.1;1;145;1;27;1-1"
'
'Announce1:
'Befehl &H01
'liest Konzentration 1.0
'read concentration 1.0
Data "1;an,read mass concentration 1.0;w,ug/cbm;770,start at;124,to send"  
'
'Announce2:
'Befehl &H02
'liest Konzentration 2.5
'read concentration 2.5
Data "2;an,read mass concentration 2.5;w,ug/cbm;770,start at;124,to send"
'
'Announce3:
'Befehl &H02
'liest Konzentration 4.0
'read concentration 4.0
Data "3;an,read mass concentration 4.0;w,ug/cbm;770,start at;124,to send"
'
'Announce4:
'Befehl &H04
'liest Konzentration 10
'read concentration 10
Data "4;an,read mass concentration 10;w,ug/cbm;770,start at;124,to send"
'Announce5:
'Befehl &H05
'liest Konzentration 0.5
'read concentration 0.5
Data "5;an,read number concentration 0.5;w,/cbcm;770,start at;124,to send"
'
'Announce6:
'Befehl &H06
'liest Konzentration 1.0
'read concentration 1.0
Data "6;an,read number concentration 1.0;w,/cbcm;770,start at;124,to send"
'Announce7:
'Befehl &H07
'liest Konzentration 2.5
'read concentration 2.5
Data "7;an,read number concentration 2.5;w,/cbcm;770,start at;124,to send"
'
'Announce8:
'Befehl &H08
'liest Konzentration 4.0
'reed concentration 4.0
Data "8;an,read number concentration 4.0;w,/cbcm;770,start at;124,to send"
'
'Announce9:
'Befehl &H09
'liest Konzentration 10
'read concentration 10
Data "9;an,read number concentration 10;w,/cbcm;770,start at;124,to send"
'
'Announce10:
'Befehl &H0A
'typische Groese
'typical size
Data "10;an,typical size;w,um;124,to sent;770,start at"
'
'Announce11:
'Befehl &H0B
'Messintervall
'measunring time
Data "11;os,measuring time;1;0,3s;1,10s;2,30s;3,1min;4,10min;5,30min;6,60min"
'
'Announce12:
'Befehl &H0C
'Messintervall
'measunring time
Data "12;as,as11"
'
'Announce13:
'Befehl &H0D
'startet / beendet Messung
'start /stop measurement
Data "13;os,start/stop measurement;1;0,off;1,on"
'
'Announce14:
'Befehl &H0E
'Reinigung Intervall
'cleaning interval
Data "14;op,cleaning interval;1;700000;lin;s"
'
'Announce15:
'Befehl &H0F
'Reinigung Intervall
'cleaning time
Data "15;ap,as14"
'
'Announce16:
'Befehl &H10
'startet Reinigung
'start cleaning
Data "16;ou,start cleaning;0,idle;1,start"
'
'Announce17:
'Befehl &H11
'Product Name
'Product Name
Data "17;aa,Product Name;31"
'
'Announce18:
'Befehl &H12
'Version
'Version
Data "18;aa,version;31"
'
'Announce19:
'Befehl &H13
'Serial Number
'Serial Number
Data "19;aa,serial number;31"
'
'Announce20:
'Befehl &H14
'Reset
'reset
Data "20;ou,reset;1;0,idle;1,reset"
'
'Announce21:
'Befehl &H15
'Status Register
'status register
Data "21;aa,status register;1;10;14,CHAPTER,ADMINISTRATION"
'
'Announce22:
'Befehl &HF0<n><m>
'liest announcements
'read m announcement lines
Data "240;an,ANNOUNCEMENTS;145;27,start at;27;14,CHAPTER,ADMINISTRATION"
'
'Announce23:
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;60,last_error"
'
'Announce24:
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
'Announce25:
'Befehl &HFE <n><data>
'eigene Individualisierung schreiben
'write individualization
Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,28,{1_0to127};a,SERIAL,1;14,CHAPTER,ADMINISTRATION"
'
'Announce26:
'Befehl &HFF <n>
'eigene Individualisierung lesen
'read individualization
Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,28,{1_0to127};a,SERIAL,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;14,CHAPTER,ADMINISTRATION"
'