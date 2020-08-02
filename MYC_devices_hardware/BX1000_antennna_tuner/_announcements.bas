' annoucements
' 20200728
'
Announce:
'Befehl &H00
'basic annoumement wird gelesen
'basic announcement is read
Data "0;m;DK1RI;Matchbox FA BX1000;V01.1;1;110;1;34;1-1"
'
'Announce1:
'Befehl &H01
'schaltet einzelne Inductivitaet
'switch single inductance
Data "1;or,single Inductance;1;0,40n;1,80n;2,150n;3,300n;4,580n;5,1.12u;6,2.2u;7.4,3u;8,8.4u;9,16.4u;10,32.2u"
'
'Announce2:
'Befehl &H02
'liest Induktivitaetseinstellung
'read control value inductance
Data "2;am,L position value;1;w,{0 To 2047}"
'
'Announce3:
'Befehl &H03
'schaltet einelne Kapazitaet
'switch single capacitance
Data "3;or,single capacitance;1;0,2p4;1,4p8;2,10p;3,20p;4,;5,40p;6,78p;7,150p;8,280p;9,500p;10,960p;11,1860p;12,3600p"
'
'Announce4:
'Befehl &H04
'liest Kapazitaetseinstellung
'read control value of capacitance
Data "4;am,C position value;1;w,{0 To 4095}"
'
'Announce5:
'Befehl &H05
'schreibt Konfiguration
'write configuration
Data "5;os,set configuration;1;0,C-L;1,C1-L-C;2,C2-L-C;3,50Ohm straight"
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
Data "7;or,set additional relais;1;0,1;1,2;2,3;3,4"
'
'Announce8:
'liest status weiterer  Relais
'read status of additional relais
Data "7;am,relaisstatus;1;b,{0 To 15}"
'
'Announce9:
'Befehl &H09
'schaltet L aufwärts
'switch L upward
Data "9,ot,L upwards;1;0,idle;1;0,idle;1,start / stop every;2,start / stop every second;3,start / stop every forth"
'
'Announce10:
'Befehl &H0A
'schaltet L abwärts
'switch L downward
Data "10,ot,L downwards;1;0,idle;1,start / stop every;2,start / stop every second;3,start / stop every forth"
'
'Announce11:
'Befehl &H0B
'schaltet C aufwärts
'switch C upward
Data "11,ot,C upwards;1;0,idle;1,start / stop every;2,start / stop every second;3,start / stop every forth"
'
'Announce12:
'Befehl &H0C
'schaltet C abwärts
'switch C downward
Data "12,ot,C downwards;1;0,idle;1,start / stop every;2,start / stop every second;3,start / stop every forth"
'
'Announce13:
'Befehl &H0D
'liest up_down status
'read up_down status
Data "13,am,up_down status;1;b,{0 to 4}"
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
Data "16;ap,SWR;1;51{0.0 to 25.0};lin;-"
'
' Annunce17:
' Befehl &H11
' setzt Frequenz
' Set frequency
Data "17;op;set frequency;1;29701;lin;kHz"
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
Data "19;am,read actual chanal;1;w,{1 to 679}"
'
'Announce20:
'Befehl &H14
'liest aktuelles Band
'read actual band
Data "20;as,actual band;1;0,160m;1,160m - 80m;2,80m;3,80m - 40m;4,40m;5,40m - 30m;6,30m;7,30m - 20m;8,20m;9,20m - 17m;10,17m;11,17m - 15m;12,15m;13,15m - 12m,14,12m;15,21m - 10m;16,10m"
'
'Announce21:
'Befehl &H15
'Stellung der Relais in aktuellen memorykanal schreiben
'set drive for actual memory chanal
Data "21;ou,store L/C to actual memory chanal / memory;1;0,idle;1,store"
'
'Announce22:
'Befehl &H16
'Stellung der Relais für aktuelle Frequenz setzen vom Speicher
'set relais position from memory for actual frequency
Data "22;au,set L/C values from memory for actual frequency;1;0,idle;1,set relais"
'
'Announce23:
'Befehl &H17
'Speicher auf default setzen
'set memory to default
Data "23,ou,set memory to default;1;0,idle;1,clear"
'
'Announce24:
'Befehl &H18
'default fuer aktuellen Kanal
'default for actual chanal
Data "24;ou,set default for actual chanal;1;0,idle;1;clear actual chanal"
'
'Announce25:
'Befehl &H19
'schaltet Luefter
'switch fan
Data "25;os,fan;1;0,off;1,on"
'
'Announce26:
'Befehl &H1A
'liest Luefter
'read fan
Data "26;as,as25"
'
'Announce27:
'Befehl &H1B
'liest Spannung
'read Voltage
Data "27;ap,voltage;1;1500;lin;10mV"
'
'Announce28:
'Befehl &H1C
'liest Temperature
'read temperature
Data "28;ap,Temperature;1;101;lin;degC"
'
'Announce28:
'Befehl &HF0
'announcement aller Befehle lesen
'read announcement lines
Data "240;ln,ANNOUNCEMENTS;100;33"
'
'Announce29:                                            '
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
'Befehl &HFE <n> <n>
'Individualisierung schreiben
'write indivdualization
Data "254;ka,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,SERIAL,1"
'
'Announce32:
'Befehl &HFF
'Individualisierung lesen
'read indivdualization
Data "255;la,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,SERIAL,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1"
'
Announce33:
' Switch off up /down if Power > 12W
Data "R $15 = 1 IF $19 > 0 AND $14 > 100"