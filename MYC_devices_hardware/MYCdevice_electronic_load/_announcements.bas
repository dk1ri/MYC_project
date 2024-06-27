' announcements
' 20240625
'
Announce:
'Befehl &H00; 1 byte / 1 byte + string
'eigenes basic announcement lesen
'basic announcement is read to I2C or output
Data "0;m;DK1RI;electronic load for 7 IRFP150;V05.0;1;145;1;63;1-1"
'
'Announce1:
'Befehl &H01
'lese aktuelle Spannung
'read actual voltage
Data "1;ap,actual voltage;1;90001,,{0.001_0.000to90.000};lin;V"
 '
'Announce2:
'Befehl &H02
'liest gesamten Strom (1Bit -> 1mA)
'read all current
Data "2;ap,actual current;1;175001,,{0.001_0.000to175.000};lin;A"
'
'Announce3:
'Befehl &H03
'liest aktuellen Strom eines FETs
'read actual current of a FET
Data "3;ap,actual current;7,FET;25001,,{0.001_0.000to25.000};lin;A"
'
'Announce4:
'Befehl &H04
'liest gesamte Leistung
'read all power
Data "4;ap,actual power;1;350001,,{0.001_0.000to350.000};lin;W"
'
'Announce5:
'Befehl &H05
'liest aktuelle Leistung eines FETs
'read actual power of a FET
Data "5;ap,actual power;7,FET;5001,,{0.001_0.000to50.000};lin;W"
'
'Announce6:
'Befehl &H06
'liest aktuellen Widerstand
'read actual resistor
Data "6;ap,actual resistor;1;120000000;lin;mOhm"
'
'Announce7:
'Befehl &H07
'gewuenschte Spannung schreiben
'write required voltage
Data "7;op,required voltage;1;89601,,{0.001_0.4to90.000};lin;V"
'
'Announce8:
'Befehl &H08
'gewuenschte Spannung lesen
'read required voltage
Data "8;ap,as7"
'
'Announce9:
'Befehl &H09
'gewuenschten Strom
'required current
Data "9;op,required current;1;154001,,{0.001_0.00to154.000};lin;A"
'
'Announce10:
'Befehl &H0A
'gewuenschten Strom lesen
'read required current
Data "10;ap,as9"
'
'Announce11:
'Befehl &H0B
'gewuenschte Leistung
'required power
Data "11;op,required power;1;300001,,{0.001_0.00to300.000};lin;W"
'
'Announce12:
'Befehl &H0C
'gewuenschte Leistung lesen
'read required power
Data "12;ap,as11"
'
'Announce13:
'Befehl &H0D
'gewuenschten Widerstand schreiben
'write required resistor
Data "13;op,required resistor;1;119999990,,{0.001_0.00to120000.000};lin;Ohm"
'
'Announce14:
'Befehl &H0E
'gewuenschter Widerstand lesen
'read required resistor
Data "14;ap,as13"
'
'Announce15:
'Befehl &H0F
'Wechsellast schreiben
'write on /off mode
Data "15;or,on off mode;1;0,off;1,regulated;2,fixed"
'
'Announce16:
'Befehl &H10
'Wechsellast lesen
'read on /off mode
Data "16;ar,as15"
'
'Announce17:
'Befehl &H11
'Wechsellast schreiben
'write on - off mode
Data "17;op,time for on off mode;1;1000,,{0.01_0.01to10.00};lin;s"
'
'Announce18:
'Befehl &H12
'Wechsellast lesen
'read on - off mode
Data "18;ap,as17"
'
'Announce19:
'Befehl &H13
'Betriebsart lesen
'read mode
Data "19;as,mode;1;0,off;1,V;2,I;3,P;4,R;.Test;6 calibrate V;7,calibrate I"
'
'Announce20:
'Befehl &H14
'schaltet Last ab
'switch off
Data "20;ou,switch off;1;0,idle;1,off"
'
'Announce21:
'Befehl &H15
'Hysterese schreiben
'write hysteresys
Data "21;op,hysteresys;1;101,,{0.1_0.01to10};lin;%"
'
'Announce22:
'Befehl &H16
'Hysterese lesen
'read hysteresys
Data "22;ap,as21"
'
'Announce23:
'Befehl &H17
'Aktive FETs binaer schreiben
'write active FETS binary
Data "23;oa,available FETs;7,;13,CHAPTER,configuration"
'
'Announce24:
'Befehl &H18
'Aktive Fets binaer lesen
'read active FETS binary
Data "24;aa,as23"
'
'Announce25:
'Befehl &H19
'Zahl der aktiven Fets lesen
'read number of active FETs
Data "25;aa,number of available FETs;1"
'
'Announce26:
'Befehl &H1A
'Maximale Leistung pro Fet
'maximum power per FET
Data "26;op,maximum power per FET;1;150,;lin;Watt;13,CHAPTER,configuration"
'
'Announce27:
'Befehl &H1B
'Maximale Leistung pro Fet lesen
'read maximum power per FET
Data "27;ap,as26"
'
'Announce28:
'Befehl &H1C
'Fet control register einstellen
'set fet control register
Data "28;om,control register;w,{1_0to4095};6;13,CHAPTER,configuration"
'
'Announce29:
'Befehl &H1D
'Fet control register lesen
'read fet control register
Data "29;am,as28"
'
'Announce30:
'Befehl &H1E
'Spannung fuer Spannungseichung schreiben
'write voltage for voltage calibration
Data "30;op,calibration voltage;1;70001,{1_20000to90000};lin;mV;13,CHAPTER,configuration"
'
'Announce31:
'Befehl &H1F
'Spannung fuer Spannungseichung lesen
'read voltage for calibration
Data "31;ap,as30"
'
'Announce32:
'Befehl &H20
'Spannung eichen
'calibrate Voltage
Data "32;ou,calibrate voltage;1;0,idle;1,calibrate voltage;13,CHAPTER,configuration"
'
'Announce33:
'Befehl &H1F
'Spannungseichung lesen
'read voltage calibration
Data "33;ap,voltage calibration;1;4000,,{0.001_0.8000to1.2000};lin;-;13,CHAPTER,configuration"
'
'Announce34:
'Befehl &H22
'Strom fuer Stromeichung schreiben
'write current for current calibration
Data "34;op,current for calibration;1;20001,{1_2000to22000};lin;mA;13,CHAPTER,configuration"
'
'Announce35:
'Befehl &H23
'Strom fuer Stromeichung lesen
'read current for calibration
Data "35;ap,as34"
'
'Announce36:
'Befehl &H24
'Fet kurzschliessen
'shorten FET
Data "36;ou,shorten Fet;1;0,idle;1,FET1;2,FET2;3,FET3;4,FET4;5,FET5;6,FET6;7,FET7;13,CHAPTER,configuration"
'
'Announce37:
'Befehl &H25
'Strom eichen
'calibrate Current
Data "37;ou,calibrate current;1;0,idle;1,FET1;2,FET2;3,FET3;4,FET4;5,FET5;6,FET6;7,FET7;13,CHAPTER,configuration"
'
'Announce38:
'Befehl &H26
'Stromeichung lesen
'read current calibration
Data "38;ap,current calibration;7,FET;4000,,{0.001_0.8000to1.2000};lin;-;13,CHAPTER,configuration"
'
'Announce39:
'Befehl &HF0
'liest announcements
'read m announcement lines
Data "240;an,ANNOUNCEMENTS;145;63,start at;63,elements;14,CHAPTER,ADMINISTRATION"
'
'Announce40:
'Befehl &HFA
'OPTION INFO
'OPTION INFO
Data "250;ia,INFO;b,INFO,0"
'
'Announce41:
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
'
'Announce42:
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
'Announce43:
'Befehl &HFE
'eigene Individualisierung schreiben
'write individualization
Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,21,{1_0to127};a,SERIAL,1;14,CHAPTER,ADMINISTRATION"
'
'Announce44:
'Befehl &HFF
'eigene Individualisierung lesen
'read individualization
Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,21,{1_0to127};a,SERIAL,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;14,CHAPTER,ADMINISTRATION"
'
'Announce45:
' Undervoltage
Data "R !$9 !$11 !$13 IF $1<400"
'
'Announce46:
' Undervoltage
Data "R !$7 IF $1<10"
'
'Announce47:
' On - off mode only during operation
Data "R $15 IF $19>0 AND $19<5"
'
'Announce48:
' Switch off, if power is exceeded
Data "R $20=1! IF $4>$27*$27"
'
'Announce49:
' Switch off, if current is exceeded
Data "R $20=1! IF $2&*>150000"
'
'Announce50:
Data "R !E8 IF $1<400"
'
'Announce51;
Data "L;original;english;deutsch"
'
'Announce52:
Data "L;electronic load for 7 IRFP150;electronic load for 7 IRFP150;elektronische Last fuer 7 IRFP150;"
'
'Announce53:
Data "L;actual voltage;actual voltage;aktuelle Spannung;actual current;actual current; aktueller Strom;"
'
'Announce54:
Data "L;actual power;actual power;aktuelle Leistung;actual resistor;actual resistor;aktueller Widerstand;"
'
'Announce55:
Data "L;required voltage;required voltage;minimale Spannung;required current;required current;minimaler Strom;"
'
'Announce56;
Data "L;required power;required power;minimale Leistung;required resistor;required resistor; minimaler Widerstand;"
'
'Announce57:
Data "L;time for on off mode;time for on off mode;Zeit fuer Ein/Aus mode;switch off;switch off;Aus;"
'
'Anoounce58:
Data "L;hysteresys;hysteresys;Hysterese;available FETs;available FETs;verfuegbare FERs; "
'
'Announce59:
Data "L;number of available FETs;number of available FETs;Zahl der FETs;maximum power per FET;maximum power per FET;Leistung der FETs;"
'
'Announce60:
Data "L;control register;control register;Steuerregister;calibration voltage;calibration voltage;Eichspannung;"
'
'Announce61:
Data "L;calibrate voltage;calibrate voltage;Spannung eichen;current for calibration;current for calibration;Eichstrom;shorten Fet;shorten Fet;FET kurzschliessen;"
'
'Announce62:
Data "L;calibrate current;calibrate current;Strom eichen;current calibration;current calibration;Stromeichung"