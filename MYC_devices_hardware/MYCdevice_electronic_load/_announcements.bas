' announcements
' 20220113
'
Announce:
'Befehl &H00; 1 byte / 1 byte + string
'eigenes basic announcement lesen
'basic announcement is read to I2C or output
Data "0;m;DK1RI;electronic load for 7 IRFP150;V04.2;1;145;1;52;1-1"
'
'Announce1:
'Befehl &H01 (resolution 1mV);  1 byte / 4 byte
'lese aktuelle Spannung
'read actual voltage
Data "1;ap,read actual voltage;1;90001,{0.000 to 90.000};lin;V"
 '
'Announce2:
'Befehl &H02; 1 byte / 4 byte
'liest gesamten Strom (1Bit -> 1mA)
'read all current
Data "2;ap,read actual current;1;175001,{0.000 to 175.000};lin;A"
'
'Announce3:
'Befehl &H03  0 - 6 (resolution 1mA); 2 byte / 4 byte
'liest aktuellen Strom eines FETs
'read actual current of a FET
Data "3;ap,read actual current;7;25001,{0.000 to 25.000};lin;A"
'
'Announce4:
'Befehl &H04  (resolution 1mW); 1 byte / 4 byte
'liest gesamte Leistung
'read all power
Data "4;ap,read actual power;1;350001,{0.000 to 350.000};lin;W"
'
'Announce5:
'Befehl &H05  0 - 6 (resolution 1mW); 2 byte / 4 Byte
'liest aktuelle Leistung eines FETs
'read actual power of a FET
Data "5;ap,read actual power;7;5001,{0.000 to 50.000};lin;W"
'
'Announce6:
'Befehl &H06 (resolution mOhm); 1 byte / 5 byte
'liest aktuellen Widerstand
'read actual resistor
Data "6;ap,read actual resistor;1;120000000,{1 To 12000000};lin;mOhm"
'
'Announce7:
'Befehl &H07 (resolution 1mV);  4 byte
'gewuenschte Spannung schreiben
'write required voltage
Data "7;op,reqired voltage;1;89601,{0.400 to 90.000};lin;V"
'
'Announce8:
'Befehl &H08 (resolution 1mV);  1 byte / 4 byte
'gewuenschte Spannung lesen
'read required voltage
Data "8;ap,as7"
'
'Announce9:
'Befehl &H09 0 - 21000 (1mA resolution); 4 byte / -
'gewuenschten Strom
'required current
Data "9;op,required current;1;154001,{0.00 To 154.000};lin;A"
'
'Announce10:
'Befehl &H0A  (1mA resolution); 1 byte / 4 byte
'gewuenschten Strom lesen
'read required current
Data "10;ap,as9"
'
'Announce11:
'Befehl &H0B 0 - 140000 (1mW resolution); 4 byte / -
'gewuenschte Leistung
'required power
Data "11;op,required power;1;300001,{0.00 To 300.000};lin;W"
'
'Announce12:
'Befehl &H0C (1mW resolution); 1 byte / 4 byte
'gewuenschte Leistung lesen
'read required power
Data "12;ap,as11"
'
'Announce13:
'Befehl &H0D 10mOhm - 120kOhm (resolution 1mOhm); 5 byte / -
'gewuenschten Widerstand schreiben
'write required resistor
Data "13;op,required resistor:1;119999990,{0.01 To 120000.000};lin;Ohm"
'
'Announce14:
'Befehl &H0E (resolution 10mOhm); 1 byte / 5 byte
'gewuenschter Widerstand lesen
'read required resistor
Data "14;ap,as13"
'
'Announce15:
'Befehl &H0F 0|1|2; 2 byte / -
'Wechsellast schreiben
'write on /off mode
Data "15;or,on off mode;1;0,off;1,regulated;2,fixed"
'
'Announce16:
'Befehl &H10; 1 byte / 2 byte
'Wechsellast lesen
'read on /off mode
Data "16;ar,as15"
'
'Announce17:
'Befehl &H11; 4 byte / -
'Zeit fuer Wechsellast schreiben
'write time for on - off mode
Data "17;op,time for on off mode;1;1000,{0.01 To 10.00};lin;s"
'
'Announce18:
'Befehl &H12; 1 byte / 4 byte
'Zeit fuer Wechsellast lesen
'read time for on - off mode
Data "18;ap,as17"
'
'Announce19:
'Befehl &H13; 1 byte / 1 byte + string
'Betriebsart lesen
'read mode
Data "19;aa,read mode;b,{idle,V,I,P,R};20"
'
'Announce20:
'Befehl &H14; 1 byte / -
'schaltet Last ab
'switch off
Data "20;ou,switch off;1;0,idle;1,off"
'
'Announce21:
'Befehl &H15; 2 byte / -
'Hysterese an schreiben
'write hysteresys on
Data "21;or,hysteresys;1;0,off;1,on"
'
'Announce22:
'Befehl &H16; 1 byte / 2 byte
'Hysterese an lesen
'read hysteresys on
Data "22;ar,as21"
'
'Announce23:
'Befehl &H17; 2 byte / -
'Hysterese schreiben
'write hysteresys
Data "23;op,hysteresys;1;100,{0,1 To 10};lin;%"
'
'Announce24:
'Befehl &H18; 1 byte / 2 byte
'Hysterese lesen
'read hysteresys
Data "24;ap,as23"
'
'Announce25:
'Befehl &H19 (0 to 127); 2  byte / -
'Aktive FETs binaer schreiben
'write active FETS binary
Data "25;ka,active FETs, binary;b,127,{0 To 127}"
'
'Announce26:
'Befehl &H1A; 1 byte / 2 Byte
'Aktive Fets binaer lesen
'read active FETS binary
Data "26;aa,as25"
'
'Announce27:
'Befehl &H1B; 1 byte / 2 Byte
'Zahl der aktiven Fets lesen
'read number of active FETs
Data "27;ar,read number of active FETs;1;b,{1 to 7}"
'
'Announce28:
'Befehl &H1C; 1 byte / 4 byte
'Maximale Leistung pro Fet lesen
'read maximum power per FET
Data "28;lp,maximum power per FET;1;150001,15000,{0 to 150,000};lin;Watt"
'
'Announce29:
'Befehl &H1D; 3 byte / -
'Maximale Leistung pro Fet
'maximum power per FET
Data "29;kp;maximum power per FET;1;150001,15000,{0 to 150,000};lin;Watt"
'
'Announce30:
'Befehl &H1E 0 to 6 , 0 to 4095; 4 byte / -
'Fet control register einstellen
'set fet control register
Data "30;km,set fet control register;6;w,{0 To 4095}"
'
'Announce31:
'Befehl &H1F; 2 byte / 4 byte
'Fet control register lesen
'read fet control register
Data "31; lm,as30"
'
'Announce32:
'Befehl &H20 0 to 90000; 4 byte / -
'Spannung fuer Spannungseichung schreiben
'write voltage for voltage calibration
Data "32;ap,calibration voltage;1;70001,{20000 To 90000};lin:mV"
'
'Announce33:
'Befehl &H21; 1 byte / 4 byte
'Spannung fuer Spannungseichung lesen
'read voltage for calibration
Data "33;la,as32"
'
'Announce34:
'Befehl &H22; 1 byte / -
'Spannung eichen
'calibrate Voltage
Data "34;ku,calibrate voltage;1;0,,idle;1 calibrate voltage"
'
'Announce35:
'Befehl &H23:1 byte / 2 byte
'Spannungseichung lesen
'read voltage calibration
Data "35;lp,read voltage calibration;1;4000,{0.8000 To 1.2000};lin;-" :
'
'Announce36:
'Befehl &H24 0 to 30000; 3 byte / -
'Strom fuer Stromeichung schreiben
'write current for current calibration
Data "36;op,current for calibration;1;20001,{2000 To 22000};lin:mA"
'
'Announce37:
'Befehl &H25; 1 byte / 3 byte
'Strom fuer Stromeichung lesen
'read current for calibration
Data "37;ap,as36"
'
'Announce38:
'Befehl &H26 0 - 6 ; 2 byte / -
'Fet kurzschliessen
'shorten FET
Data "38;ku,shorten Fet;0,FET1;1,FET2;2,FET3;3FET4;4,FET5;5,FET6;6,FET7"
'
'Announce39:
'Befehl &H27 0 - 6 ; 2 byte / -
'Strom eichen
'calibrate Current
'Data "39;ku,calibrate current;0,FET1;1,FET2;2,FET3;3FET4;4,FET5;5,FET6;6,FET7"
'
'Announce40:
'Befehl &H28; 2 byte / 4 byte
'Stromeichung lesen
'read current calibration
Data "40;lp,read current calibration;7;4000,{0.8000 To 1.2000};lin;-" :
'
'Announce41:
'Befehl &HF0<n><m>
'liest announcements
'read m announcement lines
Data "240;ln,ANNOUNCEMENTS;145;52"
'
'Announce42:
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
'
'Announce43:
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
'Announce44:
'Befehl &HFE :
'eigene Individualisierung schreiben
'write individualization
Data "254;ka,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,21,{0 to 127};a,SERIAL,1"
'
'Announce45:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;la,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,21,{0 to 127};a,SERIAL,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1"
'
'Announce46:
' Undervoltage
Data "R !$9 !$11 !$13 IF $1<400"
'
'Announce47:
' Undervoltage
Data "R !$7 IF $1<10"
'
'Announce48:
' On - off mode only during operation
Data "R $15 IF $19>0 AND $19<5"
'
'Announce49:
' Switch off, if power is exceeded
Data "R $20=1! IF $4>$27*$27"
'
'Announce50:
' Switch off, if current is exceeded
Data "R $20=1! IF $2&*>150000"
'
'Announce51:
Data "S !E8 IF $1<400"