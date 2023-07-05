' annoucements
' 20220705
'
Announce:
'Befehl &H00
'basic annoumement wird gelesen
'basic announcement is read
Data "0;m;DK1RI;Klimasensor;V04.0;1;145;1;21;1-1"
'
'Announce1:
'Befehl &H01
'liest Temperatur
'read temperature
Data "1;ap,temperature;1;12500,{0.01_-40.00to84.99};lin;DegC"
'
'Announce2:
'Befehl &H02
'liest Feuchtigkeit
'read humidity
Data "2;ap,humidity;1;100001,{0.001_0.000to100.000};lin;%"
'
'Announce3:
'Befehl &H03
'liest Druck
'read pressure
Data "3;ap,pressure;1;1100001,{0.001_0.000to1100.000};lin;hPa"
'
'Announce4:
'Befehl &H04 0 to 5
'schreibt Oversampling Feuchte
'write Oversampling humidity
Data "4;os,oversampling humidity;1;0,0;1,1;2,2,3,4;4,8;5,16"
'
'Announce5:
'Befehl &H05
'liest Oversampling Feuchte
'read Oversampling humidity
Data "5;as,as4"
'
'Announce6:
'Befehl &H06 0 to 5
'schreibt Oversampling Druck
'write Oversampling pressure
Data "6;os,oversampling pressure;1;0,0;1,1;2,2,3,4;4,8;5,16"
'
'Announce7:
'Befehl &H07
'liest Oversampling Druck
'read Oversampling pressure
Data "7;as,as6"
'
'Announce8:
'Befehl &H08
'schreibt Oversampling Temperatur
'write Oversampling Temperature
Data "8;os,oversampling Temperatur;1;0,0;1,1;2,2,3,4;4,8;5,16"
'
'Announce9:
'Befehl &H09
'liest Oversampling Temperatur
'read Oversampling Temperatur
Data "9;as,as8"
'
'Announce10:
'Befehl &H0A
'schreibt Pause Zeit
'write non active time
Data "10;os,non activ time;1;0,0.5;1,62.5;2,125;3,500,1000;4,10;5,20"
'
'Announce11:
'Befehl &H0B
'liest Pause Zeit
'read non active time
Data "11;as,as10"
'
'Announce12:
'Befehl &H0C
'schreibt Filter
'write Filter
Data "12;os,filter;1;0,0;1,1;2,4;3,8;4,16"
'
'Announce13:
'Befehl &H0D
'liest Filter
'read Filter
Data "13;as,as12"
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
Data "15;ou,reset;0;1,reset"
'
'Announce16:
'Befehl &HF0<n><m>
'liest announcements
'read m announcement lines
Data "240;an,ANNOUNCEMENTS;145;21,start at;21,lines;14,CHAPTER,ADMINISTRATION"
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
Data "253;aa,MYC INFO;b,ACTIVE"
'
'Announce19:
'Befehl &HFE <n><data>
'eigene Individualisierung schreiben
'write individualization
Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,22,{1_0to127};a,SERIAL,1;14,CHAPTER,ADMINISTRATION"
'
'Announce20:
'Befehl &HFF <n>
'eigene Individualisierung lesen
'read individualization
Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,22,{1_0to127};a,SERIAL,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;14,CHAPTER,ADMINISTRATION"
'