' annoucements
' 20200504
'
Announce:
'Befehl &H00
'basic annoumement wird gelesen
'basic announcement is read
Data "0;m;DK1RI;Klimasensor;V03.2;1;145;1;21;1-1"
'
'Announce1:
'Befehl &H01
'liest Temperatur
'read temperature
Data "1;ap,read temperature;1;12500,{-40.00 to 84.99};lin;DegC"
'
'Announce2:
'Befehl &H02
'liest Feuchtigkeit
'read humidity
Data "2;ap,read humidity;1;100001,{0.000 to 100.000};lin;%"
'
'Announce3:
'Befehl &H03
'liest Druck
'read pressure
Data "3;ap,read pressure;1;1100001,{0.000 to 1100.000};lin;hPa"
'
'Announce4:
'Befehl &H04 0 to 5
'schreibt Oversampling Feuchte
'write Oversampling humidity
Data "4;oa,oversampling humidity;b,{0,1,2,4,8,16}"
'
'Announce5:
'Befehl &H05
'liest Oversampling Feuchte
'read Oversampling humidity
Data "5;aa,as4"
'
'Announce6:
'Befehl &H06 0 to 5
'schreibt Oversampling Druck
'write Oversampling pressure
Data "6;oa,oversampling pressure;b,{0,1,2,4,8,16}"
'
'Announce7:
'Befehl &H07
'liest Oversampling Druck
'read Oversampling pressure
Data "7;aa,as6"
'
'Announce8:
'Befehl &H08
'schreibt Oversampling Temperatur
'write Oversampling Temperature
Data "8;oa,oversampling Temperatur;b,{0,1,2,4,8,16}"
'
'Announce9:
'Befehl &H09
'liest Oversampling Temperatur
'read Oversampling Temperatur
Data "1;aa,as8"
'
'Announce10:
'Befehl &H0A
'schreibt Pause Zeit
'write non active time
Data "10;oa,non activ time;b,{0.5,62.5,125,500,1000,10,20},ms"
'
'Announce11:
'Befehl &H0B
'liest Pause Zeit
'read non active time
Data "11;aa,as10"
'
'Announce12:
'Befehl &H0C
'schreibt Filter
'write Filter
Data "12;oa,filter;b,{0,2,4,8,16}"
'
'Announce13:
'Befehl &H0D
'liest Filter
'read Filter
'Data "13;aa,as12"
'
'Announce14:
'Befehl &H0E
'liest ID
'read ID
Data "14;aa,read ID;b"
'
'Announce15:
'Befehl &H0F
'Reset
'Reset
Data "15;ot,reset;0"
'
'Announce16:
'Befehl &HF0<n><m>
'liest announcements
'read m announcement lines
Data "240;ln,ANNOUNCEMENTS;145;21"
'
'Announce17:
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
'
'Announce18:
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
'Data "253;aa,MYC INFO;b,ACTIVE"
'
'Announce19:
'Befehl &HFE <n><data>
'eigene Individualisierung schreiben
'write individualization
Data "254;ka,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,22,{0 to 127};a,SERIAL,1"
'
'Announce20:
'Befehl &HFF <n>
'eigene Individualisierung lesen
'read individualization
Data "255;la,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,22,{0 to 127};a,SERIAL,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1"
'
