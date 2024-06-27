' announcements
' 2024040627
'
Announce:
'Befehl &H00
'basic annoumement wird gelesen
'basic announcement is read
Data "0;m;DK1RI;dust sensor;V03.4;1;145;1;46;1-1"
'
'Announce1:
'Befehl &H01
'liest Konzentration 1.0
'read concentration 1.0
Data "1;aa,mass concentration 1.0;w,ug/cbm;w,METER,5000"
'
'Announce2:
'Befehl &H02
'liest Konzentration 1.0
'read concentration 1.0
Data "2;an,mass concentration 1.0;w,ug/cbm;700,start at,{10,MUL100,};124,to send"
'
'Announce3:
'Befehl &H03
'liest Konzentration 2.5
'read concentration 2.5
Data "3;aa,mass concentration 2.5;w,ug/cbm;w,METER,5000"
'
'Announce4:
'Befehl &H04
'liest Konzentration 2.5
'read concentration 2.5
Data "4;an,mass concentration 2.5;w,ug/cbm;700,start at,{10,MUL100,};124,to send"
'
Announce5:
'Befehl &H05
'liest Konzentration 4.0
'read concentration 4.0
Data "5;aa,mass concentration 4.0;w,ug/cbm;w,METER,5000"
'
'Announce6:
'Befehl &H06
'liest Konzentration 4.0
'read concentration 4.0
Data "6;an,mass concentration 4.0;w,ug/cbm;700,start at,{10,MUL100,};124,to send"
'
'Announce7:
'Befehl &H07
'liest Konzentration 10
'read concentration 10
Data "7;aa,mass concentration 10;w,ug/cbm;w,METER,5000"
'
'Announce8:
'Befehl &H08
'liest Konzentration 10
'read concentration 10
Data "8;an,mass concentration 10;w,ug/cbm;700,start at,{10,MUL100,};124,to send"
'
'Announce9:
'Befehl &H09
'liest Konzentration 0.5
'read concentration 0.5
Data "9;aa,number concentration 0.5;w,ug/cbm;w,METER,5000"
'
'Announce10:
'Befehl &H0A
'liest Konzentration 0.5
'read concentration 0.5
Data "10;an,number concentration 0.5;w,/cbm;700,start at,{10,MUL100,};124,to send"
'
'Announce11:
'Befehl &H0B
'liest Konzentration 1.0
'read concentration 1.0
Data "11;aa,number concentration 1.0;w,ug/cbm;w,METER,5000"
'
'Announce12:
'Befehl &H0C
'liest Konzentration 1.0
'read concentration 1.0
Data "12;an,number concentration 1.0;w,/cbm;700,start at,{10,MUL100,};124,to send"

