' annoucements
' 20240627
'
Announce:
'Befehl &H00
'eigenes basic announcement lesen
'basic announcement is read to I2C or output
Data "0;m;DK1RI;70MHz DDS geneato V03.2r;180;1;35;1-1"
'
'Announce1:
'Befehl &H01
'Frequenz
'frequency
Data "1;op,frequency;1;70000000,;lin;Hz"
'
'Announce2:
'Befehl &H01
'Frequenz
'frequency
Data "2;ap,as1"
'
'Announce3:
'Befehl &H03  after switch off do dont work for unknown reason -> dropped
'DDS ein
'DDS on
' Data "3;os,switch;1;0,off;1,on"
'
'Announce4:
'Befehl &H04
'DDS ein
'DDS on
' Data "4;as,as3"
'
'Announce5:
'Befehl &H05
'Relais
'Relais
Data "5;os,relais;1;0,off;1,on"
'
'Announce6:
'Befehl &H06
'Relais
'Relais
Data "6;as,as5"
'
'Announce7:
'Befehl &H07
'Temperatursensor vorhanden
'temperature sensor available
Data "7;os,temperature;1;0,no sensor;1,sensor"
'
'Announce8:
'Befehl &H08
'Temperatursensor vorhanden
'temperature sensor available
Data "8;as,as7"
'
'Announce9:
'Befehl &H09
'Temperatur
'temperature
Data "9;ap,temperature;1;1024,,{0.1_0.0to102.3};lin;C"
'
'Announce10:
'Befehl &H0A
'Eichung
'calibrate
Data "10;oa,calibrate;w,,{1_-20000to20000};13,CHAPTER,configuration"
'
'Announce11:
'Befehl &H0B
'Eichung
'calibrate
Data "11;aa,as10"
'
'Announce12:
'Befehl &H0C
'Eichung speichern
'store calibrate
Data "12;ou,store calibrate;1;0,idle;1,store;13,CHAPTER,configuration"
'
'Announce13:
'Befehl &H0D
'Tk Messung
'Tk measurement
Data "13;os,Tc measurement;1;0,off;1,on;13,CHAPTER,configuration"
'
'Announce14:
'Befehl &H0E
'Tk Messung Temp
'Tk measurement temp
Data "14;ou,Tc measurement temperature;1;0,idle;1,tmin;2,tmax;13,CHAPTER,configuration"
'
'Announce15:
'Befehl &H0F
'Tk Messung Frequenz
'Tk measurement frequency
Data "15;op,Tc measurement frequency at tmin;1;70000000;lin;Hz;13,CHAPTER,configuration"
'
'Announce16:
'Befehl &H10
'Tk Messung Frequenz
'Tk measurement frequency
Data "16;op,Tc measurement frequency at tmax;1;70000000;lin;Hz;13,CHAPTER,configuration"
'
'Announce17:
'Befehl &H11
'Abweichung durch Tempratur
'Tc
Data "17;ap,Tc deviation at 70MHz;1;65536,,{1_-32768to32767};lin;Hz;13,CHAPTER,configuration"
'
'Announce18:
'Befehl &H12
'RC5 adress
'RC5 adress
Data "18;oa,RC5 adress;b,{1_0to127};13,CHAPTER,configuration"
'
'Announce19:
'Befehl &H13
'RC5 adress
'RC5 adress
Data "19;aa,as18"
'
'Announce20:
'Befehl &H14
'RC5 Codes
'RC5 Codes
Data "20;om,RC5 Codes 0 to 20;b,{1_0to20};20,key;13,CHAPTER,configuration"
'
'Announce21:
'Befehl &H15
'RC5 Codes
'RC5 Codes
Data "21;am,as20"
'
'Announce22:
'Befehl &H16
'Mode
'mode
Data "22;os,mode;1;0,MYC;1,IR"
'
'Announce23:
'Befehl &H17
'Mode
'mode
Data "23;as,as22"
'
'Announce24
'Befehl &H18
' voredefinierete Frequenz
' predefined frequency
Data "24;os,predefined;1;0,F2;1,F3;2,F4;3,F5;4,F6;5,F7;6;F8;7,F9;8,F10;9,F11;10;F12;11,F13;12,F14;13,F15;14,F16;15,F17;16,F18;17,F19;18,F20"
'
'Announce23:
'Befehl &HF0<n><m>
'announcement aller Befehle lesen
'read m announcement lines
Data "240;an,ANNOUNCEMENTS;100;35,start at;35,lines;14,CHAPTER,ADMINISTRATION"
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
Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,37,{1_0to127};a,RS232,1;a,USB,1;14,CHAPTER,ADMINISTRATION"
'
'Announce27:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,37,{1_0to127};a,RS232,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;a,USB,1;14,CHAPTER,ADMINISTRATION"
'
'Announce28:
Data"R $22 IF $20 = 1"
'
'Announce29;
Data "L;original;english;deutsch"
'
'Announce30;
Data "L;70MHz DDS geneator;70MHz DDS geneator;70MHz DDS Sender;frequency;frequency;Frequenz;switch;switch;Schalter;relais;relais;Relais;temperature;temperature;Temperatur;"
'
'Announce31:
Data "L;calibrate;calibrate;eichen;store calibrate;store calibrate;Eichung speichern;Tc measurement;Tc measurement;Tk Messung;Tc measurement temperature;Tc measurement temperature;Tk Messung Temperatur;"
'
'Announce32:
Data "L;Tc measurement frequency at tmin;Tc measurement frequency at tmin;TK Messung Frequenz bei tmin;Tc measurement frequency at tmax;Tc measurement frequency at tmax;TK Messung Frequenz bei tmax;"
'
'Announce33:
Data "L;Tc deviation at 70MHz;Tc deviation at 70MHz;Tk Abweichung bei 70MHz;RC5 adress;RC5 adress;RC5 Adressde;RC5 Codes 0 to 20;RC5 Codes 0 to 20;RC5 Codes 0 bis 20;"
'
'Announce34:
Data "L;mode;mode;Betriebsart;predefined;predefined;voreingestellt"