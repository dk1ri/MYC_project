' announcements
' 20200430
'
Announce:
'Befehl &H00
'basic annoumement wird gelesen
'basic announcement is read
Data "0;m;DK1RI;RC5 rotator control;V06.0;1;145;1;24:1-1"
'
'Announce1:
'Befehl &H01 0|1
'Motorsteuerung aus /an schalten
'control off / on
Data "1;os,Device off on;1;0,off;1,on"
'
'Announce2:
'Befehl &H02
'liest Antennenposition 0... 359
'read antenna position
Data "2;ap,antenna position;1;360;lin:degree"
'
'Announce3:
'Befehl &H03 0|1
'Manual / Preset switch
Data "3;os;1;0,manual;1,preset"
'
'Announce4:
'Befehl &H04 0 to 359
'preset Antennerichtung; kann motor im preset mode starten
'preset, real antenna direction may starts motor if preset mode
Data "4;op,Preset Position;1;360;lin;degree"
'
'Announce5:
'Befehl &H05
'manuell startet den Motor ccw
'manual start motor ccw
Data "5;ou,Motor ccw;1;0,idle;1,ccw"
'
#Announce6:
'Befehl &H06
'manuell stoppt den Motor
'manual stops motor
'Data "6;ou,Motor stop;1;0;idle;1,stop"
'
#Announce7:
'Befehl &H07
'manuell startet den Motor cw
'manual start motor cw
Data "7;ou,Motor cw;1;0,idle;1,cw"
'
'Announce8:
'Befehl &H08 0 to 359
'schreibt Antenna_limit_direction 0 ... 359
'write Antenna_limit_direction
Data "8;op,Antenna_limit_direction;1;360;lin;degree"
'
'Announce9:
'Befehl &H09
'liest Antenna_limit_direction
'read Antenna_limit_direction
Data "9;as8"
'
'Announce10:
'Befehl &H0A
'liest Werte
'read values
Data "10;aa,Values 1;b,controlon;b,Preset;b,Motor_cw;b,Motor_ccw;b,not_Limit;b,preset_limits"
'
#Announce11:
'Befehl &H0B
'liest Werte
'read values
Data "11;aa,values 2;w,preset value;w,Ccw_correction;w.Cw_correction,w,dir_rotor;w,preset_rotor"
'
'Announce12:
'Befehl &H0C
'liest die Spannung an der ccw Grenze, Eichung (noch vor hardware Limit)
'read voltage for ccw limit, calibration (before hardware limit)
Data "12;ou;1;0,idle;1,CCW calibration"
'
'Announce13:
'Befehl &H0D
'liest die Spannung an der cw Grenze, Eichung (noch vor hardware Limit)
'read voltage for cw limit, calibration (before hardware limit)
Data "13;ou;1;0,idle;1,CW calibration"
'
'Announce14:
'Befehl &H0E
'liest limit
'read limit
Data "14;aa,limit value;a,Limit"
'
'Announce15:
'Befehl &H0F
'Motorsteuerung aus /an status lesen
'read on / off control
'Data "1;as,as1"
'
'Announce16:
'Befehl &HF0<n><m>
'liest announcements
'read n announcement lines
Data "240;ln,ANNOUNCEMENTS;145;24"
'
'Announce17:                                                  '
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
'
'Announce18:                                                  '
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
'Announce19:
'Befehl &HFE :
'eigene Individualisierung schreiben
'write individualization
Data "254;ka,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,2,{0 to 127};a,SERIAL,1"
'
'Announce20:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;la,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,2,{0 to 127};a,SERIAL,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8N1"
'
'Announce21:
' - no operate command is done before Control_on is set
Data "R !$3 !$5 !$7 IF $15=0"
'
'Announce22:
' - motor at limit will switch off , no need for logic device to send switch off command
Data "R $6 IF $14=1"
'
'Announce23:
'No Preset If hardwarelimit
Data "R !$3 IF $14=1"