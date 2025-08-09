' annoucements
' 20240415
'
Announce:
'Befehl &H00
'basic annoumement wird gelesen
'basic announcement is read
Data "0;m;DK1RI;sensor for climate with raio interface;V01.0;1;145;1;31;1-1"
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
Data "4;os,oversampling humidity;1;0,1;1,2;2,4,3,8;4,16"
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
Data "6;os,oversampling pressure;1;0,1;1,2;2,4,3,8;4,16"
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
Data "8;os,oversampling Temperatur;1;0,1;1,2;2,4,3,8;4,16"    
'
'Announce9:
'Befehl &H09
'liest Oversampling Temperatur
'read Oversampling Temperatur
Data "9;as,as8"
'
'Announce10:
'Befehl &H0A
'schreibt Filter
'write Filter
Data "10;os,filter;1;0,0;1,1;2,4;3,8;4,16"
'
'Announce11:
'Befehl &H0B
'liest Filter
'read Filter
Data "11;as,as10"
'
'Announce12:
'Befehl &H0C
'liest ID
'read ID
Data "12;aa,read ID;b"
'
'Announce14:
'Befehl &H0D
'Reset
'Reset
Data "13;ou,reset;1;0,idle;1,reset"
'
'Announce14:
'Befehl &H0E
'Radio type      7    7
'Radio Type
Data "16;os,radio type;1;0,RFM95 900;1,RFM95 450; 2,RFM95 150;3,nRF24;4,WLAN;5,RYFA689;14,CHAPTER,ADMINISTRATION"
'
'Announce15:
'Befehl &H0F
'Radi type
'Radio Type
Data "15;as,as14"  "
'
'Announce16:
'Befehl &H10
'Radio Name
'radio name
Data "16;oa,radio name;5,,radi;14,CHAPTER,ADMINISTRATION"  "
'
'Announce17:
'Befehl &H11
'Radio Name
'radio name
Data "17;aa,as16"
'
'Announce18:
'Frequenz 137 175MHz
'frequency
Data "18;op,frequency;1;612903,,{62_137000000to175000000};lin;Hz;14,CHAPTER,ADMINISTRATION"

'
'Announce19:
'Frequenz 137 175MHz
'frequency
Data "19;ap,as18"
'
'Announce20:
'Frequenz 410 525MHz
'frequency
Data "20;op,frequency;1;1854838,{62_410000000to525000000};lin;Hz;14,CHAPTER,ADMINISTRATION"

'
'Announce21:
'Frequenz 410 525MHz
'frequency
Data "21;ap,as22"
'
'Announce22:
'Frequenz 862 1020MHz
'frequency
Data "22;op,frequency;1;1019999,{62_820000000to1020000000};lin;Hz;14,CHAPTER,ADMINISTRATION"

'
'Announce23:
'Frequenz 862 1020MHz
'frequency
Data "23;ap,as22"
'
'Announce24:
'Befehl &HF0
'liest announcements
'read m announcement lines
Data "240;an,ANNOUNCEMENTS;145;31,start at;31,lines;14,CHAPTER,ADMINISTRATION"
'
'Announce25:
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
'
'Announce26:
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
'Announce27:
'Befehl &HFE <n><data>
'eigene Individualisierung schreiben
'write individualization
Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,RS232,1;a,USB,1;a,wireless,0;14,CHAPTER,ADMINISTRATION"
'
'Announce28:
'Befehl &HFF <n>
'eigene Individualisierung lesen
'read individualization
Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,RS232,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;a,USB,1;a,wireless,0;14,CHAPTER,ADMINISTRATION"
'
'Announce29:
Data "L;language name;english;deutsch"
'
'Announce30:
Data "L;sensor for climate;sensor for climate;Klimasensor;temperature;temperature;Temperatur;humidity;humidity;Feuchtigkeit;pressure;pressure;Druck;non activ time;non activ time;Pause Zeit;filter;filter;Filter"