' announcements
' 20240611
'
Announce:
'Befehl &H00
'basic annoumement wird gelesen
'basic announcement is read
Data "0;m;DK1RI;RC5 rotator control;V07.2;145;1;31;1-1"
'
'Announce1:
'Befehl &H01
'Motorsteuerung aus / an schalten
'control off / on
Data "1;os,control;1;0,off;1,on"
'
'Announce2":
'Befehl &H02"
'Motorsteuerung aus /an status lesen
'read on / off control
Data "2;as,as1"
'
'Announce3:
'Befehl &H03
'liest Antennenposition 0... 359
'read antenna position
Data "3;ap,antenna position;1;360;lin;degree"
'
'Announce4:
'Befehl &H04
'Manual / Preset switch
Data "4;os,operation;1;0,manual;1,preset"
'
'Announce5:
'Befehl &H05
'Manual / Preset switch
Data "5;as,as4"
'
'Announce6:
'Befehl &H05
'preset Antennerichtung; kann motor im preset mode starten
'preset, real antenna direction may starts motor if preset mode
Data "6;op,preset position;1;360;lin;degree"
'
'Announce7:
'Befehl &H07
'preset Antennerichtung; kann motor im preset mode starten
'preset, real antenna direction may starts motor if preset mode
Data "7;ap,as6"
'
'Announce8:
'Befehl &H08
'manuell startet den Motor ccw
'manual start motor ccw
Data "8;ou,motor ccw;1;0,idle;1,ccw"
'
'Announce9:
'Befehl &H09
'manuell stoppt den Motor
'manual stops motor
Data "9;ou,motor stop;1;0;idle;1,stop"
'
'Announce10:
'Befehl &H0A
'manuell startet den Motor cw
'manual start motor cw
Data "10;ou,motor cw;1;0,idle;1,cw"
'
'Announce11:
'Befehl &H0B
'schreibt Antenna_limit_direction 0 ... 359
'write Antenna_limit_direction
Data "11;op,antenna direction limit;1;360;lin;degree"
'
'Announce12:
'Befehl &H0C
'liest Antenna_limit_direction
'read Antenna_limit_direction
Data "12;ap,as11"
'
'Announce13:
'Befehl &H0D
'liest Werte
'read values
Data "13;aa,values 1;a,controlon;a,Motor_cw;a,Motor_ccw"
'
'Announce14:
'Befehl &H0E
'liest Werte
'read values
Data "14;aa,values 2;w,Ccw_correction;w,Cw_correction,w,rotator_direction;w,rotator_preset_direction"
'
'Announce15:
'Befehl &H0F
'liest die Spannung an der ccw Grenze, Eichung (noch vor hardware Limit)
'read voltage for ccw limit, calibration (before hardware limit)
Data "15;ou,calibration;1;0,idle;1,CCW;13,CHAPTER,configuration"
'
'Announce16:
'Befehl &H10
'liest die Spannung an der cw Grenze, Eichung (noch vor hardware Limit)
'read voltage for cw limit, calibration (before hardware limit)
Data "16;ou,calibration;1;0,idle;1,CW;13,CHAPTER,configuration"
'
'Announce17:
'Befehl &H11
'liest limit
'read limit
Data "17;as,at limit;1;0,ok;1,at limit"
'
'Announce18:
'Befehl &HF0<n><m>
'liest announcements
'read n announcement lines
Data "240;an,ANNOUNCEMENTS;145;31,start at;31,lines;14,CHAPTER,ADMINISTRATION"
'
'Announce19:                                                  '
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20"
'
'Announce20:                                                  '
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
'Announce21:
'Befehl &HFE :
'eigene Individualisierung schreiben
'write individualization
Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,2,{0 to 127};a,SERIAL,1;14,CHAPTER,ADMINISTRATION"
'
'Announce22:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,2,{0 to 127};a,SERIAL,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8N1;14,CHAPTER,ADMINISTRATION"
'
'Announce24:
Data "L;language name;english;deutsch"
'
'Announce35:
Data "L;RC5 rotator control;RC5 rotator control;RC5 Rotorsteuerung;control;control;Steuerung;antenna position;antenna position;Antennen Position;"
'
'Announce25:
Data "L;operation;operation;Bedienung;preset position;preset position;Vorgabe Position;motor ccw;motor ccw;Motor ccw;motor cw;motor cw;Motor cw;"
'
'Announce26:
Data "L;motor stop;motor stop;stoppt Motor;antenna direction limit;antenna direction limit;Grenze fuer Antennen Richtung;values 1;values 1;Werte 1;"
'
'Announce27:
Data "L;values 2;values 2;Werte 2;calibration;calibration;Eichung;at limit;at limit;an der Grenze"
'
'Announce28:
' - no operate command is done before Control_on is set
Data "R !$4 !$5 !$6 !$8 IF $2=0"
'
'Announce29:
' - motor at limit will switch off , no need for logic device to send switch off command
Data "R $7 IF $15=1"
'
'Announce30:
'No Preset If hardwarelimit
Data "R !$4 IF $15=1"