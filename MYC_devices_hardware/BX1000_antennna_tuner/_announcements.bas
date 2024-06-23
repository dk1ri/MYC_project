' annoucements
' 20240611
'
Announce:
'Befehl &H00
'basic annoumement wird gelesen
'basic announcement is read
Data "0;m;DK1RI;Matchbox FA BX1000;V02.1;1;150;1;44;1-1"
'
'Announce1:
'Befehl &H01
'schaltet einzelne Inductivitaet
'switch single inductance
Data "1;or,Inductance;1;0,40n;1,80n;2,150n;3,300n;4,580n;5,1.12u;6,2.2u;7.4,3u;8,8.4u;9,16.4u;10,32.2u"
'
'Announce2:
'Befehl &H02
'liest Induktivitaetseinstellung
'read value inductance
Data "2;ap,L;1;48600,{0.001_0to48.600};lin;uH"
'
'Announce3:
'Befehl &H03
'schaltet einelne Kapazitaet
'switch single capacitance
Data "3;or,capacitance;1;0,2p4;1,4p8;2,10p;3,20p;4,40p;5,78p;6,150p;7,280p;8,500p;9,960p;10,1860p;11,3600p"
'
'Announce4:
'Befehl &H04
'liest Kapazitaetseinstellung
'read value of capacitance
Data "4;ap,C;1;7505;lin;pF"
'
'Announce5:
'Befehl &H05
'schreibt Konfiguration
'write configuration
Data "5;os;configuration;1;0,C-L;1,C1-L-C;2,C2-L-C;3,50Ohm straight"
'
'Announce6:
'Befehl &H06
'liest Konfiguration
'read configuration
Data "6;as,as5"
'
Announce7:
'Befehl &H07
'schaltet weitere  Relais
'switch additional relais
Data "7;or,additional relais;1;0,1;1,2;2,3;3,4"
'
'Announce8:
'liest status weiterer  Relais
'read status of additional relais
Data "8;aa,relaisstatus;4"
'
'Announce9:
'Befehl &H09
'schaltet L aufw rts
'switch L upward
Data "9;ou,start / stop L upwards;1;0,idle;1,stop;2,every;3,every second;4,+50;5,+100"
'
'Announce10:
'Befehl &H0A
'schaltet L abw rts
'switch L downward
Data "10;ou,start / stop L downwards;1;0,idle;1,stop;2,every;3,every second;4,-50;5,-100"
'
'Befehl &H0B
'schaltet C aufw rts
'switch C upward
Data "11;ou,start / stop C upwards;1;0,idle;1,stop;2,every;3,every second;4,+50;5,+100"
'
'Announce12:
'Befehl &H0C
'schaltet C abw rts
'switch C downward
Data "12;ou,start / stop C downwards;1;0,idle;1,stop;2,every;3,every second;4,-50;5,-100"
'
'Announce13:
'Befehl &H0D
'liest up_down status
'read up_down status
Data "13;as,up_down status;1;0,off;1,L up;2,L down;3,C up;4,C down"
'
'Announce14:
'Befehl &H0E
'liest Forward
'read Forward
Data "14;ap,forward;1;1050;lin;W"
'
'Announce15:
'Befehl &H0F
'liest Reflektiert
'read reflected
Data "15;ap,reflected;1;1050;lin;W"
'
'Announce16:
'Befehl &H10
'liest SWR
'read SWR
Data "16;ap,SWR;1;51,{0.1_0.0to25.0};lin;-"
'
' Annunce17:
' Befehl &H11
' setzt Frequenz
' Set frequency
Data "17;op,frequency;1;26101,{1_1800to29700};lin;kHz"
'
' Announce18:
' Befehl &H12
' liest aktuelle Frequenz
' read actual frequency
Data "18;ap,as17"
'
'Announce19:
'Befehl &H13
'liest aktuellen Kanal
'read actual chanal
Data "19;ap,actual chanal;1;679,{1_1to679};lin;-"
'
'Announce20:
'Befehl &H14
'liest aktuelles Band
'read actual band
Data "20;as,actual band;1;0,160m;1,160m - 80m;2,80m;3,80m - 40m;4,40m;5,40m - 30m;6,30m;7,30m - 20m;8,20m;9,20m - 17m;10,17m;11,17m - 15m;12,15m;13,15m - 12m,14,12m;15,21m - 10m;16,10m"
'
'Announce21:
'Befehl &H15
'Stellung der Konfiguration in aktuellen memorykanal schreiben
'set drive for actual memory chanal
Data "21;ou,store L/C to actual frequency;1;0,idle;1,store"
'
'Announce22:
'Befehl &H16
'Stellung der Relais f r aktuelle Frequenz setzen vom Speicher
'set relais chanal from memory for actual frequency
Data "22;ou,load L/C values for actual frequency;1;0,idle;1,load"
'
'Announce23:
'Befehl &H17
'Speicher auf default setzen
'set memory to default
Data "23,ou,actual chanal to default;1;0,idle;1,clear chanal"
'
'Announce24:
'Befehl &H18
'default fuer aktuellen Kanal
'default for actual chanal
Data "24;ou,default;1;0,idle;1;set default"
'
'Announce25:
'Befehl &H19
'schaltet Luefter
'switch fan
Data "25;os,force fan;1;0,off;1,on"
'
'Announce26:
'Befehl &H1A
'liest Luefter
'read fan
Data "26;as,fan;1;0,off;1,on"
'
'Announce27:
'Befehl &H1B
'liest Spannung
'read Voltage
Data "27;ap,voltage;1;1500,{0.01_0to15.00;lin;V"
'
'Announce28:
'Befehl &H1C
'liest Temperature
'read temperature
Data "28;ap,temperature;1;101;lin;degC"
'
'Announce29:
'Befehl &HF0
'announcement aller Befehle lesen
'read announcement lines
Data "240;an,ANNOUNCEMENTS;150;44,start at;44,elements;14,CHAPTER,ADMINISTRATION"
'
'Announce30:                                            '
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
'
'Announce31:                                                  '
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
'Announce32:
'Befehl &HFE <n> <n>
'Individualisierung schreiben
'write indivdualization
Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,SERIAL,1;14,CHAPTER,ADMINISTRATION"
'
'Announce33:
'Befehl &HFF
'Individualisierung lesen
'read indivdualization
Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,SERIAL,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;14,CHAPTER,ADMINISTRATION"
'
'Announce34:
Data "L;language name;english;deutsch"
'
'Announce35:
Data "L;Inductance;Inductance;Induktivitaet;capacitance;capacitance;Kapazitaet;configuration;configuration;Konfiguration;additional relais;additional relais;weitere Relais;"
'
'Announce36:
Data "L;start / stop C upwards;start / stop C upwards;start / stop C aufwaerts;start / stop C downwardsstart / stop C downwards;start / stop C abwaert;"
'
'Announce37:
Data "L;start / stop L upwards;start / stop L upwards;start / stop L aufwaerts;start / stop L downwardsstart / stop L downwards;start / stop L abwaert;"
'
'Announce38:
Data "L;up_down status;up_down status;aufwaerts abwaerts status;forward;forward;vorwaerts;reflected;reflected;reflektiert;frequency;frequency;Frequenz;"
'
'Announce39:
Data "L;actual chanal;actual chanal;aktueller Kanal;actual band;actual  band;aktuelles Band;store L/C to actual frequency;store L/C to actual frequency;"
'
'Announce40:
Data "L;L/C zu aktueller Frequenz speichern;load L/C values for actual frequency;load L/C values for actual frequency;L / C von aktueller Frequenz lesen;"
'
'Announce41:
Data "L;actual chanal to default;actual chanal to default;Grundwerte für aktuellen Kanal;default;default;Grundwerte;force fan;force fanMLuefter ein;"
'
'Announce42:
Data "L;fan;fan;Luefter;voltage;voltage;Spannung;temperature;temperature;Temperatur"
'
'Announce43:
' Switch off up /down if Power > 12W
Data "R $15 = 1 IF $19 > 0 AND $14 > 100"