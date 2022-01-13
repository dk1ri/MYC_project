' annoucements
' 20210908
'
Announce:
'Befehl &H00
'eigenes basic announcement lesen
'basic announcement is read to I2C or output
Data "0;m;DK1RI;70MHz DDS Sender;V01.1;1;180;1;26"
'
'Announce1:
'Befehl &H01
'Frequenz
'frequency
Data "1;op,frequency;1;70000000;lin;Hz"
'
'Announce2:
'Befehl &H01
'Frequenz
'frequency
Data "2;ap,as1"
'
'Announce3:
'Befehl &H03
'DDS ein
'DDS on
Data "3;os,switch on;1;0,off:1 on"
'
'Announce4:
'Befehl &H04
'DDS ein
'DDS on
Data "4;as,as3"
'
'Announce5:
'Befehl &H05
'Eichung
'calibrate
Data "5;op,calibrate;1;16777215;lin;-"
'
'Announce6:
'Befehl &H06
'Eichung
'calibrate
Data "6;ap,as5"
'
'Announce7:
'Befehl &H07
'Eichung speichern
'store calibrate
Data "7;ot,sore calibrate;0,idle;1,store"
'
'Announce8:
'Befehl &H08
'Temperatursensor vorhanden
'temperature sensor available
Data "8;os,temperature sensor available;1,0,off;1,on"
'
'Announce9:
'Befehl &H09
'Temperatursensor vorhanden
'temperature sensor available
Data "9;as,as8"
'
'Announce10:
'Befehl &H0A
'Temperatur
'temperature
Data "10;ap,temperature;1;1024,{0.0 To 102.3};lin;C"
'
'Announce11:
'Befehl &H0B
'Abweichung durch Tempratur
'Tc
Data "11;op,Tc;1;65536,{-32768 To 32767};lin;ppb/K"
'
'Announce12:
'Befehl &H0C
'Abweichung durch Tempratur
'Tc
Data "12;ap,as11"
'
'Announce13:
'Befehl &H0D
'RC5 Codes
'RC5 Codes
Data "13;om,RC5 Codes;1;0,20,{adress;1 to 19};b,{0 to 127}"
'
'Announce14:
'Befehl &H0E
'RC5 Codes
'RC5 Codes
Data "14;am,as13",
'
'Announce115:
'Befehl &H0F
'aktueller RC5 Code
'actual RC5 Code
Data "15;am,actual RC5 code;1;b,address;b,code",
'
'Announce16:
'Befehl &H10
'Relais
'Relais
Data "16,os,relais;1;0,off;1,on"
'
'Announce17:
'Befehl &H11
'Relais
'Relais
Data "17,as,as16"
'
'Announce18:
'Befehl &H12
'Tk Messung
'Tk measurement
Data "18,os,Tk measurement;1;0,off;1,on"
'
'Announce19:
'Befehl &H13
'Tk Messung
'Tk measurement
Data "19,as,as18"
'
'Announce20:
'Befehl &HF0<n><m>
'announcement aller Befehle lesen
'read m announcement lines
Data "240;ln,ANNOUNCEMENTS;100;26"
'
'Announce21:                                                  '
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
'
'Announce22:                                                  '
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
'Announce23:
'Befehl &HFE :
'eigene Individualisierung schreiben
'write individualization
Data "254;ka,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,37,{0 to 127};a,RS232,1;a,USB,1"
'
'Announce24:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;la,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,37,{0 to 127};a,RS232,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;a,USB,1"
'
Announce25:
Data"R $10 IF $9 = 1"