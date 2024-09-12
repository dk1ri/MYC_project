' annoucements
' 20240730
'
Announce:
'Befehl &H00
'eigenes basic announcement lesen
'basic announcement is read to I2C or output
Data "0;m;DK1RI;70MHz DDS geneator;V03.3;1;180;1;43;1-1"
'
'Announce1:
'Befehl &H01
'Frequenz
'frequency
Data "1;op,frequency;1;69999999,,{1_1 to 70000000};lin;Hz"
'
'Announce2:
'Befehl &H01
'Frequenz
'frequency
Data "2;ap,as1"
'
'Announce3:
'Befehl &H0
'Relais
'Relais
Data "3;os,relais;1;0,off;1,on"
'
'Announce4:
'Befehl &H04
'Relais
'Relais
Data "4;as,as3"
'
'Announce5:
'Befehl &H05
'Temperatursensor vorhanden
'temperature sensor available
Data "5;os,temperature;1;0,no sensor;1,sensor"
'
'Announce6:
'Befehl &H06
'Temperatursensor vorhanden
'temperature sensor available
Data "6;as,as5"
'
'Announce7:
'Befehl &H07
'Temperatur
'temperature
Data "7;ap,temperature;1;1024,,{0.1_0.0to102.3};lin;C"
'
'Announce8:
'Befehl &H08
'Eichung
'calibrate
Data "8;op,correct frequency;1;69999999,,{1_1to70000000};lin;Hz;13,CHAPTER,configuration"
'
'Announce9:
'Befehl &H09
'Eichung
'calibrate
Data "9;ap,correction;1;2001,,{1_-1000to1000};lin;ppm;13,CHAPTER,configuration"
'
'Announce10:
'Befehl &H0A
'Tk Messung
'Tk measurement
Data "10;os,Tc measurement;1;0,off;1,on;13,CHAPTER,configuration"
'
'Announce11:
'Befehl &H0B
'Tk Messung Temp
'Tk measurement temp
Data "11;ou,Tc measurement temperature;1;0,idle;1,tmin;2,tmax;13,CHAPTER,configuration"
'
'Announce12:
'Befehl &H0C
'Tk Messung Frequenz
'Tk measurement frequency
Data "12;op,Tc measurement frequency at tmin;1;70000000;lin;Hz;13,CHAPTER,configuration"
'
'Announce13:
'Befehl &H0D
'Tk Messung Frequenz
'Tk measurement frequency
Data "13;op,Tc measurement frequency at tmax;1;70000000;lin;Hz;13,CHAPTER,configuration"
'
'Announce14:
'Befehl &H0E
'Tc Berechnung
'Tc calculation
Data "14;ou,calculate Tc;1;0,idle;1,calculate;13,CHAPTER,configuration"
'
'Announce15:
'Befehl 0F
'Tk lesen
'read Tk
Data "15;ap,Tc;1;5001,,{1_-2500to2500};lin;ppb/K;13,CHAPTER,configuration"
'
'Announce16:
'Befehl &H10
'RC5 adress  code
'RC5 adress code
Data "16;aa,last RC5 adress and code;7;13,CHAPTER,configuration"
'
'Announce17:
'Befehl &H11
'RC5 adress
'RC5 adress
Data "17;oa,RC5 adress;b,;13,CHAPTER,configuration"
'
'Announce18:
'Befehl &H12
'RC5 adress
'RC5 adress
Data "18;aa,as17"
'
'Announce19:
'Befehl &H13
'RC5 Codes
'RC5 Codes
Data "19;om,RC5 Codes;n,code,{1_1to127},;20,key;13,CHAPTER,configuration"
'
'Announce20:
'Befehl &H14
'RC5 Codes
'RC5 Codes
Data "20;am,as19"
'
'Announce21:
'Befehl &H16
'Mode
'mode
'Data "21;os,mode;1;0,MYC;1,IR"
'
'Announce22:
'Befehl &H16
'Mode
'mode
'Data "22;as,as21"
'
'Announce23
'Befehl &H17
' vordefinierte Frequenz
' predefined frequency
Data "23;os,set predefined;1;0,F1;1,F2;2,F3;3,F4;4,F5;5,F6;6;F7;7,F8;8,F9;9,F10;10;F11;11,F12;12,F13;13,F14;14,F15;15,F16;16,F17;17,F18;18,F19;19,F20"
'
'Announce24
'Befehl &H18
' vordefinierte Frequenz
' predefined frequency
Data "24;om,IR frequencies;L,,{1_0to70000;20,key;13,CHAPTER,configuration"
'
'Announce25
'Befehl &H19
' vordefinierte Frequenz
' predefined frequency
Data "25;am,as24"
'
'Announce26:
' mit Verstarker
'with ampliflier
Data "26;os,with aplifier;1;0,yes;1,no;13,CHAPTER,configuration"
'
'Announce27:
' mit Verstarker
'with ampliflier
Data "27;as,as26"
'
'Announce28:
'Befehl &HF0<n><m>
'announcement aller Befehle lesen
'read m announcement lines
Data "240;an,ANNOUNCEMENTS;100;43,start at;43,lines;14,CHAPTER,ADMINISTRATION"
'
'Announce29:                                                  '
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
'
'Announce30:                                                  '
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
'Announce31:
'Befehl &HFE :
'eigene Individualisierung schreiben
'write individualization
Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,37,{1_0to127};a,RS232,1;a,USB,1;14,CHAPTER,ADMINISTRATION"
'
'Announce32:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,37,{1_0to127};a,RS232,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;a,USB,1;14,CHAPTER,ADMINISTRATION"
'
'Announce33:
'Temp
Data "R;!$7 IF $6=0"
'
'Announce34:
'Relais
Data "R;$3 IF $22=0"
'
'Announce35:
Data "R;$08 $09 IF $22=0"
 '
 'Announce36:
Data "R;$10 $11 R12 $13 $14 IF $22=0 AND $6=1"
'
'Announce37;
Data "L;original;english;deutsch"
'
'Announce38;
Data "L;70MHz DDS geneator;70MHz DDS geneator;70MHz DDS Sender;frequency;frequency;Frequenz;relais;relais;Relais;temperature;temperature;Temperatur;"
'
'Announce39:
Data "L;correct frequency;,correct frequency;korrekte Frequenz;correction;correction;Korrektur;Tc measurement;Tc measurement;Tk Messung;Tc measurement temperature;Tc measurement temperature;Tk Messung Temperatur;"
'
'Announce40:
Data "L;Tc measurement frequency at tmin;Tc measurement frequency at tmin;TK Messung Frequenz bei tmin;Tc measurement frequency at tmax;Tc measurement frequency at tmax;TK Messung Frequenz bei tmax;"
'
'Announce41:
Data "L;RC5 adress;RC5 adress;RC5 Adressde;RC5 Codes 0 to 20;RC5 Codes 0 to 20;RC5 Codes 0 bis 20;"
'
'Announce42:
Data "L;mode;mode;Betriebsart;predefined;predefined;voreingestellt;IR frequencies;IR frequencies;IR Frequenzen;with amplifier;with amplifier;mit Verstaerker"
'