'Announce13:
'Befehl &H0D
'liest Konzentration 2.5
'read concentration 2.5
Data "13;aa,number concentration 2.5;w,ug/cbm;w,METER,5000"
'
'Announce14:
'Befehl &H0E
'liest Konzentration 2.5
'read concentration 2.5
Data "14;an,number concentration 2.5;w,/cbm;700,start at,{10,MUL100,};124,to send"
'
'Announce15:
'Befehl &H0F
'liest Konzentration 4.0
'read concentration 4.0
Data "15;aa,number concentration 4.0;w,ug/cbm;w,METER,5000"
'
'Announce16:
'Befehl &H10
'liest Konzentration 4.0
'read concentration 4.0
Data "16;an,number concentration 4.0;w,/cbm;700,start at,{10,MUL100,};124,to send"
'
'Announce17:
'Befehl &H11
'liest Konzentration 10.0
'read concentration 10.0
Data "17;aa,number concentration 10.0;w,ug/cbm;w,METER,5000"
'
'Announce18:
'Befehl &H12
'liest Konzentration 10
'read concentration 10
Data "18;an,number concentration 10;w,/cbm;700,start at,{10,MUL100,};124,to send"
'
'Announce19:
'Befehl &H13
'typische Groese
'typical size
Data "19;aa,typical size;w,um;w,METER,5000"
'
'Announce20:
'Befehl &H14
'typische Groese
'typical size
Data "20;an,typical size;w,um;700,start at,{10,MUL100,};124,to send"
'
'Announce21:
'Befehl &H15
'memorypointer
'memorypointer
Data "21;aa,memorypointer;w"
'
'Announce22:
'Befehl &H16
'startet / beendet Messung
'start /stop measurement
Data "22;os,stop/start measurement;1;0,off;1,on"
'
'Announce23:
'Befehl &H17
'Messintervall
'measunring time
Data "23;os,measuring time;1;0,3s;1,10s;2,30s;3,1min;4,10min;5,30min;6,60min"
'
'Announce24:
'Befehl &H18
'Messintervall
'measunring time
Data "24;as,as23"
'
'Announce25:
'Befehl &H19
'Reinigung Intervall
'cleaning interval
Data "25;op,cleaning interval;1;700000;lin;s"
'
'Announce26:
'Befehl &H1A
'Reinigung Intervall
'cleaning time
Data "26;ap,as25"
'
'Announce27:
'Befehl &H1B
'startet Reinigung
'start cleaning
Data "27;ou,start cleaning;1;0,idle;1,start"
'
'Announce28:
'Befehl &H1C
'Product Typ
'Product type
Data "28;aa,product type;31"
'
'Announce29:
'Befehl &H1D
'Serial Number
'Serial Number
Data "29;aa,serial number;31"
'
'Announce30:
'Befehl &H1E
'Version
'version
Data "30;aa,version;31"
'
'Announce31:
'Befehl &H1F
'Reset
'reset
Data "31;ou,reset;1;0,idle;1,reset"
'
'Announce32:
'Befehl &H20
'Status Register
'status register
Data "32;aa,status register;20;14,CHAPTER,ADMINISTRATION"
'
'Announce33:
'Befehl &HF0
'liest announcements
'read m announcement lines
Data "240;an,ANNOUNCEMENTS;145;46,start at;46,elements;14,CHAPTER,ADMINISTRATION"
'
'Announce34:
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;60,last_error"
'
'Announce35:
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
'Announce36:
'Befehl &HFE <n><data>
'eigene Individualisierung schreiben
'write individualization
Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,28,{1_0to127};a,SERIAL,1;14,CHAPTER,ADMINISTRATION"
'
'Announce37:
'Befehl &HFF <n>
'eigene Individualisierung lesen
'read individualization
Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,28,{1_0to127};a,SERIAL,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;14,CHAPTER,ADMINISTRATION"
'
'Announce38;
Data "L;original;english;deutsch"
'
'Announce39;
Data "L;dust sensor;dust sensor;Feinstaubsensor;mass concentration 1.0;mass concentration 1.0;Masse Konzentration 1.0;mass concentration 2.5;mass concentration 2.5;Masse Konzentration 2.5;"
'
'Announce40
Data "L;mass concentration 4.0;mass concentration 4.0;Masse Konzentration 4.0;mass concentration 10;mass concentration 10;Masse Konzentration 10;"
'
'Announce41:
Data "L;number concentration 0.5;number concentration 0.5;Teilchenzahl 0.5;number concentration 1.0;number concentration 1.0;Teilchenzahl 1.0;"
'
'Announce42:
Data "L;number concentration 2.5;number concentration 2.5;Teilchenzahl 2.5;number concentration 4.0;number concentration 4.0;Teilchenzahl 4.0;"
'
'Announce43:
Data "L;number concentration 10;number concentration 10;Teilchenzahl 10;typical size;typical size;typische Groesse;memorypointer;memorypointer;Speicherzeiger;"
'
'Announce44:
Data "L;stop/start measurement;stop/start measurement;Messung stop/start;measuring time;measuring time;Messzeit;cleaning interval;cleaning interval;Reinigungsintervall;"
'
'Announce45
Data "L;start cleaning;start cleaning;startet Reinigung;product type;product type;Typ;serial number;serial number;Seriennummer;version;version; Version;"