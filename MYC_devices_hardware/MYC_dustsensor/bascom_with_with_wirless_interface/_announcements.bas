' announcements
' 20250730
'
Announce:
'Befehl &H00
'basic annoumement wird gelesen
'basic announcement is read
Data "0;m;DK1RI;dust sensor with radio interface;V01.0;1;145;1;36;1-1"
'
'Announce1:
'Befehl &H01
'liest Konzentration 1.0
'read concentration 1.0
Data "1;an,mass concentration 1.0 ug/cbm;w;700,start at (0-770);124,to send 0: actual value"
'
'Announce2:
'Befehl &H02
'liest Konzentration 2.5
'read concentration 2.5
Data "2;an,mass concentration 2.5 ug/cbm;w;700,start at (0-770);124,to send 0: actual value"
'
'Announce3:
'Befehl &H03
'liest Konzentration 4.0
'read concentration 4.0
Data "3;an,mass concentration 4.0 ug/cbm;w;700,start at (0-770);124,to send 0: actual value"
'
'Announce4:
'Befehl &H04
'liest Konzentration 10
'read concentration 10
Data "4;an,mass concentration 10 ug/cbm;w;700,start at (0-770);124,to send 0: actual value"
'Announce5:
'Befehl &H05
'liest Konzentration 0.5
'read concentration 0.5
Data "5;an,number concentration 0.5 /cbm;w;700,start at (0-770);124,to send 0: actual value"
'
'Announce16:
'Befehl &H06
'liest Konzentration 1.0
'read concentration 1.0
Data "6;an,number concentration 1.0 /cbm;w;700,start at (0-770);124,to send 0: actual value"
'
'Announce7:
'Befehl &H07
'liest Konzentration 2.5
'read concentration 2.5
Data "7;an,number concentration 2.5 /cbm;w;700,start at (0-770);124,to send 0: actual value"
'
'Announce8:
'Befehl &H08
'liest Konzentration 4.0
'read concentration 4.0
Data "8;an,number concentration 4.0 /cbm;w;700,start at (0-770);124,to send 0: actual value"
'
'Announce9:
'Befehl &H09
'liest Konzentration 10
'read concentration 10
Data "9;an,number concentration 10 /cbm;w;700,start at (0-770);124,to send 0: actual value"
'
'Announce10:
'Befehl &H0A
'typische Groese
'typical size
Data "10;an,typical size um;w;700,start at (0-770);124,to send 0: actual value"       
'
'Announce11:
'Befehl &0B
'memorypointer
'memorypointer
Data "11;aa,memorypointer;w"
'
'Announce12:
'Befehl &H0C
'startet / beendet Messung
'start /stop measurement
Data "12;os,stop/start measurement;1;0,off;1,on"
'
'Announce13:
'Befehl &H0D
'Messintervall
'measunring time
Data "13;os,measuring time;1;0,3s;1,10s;2,30s;3,1min;4,10min;5,30min;6,60min"
'
'Announce14:
'Befehl &H0E
'Messintervall
'measunring time
Data "14;as,as13"
'
'Announce15:
'Befehl &H0F
'Reinigung Intervall
'cleaning interval
Data "15;op,cleaning interval;1;700000;lin;s"
'
'Announce16:
'Befehl &H10
'Reinigung Intervall
'cleaning time
Data "16;ap,as15"
'
'Announce17:
'Befehl &H11
'startet Reinigung
'start cleaning
Data "17;ou,start cleaning;1;0,idle;1,start"
'
'Announce18:
'Befehl &H12
'Product Typ
'Product type
Data "18;aa,product type;31;14,CHAPTER,ADMINISTRATION"
'
'Announce19:
'Befehl &H13
'Serial Number
'Serial Number
Data "19;aa,serial number;31;14,CHAPTER,ADMINISTRATION"
'
'Announce20:
'Befehl &H14
'Version
'version
Data "20;aa,version;31;14,CHAPTER,ADMINISTRATION"
'
'Announce21:
'Befehl &H15
'Reset
'reset
Data "21;ou,reset;1;0,idle;1,reset"
'
'Announce22:
'Befehl &H16
'Status Register
'status register
Data "22;aa,status register;20;14,CHAPTER,ADMINISTRATION"
'
'Announce23:
'Befehl &HF0
'liest announcements
'read m announcement lines
Data "240;an,ANNOUNCEMENTS;145;36,start at;36,elements;14,CHAPTER,ADMINISTRATION"
'
'Announce24:
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;60,last_error"
'
'Announce25:
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
'Announce26:
'Befehl &HFE <n><data>
'eigene Individualisierung schreiben
'write individualization
Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,RS232,1;a,USB,1;a,wireless,0;a,I2Cactiv,1;b,I2caddress,28;14,CHAPTER,ADMINISTRATION"
'
'Announce27:
'Befehl &HFF <n>
'eigene Individualisierung lesen
'read individualization
Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,RS232,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;a,USB,1;a,wireless,0;a,I2Cactiv,1;b,I2caddress,41;14,CHAPTER,ADMINISTRATION"
'
'Announce28;
Data "L;original;english;deutsch"
'
'Announce29;
Data "L;dust sensor;dust sensor;Feinstaubsensor;mass concentration 1.0;mass concentration 1.0;Masse Konzentration 1.0;mass concentration 2.5;mass concentration 2.5;Masse Konzentration 2.5;"
'
'Announce30
Data "L;mass concentration 4.0;mass concentration 4.0;Masse Konzentration 4.0;mass concentration 10;mass concentration 10;Masse Konzentration 10;"
'
'Announce31:
Data "L;number concentration 0.5;number concentration 0.5;Teilchenzahl 0.5;number concentration 1.0;number concentration 1.0;Teilchenzahl 1.0;"
'
'Announce32:
Data "L;number concentration 2.5;number concentration 2.5;Teilchenzahl 2.5;number concentration 4.0;number concentration 4.0;Teilchenzahl 4.0;"
'
'Announce33:
Data "L;number concentration 10;number concentration 10;Teilchenzahl 10;typical size;typical size;typische Groesse;memorypointer;memorypointer;Speicherzeiger;"
'
'Announce34:
Data "L;stop/start measurement;stop/start measurement;Messung stop/start;measuring time;measuring time;Messzeit;cleaning interval;cleaning interval;Reinigungsintervall;"
'
'Announce35
Data "L;start cleaning;start cleaning;startet Reinigung;product type;product type;Typ;serial number;serial number;Seriennummer;version;version; Version;"