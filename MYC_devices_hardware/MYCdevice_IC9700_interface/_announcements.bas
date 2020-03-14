' name : _announcements.bas
' 20200310
'
Announce:
'Befehl &H00
'eigenes basic 'Announcement lesen
'basic 'Announcement is read to I2C or output
Data "0;m;DK1RI;IC9700 Interface;V01.2;1;175;2;969;1-1"
'
'Announce1:
'Befehl 256 &H0100: --> Code 00 (05)
'Frequenz schreiben
'write Frequency
Data "256;op,freqency;1;82000000,{1440000 to 1479999999, 430 to 449999999,1240 to 12399999999};lin;Hz"
'
'Announce2:
'Befehl 257 &H0101: --> Code 03
'Frequenz lesen
'read Frequency
Data "257;ap,as256"
'
'Announce3:
'Befehl 258 &H0102: --> Code 01 (06)
'Mode schreiben
'write mode
Data "258;os,mode;2;0,LSB;1,USB;1,AM;3,CW;4,RTTY;5,FM;6,CW-R;7,RTTY-R;8,DV;9,DD;0,FIL1;1,FIL2;2.FIL3"
'
'Announce4:
'Befehl 259 &H0103: -> Code 04
'Mode lesen
'read mode
Data "259,as258"
'
'Announce5:
'Befehl 260 &H0104: -->  Code 02
'Bandgrenze lesen
'read band edge
Data "260;ap,band edge frequencies;1;70000000,{0 to 74800000},low;lin;Hz;70000000,{0 to 74800000},high;lin;Hz"
'
'Announce6:
'Befehl 261 &H0105: --> Code 07
'Vfo Mode setzen
'set vfo mode
Data "261;ou,set vfo mode;1;0,idle;1,VFO mode"
'
'Announce7:
'Befehl 262 &H0106: --> Code 07
'Vfo Mode schreiben
'write vfo mode
Data "262;os,vfo mode;1;0,A;1,B;2,A=B;3,A<>B"
'
'Announce8:
'Befehl 263 &H0107: --> Code 07D2
'main band selection
'main band selection
Data "263;os,main band selection ;1;0.main;1,sub"
'
'Announce9:
'Befehl 264 &H0108: --> Code 07D2
'main band selection
'main band selection
Data "264;as,as263"
'
'Announce10:
'Befehl 265 &H0109: --> Code 08
'set memory mode
'set memory mode
Data "263;ou,memory mode;1;0.idle;1,memory mode"
'
'Announce11:
'Befehl 266 &H010A: --> Code 08
'select memory
'select memory
Data "264;op,vfo to memory;1;107,{1 to 99,1A,1B,2A,2NB,3A,3C,C1,C2};lin;-"
'
'Announce12:
'Befehl 267 &H010B: --> Code 09
'Vfo und Mode nach memory schreiben
'write vfo and mode to memory
Data "265;ou,copy vfo and mode to memory;1;0,idle;1,copy to memory"
'
'Announce13:
'Befehl 268 &H010C: --> Code 0A
'memory nach Vfo und mode schreiben
'write memory to vfo and mode
Data "268;ou,copy memory to vfo and mode;1;0,idle;1,copy to vfo and mode"
'
'Announce14:
'Befehl 269 &H010D: --> Code 0B
'memory loeschen
'clear memory
Data "269;ou,clear memory;1;0,idle;1,clear memory"
'
'Announce15:
'Befehl 270 &H010E: --> Code 0C
'Duplex offset
'Duplex offset
Data "270;op,Duplex offset;1;1000000,{0 to 99000000,lin;Hz"
'
'Announce16:
'Befehl 271 &H010F: --> Code 0D
'Duplex offset
'Duplex offset
Data "271;ap,as 270"
'
'Announce17:
'Befehl 272 &H0110: --> Code 0E00..
'start scan mode
'start scan mode
Data "272;os,start scan mode;1;0,stop;1,prog memory;2,prog;3,frequncy;4,fine;5,fine delta;6,memory;7,select memory;8,mode select"
'
'Announce18:
'Befehl 273 &H0111: --> Code 0EA1 - A7
'scan span waehlen
'select scan span
Data "273;os,select scan span;1;0,5kHz;1,10kHz;2,20kHz;3,50kHz;4,100kHz;5,500kHz;6,1MHz"
'
'Announce19:
'Befehl 274 &H0112:--> Code 0EB0
'clear select chanal
'clear select chanal
Data "270,ou,clear select chanal;1;0,idle;1,set"
'
'Announce20:
'Befehl 275 &H0113: --> Code 0EB1
'select chanal
'select chanal
Data "275,os,select chanal;1;0,1;1,2;2,3"
'
'Announce21:
'Befehl 276 &H0114: --> Code 0EB2
'Set for select memory scan
'Set for select memory scan
Data "276,os,Set for select memory scan;0;1,sel1;1,sel2;2,sel3"
'
'Announce22:
'Befehl 277 &H0115: --> Code 0ED0, 0ED3
'scan resume
'scan resume
Data "277;os,scan resume;1;0,off;1,on"
'
'Announce23:
'Befehl 278 &H0116: Code 0F
'split
'split
Data "278;os,split;1;0,split off;1,split on;2,simplex;3,dup-;4,dup;5+,RPS"
'
'Announce24:
'Befehl 279 &H0117: --> Code 0F
'split
'split
Data "279;as,split;1;0,split off;1,split on;2,dup-;3,dup+;4,RPS"
'
'Announce25:
'Befehl 280 &H0118: --> Code 10
'tuning step
'tuning step
Data "280;os,tuning step;1;0,off;1,100;2,500,3;1k;4,5k;5,6.25;7,10k;8,12.5k;7,20k;8,25k;9,50k;10,100k"
'
'Announce26:
'Befehl 281 &H0119:  --> Code 10
'tuning step
'tuning step
Data "281;as,as280"
'
'Announce27:
'Befehl 282 &H011A: -->  Code 11
'Abschwaecher
'attenuator
Data "282;os,attenuator;1;0,off;1,10dB"
'
'Announce28:
'Befehl 283 &H011B: --> Code 11
'Abschwaecher
'attenuator
Data "283;as,as282"
'
'Announce29:
'Befehl 284 &H011C: --> Code 13
'aktuelle Sprachausgabe
'actual speech
Data "284;os,speech;1;0,all;1,freq and smeter;2,mode"
'
'Announce30:
'Befehl 285 &H011D: --> Code 1401
'Lautstaerke
'AF level
Data "285;op,AF level;1;256;lin;%"
'
'Announce31:
'Befehl 286 &H011E: --> Code 1401
'Lautstaerke
'AF level
Data "286;ap,as285"
'
'Announce32:
'Befehl 287 &H011F: --> Code 1402
'Hf Pegel
'RF level
Data "287;op,RF level;1;256;lin;%"
'
'Announce33:
'Befehl 288 &H0120: --> Code 1402
'Hf Pegel
'RF level
Data "287;ap,as286"
'
'Announce34:
'Befehl 289 &H0121: --> Code 1403
'Squelch
'Squelch
Data "289;op,Squelch;1;256,{0 to 100};lin;%"
'
'Announce35:
'Befehl 290 &H0122: --> Code 1403
'Squelch
'Squelch
Data "290;ap,as289"
'
'Announce36:
'Befehl 291 &H0123: --> Code 1406
'Noise reduction
'Noise reduction
Data "291;op,Noise reduction;1;256;lin;%"
'
'Announce37:
'Befehl 292 &H0124: --> Code 1406
'Noise reduction
'Noise reduction
Data "292;ap,as291"
'
'Announce38:
'Befehl 293 &H0125: --> Code 1407
'inner Twin PBT
'inner Twin PBT
Data "293;op, PBT1;1;256;lin;-"
'
'Announce39:
'Befehl 294 &H0126: --> Code 1407
'inner Twin PBT
'inner Twin PBT
Data "294;ap,as293"
'
'Announce40:
'Befehl 295 &H0127: --> Code 1408
'outer Twin PBT
'outer Twin PBT
Data "295;op,PBT2;1;256;lin;-"
'
'Announce41:
'Befehl 296 &H0128: --> Code 1408
'outer Twin PBT
'outer Twin PBT
Data "296;ap,as295"
'
'Announce42:
'Befehl 297 &H0129: --> Code 1409
'CW Pitch
'CW Pitch
Data "297;op,CW Pitch;1;256,{300 to 900};lin;Hz"
'
'Announce43:
'Befehl 298 &H012A: --> Code 1409
'CW Pitch
'CW Pitch
Data "298;ap,as297"
'
'Announce44:
'Befehl 299 &H012B: --> Code 140A
'Hf Leistung
'Rf power
Data "299;op,Rf power;1;256,{0 to 100};lin;%"
'
'Announce45:
'Befehl 300 &H012C: --> Code 140A
'Hf Leistung
'Rf power
Data "300;ap,as299"
'
'Announce46:
''Befehl 301 &H012D: --> Code 140B
'Mic Pegel
'Mic level
Data "301;op,Mic level;1;256,{0 to 100};lin;%"
'
'Announce47:
'Befehl 302 &H012E: --> Code 140B
'Mic Pegel
'Mic level
Data "302;ap,as301"
'
'Announce48:
'Befehl 303 &H012F : --> Code 140C
'CW Geschwindigkeit
'key speed
Data "303;op,key speed;1;256,{6 to 48};lin;wpm"
'
'Announce49:
'Befehl 304 &H0130: --> Code 140C
'CW Geschwindigkeit
'key speed
Data "304;ap,as303"
'
'Announce50:
'Befehl 305 &H0131: --> Code 140D
'Notch
'Notch
Data "306;op,Notch;1;256,{0 to 100};lin;%"
'
'Announce51:
'Befehl 306 &H0132: --> Code 140D
'Notch
'Notch
'Data "306;ap,as305"
'
'Announce52:
'Befehl 307 &H0133: --> Code 140E
'Comp
'Comp
Data "307;op,comp;1;256,{0 to 10};lin;-"
'
'Announce53:
'Befehl 308 &H0134: --> Code 140E
'Comp
'Comp
Data "308;ap,as307"
'
'Announce54:
'Befehl 309 &H0135: --> Code 140F
'Break in delay
'Break in delay
Data "309;op,break in delay;1;256,{2.0 to 13.0};lin;d"
'
'Announce55:
'Befehl 310 &H0136: --> Code 140F
'Break in delay
'Break in delay
Data "310;ap,as309"
'
'Announce56:
'Befehl 311 &H0137: --> Code 1412
'NB Pegel
'NB level
Data "311;op,NB level;1;256,{0 to 100};lin;%"
'
'Announce57:
'Befehl 312 &H0138: --> Code 1412
'NB Pegel
'NB level
Data "312;ap,as311"
'
'Announce58:
'Befehl 313 &H0139: --> Code 1415
'Monitor Pegel
'monitor level
Data "313;op,monitor level;1;256,{0 to 100};lin;%"
'
'Announce59:
'Befehl 314 &H013A: --> Code 1415
'Monitor Pegel
'monitor level
Data "314;ap,as313"
'
'Announce60:
'Befehl 315 &H013B: --> Code 1416
'VOX Pegel
'VOX level
Data "315;op,vox level;1;256,{0 to 100};lin;%"
'
'Announce61:
'Befehl 316 &H013C: --> Code 1416
'VOX Pegel
'VOX level
Data "316;ap,as315"
'
'Announce62:
'Befehl 317 &H013D: --> Code 1417
'AnitVOX Pegel
'AntiVOX level
Data "317;op,antivox level;1;256,{0 to 100};lin;%"
'
'Announce63:
'Befehl 318 &H013E:  --> Code 1417
'AnitVOX Pegel
'AntiVOX level
Data "318;ap,as317"
'
'Announce64:
'Befehl 319 &H013F: --> Code 1419
'Helligkeit
'brightness
Data "319;op,brightness;1;256,{0 to 100};lin;%"
'
'Announce65:
'Befehl 320 &H0140: --> Code 1419
'Helligkeit
'brightness
Data "320;ap,as319"
'
'Announce66:
'Befehl 321 &H0141: --> Code 1501
'noise or S-meter squelch status
'noise or S-meter squelch status
Data "321;as,noise or S-meter squelch status;1;0,off;1,on "
'
'Announce67:
'Befehl 322 &H0142: --> Code 1502
'S meter Pegel
's meter level
Data "322;as,s meter level;1;256,{121{0 to 9},135{0 to 62}}"
'
'Announce68:
'Befehl 323 &H0143 -->  Code 1505
'various squelch functions status
'various squelch functions status
Data "319;as;various squelch functions status;1;0,off;1,on "
'
'Announce69:
'Befehl 324 &H0144 -->  Code 1507
'OFV
'OFV
Data "319;as;OFV;1;0,off;1,on "
'
'Announce70:
'Befehl 325 &H0145: -->  Code 1511
'Leistung
'PO meter
Data "325;ap,PO meter;1;256,{143,{0 TO 50},113,{51 to 150};lin;%"
'
'Announce71:
'Befehl 326 &H0146: -->  Code 1512
'SWR meter
'SWR meter
Data "326;ap;SWR meter;1;256,49,{1.00 to 1.50},32,{1,51 to 2.00},40,{2,01 to 3,00},135,{3,01 to 6.00};lin;-"
'
'Announce72:
'Befehl 327 &H0147: --> Code 1513
'ALC meter
'ALC meter
Data "327;ap;ALC meter;1;121,{0 to 100};lin;%"
'
'Announce73:
'Befehl 328 &H0148: -->  Code 1514
'Comp meter
'comp meter
Data "328;ap;comp meter;1;256,130,{0 to 15.0},126,{15,1 to 30.0};lin;dB"
'
'Announce74:
'Befehl 329 &H0149: --> Code 1515
'Vsupply meter
'vsupply meter
Data "329;ap;v supply;1;256,14,{0 to 10},246,{10 to 17};lin;V"
'
'Announce75:
'Befehl 330 &H014A: --> Code 1516
'Isupply meter
'isupply meter
Data "330;ap;i supply;1;256,98,{0 to 10.0},158,{10.1 to 26.0};lin;A"
'
'Announce76:
'Befehl 331 &H014B: --> Code 1602
'Preamp
'Preamp
Data "326;os,preamp;1;0,off;1,preamp1;2,ext;3,preamp+ext"
'
'Announce77:
'Befehl 332 &H014C: --> Code 1602
'Preamp
'Preamp
Data "332;as,as331"
'
'Announce78:
'Befehl 333 &H014D: --> Code 1612
'AGC
'AGC
Data "333;os,AGC;1;0,off;1,fast;2,med;3,slow"
'
'Announce79:
'Befehl 334 &H014E: --> Code 1612
'AGC
'AGC
Data "334;as,as333"
'
'Announce80:
'Befehl 335 &H014F: --> Code 1622
'Noise blanker
'Noise blanker
Data "335;os,Noise blanker;1;0,off;1,on"
'
'Announce81:
'Befehl 336 &H0150: --> Code 1622
'Noise blanker
'Noise blanker
Data "336;as,as335"
'
'Announce82:
'Befehl 337 &H0151: --> Code 1640
'Noise reduction
'Noise reduction
Data "337;os,Noise reduction;1;0,off;1,on"
'
'Announce83:
'Befehl 338 &H0152: --> Code 1640
'Noise reduction
'Noise reduction
Data "338;as,as337"
'
'Announce84:
'Befehl 339 &H0153: --> Code 1641
'Auto notch
'Auto notch
Data "339;os,Auto notch;1;0,off;1,on"
'
'Announce85:
'Befehl 340 &H0154: --> Code 1641
'Auto notch
'Auto notch
Data "340;as,as339"
'
'Announce86:
'Befehl 341 &H0155: --> Code 1642
'Repeater tone
'Repeater tone
Data "341;os,Repeater tone;1;0,off;1,on"
'
'Announce87:
'Befehl 342 &H0156: -->  Code 1642
'Repeater tone
'Repeater tone
Data "342;as,as341"

'Announce88:
'Befehl 343 &H0157: --> Code 1643
'Tone squelch
'Tone squelch
Data "343;os,Tone squelch;1;0,off;1,on"
'
'Announce89:
'Befehl 344 &H0158: -->  Code 1643
'Tone squelch
'Tone squelch
'Data "344;as,as343"
'
'Announce90:
'Befehl 345 &H0159: --> Code 1644
'Speech compressor
'Speech compressor
Data "345;os,speech compressor;1;0,off;1,on"
'
'Announce91:
'Befehl 346 &H015A: --> Code 1644
'Speech compressor
'Speech compressor
Data "346;as,as345"
'
'Announce92:
'Befehl 347 &H015B: --> Code 1645
'Monitor
'Monitor
Data "347;os,Monitor;1;0,off;1,on"
'
'Announce93:
'Befehl 348 &H015C: --> Code 1645
'Monitor
'Monitor
Data "348;as,as347"
'
'Announce94:
'Befehl 349 &H015D: --> Code 1646
'VOX
'VOX
Data "349;os,VOX;1;0,off;1,on"

'Announce95:
'Befehl 350 &H015E: --> Code 1646
'VOX
'VOX
Data "350;as,as349"
'
'Announce96:
'Befehl 351 &H015F: --> Code 1647
'BK
'BK
Data "351;os,BK;1;0,off;1,semi;2,full"
'
'Announce97:
'Befehl 352 &H0160: --> Code 1647
'BK
'BK
Data "352;as,as351"
'
'Announce98:
'Befehl 353 &H0161: --> Code 1648
'Manual notch
'Manual notch
Data "353;os,manual notch;1;0,off;1,on"
'
'Announce99:
'Befehl 354 &H0162: --> Code 1648
'Manual notch
'Manual notch
Data "354;as,as353"
'
'Announce100:
'Befehl 355 &H0163: --> Code 164A
'AFC
'AFC
Data "355;os,AFC;1;0,off;1,on"
'
'Announce101:
'Befehl 356 &H0164: --> Code 164A
'AFC
'AFC
Data "356;as,as355"
'
'Announce102:
'Befehl 357 &H0165: --> Code 164B
'DTCS
'DTCS
Data "357;os,DTCS;1;0,off;1,on"
'
'Announce103:
'Befehl 358 &H0166: --> Code 164B
'DTCS
'DTCS
Data "358;as,as357"
'
'Announce104:
'Befehl 359 &H0167: --> Code 164F
'Twin Peak Filter
'Twin Peak Filter
Data "359;os,Twin Peak Filter;1;0,off;1,on"
'
'Announce105:
'Befehl 360 &H0168: --> Code 164F
'Twin Peak Filter
'Twin Peak Filter
Data "360;as,as359"
'
'Announce106:
'Befehl 361 &H0169: --> Code 1650
'Dial lock
'Dial lock
Data "357;os,Dial lock;1;0,off;1,on"
'
'Announce107:
'Befehl 362 &H016A:  --> Code 1650
'Dial lock
'Dial lock
Data "362;as,as361"
'
'Announce108:
'Befehl 363 &H016B: --> Code 1656
'DSP filter type
'DSP filter type
Data "363;os,DSP filter type;1;0,sharp;1,soft"
'
'Announce109:
'Befehl 364 &H016C: --> Code 1656
'DSP filter type
'DSP filter type
Data "364;as,as363"
'
'Announce110:
'Befehl 365 &H016D: --> Code 1657
'Manual notch width
'Manual notch width
Data "365;os,Manual notch width;1;0,wide;1,mid;2,narrow"
'
'Announce111:
'Befehl 366 &H016E: --> Code 1657
'Manual notch width
'Manual notch width
Data "366;as,as365"
'
'Announce112:
'Befehl 367 &H016F: --> Code 1658
'SSB transmit bandwidth
'SSB transmit bandwidth
Data "367;os,SSB transmit bandwidth;1;0,wide;1,mid;2,narrow"
'
'Announce113:
'Befehl 368 &H0170: --> Code 1658
'SSB transmit bandwidth
'SSB transmit bandwidth
Data "368;as,as367"
'
'Announce114:
'Befehl 369 &H0171: --> Code 1659
'Dual watch
'Dual watch
Data "369;os,Dual watch;1;0,off;1,on"
'
'Announce115:
'Befehl 370 &H0172: --> Code 1659
'Dual watch
'Dual watch
Data "370;as,as369"
'
'Announce116:
'Befehl 371 &H0173: --> Code 165A
'Satellite mode
'Satellite mode
Data "371;os,Satellite mode;1;0,off;1,on"
'
'Announce117:
'Befehl 372 &H0174: --> Code 165A
'Satellite mode
'Satellite mode
Data "372;as,as371"
'
'Announce118:
'Befehl 373 &H0175: --> Code 165B
'DSQL/CSQL
'DSQL/CSQL
Data "373;os,DSQL/CSQL;1;0,off;1,on"
'
'Announce119:
'Befehl 374 &H0176: --> Code 165B
'DSQL/CSQL
'DSQL/CSQL
Data "374;as,as373"
'
'Announce120:
'Befehl 375 &H0177: --> Code 165C
'GPS TX
'GPS TX
Data "375;os,GPS TX;1;0,off;1,PRS;2,NMEA"
'
'Announce121:
'Befehl 376 &H0178: --> Code 165C
'GPS TX
'GPS TX
Data "376;as,as375"
'
'Announce122:
'Befehl 377 &H0179: --> Code 165D
'SQL
'SQL
Data "377;os,SQL;1;0,off;1,Tone;2,TSQL;3,DTCS;4,DTCS(T);5,Tone(T)-DTCS(R);6,DTCS(T)-TSQL(R);7,Tone(T)-TSQL(R)"
'
'Announce123:
'Befehl 378 &H017A: --> Code 165D
'SQL
'SQL
Data "378;as,as377"
'
'Announce124:
'Befehl 379 &H017B: --> Code 1665
'IP+
'IP+
Data "375;os,IP+;1;0,off;1,on"
'
'Announce125:
'Befehl 380 &H017C: --> Code 1665
'iP+
'IP+
Data "380;as,as379"
'
'Announce126:
'Befehl 381 &H17D: --> Code 17
'Cw message
'Cw message
Data "381;om,Cw message ;30,{0 to 9,a to z, A to Z,/,?,.,;,(,),-,=,+, ,0x27,0x2C,0x22,@}"
'
'Announce127:
'Befehl 382 &H017E: --> Code 18
'Aus / Einschalten
'switch off / on
Data "382;os,main switch;1;0,off;1,on"
'
'Announce128:
'Befehl 383 &H017F: --> Code 19
'ID
'Id
Data "383;aa,id;b"
'
'Announce129:
'Befehl 384 &H0180: --> Code 1A00
'memory Frequenz schreiben
'Write Memory frequency
Data "384;op,memory frequency;107;82000000,{1440000 to 1479999999, 430 to 449999999,1240 to 12399999999};lin;Hz"
'
'Announce130:
'Befehl 385 &H0181: --> Code 1A00
'memory Frequenz lesen
'read memory frequency
Data "385;ap,as384"

'Announce131:
'Befehl 386 &H0182: --> Code 1A00
'memory mode schreiben
'Write Memory mode
Data "386;os, mode;107;0,LSB;1,USB;1,AM;3,CW;4,RTTY;5,FM;6,CW-R;7,RTTY-R;8,DV;9,DD"
'
'Announce132:
'Befehl 387 &H0183: --> Code 1A00
'memory mode lesen
'read Memory mode
Data "387;as,as386"
'
'Announce133:
'Befehl 388 &H0184: --> Code 1A00
'memory filter schreiben
'Write Memory filter
Data "388:os, filter;107;0,Fil1,1;Fil2;2,Fil3"
'
'Announce134::
'Befehl 389 &H0185: --> Code 1A00
'memory filter lesen
'read Memory filter
Data "389;as,as388"
'
'Announce135:
'Befehl 390 &H0186: --> Code 1A00
'memory data mode schreiben
'Write Memory data mode
Data "390;os,memory data mode;107;0,off;1,on"
'
'Announce136:
'Befehl 391 &H0187: --> Code 1A00
'memory data mode lesen
'read Memory data mode
Data "391;as,as390"
'
'Announce137:
'Befehl 392 &H0188: --> Code 1A00
'memory tone schreiben
'Write Memory tone
Data "391;os,tone;107;0.off;1;tone;2;tsql;3,DTCS"
'
'Announce138::
'Befehl 393 &H0189: --> Code 1A00
'memory tone lesen
'read Memory tone
Data "394;as,as393"
'
'Announce139:
'Befehl 394 &H018A: --> Code 1A00
'memory duplex schreiben
'Write Memory duplex
Data "394;os,duplex;107;0.off;1;-;2;+;3,RPS"
'
'Announce140::
'Befehl 395 &H018B: --> Code 1A00
'memory duplex lesen
'read Memory duplex
Data "395;as,as394"
'
'Announce141:
'Befehl 396 &H018C: --> Code 1A00
'memory DQQL/CSQL schreiben
'Write Memory DQQL/CSQL
Data "396;os,DSQL/CSQL;107;0.off;1;DSQL;2,CSQL"
'
'Announce142::
'Befehl 397 &H018D: --> Code 1A00
'memory DQQL/CSQL lesen
'read Memory DQQL/CSQL
Data "397;as,as396"
'
'Announce143:
'Befehl 398 &H018E: --> Code 1A00
'memory tone frequenz schreiben
'Write Memory tone frequency
Data "398;os,memory tone frequency;107;0,67.0;1,69.3;2,71.9;3,74.4;4,77,0;5,79.7;6,82.5;7,85.4;8,88.5;9,91.5;10,94.8,11,97.4;"
Data "398;os,memory tone frequency;12,100.0;13,103.5;14,107,2;15,110.9;16,114.8;17,118.8;18,123.0;19,127.3;20,131.8;"
Data "398;os,memory tone frequency;21,136.5;22,141.3;23,146.2;24,151.4;25,156.7;26,159.8;27,162.2;28,165.5;29,167.9;"
Data "398;os,memory tone frequency;30,171.3;31,173.8;32,177.3;33,179.9;34,183,5;35,186.2;36,189.9;37,192.8;38,196.6;"
Data "398;os,memory tone frequency;39,199.5;40,203.5;41,206.5;42,210.7;43,218.1;44,225,7;45,229.1;46,233.6;47,241.8;48,250.2;49,254.1"
'
'Announce144:
'Befehl 399 &H018F: --> Code 1A00
'memory tone frequenz lesen
'read memory tone frequency
Data "399;as,as398"
'
'Announce145:
'Befehl 400 &H0190: --> Code 1A00
'memory tone squelch schreiben
'Write memory tone squelch
Data "400;os,memory tone squelch;107;0,67.0;1,69.3;2,71.9;3,74.4;4,77,0;5,79.7;6,82.5;7,85.4;8,88.5;9,91.5;10,94.8,11,97.4;"
Data "400;os,memory tone squelch;12,100.0;13,103.5;14,107,2;15,110.9;16,114.8;17,118.8;18,123.0;19,127.3;20,131.8;"
Data "400;os,memory tone squelch;21,136.5;22,141.3;23,146.2;24,151.4;25,156.7;26,159.8;27,162.2;28,165.5;29,167.9;"
Data "400;os,memory tone squelch;30,171.3;31,173.8;32,177.3;33,179.9;34,183,5;35,186.2;36,189.9;37,192.8;38,196.6;"
Data "400;os,memory tone squelch;39,199.5;40,203.5;41,206.5;42,210.7;43,218.1;44,225,7;45,229.1;46,233.6;47,241.8;48,250.2;49,254.1"
'
'Announce146:
'Befehl 401 &H0191: --> Code 1A00
'memory tone squelch lesen
'read memory tone squelch
Data "401;as,as400"
'
'Announce147:
'Befehl 402 &H0192: --> Code 1A00
'memory DTCS schreiben
'Write Memory DTCS
Data "402;op,DTCS;107;512;lin;-"
'
'Announce148::
'Befehl 403 &H0193: --> Code 1A00
'memory DTCS lesen
'read Memory DTCS
Data "403;ap,as402"
'
'Announce149:
'Befehl 404 &H0194: --> Code 1A00
'memory DTCS pol  schreiben
'Write Memory DTCS pol
Data "404;os,DTCS polarity;107;0,normal;1.r normal - t rev;2,r rev - t normal;3 rev"
'
'Announce150::
'Befehl 405 &H0195: --> Code 1A00
'memory DTCS pol lesen
'read Memory DTCS pol
Data "405;as,as404"
'
'Announce151:
'Befehl 406 &H0196: --> Code 1A00
'memory DV code  schreiben
'Write Memory DV code
Data "406;os,DV code;107;100,;lin;-"
'
'Announce152::
'Befehl 407 &H0197: --> Code 1A00
'memory DV code lesen
'read Memory DV code
Data "407as,as406"
'
'Announce153:
'Befehl 408 &H0198: --> Code 1A00
'memory duplex offset  schreiben
'Write Memory duplex offset
Data "408;os,duplex offset;107;1000000,{0 to 99000000,lin;Hz"
'
'Announce154::
'Befehl 409 &H0199: --> Code 1A00
'memory duplex offset lesen
'read Memory duplex offset
Data "409;as,as408"
'
'Announce155:
'Befehl 410 &H019A: --> Code 1A00
'memory UR  schreiben
'Write UR offset
Data "408;om,UR;107;8"
'
'Announce156::
'Befehl 411 &H019B: --> Code 1A00
'memory UR lesen
'read Memory UR
Data "411;as,as410"
'
'Announce157:
'Befehl 412 &H019C: --> Code 1A00
'memory R1  schreiben
'Write memory R1
Data "412;om,R1;107;8"
'
'Announce158::
'Befehl 413 &H019D: --> Code 1A00
'memory R1 lesen
'read Memory R1
Data "413;as,as412"
'
'Announce159:
'Befehl 414 &H019E: --> Code 1A00
'memory R2  schreiben
'Write R2 offset
Data "414;om,R2;107;8"
'
'Announce160::
'Befehl 415 &H019F: --> Code 1A00
'memory R2 lesen
'read Memory R2
Data "415;as,as414"
'
'Announce161:
'Befehl 416 &H01A0: --> Code 1A00
'memory Frequenz schreiben split
'Write Memory frequency split
Data "416;op,memory frequency split;107;82000000,{1440000 to 1479999999, 430 to 449999999,1240 to 12399999999};lin;Hz"
'
'Announce162:
'Befehl 417 &H01A1: --> Code 1A00
'memory Frequenz lesen split
'read memory frequency split
Data "417;ap,as416"

'Announce163:
'Befehl 418 &H01A2: --> Code 1A00
'memory mode schreiben split
'Write Memory mode split
Data "418;os, mode split;107;0,LSB;1,USB;1,AM;3,CW;4,RTTY;5,FM;6,CW-R;7,RTTY-R;8,DV;9,DD"
'
'Announce164:
'Befehl 419 &H01A3: --> Code 1A00
'memory mode lesen split
'read Memory mode split
Data "419;as,as418"
'
'Announce165:
'Befehl 420 &H01A4: --> Code 1A00
'memory filter schreiben split
'Write Memory filter split
Data "420:os, filter split;107;0,Fil1,1;Fil2;2,Fil3"
'
'Announce166::
'Befehl 421 &H01A5: --> Code 1A00
'memory filter lesen split
'read Memory filter split
Data "421;as,as420"
'
'Announce167:
'Befehl 422 &H01A6: --> Code 1A00
'memory data mode schreiben split
'Write Memory data mode split
Data "422;os,memory data mode split;107;0,off;1,on"
'
'Announce168:
'Befehl 423 &H01A7: --> Code 1A00
'memory data mode lesen split
'read Memory data mode split
Data "423;as,as422"
'
'Announce169:
'Befehl 424 &H01A8: --> Code 1A00
'memory tone schreiben split
'Write Memory tone split
Data "424;os,tone split;107;0.off;1;tone;2;tsql;3,DTCS"
'
'Announce170::
'Befehl 425 &H01A9: --> Code 1A00
'memory tone lesen split
'read Memory tone split
Data "425;as,as4243"
'
'Announce171:
'Befehl 426 &H01AA: --> Code 1A00
'memory duplex schreiben split
'Write Memory duplex split
Data "426;os,duplex split;107;0.off;1;-;2;+;3,RPS"
'
'Announce172::
'Befehl 427 &H01AB: --> Code 1A00
'memory duplex lesen split
'read Memory duplex split
Data "427;as,as426"
'
'Announce173:
'Befehl 428 &H01AC: --> Code 1A00
'memory DQQL/CSQL schreiben split
'Write Memory DQQL/CSQL split
Data "428;os,DSQL/CSQL split;107;0.off;1;DSQL;2,CSQL"
'
'Announce174::
'Befehl 429 &H01AD: --> Code 1A00
'memory DQQL/CSQL lesen split
'read Memory DQQL/CSQL split
Data "429;as,as428"
'
'Announce175:
'Befehl 430 &H01AE: --> Code 1A00
'memory tone frequenz schreiben split
'Write Memory tone frequency split
Data "430;os,memory tone frequency split;107;0,67.0;1,69.3;2,71.9;3,74.4;4,77,0;5,79.7;6,82.5;7,85.4;8,88.5;9,91.5;10,94.8,11,97.4;"
Data "430;os,memory tone frequency split;12,100.0;13,103.5;14,107,2;15,110.9;16,114.8;17,118.8;18,123.0;19,127.3;20,131.8;"
Data "430;os,memory tone frequency split;21,136.5;22,141.3;23,146.2;24,151.4;25,156.7;26,159.8;27,162.2;28,165.5;29,167.9;"
Data "430;os,memory tone frequency split;30,171.3;31,173.8;32,177.3;33,179.9;34,183,5;35,186.2;36,189.9;37,192.8;38,196.6;"
Data "430;os,memory tone frequency split;39,199.5;40,203.5;41,206.5;42,210.7;43,218.1;44,225,7;45,229.1;46,233.6;47,241.8;48,250.2;49,254.1"
'
'Announce176:
'Befehl 431 &H01AF: --> Code 1A00
'memory tone frequenz lesen split
'read memory tone frequency split
Data "431;as,as430"
'
'Announce177:
'Befehl 432 &H01B0: --> Code 1A00
'memory tone squelch schreiben split
'Write memory tone squelch split
Data "432;os,memory tone squelch split;107;0,67.0;1,69.3;2,71.9;3,74.4;4,77,0;5,79.7;6,82.5;7,85.4;8,88.5;9,91.5;10,94.8,11,97.4;"
Data "432;os,memory tone squelch split;12,100.0;13,103.5;14,107,2;15,110.9;16,114.8;17,118.8;18,123.0;19,127.3;20,131.8;"
Data "432;os,memory tone squelch split;21,136.5;22,141.3;23,146.2;24,151.4;25,156.7;26,159.8;27,162.2;28,165.5;29,167.9;"
Data "432;os,memory tone squelch split;30,171.3;31,173.8;32,177.3;33,179.9;34,183,5;35,186.2;36,189.9;37,192.8;38,196.6;"
Data "432;os,memory tone squelch split;39,199.5;40,203.5;41,206.5;42,210.7;43,218.1;44,225,7;45,229.1;46,233.6;47,241.8;48,250.2;49,254.1"
'
'Announce178:
'Befehl 433 &H01B1: --> Code 1A00
'memory tone squelch lesen split
'read memory tone squelch split
Data "433;as,as432"
'
'Announce179:
'Befehl 434 &H01B2: --> Code 1A00
'memory DTCS schreiben split
'Write Memory DTCS split
Data "433;op,DTCS split;107;512;lin;-"
'
'Announce180::
'Befehl 435 &H01B3: --> Code 1A00
'memory DTCS lesen split
'read Memory DTCS split
Data "435;ap,as434"
'
'Announce181:
'Befehl 436 &H01B4: --> Code 1A00
'memory DTCS pol  schreiben split
'Write Memory DTCS pol split
Data "436;os,DTCS polarity split;107;0,normal;1.r normal - t rev;2,r rev - t normal;3 rev"
'
'Announce182::
'Befehl 437 &H01B5: --> Code 1A00
'memory DTCS pol lesen split
'read Memory DTCS pol split
Data "437;as,as436"
'
'Announce183:
'Befehl 438 &H01B6: --> Code 1A00
'memory code  schreiben split
'Write Memory DV code split
Data "438;os,DV code split;107;100,;lin;-"
'
'Announce184::
'Befehl 439 &H01B7: --> Code 1A00
'memory DV code lesen split
'read Memory DV code split
Data "439as,as438"
'
'Announce185:
'Befehl 440 &H01B8: --> Code 1A00
'memory duplex offset  schreiben split
'Write Memory duplex offset split
Data "440;os,duplex offset split;107;1000000,{0 to 99000000,lin;Hz"
'
'Announce186::
'Befehl 441 &H01B9: --> Code 1A00
'memory duplex offset lesen split
'read Memory dupl40 offset split
Data "441;as,as408"
'
'Announce187:
'Befehl 442 &H01BA: --> Code 1A00
'memory UR  schreiben split
'Write UR offset split
Data "442;om,UR split;107;8"
'
'Announce188::
'Befehl 443 &H01BB: --> Code 1A00
'memory UR lesen split
'read Memory UR split
Data "443;as,as440"
'
'Announce189:
'Befehl 444 &H01BC: --> Code 1A00
'memory R1  schreiben split
'Write memory R1 split
Data "444;om,R1 split;107;8"
'
'Announce190::
'Befehl 445 &H01BD: --> Code 1A00
'memory R1 lesen split
'read Memory R1 split
Data "445;as,as444"
'
'Announce191:
'Befehl 446 &H01BE: --> Code 1A00
'memory R2  schreiben split
'Write R2 offset split
Data "446;om,R2 split;107;8"
'
'Announce192::
'Befehl 447 &H01BF: --> Code 1A00
'memory R2 lesen split
'read Memory R2 split
Data "447;as,as446"
'
'Announce193:
'Befehl 448 &H03C0: --> Code 1A00
'memory name schreiben
'Write Memory name
Data "448;om,memory name;101;10"
'
'Announce194:
'Befehl 449 &H01C1: --> Code 1A00
'memory name lesen
'read memory name
Data "449;am,as448"
'
'Announce195:
'Befehl 450 &H03C2: --> Code 1A00
'memory select schreiben
'Write Memory select
Data "450;om,memory select;101;10"
'
'Announce196:
'Befehl 451 &H01C3: --> Code 1A00
'memory select lesen
'read memory select
Data "451;am,as450"
'
'Announce197:
'Befehl 452 &H01C4: --> Code 1A02
'8 Kanal memory keyer
'8 chanal memory keyer
Data "452;om,memory keyer;8;70,{0 to 9, A to Z, ,/,?,.,0x2c,0x5e,*,@}"
'
'Announce198:
'Befehl 453 &H01C5: -> Code 1A02
'8 Kanal memory keyer
'8 chanal memory keyer
Data "453,am,as452"
'
'Announce199:
'Befehl 454 &H01C6: --> Code 1A03
'selected CW Filter Bandbreite
'selected CW filter width
Data "454;op,CW filter width;1;10,{50 to 500};lin;Hz"
'
'Announce200:
'Befehl 455 &H01C7: --> Code 1A03
'selected CW Filter Bandbreite
'selected CW filter width
Data "455,ap,as454"
'
'Announce201:
'Befehl 456 &H01C8 --> Code 1A03
'selected SSB Filter Bandbreite
'selected SSB filter width
Data "456;op,SSB filter width;1;31,{600 to 3600};lin;Hz"
'
'Announce202:
'Befehl 457 &H01C9: --> Code 1A03
'selected SSB Filter Bandbreite
'selected SSB 'filter width
Data "457,ap,as456"
'
'Announce203:
'Befehl 458 &H01CA: --> Code 1A03
'selected RTTY Filter Bandbreite
'selected RTTY filter width
Data "458;op,RTTY filter width;1;10,{50 to 500};lin;Hz"
'
'Announce204:
'Befehl 459 &H01CB: --> Code 1A03
'selected RTTY Filter Bandbreite
'selected RTTY filter width
Data "459,ap,as458"
'
'Announce205:
'Befehl 460 &H01CC --> Code 1A03
'selected SSB Filter Bandbreite
'selected SSB filter width
Data "460;op,SSB filter width;1;31,{600 to 3600};lin;Hz"
'
'Announce206:
'Befehl 461 &H01CD: --> Code 1A03
'selected SSB Filter Bandbreite
'selected SSB 'filter width
Data "461,ap,as460"

'Announce207:
'Befehl 462 &H01CE: --> Code 1A04
'selected AM AGC Zeitkonstante
'selected AM AGC time constant
Data "462;op,AM time comstant;1;14,1,{off},13,{0 to 8.0};lin;Hz"
'
'Announce208:
'Befehl 463 &H01CF: --> Code 1A04
'selected AM AGC Zeitkonstante
'selected AM AGC time constant
Data "463,ap,as462"
'
'Announce209:
'Befehl 464 &H01D0: --> Code 1A04
'selected non AM AGC Zeitkonstante
'selected non AM AGC time constant
Data "465;op,non AM AGC time comstant;1;14;1,{off},13,{0 to 6.0};lin;s"
'
'Announce210:
'Befehl 465 &H01D1: --> Code 1A04
'selected non AM AGC Zeitkonstante
'selected non AM AGC time constant
Data "465,ap,as464"
'
'Announce211:
'Befehl 466 &H01D2: --> Code 1A050001
'HPF / LPF SSB
'HPF / LPF SSB
Data "466;op,SSB HPF / LPF;1;20,{through,100 to 2000};lin;Hz;20,{500 to 2400},though;lin;Hz"
'
'Announce212:
'Befehl 467 &H01D3 --> Code 1A0500001
'HPF / LPF SSB
'HPF / LPF SSB
Data "467;ap;as466"
'
'Announce213:
'Befehl 468 &H01D4: --> Code 1A050002
'SSB Bass Level
'SSB Bass Level
Data "468;op,SSB Bass Level;1;11,{-5 to 5};lin;-"
'
'Announce214:
'Befehl 469 &H01D5: --> Code 1A050002
'SSB Bass Level
'SSB Bass Level
Data "469;ap,as468"
'
'Announce215:
'Befehl 470 &H01D6: --> Code 01A05003
'SSB Hoehen Level
'SSB Treble Level
Data "3470;op,SSB Treble Level;1;11,{-5 to 5};lin;-"
'
'Announce216:
'Befehl 471 &H01D7: --> Code 1A050003
'SSB Hoehen Level
'SSB Treble Level
Data "471;ap,as470"
'
'Announce217:
'Befehl 472 &H01D8: --> Code 01A050004
'HPF / LPF AM
'HPF / LPF AM
Data "472;op,HPF / LPF AM;1;20,{through,100 to 2000};lin;Hz;20,{500 to 2400,though};lin;Hz"
'
'Announce218:
'Befehl 473 &H01D9: --> Code 1A050004
'HPF / LPF AM
'HPF / LPF AM
Data "473;ap;as472"
'
'Announce219:
'Befehl 474 &H01DA: --> Code 01A050005
'AM Bass Level
'AM Bass Level
Data "474;op,AM Bass Level;1;10,{-5 to 5};lin;-"
'
'Announce220:
'Befehl 475 &H01DB: --> Code 1A050005
'AM Bass Level
'AM Bass Level
Data "475;ap,as474"
'
'Announce221:
'Befehl 476 &H01DC: --> Code 1A050006
'AM Hoehen Level
'AM Treble Level
Data "476;op,AM Treble Level;1;10,{-5 to 5};lin;-"
'
'Announce222:
'Befehl 477 &H01DD: --> Code 1A050006
'AM Hoehen Level
'AM Treble Level
Data "477;ap,as476"
'
'Announce223:
'Befehl 478 &H01DE: --> Code 1A050007
'HPF / LPF FM
'HPF / LPF FM
Data "478;op,HPF / LPF FM;1;20,{through,100 to 2000};lin;Hz;20,{500 to 2400,though};lin;Hz"
'
'Announce224:
'Befehl 479 &H01DF: --> Code 1A050007
'HPF / LPF FM
'HPF / LPF FM
Data "479;ap;as478"
'
'Announce225:
'Befehl 480 &H01E0: --> Code 1A050008
'FM Bass Level
'FM Bass Level
Data "480;op,FM Bass Level;1;10,{-5 to 5};lin;-"
'
'Announce226:
'Befehl 481 &H01E1: --> Code 1A050008
'FM Bass Level
'FM Bass Level
Data "481;ap,as480"
'
'Announce227:
'Befehl 482 &H01E2: --> Code 1A050009
'FM Hoehen Level
'FM Treble Level
Data "482;op,FM Treble Level;1;10,{-5 to 5};lin;-"
'
'Announce228:
'Befehl 483 &H01E3: --> Code 1A050009
'FM Hoehen Level
'FM Treble Level
Data "483;ap,as482"
'
'Announce229:
'Befehl 484 &H01E4: --> Code 1A050010
'HPF / LPF DV
'HPF / LPF DV
Data "484;op,HPF / LPF DV;1;20,{through,100 to 2000};lin;Hz;20,{500 to 2400,though};lin; Hz"
'
'Announce230:
'Befehl 485 &H01E5: --> Code 1A050010
'HPF / LPF DV
'HPF / LPF DV
Data "485;ap;as484"
'
'Announce231:
'Befehl 486 &H01E6: --> Code 1A050011
'DV Bass Level
'DV Bass Level
Data "486;op,DV Bass Level   ;1;1;10,{-5 to 5};lin;-"
'
'Announce232:
'Befehl 487 &H01E7: --> Code 1A050011
'DV Bass Level
'DV Bass Level
Data "487;ap;as486"
'
'Announce233:
'Befehl 488 &H01E8: --> Code 1A050012
'DV Hoehen Level
'DV treble Level
Data "488;op,DV treble Level   ;1;1;10,{-5 to 5};lin;-"
'
'Announce234:
'Befehl 489 &H01E9: --> Code 1A050012
'DV Hoehen Level
'DV treble Level
Data "489;ap;as488"
'
'Announce235:
'Befehl 490 &H01EA: --> Code 1A050013
'HPF / LPF CW
'HPF / LPF CW
Data "490;op,HPF / LPF CW;1;20,{through,100 to 2000};lin;Hz;20,{500 to 2400,though};lin; Hz"
'
'Announce236:
'Befehl 491 &H01EB: --> Code 1A050013
'HPF / LPF CW
'HPF / LPF CW
Data "491;ap;as490"
'
'Announce237:
'Befehl 492 &H01EC: --> Code 1A050014
'HPF / LPF RTTY
'HPF / LPF RTTY
Data "492;op,HPF / LPF RTTY;1;20,{through,100 to 2000};lin;Hz;20,{500 to 2400,though};lin; Hz"
'
'Announce238:
'Befehl 493 &H01ED: --> Code 1A050014
'HPF / LPF RTTY
'HPF / LPF RTTY
Data "493;ap;as492"
'
'Announce239:
'Befehl 494 &H01EE: --> Code 1A050015
'SSB TX Bass Level
'SSB TX Bass Level
Data "394;op,SSB Tx Bass Level;1;10,{-5 to 5};lin;-"
'
'Announce240:
'Befehl 495 &H01EF: --> Code 1A050015
'SSB Tx Bass Level
'SSB Tx Bass Level
Data "495;ap,as494"
'
'Announce241:
'Befehl 496 &H01F0: --> Code 1A050016
'SSB Tx Hoehen Level
'SSB Tx Treble Level
Data "496;op,SSB Tx Treble Level;1;10,{-5 to 5};lin;-"
'
'Announce242:
'Befehl 497 &H01F1: --> Code 1A050016
'SSB Tx Hoehen Level
'SSB Tx Treble Level
Data "497;ap,as496"
'
'Announce243:
'Befehl 498 &H01F2: --> Code 1A050017
'SSB Tx wide  Bandbreite
'SSB Tx wide bandwidth
Data "498;os,SSB Tx wide bandwidth;2;0,0k1;1,0k2;2,0k3;3,0k5;0,2k5;1,2k7;2,2k8;3,2k9"
'
'Announce244:
'Befehl 499 &H01F3: --> Code 1A050017
'SSB Tx wide  Bandbreite
'SSB Tx wide bandwidth
Data "499;as,as399"
'
'Announce245:
'Befehl 500 &H01F4: --> Code 1A050018
'SSB Tx mid  Bandbreite
'SSB Tx mid bandwidth
Data "500;os,SSB Tx mid bandwidth;2;0,0k1;1,0k2;2,0k3;3,0k5;0,2k5;1,2k7;2,2k8;3,2k9"
'
'Announce246:
'Befehl 501 &H01F5: --> Code 1A050018
'SSB Tx mid  Bandbreite
'SSB Tx wide bandwidth
Data "501;as,as500"
'
'Announce247:
'Befehl 502 &H01F6: --> Code 1A050019
'SSB Tx narrow  Bandbreite
'SSB Tx narrow bandwidth
Data "502;os,SSB Tx narrow bandwidth;2;0,0k1;1,0k2;2,0k3;3,0k5;0,2k5;1,2k7;2,2k8;3,2k9"
'
'Announce348:
'Befehl 503 &H01F7: --> Code 1A050019
'SSB Tx narrow  Bandbreite
'SSB Tx narrow bandwidth
Data "503;as,as502"
'
'Announce349:
'Befehl 504 &H01F8: --> Code 1A050020
'SSB D  Bandbreite
'SSB D bandwidth
Data "504;os,SSB D bandwidth;2;0,0k1;1,0k2;2,0k3;3,0k5;0,2k5;1,2k7;2,2k8;3,2k9"
'
'Announce250:
'Befehl 505 &H01F9: --> Code 1A050020
'SSB D  Bandbreite
'SSB D bandwidth
Data "505;as,as504"
'
'Announce251:
'Befehl 506 &H01FA: --> Code 1A050021
'AM TX Bass Level
'AM TX Bass Level
Data "506;op,AM TX Bass Level;1;10,{-5 to 5};lin;-"
'
'Announce252:
'Befehl 507 &H01FB: --> Code 1A050021
'AM TX Bass Level
'AM TX Bass Level
Data "507;ap,as506"
'
'Announce253:
'Befehl 508 &H01FC: --> Code 1A050022
'AM Tx Hoehen Level
'AM Tx Treble Level
Data "508;op,AM TX Treble Level;1;10,{-5 to 5};lin;-"
'
'Announce254:
'Befehl 509 &H01FD: --> Code 1A050022
'AM Tx Hoehen Level
'AM Tx Treble Level
Data "509;ap,as5008"
'
'Announce255:
'Befehl 510 &H01FE: --> Code 1A050023
'FM Tx Bass Level
'FM Tx Bass Level
Data "510;op,FM Tx Bass Level;1;10,{-5 to 5};lin;-"
'
'Announce256:
'Befehl 511 &H01FF: --> Code 1A050023
'FM Tx Bass Level
'FM Tx Bass Level
Data "511;ap,as510"
'
'Announce257:
'Befehl 512 &H0200: --> Code 1A050024
'FM Tx Hoehen Level
'FM Tx Treble Level
Data "512;op,FM Tx Treble Level;1;10,{-5 to 5};lin;-"
'
'Announce258:
'Befehl 513 &H0201: --> Code 1A050024
'FM Tx Hoehen Level
'FM Tx Treble Level
Data "513;ap,as512"

'Announce259:
'Befehl 514 &H0202: --> Code 1A050025
'DV Bass Level
'DV Bass Level
Data "514;op,DV Bass Level;1;10,{-5 to 5};lin;-"
'
'Announce260:
'Befehl 515 &H0203: --> Code 1A050025
'DV Bass Level
'DV Bass Level
Data "515;ap,as514"
'
'Announce261:
'Befehl 516 &H0204: --> Code 1A050026
'DV Hoehen Level
'DV Treble Level
Data "516;op,DV Treble Level;1;10,{-5 to 5};lin;-"
'
'Announce262:
'Befehl 517 &H0205: --> Code 1A050026
'DV Hoehen Level
'DV Treble Level
Data "517;ap,as516"

'Announce263:
'Befehl 518 &H0206: --> Code 1A050027
'Beep Pegel
'Beep gain
Data "518;op,beep gain;1;255;lin;-"
'
'Announce264:
'Befehl 519 &H0207: --> Code 1A050027
'Beep Pegel
'Beep gain
Data "519;ap,as518"
'
'Announce265:
'Befehl 520 &H0208: --> Code 1A050028
'Beep Pegel Grenze
'Beep gain limit
Data "520;os,beep gain limit;1;0,off;1;,on"
'
'Announce266:
'Befehl 521 &H0209: --> Code 1A050028
'Beep Pegel Grenze
'Beep gain limit
Data "521;as,as520"
'
'Announce267:
'Befehl 522 &H020A: --> Code 1A050029
'Bestaetigungston
'confirmation beep
Data "522;os,confirmation beep;1;0,off;1,on"
'
'Announce268:
'Befehl 523 &H020B: --> Code 1A050029
'Bestaetigungston
'confirmation beep
Data "523;as,as522"
'
'Announce269:
'Befehl 524 &H020C: --> Code 1A050030
'Bandgrenze: Beep mode
'bandedge beep mode
Data "524;os,bandedge beep mode;1;0,off;1,amateur bands;2,user defined;3,user Tx defined"
'
'Announce270:
'Befehl 525 &H020D: --> Code 1A050030
'Bandgrenze: Beep mode
'bandedge beep mode
Data "525;as,as524"
'
'Announce271:
'Befehl 526 &H020E: --> Code 1A050031
'Beep Sound (MAIN)
'Beep Sound (MAIN)
Data "526;op,Beep Sound (MAIN);1;152,{500 to 2000};Hz"
'
'Announce272:
'Befehl 527 &H020F: --> Code 1A050031
'Beep Sound (MAIN)
'Beep Sound (MAIN)
Data "527;as,as526"
'
'Announce273:
'Befehl 528 &H0210: --> Code 1A050032
'Beep Sound (SUB)
'Beep Sound (SUB)
Data "528;op,Beep Sound (SUB);1;152,{500 to 2000};Hz"
'
'Announce274:
'Befehl 529 &H0211: --> Code 1A050032
'Beep Sound (SUB)
'Beep Sound (SUB)
Data "529;as,as528"
'
'Announce275:
'Befehl 530 &H0212: --> Code 1A050033
'Sub Band Mute (TX) Speaker/Phones
'Sub Band Mute (TX) Speaker/Phones
Data "530;os,Sub Band Mute (TX) Speaker/Phones;1;0,off;1,on"
'
'Announce276:
'Befehl 531 &H0213: --> Code 1A050033
'Sub Band Mute (TX) Speaker/Phones
'Sub Band Mute (TX) Speaker/Phones
Data "531;as,as530"
'
'Announce277:
'Befehl 532 &H0214: --> Code 1A050034
'Sub Band Mute (TX) Speaker/Phones
'Sub Band Mute (TX) Speaker/Phones
Data "532;os,Sub Band Mute (TX) Speaker/Phones;1;0,off;1,on"
'
'Announce278:
'Befehl 533 &H0215: --> Code 1A050034
'Sub Band Mute (TX) Speaker/Phones
'Sub Band Mute (TX) Speaker/Phones
Data "533;as,as532"
'
'Announce279:
'Befehl 534 &H0216: --> Code 1A050035
'Sub Band Mute (TX) Speaker/Phones
'Sub Band Mute (TX) Speaker/Phones
Data "534;os,Sub Band Mute (TX) Speaker/Phones;1;0,off;1,on"
'
'Announce280:
'Befehl 535 &H0217: --> Code 1A050035
'Sub Band Mute (TX) Speaker/Phones
'Sub Band Mute (TX) Speaker/Phones
Data "535;as,as534"
'
'Announce281:
'Befehl 536 &H0218: --> Code 1A050036
'Rf / SQL
'RF / SQL
Data "536;os,RF/SQL;1;0,auto;1,SQL;2,SQL+RF"
'
'Announce282:
'Befehl 537 &H0219: --> Code 1A050036
'Rf / SQL
'RF / SQL
Data "537;as,as536"
'
'Announce283:
'Befehl 538 &H021A: --> Code 1A050037
'FM/DV Center Error function
'FM/DV Center Error function
Data "538;os,FM/DV Center Error function;1;0,auto;1,SQL;2,SQL+RF"
'
'Announce284:
'Befehl 539 &H021B: --> Code 1A050037
'FM/DV Center Error function
'FM/DV Center Error function
Data "539;as,as538"
'
'Announce285:
'Befehl 540 &H021C: --> Code 1A050038
'144MHz Tx Verzoegerung
'144MHz Tx delay
Data "540;os,144MHz Tx delay;1;0,off;1,10ms;2,15ms;3,20ms;4,25ms;5,30ms"
'
'Announce286:
'Befehl 541 &H021D: --> Code 1A050038
'144MHz Tx Verzoegerung
'144MHz Tx delay
Data "541;as,as540"
'
'Announce287:
'Befehl 542 &H021E: --> Code 1A050039
'430MHz Tx Verzoegerung
'430MHz Tx delay
Data "542;os,430MHz Tx delay;1;0,off;1,10ms;2,15ms;3,20ms;4,25ms;5,30ms"
'
'Announce288:
'Befehl 543 &H021F: --> Code 1A050039
'430MHz Tx Verzoegerung
'430MHz Tx delay
Data "543;as,as542"
'
'Announce289:
'Befehl 544 &H0220: --> Code 1A050040
'1200MHz Tx Verzoegerung
'1200MHz Tx delay
Data "544;os,1200MHz Tx delay;1;0,off;1,10ms;2,15ms;3,20ms;4,25ms;5,30ms"
'
'Announce290:
'Befehl 545 &H0221: --> Code 1A050040
'1200MHz Tx Verzoegerung
'1200MHz Tx delay
Data "545;as,as544"
'
'Announce291:
'Befehl 546 &H0222: --> Code 1A050041
'Timeout
'Timeout
Data "546;os,Timeout;1;0,off;1,3min;2,5min;3,10mi;4,20min;5,30min"
'
'Announce292:
'Befehl 547 &H0223: --> Code 1A050041
'Timeout
'Timeout
Data "547;as,as546"
'
'Announce293:
'Befehl 548 &H0224: --> Code 1A050042
'PTT Lock
'PTT Lock
Data "548;os,PTT Lock;1;0,off;1,on"
'
'Announce294:
'Befehl 549 &H0225: --> Code 1A050042
'PTT Lock     :
'PTT Lock
Data "549;as,as548"
'
'Announce295:
'Befehl 550 &H0226: --> Code 1A050043
'Quick split
'Quick split
Data "550;os,Quick split;1;0,off;1,on"
'
'Announce296:
'Befehl 551 &H0227: --> Code 1A050043
'Quick split     :
'Quick split
Data "551;as,as550"
'
'Announce297:
'Befehl 552 &H0228: --> Code 1A050044
'FM split offset
'FM split offset
Data "552;op,FM split offset;1;19999,{-9.999 to 9.999};lin;MHz"
'
'Announce298:
'Befehl 553 &H0229: --> Code 1A050044
'FM split offset
'FM split offset
Data "553;ap,as552"
'
'Announce299:
'Befehl 554 &H022A: --> Code 1A050045
'split lock
'split lock
Data "554;os,split lock;1;0,off;1,on"
'
'Announce300:
'Befehl 555 &H022B: --> Code 1A050045
'split lock
'split lock
Data "555;as,as554"
'
'Announce301:
'Befehl 556 &H022C: --> Code 1A050046
'Auto Repeater
'Auto Repeater
Data "556;os,Auto Repeater;1;0,off;1,on"
'
'Announce302:
'Befehl 557 &H022D: --> Code 1A050046
'Auto Repeater
'Auto Repeater
Data "557;as,as556"
'
'Announce303:
'Befehl 558 &H022E: --> Code 1A050047
'RTTY mark freqency
'RTTY mark freqency
Data "558;os,RTTY mark freqency;1;0,1275Hz;1,1615Hz;2,2125Hz"
'
'Announce304:
'Befehl 559 &H022F: --> Code 1A050047
'RTTY mark freqency
'RTTY mark freqency
Data "559;as,as558"
'
'Announce305:
'Befehl 560 &H0230: --> Code 1A050048
'RTTY shift width
'RTTY shift width
Data "560;os,RTTY shift width;1;0,170Hz;1,200Hz;2,425Hz"
'
'Announce306:
'Befehl 561 &H0231: --> Code 1A050048
'RTTY shift width
'RTTY shift width
Data "561;as,as560"
'
'Announce307:
'Befehl 562 &H0232: --> Code 1A050049
'RTTY polaritaet
'RTTY polarity
Data "562;os,RTTY polarity;1;0,normal;1,reverse"
'
'Announce308:
'Befehl 563 &H0233: --> Code 1A050049
'RTTY polaritaet
'RTTY polarity
Data "563;as,as562"
'
'Announce309:
'Befehl 564 &H0234: --> Code 1A050050
'Sprache
'language
Data "564;os,language;1;0,english;1,japanese"
'
'Announce310:
'Befehl 565 &H0235: --> Code 1A050050
'Sprache
'language
Data "565;as,as564"
'
'Announce311:
'Befehl 566 &H0236: --> Code 1A050051
'Sprach alphabet
'language alphabet
Data "566;os,language alphabet;1;0,normal;1,phonetic"
'
'Announce312:
'Befehl 567 &H0237: --> Code 1A050051
'Sprache alphabet
'language alphabet
Data "567;as,as566"
'
'Announce313:
'Befehl 568 &H0238: --> Code 1A050052
'Sprachgeschwindigkeit
'language speed
Data "568;os,language speed;1;0,low;1,high"
'
'Announce314:
'Befehl 569 &H0239: --> Code 1A050052
'Sprachgeschwindigkeit
'language speed
Data "569;as,as568"
'
'Announce315:
'Befehl 570 &H023A: --> Code 1A050053
'RX Call Sign SPEECH
'RX Call Sign SPEECH
Data "570;os,RX Call Sign SPEECH;1;0,off;1,on"
'
'Announce316:
'Befehl 571 &H023B: --> Code 1A050053
'RX Call Sign SPEECH
'RX Call Sign SPEECH
Data "571;as,as570"
'
'Announce317:
'Befehl 572 &H023C: --> Code 1A050054
'RX>CS SPEECH
'RX>CS SPEECH
Data "572;os,RX>CS SPEECH;1;0,off;1,on"
'
'Announce318:
'Befehl 573 &H023D: --> Code 1A050054
'RX>CS SPEECH
'RX>CS SPEECH
Data "572;as,as572"
'
'Announce319:
'Befehl 574 &H023E: --> Code 1A050055
'S meter Sprachausgabe
'S meter speech
Data "574;os,s meter speech;1;0,off;1,on"
'
'Announce320:
'Befehl 575 &H023F: --> Code 1A050055
'S meter Sprachausgabe
'S meter speech
Data "575;as,as574"
'
'Announce321:
'Befehl 576 &H0240: --> Code 1A050056
'mode Sprachausgabe
'mode speech
Data "576;os,mode speech;1;0,off;1,on"
'
'Announce322:
'Befehl 577 &H0241: --> Code 1A050056
'mode Sprachausgabe
'mode speech
Data "577;as,as576"
'
'Announce323:
'Befehl 578 &H0242: --> Code 1A050057
'Sprach Pegel
'speech level
Data "579;op,speech level;1;256;lin;-"
'
'Announce324:
'Befehl 579 &H0243: --> Code 1A050057
'Sprach Pegel
'speech level
Data "579;ap,as578"
'
'Announce325:
'Befehl 580 &H0244: --> Code 1A050058
'Speech / lock Taste
'speech / lock key
Data "580;os,speech / lock key;1;0,push:speech lock;1,lock speech"
'
'Announce326:
'Befehl 581 &H0245: --> Code 1A050058
'Speech / lock Taste
'speech / lock key
Data "581;as,as580"
'
'Announce327:
'Befehl 582 &H0246: --> Code 1A050059
'lock Funktion
'lock function
Data "582;os,lock function;1;0,main dial;1,panel"
'
'Announce328:
'Befehl 583 &H0247: ->> Code 1A050059
'lock Funktion
'lock function
Data "583;as,as582"
'
'Announce329:
'Befehl 584 &H0248: --> Code 1A050060
'Zahl der memory pads
'number of memory pads
Data "584;os,number of memory pads;1;0,5ch;1,10ch"
'
'Announce330:
'Befehl 585 &H0249: --> Code 1A050060
'Zahl der memory pads
'number of memory pads
Data "585;as,as584"
'
'Announce331:
'Befehl 586 &H024A: --> Code 1A050061
'Main Dial auto TS
'Main Dial auto TS
Data "586;os,Main Dial auto TS;1;0,off;1,low;2,high"
'
'Announce332:
'Befehl 587 &H024B: --> Code 1A050061
'Main Dial auto TS
'Main Dial auto TS
Data "587;as,as586"
'
'Announce333:
'Befehl 588 &H024C: --> Code 1A050062
'mic up/down Geschwindigkeit
'mic up/down speed
Data "588;os,mic up/down speed;1;0,slow;1,fast"
'
'Announce334:
'Befehl 589 &H024D: --> Code 1A050062
'mic up/down Geschwindigkeit
'mic up/down speed
Data "589;as,as588"
'
'Announce335:
'Befehl 590 &H024E: --> Code 1A050063
'AFC Limit
'AFC Limit
Data "590;os,AFC Limit;1;0,low;1,high"
'
'Announce336:
'Befehl 591 &H024F: --> Code 1A050063
'AFC Limit
'AFC Limit
Data "591;as,as590"
'
'Announce337:
'Befehl 592 &H0250: --> Code 1A050064
'SSB notch
'SSB notch
Data "592;os,SSB notch;1;0,auto;1,manual;2,auto/manual"
'
'Announce338:
'Befehl 593 &H0251: --> Code 1A050064
'SSB notch
'SSB notch
Data "593;as,as592"
'
'Announce339:
'Befehl 594 &H0252: --> Code 1A050651
'AM notch
'AM notch
Data "594;os,AM notch;1;0,auto;1,manual;2,auto/manual"
'
'Announce340:
'Befehl 595 &H0253: --> Code 1A050065
'AM notch
'AM notch
Data "595;as,as594"
'
'Announce341:
'Befehl 596 &H0254: --> Code 1A050066
'SSB/CW synchronous tuning
'SSB/CW synchronous tuning
Data "596;os,SSB/CW synchronous tuning;1;0,off;1,on"
'
'Announce342:
'Befehl 597 &H0255: --> Code 1A050066
'SSB/CW synchronous tuning
'SSB/CW synchronous tuning
Data "597;as,as596"
'
'Announce343:
'Befehl 598 &H0256: --> Code 1A050067
'CW normal side
'CW normal side
Data "598;os,CW normal side;1;0,LSB;1,USB"
'
'Announce344:
'Befehl 599 &H0257: --> Code 1A050067
'CW normal side
'CW normal side
Data "599;as,as598"
'
'Announce345:
'Befehl 600 &H0258: --> Code 1A050068
'Screen Keyboard Type
'Screen Keyboard Type
Data "600;os,Screen Keyboard Type ;1;0,10key;1,full"
'
'Announce346:
'Befehl 601 &H0259: --> Code 1A050068
'Screen Keyboard Type
'CW normal side    Screen Keyboard Type
Data "601;as,as600"
'
'Announce347:
'Befehl 602 &H025A: --> Code 1A050069
'Screen Full Keyboard Layout
'Screen Full Keyboard Layout
Data "602;os,Screen Full Keyboard Layout ;1;0,English;1,german;2,french"
'
'Announce348:
'Befehl 603 &H025B: --> Code 1A050069
'Screen Full Keyboard Layout
'Screen Full Keyboard Layout
Data "603;as,as602"
'
'Announce349:
'Befehl 604 &H025C: --> Code 1A050070
'power Schalter Schnappschuss
'screen capture by the POWER switch
Data "604;os,screen capture by the POWER switch;1;0,0ff;1,on"
'
'Announce350:
'Befehl 605 &H025D: --> Code 1A050070
''power Schalter Schnappschuss
'screen capture by the POWER switch
Data "605;as,as604"
'
'Announce351:
'Befehl 606 &H025E --> Code 1A050071
'Screen Capture File Type
'Screen Capture File Type
Data "606;os,calibration marker;1;0,PNG;1,BMP"
'
'Announce352:
'Befehl 607 &H025F: --> Code 1A050071
'Screen Capture File Type
'Screen Capture File Type
Data "607;as,as606"
'
'Announce353:
'Befehl 608 &H0260: --> Code 1A050072
'Referenz Frequenz
'reference frequency
Data "608;op,reference frequency;1;256;lin;-"
'
'Announce354:
'Befehl 609 &H0261: --> Code 1A050072:
'Referenz Frequenz
'reference frequency
Data "609;ap,as608"
'
'Announce355:
'Befehl 610 &H0262: --> Code 1A050073
'Referenz Frequenz fein
'reference frequency fine
Data "610;op,reference frequency fine;1;256;lin;-"
'
'Announce356:
'Befehl 611 &H0263: --> Code 1A050073:
'Referenz Frequenz fein
'reference frequency fine
Data "611;ap,as610"
'
'Announce357:
'Befehl 612 &H0264: --> Code 1A050074
'Standby Beep
'Standby Beep
Data "612;os,Standby Beep ;1;0,AF;1,IF"
'
'Announce358:
'Befehl 613 &H0265: --> Code 1A050074
'Standby Beep
'Standby Beep
Data "613;as,as612"
'
'Announce359:
'Befehl 614 &H0266: --> Code 1A050075
'Auto Reply
'Auto Reply
Data "614;os,Auto Reply;1;0,off;1,on;2.voice"
'
'Announce360:
'Befehl 615 &H0267: --> Code 1A050075
'Auto Reply
'Auto Reply
Data "615;as,as614"
'
'Announce361:
'Befehl 616 &H0268: --> Code 1A050076
'DV Data TX
'DV Data TX
Data "616;os,DV Data TX;1;0,PTT;1.auto"
'
'Announce362:
'Befehl 617 &H0269: --> Code 1A050076
'DV Data TX
'DV Data TX
Data "617;as,as616"
'
'Announce363:
'Befehl 618 &H026A: --> Code 1A050077
'DV Fast Data
'DV Fast Data
Data "618;os,DV Fast Data;1;0,off;1,on"
'
'Announce364:
'Befehl 619 &H026B: --> Code 1A050077
'DV Fast Data
'DV Fast Data
Data "619;as,as618"
'
'Announce365:
'Befehl 620 &H026C: --> Code 1A050078
'GPS Data Speed
'GPS Data Speed
Data "620;os,GPS Data Speed ;1;0,slow;1,fast"
'
'Announce366:
'Befehl 621 &H026D: --> Code 1A050078
'GPS Data Speed
'GPS Data Speed
Data "621;as,as620"
'
'Announce367:
'Befehl 622 &H026E: --> Code 1A050079
'DV Fast Data >  TX Delay (PTT)
'DV Fast Data >  TX Delay (PTT)
Data "622;op,DV Fast Data TX Delay PTT;1;11,{off,1 to 10};lin;sec"
'
'Announce368:
'Befehl 623 &H026F: --> Code 1A050079
'DV Fast Data >  TX Delay (PTT)
'DV Fast Data >  TX Delay (PTT)
Data "623;ap,as622"
'
'Announce369:
'Befehl 624 &H0270: --> Code 1A050080
'Digital Monitor
'Digital Monitor
Data "620;os,Digital Monitor ;1;0,auto;1,digital;2,analog"
'
'Announce370:
'Befehl 625 &H0271: --> Code 1A050080
'Digital Monitor
'Digital Monitor
Data "625;as,as624"
'
'Announce371:
'Befehl 626 &H0272: --> Code 1A050081
'Digital Monitor
'Digital Monitor
Data "626;os,Digital Monitor;1;0,off;1,on"
'
'Announce372:
'Befehl 627 &H0273: --> Code 1A050081
'Digital Monitor
'Digital Monitor
Data "627;as,as626"
'
'Announce373:
'Befehl 628 &H0274: --> Code 1A050082
'DV Auto Detect
'DV Auto Detect
Data "628;os,DV Auto Detect;1;0,off;1,on"
'
'Announce374:
'Befehl 629 &H0275: --> Code 1A050082
'DV Auto Detect
'DV Auto Detect
Data "629;as,as628"
'
'Announce375:
'Befehl 630 &H0276: --> Code 1A050083
'RX Record (RPT)
'RX Record (RPT)
Data "630;os,RX Record (RPT);1;0,all;1,latest only"
'
'Announce376:
'Befehl 631 &H0277: --> Code 1A050083
'RX Record (RPT)
'RX Record (RPT)
Data "631;as,as630"
'
'Announce377:
'Befehl 632 &H0278: --> Code 1A050084
'DV/DD Set BK
'DV/DD Set BK
Data "632;os,DV-DD BK;1;0,all;1,off on"
'
'Announce378:
'Befehl 633 &H0279: --> Code 1A050084
'DV/DD Set BK
'DV/DD Set BK
Data "633;as,as632"
'
'Announce379:
'Befehl 634 &H027A: --> Code 1A050085
'DV/DD Set EMR
'DV/DD Set EMR
Data "634;os,DV-DD EMR;1;0,all;1,off on"
'
'Announce380:
'Befehl 635 &H027B: --> Code 1A050085
'DV/DD Set EMR
'DV/DD Set EMR
Data "635;as,as634"
'
'Announce381:
'Befehl 636 &H027C: --> Code 1A050086
'DV/DD EMR Pegel
'DV/DD EMR level
Data "636;os,DV/DD EMR level;1;255{0 to 100};lin;%"
'
'Announce382:
'Befehl 637 &H027D: --> Code 1A050086
'DV/DD EMR Pegel
'DV/DD EMR level DV/DD EMR level
Data "637;as,as636"
'
'Announce383:
'Befehl 638 &H027E: --> Code 1A050087
'DD TX Inhibit (Power ON)
'DD TX Inhibit (Power ON)
Data "638;os,DD TX Inhibit (Power ON);1;0,off;1,on"
'
'Announce384:
'Befehl 639 &H027F: --> Code 1A050087
'DD TX Inhibit (Power ON)
'DD TX Inhibit (Power ON)
Data "639;as,as638"
'
'Announce385:
'Befehl 640 &H0280: --> Code 1A050088
'DD Packet Output
'DD Packet Output
Data "640;os,DD Packet Output;1;0,normal;1,all"
'
'Announce386:
'Befehl 641 &H0281: --> Code 1A050088
'DD Packet Output
'DD Packet Output
Data "641;as,as640"
'
'Announce387:
'Befehl 642 &H0282: --> Code 1A050089
'QSO Log
'QSO Log
Data "642;os,QSO Log;1;0,off;1,on"
'
'Announce388:
'Befehl 643 &H0283: --> Code 1A050089
'QSO Log
'QSO Log
Data "643;as,as642"
'
'Announce389:
'Befehl 644 &H0284: --> Code 1A050090
'Rx history Log
'Rx history Log
Data "644;os,Rx history Log;1;0,off;1,on"
'
'Announce390:
'Befehl 645 &H0285: --> Code 1A050090
'Rx history Log
'Rx history Log
Data "645;as,as644"
'
'Announce391:
'Befehl 646 &H0286: --> Code 1A050091
'CSV Format >  Separator/Decimal
'CSV Format >  Separator/Decimal
Data "646;os,CSV Format Separator-Decimal;1;0,{comma-dot};1,{semicolon-dot};2,{semicolon-comma}"
'
'Announce392:
'Befehl 647 &H0287: --> Code 1A050091
'CSV Format >  Separator/Decimal
'CSV Format >  Separator/Decimal
Data "647;as,as646"
'
'Announce393:
'Befehl 648 &H0288: --> Code 1A050092
'CSV Datum Format >  Separator/Decimal
'CSV date format
Data "648;os,CSV date formatl;1;0,yyyymmdd;1,mmddyyyy;2,ddmmyyyy"
'
'Announce394:
'Befehl 649 &H0289: --> Code 1A050092
'CSV Datum Format
'CSV date format
Data "649;as,as648"
'
'Announce395:
'Befehl 650 &H028A: --> Code 1A050093
'External P.AMP 144MHz
'External P.AMP 144MHz
Data "650;os,External P.AMP 144MHz;1;0,off;1,on"
'
'Announce396:
'Befehl 651 &H028B: --> Code 1A050093
'External P.AMP 144MHz
'External P.AMP 144MHz
Data "651;as,as650"
'
'Announce397:
'Befehl 652 &H028C: --> Code 1A050094
'External P.AMP 430MHz
'External P.AMP 430MHz
Data "652;os,External P.AMP 430MHz;1;0,off;1,on"
'
'Announce398:
'Befehl 653 &H028D: --> Code 1A050094
'External P.AMP 430MHz
'External P.AMP 430MHz
Data "653;as,as652"
'
'Announce399:
'Befehl 654 &H028E: --> Code 1A050095
'External P.AMP 1230MHz
'External P.AMP 1230MHz
Data "654;os,External P.AMP 1230MHz;1;0,off;1,on"
'
'Announce400:
'Befehl 655 &H028F: --> Code 1A050095
'External P.AMP 1230MHz
'External P.AMP 1230MHz
Data "655;as,as654"
'
'Announce401:
'Befehl 656 &H0290: --> Code 1A050096
'External Speaker
'External Speaker
Data "656;os,External Speaker;1;0,separate;1,mix"
'
'Announce402:
'Befehl 657 &H0291: --> Code 1A050096
'External Speaker
'External Speaker
Data "657;as,as656"
'
'Announce403:
'Befehl 658 &H0292: --> Code 1A050097
'Phones Level
'Phones Level
Data "658;op,Phones Level;1;31,{-15 to +15};lin;dB"
'
'Announce404:
'Befehl 659 &H0293: --> Code 1A050097
'Phones Level
'Phones Level
Data "659;ap,as658"
'
'Announce405:
'Befehl 660 &H0294: --> Code 1A050098
'Phones > L/R Mix
'Phones > L/R Mix
Data "660;os,Phones L/R Mix ;1;0,separate;1,mix;2,auto"
'
'Announce406:
'Befehl 661 &H0295: --> Code 1A050098
'Phones > L/R Mix
'Phones > L/R Mix
Data "661;as,as660"
'
'Announce407:
'Befehl 662 &H0296: --> Code 1A050099
'ACC AF/IF Output AF/SQL Output Select
'ACC AF/IF Output AF/SQL Output Select
Data "662;os,ACC AF/IF Output AF/SQL Output Select;1;0,main;1,sub"
'
'Announce408:
'Befehl 663 &H0297: --> Code 1A050099
'ACC AF/IF Output AF/SQL Output Select
'ACC AF/IF Output AF/SQL Output Select
Data "663;as,as662"
'
'Announce409:
'Befehl 664 &H0298: --> Code 1A050100
'ACC AF/IF Output
'ACC AF/IF Output
Data "664;os,ACC AF/IF Output;1;0,AF;1,IF"
'
'Announce410:
'Befehl 665 &H0299: --> Code 1A050100
'ACC AF/IF Output
'ACC AF/IF Output
Data "665;as,as664"
'
'Announce411:
'Befehl 666 &H029A: --> Code 1A050101
'ACC AF/IF Output Pegel
'ACC AF/IF Output level
Data "666;op,ACC AF/IF Output level;1;255,{0 to 100};lin;%"
'
'Announce412:
'Befehl 667 &H029B: --> Code 1A050101
'ACC AF/IF Output Pegel
'ACC AF/IF Output level
Data "667;ap,as666"
'
'Announce413:
'Befehl 668 &H029C: --> Code 1A050102
'AF SQL
'AF SQL
Data "668;os,AF SQL;1;0,off;1,on"
'
'Announce414:
'Befehl 669 &H029D: --> Code 1A050102
'AF SQL
'AF SQL
Data "669;as,as668"
'
'Announce415:
'Befehl 670 &H029E: --> Code 1A050103
'AF Beep/Speech... Output
'AF Beep/Speech... Output
Data "670;os,AF Beep/Speech... Output;1;0,off;1,on"
'
'Announce416:
'Befehl 671 &H029F: --> Code 1A050103
'AF Beep/Speech... Output
'AF Beep/Speech... Output
Data "671;as,as670"
'
'Announce417:
'Befehl 672 &H02A0: --> Code 1A050104
'ACC IF Output Level
'ACC IF Output Level
Data "672;os,ACC IF Output Level;1;255,{0 to 100};lin;%"
'
'Announce418:
'Befehl 673 &H02A1: --> Code 1A050104
'ACC IF Output Level
'ACC IF Output Level
Data "673;as,as672"
'
'Announce419:
'Befehl 674 &H02A2: --> Code 1A050105
'USB AF/IF Output
'USB AF/IF Output
Data "674;os,USB AF/IF Output;1;0,AF;1,IF"
'
'Announce420:
'Befehl 675 &H02A3: --> Code 1A050105
'USB AF/IF Output
'USB AF/IF Output
Data "675;as,as674"
'
'Announce421:
'Befehl 676 &H02A4: --> Code 1A050106
'USB AF Output Level
'USB AF Output Level
Data "676;os,USB AF Output Level;1;255,{0 to 100};lin;%"
'
'Announce422:
'Befehl 677 &H02A5: --> Code 1A050106
'USB AF Output Level
'USB AF Output Level
Data "677;as,as676"
'
'Announce423:
'Befehl 678 &H02A6: --> Code 1A050107
'USB AF SQL
'USB AF SQL
Data "678;os,USB AF SQL;1;0,off;1,on"
'
'Announce424:
'Befehl 679 &H02A7: --> Code 1A050107
'USB AF SQL
'USB AF SQL
Data "679;as,as678"
'
'Announce425:
'Befehl 680 &H02A8: --> Code 1A050108
'USB AF Beep/Speech... Output
'USB AF Beep/Speech... Output
Data "680;os,USB AF Beep/Speech... Output;1;0,off;1,on"
'
'Announce426:
'Befehl 681 &H02A9: --> Code 1A050108
'USB AF Beep/Speech... Output
'USB AF Beep/Speech... Output
Data "681;as,as680"
'
'Announce427:
'Befehl 682 &H02AA: --> Code 1A050109
'USB IF Output Level
'USB IF Output Level
Data "682;os,USB IF Output Level;1;255,{0 to 100};lin;%"
'
'Announce428:
'Befehl 683 &H02AB: --> Code 1A050109
'USB IF Output Level
'USB IF Output Level
Data "683;as,as682"
'
'Announce429:
'Befehl 684 &H02AC: --> Code 1A050110
'LAN
'LAN
Data "684;os,LAN;1;0,AF;1,IF"
'
'Announce430:
'Befehl 685 &H02AD: --> Code 1A050110
'LAN
'LAN
Data "685;as,as684"
'
'Announce431:
'Befehl 686 &H02AE: --> Code 1A050111
'LAN
'LAN
Data "686;os,LAN;1;0,AF;1,IF"
'
'Announce432:
'Befehl 687 &H02AF: --> Code 1A050111
'LAN
'LAN
Data "687;as,as686"
'
'Announce433:
'Befehl 688 &H02B0: --> Code 1A050112
'MOD ACC Input Level
'MOD ACC Input Level
Data "688;os,MOD ACC Input Level;1;255,{0 to 100};lin;%"
'
'Announce434:
'Befehl 689 &H02B1: --> Code 1A050112
'MOD ACC Input Level
'MOD ACC Input Level
Data "689;as,as688"
'
'Announce435:
'Befehl 690 &H02B2: --> Code 1A050113
'MOD USB InputLevel
'MOD USB InputLevel
Data "690;os,MOD USB InputLevel;1;255,{0 to 100};lin;%"
'
'Announce436:
'Befehl 691 &H02B3: --> Code 1A050113
'MOD USB InputLevel
'MOD USB InputLevel
Data "691;as,as690"
'
'Announce437:
'Befehl 692 &H02B4: --> Code 1A050114
'MOD USB InputLevel
'MOD USB InputLevel
Data "692;os,MOD USB InputLevel;1;255,{0 to 100};lin;%"
'
'Announce438:
'Befehl 693 &H02B5: --> Code 1A050114
'MOD USB InputLevel
'MOD USB InputLevel
Data "693as,as692"
'
'Announce439:
'Befehl 694 &H02B6: --> Code 1A050115
'MOD Input DATA OFF
'MOD Input DATA OFF
Data "694;os,MOD Input DATA OFF;1;0,MIC;1,ACC;2,USB;3,MIC+USB;5,LAN"
'
'Announce440:
'Befehl 695 &H02B7: --> Code 1A050115
'MOD Input DATA OFF
'MOD Input DATA OFF
Data "695;as,as694"
'
'Announce441:
'Befehl 696 &H02B8: --> Code 1A050116
'MOD Input DATA MOD
'MOD Input DATA MOD
Data "696;os,MOD Input DATA MOD;1;0,MIC;1,ACC;2,USB;3,MIC+USB;5,LAN"
'
'Announce442:
'Befehl 697 &H02B9: --> Code 1A050116
'MOD Input DATA MOD
'MOD Input DATA MOD
Data "697;as,as696"
'
'Announce443:
'Befehl 698 &H02BA: --> Code 1A050117
'ACC SEND Output 144M
'ACC SEND Output 144M
Data "698;os,ACC SEND Output 144M;1;0,off;1,on"
'
'Announce444:
'Befehl 699 &H02BB: --> Code 1A050117
'ACC SEND Output 144M
'ACC SEND Output 144M
Data "699;as,as698"
'
'Announce445:
'Befehl 700 &H02BC: --> Code 1A050118
'ACC SEND Output 430M
'ACC SEND Output 430M
Data "700;os,ACC SEND Output 430M;1;0,off;1,on"
'
'Announce446:
'Befehl 701 &H02BD: --> Code 1A050118
'ACC SEND Output 430M
'ACC SEND Output 430M
Data "701;as,as700"
'
'Announce447:
'Befehl 702 &H02BE: --> Code 1A050119
'ACC SEND Output 1230M
'ACC SEND Output 1230M
Data "702;os,ACC SEND Output 1230M;1;0,off;1,on"
'
'Announce448:
'Befehl 703 &H02BF: --> Code 1A0501219
'ACC SEND Output 1230M
'ACC SEND Output 1230M
Data "703;as,as702"
'
'Announce449:
'Befehl 704 &H02C0: --> Code 1A050120
'USB SEND/Keying
'USB SEND/Keying
Data "704;os,USB SEND/Keying;1;0,off;1,USBa-DTR;2,USBA-RTS;3,USBB-DTR;4,USBB-RTS"
'
'Announce450:
'Befehl 705 &H02C1: --> Code 1A050120
'USB SEND/Keying
'USB SEND/Keying
Data "705;as,as704"
'
'Announce451:
'Befehl 706 &H02C2: --> Code 1A050121
'USB CW/Keying
'USB CW/Keying
Data "706;os,USB CW/Keying;1;0,off;1,USBa-DTR;2,USBA-RTS;3,USBB-DTR;4,USBB-RTS"
'
'Announce452:
'Befehl 707 &H02C3: --> Code 1A050121
'USB CW/Keying
'USB CW/Keying
Data "707;as,as706"
'
'Announce453:
'Befehl 708 &H02C4: --> Code 1A050122
'USB RTTY/Keying
'USB RTTY/Keying
Data "708;os,USB RTTY/Keying;1;0,off;1,USBa-DTR;2,USBA-RTS;3,USBB-DTR;4,USBB-RTS"
'
'Announce454:
'Befehl 709 &H02C5: --> Code 1A050122
'USB RTTY/Keying
'USB RTTY/Keying
Data "709;as,as708"
'
'Announce455:
'Befehl 710 &H02C6: --> Code 1A050123
'Inhibit Timer at USB connection
'Inhibit Timer at USB connection
Data "710;os,Inhibit Timer at USB connection;1;0,off;1,on"
'
'Announce456:
'Befehl 711 &H02C7: --> Code 1A050123
'Inhibit Timer at USB connection
'Inhibit Timer at USB connection
Data "711;as,as710"
'
'Announce457:
'Befehl 712 &H02C8: --> Code 1A050124
'External Keypad >  VOICE
'External Keypad >  VOICE
Data "712;os,External Keypad VOICE;1;0,off;1,on"
'
'Announce458:
'Befehl 713 &H02C9: --> Code 1A050124
'External Keypad >  VOICE
'External Keypad >  VOICE
Data "713;as,as712"
'
'Announce459:
'Befehl 714 &H02CA: --> Code 1A050125
'External Keypad >  Keyer
'External Keypad >  Keyer
Data "714;os,External Keypad Keyer;1;0,off;1,on"
'
'Announce460:
'Befehl 715 &H02CB: --> Code 1A050125
'External Keypad >  Keyer
'External Keypad >  Keyer
Data "715;as,as714"
'
'Announce461:
'Befehl 716 &H02CC: --> Code 1A050126
'External Keypad >  RTTY
'External Keypad >  RTTY
Data "716;os,External Keypad RTTY;1;0,off;1,on"
'
'Announce462:
'Befehl 717 &H02CD: --> Code 1A050126
'External Keypad >  RTTY
'External Keypad >  RTTY
Data "717;as,as716"
'
'Announce463:
'Befehl 718 &H02CE: --> Code 1A050127
'CI-V Transceive
'CI-V Transceive
Data "718;os,CI-V Transceive;1;0,off;1,on"
'
'Announce464:
'Befehl 719 &H02CF: --> Code 1A050127
'CI-V Transceive
'CI-V Transceive
Data "719;as,as718"
'
'Announce465:
'Befehl 720 &H02D0: --> Code 1A050128
'Transceive adress
'Transceive adress
Data "720;os,Transceive adress;1;224;lin;-"
'
'Announce466:
'Befehl 721 &H02D1: --> Code 1A050128
'Transceive adress
'Transceive adress
Data "721;as,as720"
'
'Announce467:
'Befehl 722 &H02D2: --> Code 1A050129
'CI-V USB Port
'CI-V USB Port
Data "722;iz"
'
'Announce468:
'Befehl 723 &H02D3: --> Code 1A050129
'CI-V USB Port
'CI-V USB Port
Data "723;as,CI-V USB Port;1;0,link to remote;1,unlink to remote"
'
'Announce469:
'Befehl 724 &H02D4: --> Code 1A050130
'CI-V USB Echo Back
'CI-V USB Echo Back
Data "724;os,CI-V USB Echo Back;1;0,off;1,on"
'
'Announce470:
'Befehl 725 &H02D5: --> Code 1A050130
'CI-V USB Echo Back
'CI-V USB Echo Back
Data "725;as,as724"
'
'Announce471:
'Befehl 726 &H02D6: --> Code 1A050131
'CI-V DATA Echo Back
'CI-V DATA Echo Back
Data "726;os,CI-V DATA Echo Back;1;0,off;1,on"
'
'Announce472:
'Befehl 727 &H02D7: --> Code 1A050131
'CI-V DATA Echo Back
'CI-V DATA Echo Back
Data "727;as,as726"
'
'Announce473:
'Befehl 728 &H02D8: --> Code 1A050132
'USB (B)
'USB (B)
Data "728;os,USB (B);1;0,off;1,RTTY decode;2,DV DATA"
'
'Announce474:
'Befehl 729 &H02D9: --> Code 1A050132
'USB (B)
'USB (B)
Data "729;as,as728"
'
'Announce475:
'Befehl 730 &H02DA: --> Code 1A050133
'USB (B) DATA
'USB (B) DATA
Data "730;os,USB (B) DATA;1;0,off;1,RTTY decode;2,DV DATA;3,GPS,Weather;4,CIV"
'
'Announce476:
'Befehl 731 &H02DB: --> Code 1A050133
'USB (B) DATA
'USB (B) DATA
Data "731;as,as730"
'
'Announce477:
'Befehl 732 &H02DC: --> Code 1A050134
'USB (B)/DATA GPS Out
'USB (B)/DATA GPS Out
Data "732;os,USB (B)/DATA GPS Out;1;0,off;1,on"
'
'Announce478:
'Befehl 733 &H02DD: --> Code 1A050134
'USB (B)/DATA GPS Out
'USB (B)/DATA GPS Out
Data "733;as,as732"
'
'Announce479:
'Befehl 734 &H02DE: --> Code 1A050135
'DV Data/GPS Out Baud Rate
'DV Data/GPS Out Baud Rate
Data "734;os,DV Data/GPS Out Baud Rate;1;4800,off;1,9600"
'
'Announce480:
'Befehl 735 &H02DF: --> Code 1A050135
'DV Data/GPS Out Baud Rate
'DV Data/GPS Out Baud Rate
Data "735;as,as734"
'
'Announce481:
'Befehl 736 &H02E0: --> Code 1A050136
'RTTY Decode Baud Rate
'RTTY Decode Baud Rate
Data "736;os,RTTY Decode Baud Rate;1;0,4800;1,9600;2,19200;3,38400"
'
'Announce482:
'Befehl 737 &H02E1: --> Code 1A050136
'RTTY Decode Baud Rate
'RTTY Decode Baud Rate
Data "737;as,as736"
'
'Announce483:
'Befehl 738 &H02E2: --> Code 1A050137
'DHCP (Valid
'DHCP (Valid
Data "738;os,DHCP Valid;1;0,off;1,on"
'
'Announce484:
'Befehl 739 &H02E3: --> Code 1A050137
'DHCP (Valid
'DHCP (Valid
Data "739;as,as738"
'
'Announce485:
'Befehl 740 &H02E4: --> Code 1A050138
'IP Address
'IP Address
Data "740;op,IP Address;1;256;lin,-;256;lin;-;256;lin;-;255,{1 to 255};lin;-"
'
'Announce486:
'Befehl 741 &H02E5: --> Code 1A050138
'IP Address
'IP Address
Data "741;ap,as740"
'
'Announce487:
'Befehl 742 &H02E6: --> Code 1A050139
'DHCP Address
'DHCP'IP Address
Data "742;ap,DHCP Address;1;256;lin,-;256;lin;-;256;lin;-;255,{1 to 255};lin;-"
'
'Announce488:
'Befehl 743 &H02E7: --> Code 1A050140
'Subnet Mask
'Subnet Mask
Data "743;op,Subnet Mask;1;30,{1 to 30};lin,bit"
'
'Announce489:
'Befehl 744 &H02E8: --> Code 1A050140
'ISubnet Mask
'Subnet Mask
Data "744;ap,as743"
'
'Announce490:
'Befehl 745 &H02E9: --> Code 1A050141
'Default Gateway
'Default Gateway
Data "745;op,Default Gateway;1;256;lin,-;256;lin;-;256;lin;-;255;lin;-"
'
'Announce491:
'Befehl 746 &H02EA: --> Code 1A050141
'Default Gateway
'Default Gateway
Data "746;ap,as745"
'
'Announce492:
'Befehl 747 &H02EB: --> Code 1A050142
'Primary DNS Server
'Primary DNS Server
Data "747;op,Primary DNS Server;1;256;lin,-;256;lin;-;256;lin;-;255;lin;-"
'
'Announce493:
'Befehl 748 &H02EC: --> Code 1A050142
'Primary DNS Server
'Primary DNS Server
Data "748;ap,as747"
'
'Announce494:
'Befehl 749 &H02ED: --> Code 1A050143
'sec DNS Server
'sec DNS Server
Data "749;op,sec DNS Server;1;256;lin,-;256;lin;-;256;lin;-;255;lin;-"
'
'Announce495:
'Befehl 750 &H02EE: --> Code 1A050143
'sec DNS Server
'sec DNS Server
Data "750;ap,as749"
'
'Announce496:
'Befehl 751 &H02EF: --> Code 1A050144
'Network Name
'Network Name
Data "751;oa,Network Name;1;15"
'
'Announce497:
'Befehl 752 &H02F0: --> Code 1A050144
'Network Name
'Network Name
Data "752;aa,as749"
'
'Announce498:
'Befehl 753 &H02F1: --> Code 1A050145
'Network Control
'Network Control
Data "753;os,Network Control;1;0,off;1,on"
'
'Announce499:
'Befehl 754 &H02F2: --> Code 1A050145
'Network Control
'Network Control
Data "754;as,as753"
'
'Announce500:
'Befehl 755 &H02F3: --> Code 1A050146
'Power OFF
'Power OFF
Data "755;os,Power OFF;1;0,shutdown only;1,standby-shutdown"
'
'Announce501:
'Befehl 756 &H02F4: --> Code 1A050146
'Power OFF
'Power OFF
Data "756;as,as755"
'
'Announce502:
'Befehl 757 &H02F5: --> Code 1A050147
'Control Port (UDP)
'Control Port (UDP)
Data "757;op,Control Port UDP;1;65534,{1 to 65535};lin;-"
'
'Announce503:
'Befehl 758 &H02F6: --> Code 1A050147
'Control Port (UDP)
'Control Port (UDP)
Data "758;ap,as757"
'
'Announce504:
'Befehl 759 &H02F7: --> Code 1A050148
'Serial Port (UDP)
'Serial Port (UDP)
Data "759;op,Serial Port UDP;1;65534,{1 to 65535};lin;-"
'
'Announce505:
'Befehl 760 &H02F8: --> Code 1A050148
'Serial Port (UDP)
'Serial Port (UDP)
Data "760;ap,as759"
'
'Announce506:
'Befehl 761 &H02F9: --> Code 1A050149
'Audio Port (UDP)
'Audio Port (UDP)
Data "761;op,Audio Port UDP;1;65534,{1 to 65535};lin;-"
'
'Announce507:
'Befehl 762 &H02FA: --> Code 1A050149
'Audio Port (UDP)
'Audio Port (UDP)
Data "762;ap,as761"
'
'Announce508:
'Befehl 763 &H02FB: --> Code 1A050150
'Internet Access Line
'Internet Access Line
Data "763;os,Internet Access Line;1;0,FTTH;1,ADSL-CATV"
'
'Announce509:
'Befehl 764 &H02FC: --> Code 1A050150
'Internet Access Line
'Internet Access Line
Data "764;as,as763"
'
'Announce510:
'Befehl 765 &H02FD: --> Code 1A050151
'Network Radio Name
'Network Radio Name
Data "765;oa,Network Radio Name;1;16"
'
'Announce511:
'Befehl 766 &H02FE: --> Code 1A050151
'Network Radio Name
'Network Radio Name
Data "766;aa,as765"
'
'Announce512:
'Befehl 767 &H02FF: --> Code 1A050152
'LCD Backlight
'LCD Backlight
Data "767;op,ALCD Backlight;1;255{0 to 100};lin;%"
'
'Announce513:
'Befehl 768 &H0300: --> Code 1A050152
'LCD Backlight
'LCD Backlight
Data "768;ap,as767"
'
'Announce514:
'Befehl 769 &H0301: --> Code 1A050153
'Display Type
'Display Type
Data "769;os;Display Type;1;0,A;1,B"
'
'Announce515:
'Befehl 770 &H0302: --> Code 1A050153
'Display Type
'Display Type
Data "770;as,as769"
'
'Announce516:
'Befehl 771 &H0303: --> Code 1A050154
'Display Font
'Display Font
Data "771;os;Display Font;1;0,basic;1,round"
'
'Announce517:
'Befehl 772 &H0304: --> Code 1A050154
'Display Font
'Display Font
Data "772;as,as771"
'
'Announce518:
'Befehl 773 &H0305: --> Code 1A050155
'Meter Peak Hold (Bar)
'Meter Peak Hold (Bar)
Data "773;os;Meter Peak Hold Bar;1;0,off;1,on"
'
'Announce519:
'Befehl 774 &H0306: --> Code 1A050155
'Meter Peak Hold (Bar)
'Meter Peak Hold (Bar)
Data "774;as,as773"
'
'Announce520:
'Befehl 775 &H0307: --> Code 1A050156
'Display > Memory Name
'Display > Memory Name
Data "775;os;Display Memory Name;1;0,off;1,on"
'
'Announce521:
'Befehl 776 &H0308: --> Code 1A050156
'Display > Memory Name
'Display > Memory Name
Data "776;as,as775"
'
'Announce522:
'Befehl 777 &H0309: --> Code 1A050157
'MN-Q Popup
'MN-Q Popup
Data "775;os;MN-Q Popup;1;0,on;1,off"
'
'Announce521:
'Befehl 778 &H030A: --> Code 1A050157
'MN-Q Popup
'MN-Q Popup
Data "778;as,as777"
'
'Announce524:
'Befehl 779 &H030B: --> Code 1A050158
'Display BW Popup PBT
'Display BW Popup PBT
Data "779;os;Display BW Popup PBT;1;0off;1,on"
'
'Announce525:
'Befehl 780 &H030C: --> Code 1A050158
'Display BW Popup PBT
'Display BW Popup PBT
Data "780;as,as779"
'
'Announce526:
'Befehl 781 &H030D: --> Code 1A050159
'Display BW Popup Fil
'Display BW Popup Fil
Data "781;os;Display BW Popup Fil;1;0,off;1,on"
'
'Announce527:
'Befehl 782 &H030E --> Code 1A050159
'Display BW Popup Fil
'Display BW Popup Fil
Data "782;as,as781"
'
'Announce528:
'Befehl 783 &H030F: --> Code 1A050160
'RX Call Sign Display
'RX Call Sign Display
Data "783;os;RX Call Sign Display;1;0,off;1,normal;2,RXhold;3,hold"
'
'Announce529:
'Befehl 784 &H0310: --> Code 1A050160
'RX Call Sign Display
'RX Call Sign Display
Data "784;as,as783"
'
'Announce530:
'Befehl 785 &H0311: --> Code 1A050161
'RX Position Indicator
'RX Position Indicator
Data "785;os;RX Position Indicator;1;0,off;1,on"
'
'Announce531:
'Befehl 786 &H0312: --> Code 1A050161
'RX Position Indicator
'RX Position Indicator
Data "786;as,as785"
'
'Announce532:
'Befehl 787 &H0313: --> Code 1A050162
'RX Position Display
'RX Position Display
Data "787;os;RX Position Display;1;0,off;1,main-sub;2,main only"
'
'Announce533:
'Befehl 788 &H0314: --> Code 1A050162
'RX Position Display
'RX Position Display
Data "788;as,as787"
'
'Announce534:
'Befehl 789 &H0315: --> Code 1A050163
'RX Position Display Timer
'RX Position Display Timer
Data "789;os;RX Position Display Timer;1;0,5s;1,10s;2,15s;3,30s;4,hold"
'
'Announce535:
'Befehl 790 &H0316: --> Code 1A050163
'RX Position Display  Timer
'RX Position Display  Timer
Data "790;as,as789"
'
'Announce536:
'Befehl 791 &H0317: --> Code 1A050164
'Reply Position Display
'Reply Position Display
Data "791;os;Reply Position Display;1;0,off;1,on"
'
'Announce537:
'Befehl 792 &H0318: --> Code 1A050164
'Reply Position Display
'Reply Position Display
Data "792;as,as791"
'
'Announce538:
'Befehl 793 &H0319: --> Code 1A050165
'TX Call Sign Display
'TX Call Sign Display
Data "793;os;TX Call Sign Display;1;0,off;1,your;2,my"
'
'Announce539:
'Befehl 794 &H031A: --> Code 1A050165
'TX Call Sign Display
'TX Call Sign Display
Data "794;as,as793"
'
'Announce540:
'Befehl 795 &H031B: --> Code 1A050166
'Scroll Speed
'Scroll Speed
Data "795;os;Scroll Speed;1;0,slow;1,fast"
'
'Announce541:
'Befehl 796 &H031C: --> Code 1A050166
'Scroll Speed
'Scroll Speed
Data "796;as,as795"
'
'Announce542:
'Befehl 797 &H031D: --> Code 1A050167
'Screen Saver
'Screen Saver
Data "797;os;Screen Saver;1;0,off;1,15m;2.30m;3,60m"
'
'Announce543:
'Befehl 798 &H031E: --> Code 1A050167
'Screen Saver
'Screen Saver
Data "798;as,as797"
'
'Announce544:
'Befehl 799 &H031F: --> Code 1A050168
'Opening Message
'Opening Message
Data "799;os;Opening Message;1;0,off;1,on"
'
'Announce545:
'Befehl 800 &H0320: --> Code 1A050168
'Opening Message
'Opening Message
Data "800;as,as799"
'
'Announce546:
'Befehl 801 &H0321: --> Code 1A050169
'Power ON Check
'Power ON Check
Data "801;os;Power ON Check;1;0,off;1,on"
'
'Announce547:
'Befehl 802 &H0322: --> Code 1A050169
'Power ON Check
'Power ON Check
Data "802;as,as801"
'
'Announce548:
'Befehl 803 &H0323: --> Code 1A050170
'Display Unit Latitude/Longitude
'Display Unit > Latitude/Longitude
Data "803;os;Display Unit Latitude/Longitude;1;0,dddmmmm;1,dddmmss"
'
'Announce549:
'Befehl 804 &H0324: --> Code 1A050170
'Display Unit > Latitude/Longitude
'Display Unit > Latitude/Longitude
Data "804;as,as803"
'
'Announce550:
'Befehl 805 &H0325: --> Code 1A050171
'Display Unit Altitude/Distanc
'Display Unit Altitude/Distanc
Data "805;os;Display Unit Altitude/Distanc;1;0,m;1,ft-in"
'
'Announce551:
'Befehl 806 &H0326: --> Code 1A050171
'Display Unit Altitude/Distanc
'Display Unit Altitude/Distanc
Data "806;as,as805"
'
'Announce552:
'Befehl 807 &H0327: --> Code 1A050172
'Display Unit Speed
'Display Unit Speed
Data "807;os;Display Unit Speed;1;0,kmh;1,mph;2,knots"
'
'Announce553:
'Befehl 808 &H0328: --> Code 1A050172
'Display Unit Speed
'Display Unit Speed
Data "808;as,as807"
'
'Announce554:
'Befehl 809 &H0329: --> Code 1A050173
'Display Unit Temperature
'Display Unit Temperature
Data "809;os;Display Unit Temperature;1;0,C;1,F"
'
'Announce555:
'Befehl 810 &H032A: --> Code 1A050173
'Display Unit Temperature
'Display Unit Temperature
Data "810;as,as809"
'
'Announce556:
'Befehl 811 &H032B: --> Code 1A050174
'Display Unit Barometric
'Display Unit Barometric
Data "811;os;Display Unit Barometric;1;0,hPa;1,mb;2,mmHg;3,inHg"
'
'Announce557:
'Befehl 812 &H032C: --> Code 1A050174
'Display Unit Barometric
'Display Unit Barometric
Data "812;as,as811"
'
'Announce558:
'Befehl 813 &H032D: --> Code 1A050175
'Display Unit Rainfall
'Display Unit Rainfall
Data "813;os;Display Unit Rainfall;1;0,mm;1,in"
'
'Announce559:
'Befehl 814 &H032E: --> Code 1A050175
'Display Unit Rainfall
'Display Unit Rainfall
Data "814;as,as813"
'
'Announce560:
'Befehl 815 &H032F: --> Code 1A050176
'Display Unit Wind Speed
'Display Unit Wind Speed
Data "815;os;Display Unit Wind;1;0,m/s;1,km/h;2mph;3,knots"
'
'Announce561:
'Befehl 816 &H0330: --> Code 1A050176
'Display Unit Wind Speed
'Display Unit Wind Speed
Data "816;as,as815"
'
'Announce562:
'Befehl 817 &H0331: --> Code 1A050177
'Display Language
'Display Language
Data "817;os;Display Language;1;0,english;1,japanese"
'
'Announce563:
'Befehl 818 &H0332: --> Code 1A050177
'Display Language
'Display Language
Data "818;as,as817"
'
'Announce564:
'Befehl 819 &H0333: --> Code 1A050178
'System  Language
'System  Language
Data "817;os;System  Language;1;0,english;1,japanese"
'
'Announce565:
'Befehl 820 &H0334: --> Code 1A050178
'System  Language
'System  Language
Data "820;as,as819"
'
'Announce566:
'Befehl 821 &H0335: --> Code 1A050179
'Datum
'date
Data "821;op,date;1;100,{0 to 99};lin;year;12,{1 to 12};lin;month;31,{1 to 31};lin;day"

'Announce567:
'Befehl 822 &H0336: --> Code 1A050179
'Datum
'date
Data "822;ap,as821"
'
'Announce568:
'Befehl 823 &H0337: --> Code 1A050180
'Zeit
'time
Data "823;op,time;1;24,{0 to 23};lin;hour;60,{0 to 59};lin;min"
'
'Announce569:
'Befehl 824 &H0338: --> Code 1A050180
'Zeit
'time
Data "824;ap,as823"
'
'Announce570:
'Befehl 825 &H0339: --> Code 1A050181
'NTP
'NTP
Data "825;os,NTP;1;0,off;1,on"
'
'Announce571:
'Befehl 826 &H033A: --> Code 1A050181
'NTP
'NTP
Data "826;as,as825"
'
'Announce572:
'Befehl 827 &H033B: --> Code 1A050182
'NTP Serveradress
'NTP Serveradress
Data "827;ap,NTP Serveradress;1;256;lin,-;256;lin;-;256;lin;-;255,{1 to 255};lin;-"
'
'Announce573:
'Befehl 828 &H033C: --> Code 1A050182
'NTP Serveradress
'NTP Serveradress
Data "828;as,as827"
'
'Announce574:
'Befehl 829 &H033D: --> Code 1A050183
'GPS Time Correct
'GPS Time Correct
Data "829;os,GPS Time Correct;1;0,off;1,auto"
'
'Announce575:
'Befehl 830 &H033E: --> Code 1A050183
'GPS Time Correct
'GPS Time Correct
Data "830;as,as829"
'
'Announce576:
'Befehl 831 &H033F: --> Code 1A050184
'UTC Offset
'UTC Offset
Data "831;op,UTC offset;1:1682,{-14:00 to +14:00};lin,h"
'
'Announce577:
'Befehl 832 &H0340: --> Code 1A050184
'UTC Offset
'UTC Offset
Data "832;ap,as831"
'
'Announce578:
'Befehl 833 &H0341: --> Code 1A050185
'SD Card > Import/Export >  CSV Format > Separator/Decimal
'SD Card > Import/Export >  CSV Format > Separator/Decimal
Data "833;os,SD Card CSV Separator-Decimal;1;0,comman-dot;1,semicolon-dot;2,simicolon-comma"
'
'Announce579:
'Befehl 834 &H0342: --> Code 1A050185
'SD Card > Import/Export >  CSV Format > Separator/Decimal
'SD Card > Import/Export >  CSV Format > Separator/Decimal
Data "834;as,as833"
'
'Announce580:
'Befehl 835 &H0343: --> Code 1A050186
'SD Card > Import/Export >  CSV Format > Date
'SD Card > Import/Export >  CSV Format > Date
Data "835;os,SD Card CSV Date;1;0,yyyymmdd;1,mmddyyyy;2,ddmmyyyy"
'
'Announce581:
'Befehl 836 &H0344: --> Code 1A050186
'SD Card > Import/Export >  CSV Format > Date
'SD Card > Import/Export >  CSV Format > Date
Data "836;as,as835"
'
'Announce582:
'Befehl 837 &H0345: --> Code 1A050187
'Scope during Tx (CENTER TYPE)
'Scope during Tx (CENTER TYPE)
Data "837;os,Scope during Tx CENTER TYPE;1;0,off;1,on"
'
'Announce583:
'Befehl 838 &H0346: --> Code 1A050187
'Scope during Tx (CENTER TYPE)
'Scope during Tx (CENTER TYPE)
Data "838;as,as837"
'
'Announce584:
'Befehl 839 &H0347: --> Code 1A050188
'Max Hold
'Max Hold
Data "839;os,Max Hold;1;0,off;1,10s:2,on"
'
'Announce585:
'Befehl 840 &H0348: --> Code 1A050188
'Max Hold
'Max Hold
Data "840;as,as839"
'
'Announce586:
'Befehl 841 &H0349: --> Code 1A050189
'CENTER Type Display
'CENTER Type Display
Data "841;os,CENTER Type Display;1;0,filter;1,carrier:2,carrier-abs"
'
'Announce587:
'Befehl 842 &H034A: --> Code 1A050189
'CENTER Type Display
'CENTER Type Display
Data "842;as,as841"
'
'Announce588:
'Befehl 843 &H034B: --> Code 1A050190
'Marker Position (Fix Type)
'Marker Position (Fix Type)
Data "843;os,Marker Position fix type;1;0,filter;1,1,carrier"
'
'Announce589:
'Befehl 844 &H034C: --> Code 1A050190
'Marker Position (Fix Type)
'Marker Position (Fix Type)
Data "844;as,as843"
'
'Announce590:
'Befehl 845 &H034D: --> Code 1A050191
'Marker Position (Fix Type)
'Marker Position (Fix Type)
Data "845;os,Marker Position fix type;2;0,main;1,1,sub;0,narrow;1,wide"
'
'Announce591:
'Befehl 846 &H034E: --> Code 1A050191
'Marker Position (Fix Type)
'Marker Position (Fix Type)
Data "846;as,as845"
'
'Announce592:
'Befehl 847 &H034F: --> Code 1A050192
'Averaging
'Averaging
Data "847;os,Averaging;1;0,off;1,1,2;2,3;3,4"
'
'Announce593:
'Befehl 848 &H0350: --> Code 1A050192
'Averaging
'Averaging
Data "848;as,as847"
'
'Announce594:
'Befehl 849 &H0351: --> Code 1A050193
'Waveform Type
'Waveform Type
Data "849;os,Waveform Type;1;0,fill;1,fill+line"
'
'Announce595:
'Befehl 850 &H0352: --> Code 1A050193
'Waveform Type
'Waveform Type
Data "850;as,as849"
'
'Announce596:
'Befehl 851 &H0353: --> Code 1A050194
'Waveform Color current
'Waveform Color current
Data "851;op,spectrum Color current;1;256,red;lin;-;256,yellow;lin;-;256,blue,lin,-"
'
'Announce597:
'Befehl 852 &H0354: --> Code 1A050194
'Waveform Color current
'Waveform Color current
Data "852;ap,as851"
'
'Announce598:
'Befehl 853 &H0355: --> Code 1A050195
'Waveform Color line
'Waveform Color line
Data "853;op,spectrum Color line;1;256,red;lin;-;256,yellow;lin;-;256,blue,lin,-"
'
'Announce599:
'Befehl 854 &H0356: --> Code 1A050195
'Waveform Color line
'Waveform Color line
Data "854;ap,as853"
'
'Announce600:
'Befehl 855 &H0357: --> Code 1A050196
'Waveform Color max hold
'Waveform Color max hold
Data "855;op,spectrum Color max hold;1;256,red;lin;-;256,yellow;lin;-;256,blue,lin,-"
'
'Announce601:
'Befehl 856 &H0358: --> Code 1A050196
'Waveform Color max hold
'Waveform Color max hold
Data "856;ap,as855"
'
'Announce602:
'Befehl 857 &H0359: --> Code 1A050197
'Waterfall Display
'Waterfall Display
Data "857;os,Waterfall Display;1;0,off;1,on"
'
'Announce603:
'Befehl 858 &H035A: --> Code 1A050197
'Waterfall Display
'Waterfall Display
Data "858;as,as857"
'
'Announce604:
'Befehl 859 &H035B: --> Code 1A050198
'Waterfall Speed
'Waterfall Speed
Data "859;os,Waterfall Speed;1;0,slow;1,mid;2,fast"
'
'Announce605:
'Befehl 860 &H035C: --> Code 1A050198
'Waterfall Speed
'Waterfall Speed
Data "860;as,as859"
'
'Announce606:
'Befehl 861 &H035D: --> Code 1A050199
'Waterfall Size
'Waterfall Size
Data "861;os,Waterfall Size;1;0,small;1,mid;2,large"
'
'Announce607:
'Befehl 862 &H035E: --> Code 1A050199
'Waterfall Size
'Waterfall Size
Data "862;as,as860"
'
'Announce608:
'Befehl 863 &H035F: --> Code 1A050200
'Waterfall Peak Color Level
'Waterfall Peak Color Level
Data "863;op,Waterfall Peak Color Level;1;7;lin;-"
'
'Announce609:
'Befehl 864 &H0360: --> Code 1A050200
'Waterfall Peak Color Level
'Waterfall Peak Color Level
Data "864;ap,as863"
'
'Announce610:
'Befehl 865 &H0361: --> Code 1A050201
'Waterfall Size
'Waterfall Size
Data "865;os,Waterfall Size;1;0,off;1,on"
'
'Announce611:
'Befehl 866 &H0362: --> Code 1A050201
'Waterfall Size
'Waterfall Size
Data "866;as,as865"
'
'Announce612:
'Befehl 867 &H0363: --> Code 1A050202 - 4
'Scope fixed edge 144M
'Scope fixed edge 144M
Data "867;os,Waterfall Size;1;0,off;1,on"
'Data "595;iz"
'
'Announce613:
'Befehl 868 &H0364: --> Code 1A050202 - 4
'Scope fixed edge 144M
'Scope fixed edge 144M
Data "868;as,as867"
'
'Announce614:
'Befehl 869 &H0365: --> Code 1A050205 - 7
'Scope fixed edge 430M
'Scope fixed edge 430M
Data "869;iz"
'
'Announce615:
'Befehl 870 &H0366: --> Code 1A050205 -7
'Scope fixed edge 430M
'Scope fixed edge 430M
Data "870;as,as869"
'
'Announce616:
'Befehl 871 &H0367: --> Code 1A050208 - 10
'Scope fixed edge 1230M
'Scope fixed edge 1230M
Data "871;iz"
'
'Announce617:
'Befehl 872 &H0368: --> Code 1A050208 - 10
'Scope fixed edge 1230M
'Scope fixed edge 1230M
Data "872;as,as871"
'
'Announce618:
'Befehl 873 &H0369: --> Code 1A050211
'FFT Scope Waveform Type
'FFT Scope Waveform Type
Data "873;os,FFT Scope Waveform Type;1;0,line;1,fill"
'
'Announce619:
'Befehl 874 &H036A: --> Code 1A050211
'FFT Scope Waveform Type
'FFT Scope Waveform Type
Data "874;as,as873"
'
'Announce620:
'Befehl 875 &H036B: --> Code 1A050212
'FFT Scope Waveform Color
'FFT Scope Waveform Color
Data "875;op,FFT Scope Waveform Color;1;256,red;lin;-;256,yellow;lin;-;256,blue,lin,-"
'
'Announce621:
'Befehl 876 &H036C: --> Code 1A050212
'FFT Scope Waveform Color
'FFT Scope Waveform Color
Data "876;ap,as875"
'
'Announce622:
'Befehl 877 &H036D: --> Code 1A050213
'FFT Scope Waveform Display
'FFT Scope Waveform Display
Data "877;os,FFT Scope Waveform Display;1;0,off;1,on"
'
'Announce623:
'Befehl 878 &H036E: --> Code 1A050213
'FFT Scope Waveform Display
'FFT Scope Waveform Display
Data "878;as,as877"
'
'Announce624:
'Befehl 879 &H036F: --> Code 1A050214
'Oscilloscope Waveform  Waveform Color
'Oscilloscope Waveform  Waveform Color
Data "879;op,Oscilloscope Waveform Waveform Color;1;256,red;lin;-;256,yellow;lin;-;256,blue,lin,-"
'
'Announce625:
'Befehl 880 &H0370: --> Code 1A050214
'Oscilloscope Waveform Waveform Color
'Oscilloscope Waveform Waveform Color
Data "880;ap,as879"
'
'Announce626:
'Befehl 881 &H0371: --> Code 1A050215
'VOICE TX LEVEL
'VOICE TX LEVEL
Data "881;op,VOICE TX LEVEL;1;256,red;lin;-;"
'
'Announce627:
'Befehl 882 &H0372: --> Code 1A050215
'VOICE TX LEVEL
'VOICE TX LEVEL
Data "882;ap,as881"
'
'Announce628:
'Befehl 883 &H0373: --> Code 1A050216
'VOICE TX Auto Monitor
'VOICE TX Auto Monitor
Data "883;os,VOICE TX Auto Monitor;1;0,off;1,on"
'
'Announce629:
'Befehl 884 &H0374: --> Code 1A050216
'VOICE TX Auto Monitor
'VOICE TX Auto Monitor
Data "884;as,as883"
'
'Announce630:
'Befehl 885 &H0375: --> Code 1A050217
'VOICE TX Repeat Time
'VOICE TX Repeat Time
Data "885;op,VOICE TX Repeat Time;1;15,{1 to 15};lin;s"
'
'Announce631:
'Befehl 886 &H0376: --> Code 1A050217
'VOICE TX Repeat Time
'VOICE TX Repeat Time
Data "886;ap,as885"
'
'Announce632:
'Befehl 887 &H0377: --> Code 1A050218
'KEYER 001 Number Style
'KEYER 001 Number Style
Data "887;os,KEYER 001 Number Style;1;0.normal;1,190-ANO;2,190-AANT;3,90-NO;4,90-NT"
'
'Announce635:
'Befehl 888 &H0378: --> Code 1A050218
'KEYER 001 Number Style
'KEYER 001 Number Style
Data "888;as,as887"
'
'Announce634:
'Befehl 889 &H0379: --> Code 1A050219
'KEYER 001 Count Up Trigger
'KEYER 001 Count Up Trigger
Data "889;op,KEYER 001 Count Up Trigger;1;8,{M1 to M8};lin;-"
'
'Announce635:
'Befehl 890 &H037A: --> Code 1A050219
'KEYER 001 Count Up Trigger
'KEYER 001 Count Up Trigger
Data "890;ap,as889"
'
'Announce636:
'Befehl 891 &H037B: --> Code 1A050220
'KEYER 001 Present Number
'KEYER 001 Present Number
Data "891;op,KEYER 001 Present Number;1;9999,{1 to 9999};lin;-"
'
'Announce637:
'Befehl 892 &H037C: --> Code 1A050220
'KEYER 001 Present Number
'KEYER 001 Present Number
Data "892;ap,as891"
'
'Announce638:
'Befehl 893 &H037BD --> Code 1A050221
'CW-KEY SET Tone Level
'CW-KEY SET Tone Level
Data "893;op,CW-KEY Tone Level;1;255,{0 to 100};lin;%"
'
'Announce639:
'Befehl 894 &H037E: --> Code 1A050221
'CW-KEY SET Tone Level
'CW-KEY SET Tone Level
Data "894;ap,as893"
'
'Announce640:
'Befehl 895 &H037F: --> Code 1A050222
'CW-KEY Side Tone Level Limit
'CW-KEY Side Tone Level Limit
Data "895;os,CW-KEY Side Tone Level Limit;1;0.off;1,on"
'
'Announce641:
'Befehl 896 &H0380: --> Code 1A050222
'CW-KEY Side Tone Level Limit
'CW-KEY Side Tone Level Limit
Data "896;as,as895"
'
'Announce642:
'Befehl 897 &H0381: --> Code 1A050223
'CW-KEY Keyer Repeat time
'CW-KEY Keyer Repeat time
Data "897;op,CW-KEY Keyer Repeat time;1;60,{1  To 6};lin;s"
'
'Announce643:
'Befehl 898 &H0382: --> Code 1A050223
'CW-KEY Keyer Repeat time
'CW-KEY Keyer Repeat time
Data "898;ap,as897"
'
'Announce644:
'Befehl 899 &H0383: --> Code 1A050224
'CW-KEY Dot/Dash Ratio
'CW-KEY Dot/Dash Ratio
Data "899;op,CW-KEY Dot/Dash Ratio;1;18,{28 to 45};lin;-"
'
'Announce645:
'Befehl 900 &H0384: --> Code 1A050224
'CW-KEY Dot/Dash Ratio
'CW-KEY Dot/Dash Ratio
Data "990;ap,as899"
'
'Announce646:
'Befehl 901 &H0385: --> Code 1A050225
'CW-KEY Rise Time
'CW-KEY Rise Time
Data "901;os,CW-KEY Rise Time;1;0,2ms;1,4ms;3,6ms;4,8ms-"
'
'Announce647:
'Befehl 902 &H0386: --> Code 1A050225
'CW-KEY Rise Time
'CW-KEY Rise Time
Data "902;as,as901"
'
'Announce648:
'Befehl 903 &H0387: --> Code 1A050226
'CW-KEY Paddle Polarity
'CW-KEY Paddle Polarity
Data "903;os,CW-KEY Paddle Polarity;1;normal;1,reverse"
'
'Announce649:
'Befehl 904 &H0388: --> Code 1A050226
'CW-KEY Paddle Polarity
'CW-KEY Paddle Polarity
Data "904;as,as903"
'
'Announce650:
'Befehl 905 &H0389: --> Code 1A050227
'CW-KEY Key Type
'CW-KEY Key Type
Data "905;os,CW-KEY Key Type ;1;0,straight1.bug;2,paddle"
'
'Announce650:
'Befehl 906 &H038A: --> Code 1A050227
'Key Type
'Key Type
Data "906;as,as905"
'
'Announce652
'Befehl 907 &H038B: --> Code 1A050228
'CW-KEY MIC Up/Down Keyer
'CW-KEY MIC Up/Down Keyer
Data "907;os,CW-KEY MIC Up/Down Keyer;1;0,off;1,on"
'
'Announce653:
'Befehl 908 &H038C: --> Code 1A050228
'MIC Up/Down Keyer
'MIC Up/Down Keyer
Data "908;as,as907"
'
'Announce654
'Befehl 909 &H038D: --> Code 1A050229
'FFT Scope Averaging
'FFT Scope Averaging
Data "909;os,FFT Scope Averaging ;1;0,off;1,2;2,3;3,4"
'
'Announce655:
'Befehl 910 &H038E: --> Code 1A050229
'FFT Scope Averaging
'FFT Scope Averaging
Data "910;as,as909"
'
'Announce656:
'Befehl 911 &H038F: --> Code 1A050230
'FFT Scope Waveform Color
'FFT Scope Waveform Color
Data "879;op,FFT Scope Waveform Color ;1;256,red;lin;-;256,yellow;lin;-;256,blue,lin,-"
'
'Announce657:
'Befehl 912 &H0390: --> Code 1A050230
'FFT Scope Waveform Color
'FFT Scope Waveform Color
Data "912;ap,as911"
'
'Announce658
'Befehl 913 &H0291: --> Code 1A050231
'FFT Scope Averaging
'FFT Scope Averaging
Data "913;os,FFT Scope Averaging;1;0,off;1,on"
'
'Announce659:
'Befehl 914 &H0392: --> Code 1A050231
'FFT Scope Averaging
'FFT Scope Averaging
Data "914;as,as913"
'
'Announce660
'Befehl 915 &H0293: --> Code 1A050232
'RTTY Decode New Line Code
'RTTY Decode New Line Code
Data "915;os,RTTY Decode New Line Code;1;0,CT CRLF;1,CRLF"
'
'Announce661:
'Befehl 916 &H0394: --> Code 1A050232
'RTTY Decode New Line Code
'RTTY Decode New Line Code
Data "916;as,as915"
'
'Announce662
'Befehl 917 &H0295: --> Code 1A050233
'RTTY Decode TxUOS
'RTTY Decode TxUOS
Data "917;os,RTTY Decode TxUOS;1;0,off;1,on"
'
'Announce663:
'Befehl 918 &H0396: --> Code 1A050233
'RTTY Decode TxUOS
'RTTY Decode TxUOS
Data "918;as,as917"
'
'Announce664
'Befehl 919 &H0297: --> Code 1A050234
'Displayed Characters during Tx (Satellite
'Displayed Characters during Tx (Satellite
Data "919;os,Displayed Characters during Tx Satellite;1;0,during rx;1,during tx"
'
'Announce665:
'Befehl 920 &H0398: --> Code 1A050234
'Displayed Characters during Tx (Satellite
'Displayed Characters during Tx (Satellite
Data "920;as,as919"
'
'Announce666:
'Befehl 921 &H0399: --> Code 1A050235
'RTTY DECODE SET > Font Color (Receive)
'RTTY DECODE SET > Font Color (Receive)
Data "921;op,RTTY Font Color Receive;1;256,red;lin;-;256,yellow;lin;-;256,blue,lin,-"
'
'Announce667:
'Befehl 922 &H039A: --> Code 1A050235
'RTTY DECODE SET > Font Color (Receive)
'RTTY DECODE SET > Font Color (Receive)
Data "922;ap,as920"
'
'Announce668:
'Befehl 923 &H039B: --> Code 1A050236
'RTTY DECODE SET > Font Color (transceive)
'RTTY DECODE SET > Font Color (transceive)
Data "923;op,RTTY Font Color transceive;1;256,red;lin;-;256,yellow;lin;-;256,blue,lin,-"
'
'Announce669:
'Befehl 924 &H039C: --> Code 1A050236
'RTTY DECODE SET > Font Color (transceive)
'RTTY DECODE SET > Font Color (transceive)
Data "924;ap,as923"
'
'Announce670
'Befehl 925 &H029D: --> Code 1A050237
'RTTY DECODE LOG
'RTTY DECODE LOG
Data "925;os,RTTY DECODE LOG;1;0,off;1,on"
'
'Announce671:
'Befehl 926 &H039E: --> Code 1A050237
'RTTY DECODE LOG
'RTTY DECODE LOG
Data "926;as,as925"
'
'Announce672
'Befehl 927 &H029F: --> Code 1A050238
'RTTY DECODE LOG File Type
'RTTY DECODE LOG File Type
Data "927;os,RTTY DECODE LOG File Type;1;0,text;1,HTML"
'
'Announce673:
'Befehl 928 &H03A0: --> Code 1A050238
'RTTY DECODE LOG File Type
'RTTY DECODE LOG File Type
Data "928;as,as927"
'
'Announce674
'Befehl 929 &H02A1: --> Code 1A050239
'RTTY DECODE LOG Time Stamp
'RTTY DECODE LOG Time Stamp
Data "929;os,RTTY DECODE LOG Time Stamp;1;0,off;1,on"
'
'Announce675:
'Befehl 930 &H03A2: --> Code 1A050239
'RTTY DECODE LOG Time Stamp
'RTTY DECODE LOG Time Stamp
Data "930;as,as929"
'
'Announce676
'Befehl 931 &H02A3: --> Code 1A050240
'RTTY DECODE LOG Time
'RTTY DECODE LOG Time
Data "931;os,RTTY DECODE LOG Time;1;0,local;1,UTC"
'
'Announce677:
'Befehl 932 &H03A4: --> Code 1A050240
'RTTY DECODE LOG Time
'RTTY DECODE LOG Time
Data "932;as,as930"
'
'Announce678
'Befehl 933 &H02A5: --> Code 1A050241
'RTTY DECODE LOG Frequency
'RTTY DECODE LOG Frequency
Data "933;os,RTTY DECODE LOG Frequency;1;0,off;1,on"
'
'Announce679:
'Befehl 934 &H03A6: --> Code 1A050241
'RTTY DECODE LOG Frequency
'RTTY DECODE LOG Frequency
Data "934;as,as933"
'
'Announce680
'Befehl 935 &H02A7: --> Code 1A050242
'QSO RECORDER TX REC Audio
'QSO RECORDER TX REC Audio
Data "935;os,QSO RECORDER TX REC Audio;1;0,direct;1,monitor"
'
'Announce681:
'Befehl 936 &H03A8: --> Code 1A050242
'QSO RECORDER TX REC Audio
'QSO RECORDER TX REC Audio
Data "936;as,as935"
'
'Announce682
'Befehl 937 &H02A9: --> Code 1A050243
'QSO RECORDER RX REC Condition
'QSO RECORDER RX REC Condition
Data "937;os,QSO RECORDER RX REC Condition;1;0,always;1,sqelch auto"
'
'Announce683:
'Befehl 938 &H03AA: --> Code 1A050243
'QSO RECORDER RX REC Condition
'QSO RECORDER RX REC Condition
Data "938;as,as937"
'
'Announce684
'Befehl 939 &H02AB: --> Code 1A050244
'QSO RECORDER File Split
'QSO RECORDER File Split
Data "939;os,QSO RECORDER File Split;1;0,off;1,on"
'
'Announce685:
'Befehl 940 &H03AC: --> Code 1A050244
'QSO RECORDER File Split
'QSO RECORDER File Split
Data "940;as,as939"
'
'Announce686
'Befehl 941 &H02AD: --> Code 1A050245
'QSO RECORDER REC Operation
'QSO RECORDER REC Operation
Data "941;os,QSO RECORDER REC Operation main/sub;1;0,separate;1,link"
'
'Announce687:
'Befehl 942 &H03AE: --> Code 1A050245
'QSO RECORDER REC Operation
'QSO RECORDER REC Operation
Data "942;as,as941"
'
'Announce688
'Befehl 943 &H02AF: --> Code 1A050246
'QSO RECORDER PTT Auto REC
'QSO RECORDER PTT Auto REC
Data "943;os,QSO RECORDER PTT Auto REC;1;0,off;1,on"
'
'Announce689:
'Befehl 944 &H03B0: --> Code 1A050246
'QSO RECORDER PTT Auto REC
'QSO RECORDER PTT Auto REC
Data "944;as,as943"
'
'Announce690
'Befehl 945 &H02B1: --> Code 1A050247
'QSO RECORDER PRE-REC for PTT Auto REC
'QSO RECORDER PRE-REC for PTT Auto REC
Data "945;os,QSO RECORDE RPRE-REC for PTT Auto REC;1;0,off;1,5s;2,10s;3,15s"
'
'Announce691:
'Befehl 946 &H03B2: --> Code 1A050247
'QSO RECORDER PRE-REC for PTT Auto REC
'QSO RECORDER PRE-REC for PTT Auto REC
Data "946;as,as945"
'
'Announce692
'Befehl 947 &H02B3: --> Code 1A050248
'QSO RECORDER Player Skip Time
'QSO RECORDER Player Skip Time
Data "947;os,QSO RECORDER Player Skip Time;1;0,off;1,5s;2,10s;3,30s"
'
'Announce693:
'Befehl 948 &H03B4: --> Code 1A050248
'QSO RECORDER Player Skip Time
'QSO RECORDER Player Skip Time
Data "948;as,as947"
'
'Announce694
'Befehl 949 &H02B5: --> Code 1A050249
'SCAN Speed
'SCAN Speed
Data "949;os,SCAN Speed;1;0,slow;1,fast"
'
'Announce695:
'Befehl 950 &H03B6: --> Code 1A050249
'SCAN Speed
'SCAN Speed
Data "950;as,as949"
'
'Announce696
'Befehl 951 &H02B7: --> Code 1A050250
'SCAN Resume
'SCAN Resume
Data "951;os,SCAN Resume;1;0,off;1,on"
'
'Announce697:
'Befehl 952 &H03B8: --> Code 1A050250
'SCAN Resume
'SCAN Resume
Data "952;as,as951"
'
'Announce698
'Befehl 953 &H02B9: --> Code 1A050251
'SCAN Pause Timer
'SCAN Pause Timer
Data "953;op,SCAN Pause Timer;1;11,{2 to 20,hold};lin,sec"
'
'Announce699:
'Befehl 954 &H03BA: --> Code 1A050251
'SCAN Pause Timer
'SCAN Pause Timer
Data "954;ap,as953"
'
'Announce700
'Befehl 955 &H02BB: --> Code 1A050252
'SCAN Resume  Timer
'SCAN Resume  Timer
Data "955;op,SCAN Resume Timer;1;7,{0 to 5,hold};lin;sec"
'
'Announce701:
'Befehl 956 &H03BC: --> Code 1A050252
'SCAN Resume  Timer
'SCAN Resume  Timer
Data "956;ap,as955"
'
'Announce702
'Befehl 957 &H02BD: --> Code 1A050253
'SCAN Skip   Timer
'SCAN Skip   Timer
Data "957;os,SCAN Skip Timer;1;0,5min;1,10min;2,15min;3,while scanning;4,while powered on"
'
'Announce703:
'Befehl 958 &H03BE: --> Code 1A050253
'SCAN Skip Timer
'SCAN Skip Timer
Data "958;as,as957"
'
'Announce704
'Befehl 959 &H02BF: --> Code 1A050254
'SCAN MAIN DIAL Operation
'SCAN MAIN DIAL Operation
Data "959;os,SCAN MAIN DIAL Operation;1;0,off;1,up-down"
'
'Announce705:
'Befehl 960 &H03C0: --> Code 1A050254
'SCAN MAIN DIAL Operation
'SCAN MAIN DIAL Operation
Data "960;as,as959"
'
'Announce706
'Befehl 961 &H02C1: --> Code 1A050255
'GPS Select
'GPS Select
Data "961;os,GPS Select;1;0,off;1,external;2,manual"
'
'Announce707:
'Befehl 962 &H03C2: --> Code 1A050255
'GPS Select
'GPS Select
Data "962;as,as961"
'
'Announce708
'Befehl 963 &H02C3: --> Code 1A050256
'GPS Receiver Baud Rate
'GPS Receiver Baud Rate
Data "963;os,GPS Receiver Baud Rate;1;0,4800;1,9600"
'
'Announce709:
'Befehl 964 &H03C4: --> Code 1A050256
'GPS Receiver Baud Rate
'GPS Receiver Baud Rate
Data "964;as,as963"
'
'Announce710
'Befehl 965 &H02C5: --> Code 1A050257
'GPS Manual Position
'GPS Manual Position
Data "965;op,GGPS Manual Position;1;100,lat;lin;degree;60000,{0 to 59.999},lat;lin;min;2,{south,north};lin;-"
Data "965;op;1;199,long;lin;degree;60000,{0 to 59.999},long;lin;min;2,{west,east};lin;-"
Data "965;op;1;199999,{0 to 19999,9,alt;lin;m;2,{0,-},alt;lin;-"
'
'Announce711:
'Befehl 966 &H03C6: --> Code 1A050257
'GPS Manual Position
'GPS Manual Position
Data "966;ap,as965"
'
'Announce712
'Befehl 967 &H02C7: --> Code 1A050258
'GPS TX Mode
'GPS TX Mode
Data "967;os,GPS TX Mode;1;0,off;1,PRS;2,NMEA"
'
'Announce713:
'Befehl 968 &H03C8: --> Code 1A050258
'GPS TX Mode
'GPS TX Mode
Data "968;as,as967"
'
'Announce714
'Befehl 969 &H02C9: --> Code 1A050259
'GPS D-PRS Unproto Address
'GPS D-PRS Unproto Address
Data "969;oa,GPS D-PRS Unproto Address;1;56"
'
'Announce715:
'Befehl 970 &H03CA: --> Code 1A050259
'D-PRS Unproto Address
'D-PRS Unproto Address
Data "970;aa,as969"
'
'Announce716
'Befehl 971 &H02CB: --> Code 1A050260
'GPS D-PRS  TX Format
'GPS D-PRS  TX Format
Data "971;os,GPS D-PRS TX Format;1;0,position;1,item;2,object;3,weather"
'
'Announce717:
'Befehl 972 &H03CC: --> Code 1A050260
'D-PRS  TX Format
'D-PRS  TX Format
Data "972;as,as971"
'
'Announce718
'Befehl 973 &H02CD: --> Code 1A050261
'GPS D-PRS  TX Format Symbol
'GPS D-PRS  TX Format Symbol
Data "973;os,GPS D-PRS TX Format Symbol;1;0,No1;1,No2;2,No3;3,No4"
'
'Announce719:
'Befehl 974 &H03CE: --> Code 1A050261
'D-PRS  TX Format Symbol
'D-PRS  TX Format Symbol
Data "974;as,as973"
'
'Announce720
'Befehl 975 &H02CF: --> Code 1A050262
'GPS D-PRS  TX Format Position
'GPS D-PRS  TX Format Position
Data "975;oa,GPS D-PRS TX Position Symbol No.1;1;2"
'
'Announce721:
'Befehl 976 &H03D0: --> Code 1A050262
'D-PRS  TX Format Position
'D-PRS  TX Format Position
Data "976;aa,as975"
'
'Announce722
'Befehl 977 &H02D1: --> Code 1A050263
'GPS D-PRS  TX Format Position
'GPS D-PRS  TX Format Position
Data "977;oa,GPS D-PRS TX Position Symbol No.2;1;2"
'
'Announce723:
'Befehl 978 &H03D2: --> Code 1A050263
'D-PRS  TX Format Position
'D-PRS  TX Format Position
Data "978;aa,as977"
'
'Announce724
'Befehl 979 &H02D3: --> Code 1A050264
'GPS D-PRS  TX Format Position
'GPS D-PRS  TX Format Position
Data "979;oa,GPS D-PRS TX Position Symbol No.3;1;2"
'
'Announce725:
'Befehl 980 &H03D4: --> Code 1A050264
'D-PRS  TX Format Position
'D-PRS  TX Format Position
Data "980;aa,as979"
'
'Announce726
'Befehl 981 &H02D5: --> Code 1A050265
'GPS D-PRS  TX Format Position
'GPS D-PRS  TX Format Position
Data "981;oa,GPS D-PRS TX Position Symbol No.4;1;2"
'
'Announce727:
'Befehl 982 &H03D6: --> Code 1A050265
'D-PRS  TX Format Position
'D-PRS  TX Format Position
Data "982;aa,as981"
'
'Announce728
'Befehl 983 &H02D7: --> Code 1A050266
'GPS D-PRS  TX SSID
'GPS D-PRS  TX SSID
Data "983;op,GPS D-PRS Position SSID;1;43,{,,-0 to -15,A to Z},lin;-"
'
'Announce729:
'Befehl 984 &H03D8: --> Code 1A050266
'D-PRS  TX SSID
'D-PRS  TX SSID
Data "984;ap,as983"
'
'Announce730
'Befehl 985 &H02D9: --> Code 1A050267
'GPS D-PRS Comment
'GPS D-PRS Comment
Data "985;os,GPS D-PRS Position Comment;1;0,1;1,2;2,3;3,4"
'
'Announce731:
'Befehl 986 &H03DA: --> Code 1A050267
'D-PRS Comment
'D-PRS Comment
Data "986;as,as985"
'
'Announce732
'Befehl 987 &H02DB: --> Code 1A050268
'GPS D-PRS Comment
'GPS D-PRS Comment
Data "987;oa,GPS D-PRS Position Comment1;43"
'
'Announce733:
'Befehl 988 &H03DC: --> Code 1A050268
'D-PRS Comment
'D-PRS Comment
Data "988;aa,as987"
'
'Announce734
'Befehl 989 &H02DD: --> Code 1A050269
'GPS D-PRS Comment
'GPS D-PRS Comment
Data "989;oa,GPS D-PRS Position Comment2;1;43"
'
'Announce735:
'Befehl 990 &H03DE: --> Code 1A050269
'D-PRS Comment
'D-PRS Comment
Data "990;aa,as989"
'
'Announce736
'Befehl 991 &H02DF: --> Code 1A050270
'GPS D-PRS Comment
'GPS D-PRS Comment
Data "991;oa,GPS D-PRS Position Comment3;1;43"
'
'Announce737:
'Befehl 992 &H03E0: --> Code 1A050270
'D-PRS Comment
'D-PRS Comment
Data "992;aa,as991"
'
'Announce738
'Befehl 993 &H02E1: --> Code 1A050271
'GPS D-PRS Comment
'GPS D-PRS Comment
Data "993;oa,GPS D-PRS Comment4;1;43"
'
'Announce739:
'Befehl 994 &H03E2: --> Code 1A050271
'D-PRS Comment
'D-PRS Comment
Data "994;aa,as993"
'
'Announce740
'Befehl 995 &H02E3: --> Code 1A050272
'GPS D-PRS Position Time Stamp
'GPS D-PRS Position Time Stamp
Data "995;os;GPS D-PRS Position Time Stamp1;1;0,off;1,DHM;2,HMS"
'
'Announce741:
'Befehl 996 &H03E4: --> Code 1A050272
'D-PRS Position Time Stamp
'D-PRS Position Time Stamp
Data "996;as,as995"
'
'Announce742
'Befehl 997 &H02E5: --> Code 1A050273
'GPS D-PRS Position Altitude
'GPS D-PRS Position Altitude
Data "997;os;GPS D-PRS Position Altitude;1;0,off;1,on"
'
'Announce743:
'Befehl 998 &H03E6: --> Code 1A050273
'D-PRS Position Altitude
'D-PRS Position Altitude
Data "998;as,as997"
'
'Announce744:
'Befehl 999 &H02E7: --> Code 1A050274
'GPS D-PRS Position Data Extension
'GPS D-PRS Position Data Extension
Data "999;os;GPS D-PRS Position Data Extension;1;0,off;1,coursed-speed2;2,power-hight-gain-directivity"
'
'Announce745:
'Befehl 1000 &H03E8: --> Code 1A050274
'D-PRS Position Data Extension
'D-PRS Position Data Extension
Data "1000;as,as999"
'
'Announce746:
'Befehl 1001 &H02E9: --> Code 1A050275
'GPS D-PRS Position Power
'GPS D-PRS Position Power
Data "1001;os;GPS D-PRS Position Power W;1;0,0;1,1;2,4;3,9;4,16;5,25;6,36;7,49;8,64;9,81"
'
'Announce747:
'Befehl 1001 &H03EA: --> Code 1A050275
'D-PRS Power
'D-PRS Power
Data "1002;as,as1001"
'
'Announce748:
'Befehl 1003 &H02EB: --> Code 1A050276
'GPS D-PRS Height
'GPS D-PRS Height
Data "1003;os;GPS D-PRS Position Height m;1;0,3;1,6;2,12;3,24;4,49;5,98;6,195;7,390;8,780;9,1561"
'
'Announce749:
'Befehl 1004 &H03EC: --> Code 1A050276
'D-PRS Height
'D-PRS Height
Data "1004;as,as1003"
'
'Announce750:
'Befehl 1005 &H02ED: --> Code 1A050277
'GPS D-PRS Gain
'GPS D-PRS Gain
Data "1005;op;GPS D-PRS Position Gain;1:10,{0 to -9};lin;dB"
'
'Announce751:
'Befehl 1006 &H03EE: --> Code 1A050277
'D-PRS Gain
'D-PRS Gain
Data "1006;ap,as1005"
'
'Announce752:
'Befehl 1007 &H02EF: --> Code 1A050278
'GPS D-PRS Directivity
'GPS D-PRS Directivity
Data "1007;os;GPS D-PRS Position Directivity;1:0,Omni;1,NE;2,E;3,SE;4,S;5,SW;6,W;7;NW;8;N"
'
'Announce753:
'Befehl 1008 &H03F0: --> Code 1A050278
'D-PRS Directivity
'D-PRS Directivity
Data "1008;as,as1007"
'
'Announce754:
'Befehl 1009 &H02F1: --> Code 1A050279
'GPS D-PRS Object Name
'GPS D-PRS Object Name
Data "1009;oa;GPS D-PRS Object Name ;1:9"
'
'Announce755:
'Befehl 1010 &H03F2: --> Code 1A050279
'D-PRS Object Name
'D-PRS Object Name
Data "1010;aa,as1009"
'
'Announce756:
'Befehl 1011 &H02F3: --> Code 1A050280
'GPS D-PRS Object Data Type
'GPS D-PRS Object Data Type
Data "1011;os;GPS D-PRS Object Data Type;1:0,live;1,kill"
'
'Announce757:
'Befehl 1012 &H03F4: --> Code 1A050280
'D-PRS Object Data Type
'D-PRS Object Data Type
Data "1012;as,as1011"
'
'Announce758:
'Befehl 1013 &H02F5: --> Code 1A050281
'GPS D-PRS Object Symbol
'GPS D-PRS Object Symbol
Data "1013;oa;GPS D-PRS Object Symbol;1:2"
'
'Announce759:
'Befehl 1014 &H03F6: --> Code 1A050281
'D-PRS Object Symbol
'D-PRS Object Symbol
Data "1014;aa,as1013"
'
'Announce760:
'Befehl 1015 &H02F7: --> Code 1A050282
'GPS D-PRS Object Comment
'GPS D-PRSObject  Comment
Data "1015;oa;GPS D-PRS Object Comment;1:2"
'
'Announce761:
'Befehl 1016 &H03F8: --> Code 1A050282
'D-PRS Object Comment
'D-PRS Object Comment
Data "1016;aa,as1015"
'
'Announce762:
'Befehl 1017 &H02F9: --> Code 1A050283
'GPS D-PRS Object Position
'GPS D-PRS Object Position
Data "1017;op,GGPS MObject Position;1;100,lat;lin;degree;60000,{0 to 59.999},lat;lin;min;2,{south,north};lin;-"
Data "1017;op;1;199,long;lin;degree;60000,{0 to 59.999},long;lin;min;2,{west,east};lin;-"
Data "1017;op;1;199999,{0 to 19999,9,alt;lin;m;2,{0,-},alt;lin;-"
'
'Announce763:
'Befehl 1018 &H03FA: --> Code 1A050283
'D-PRS Object Position
'D-PRS Object Position
Data "1018;ap,as1017"
'
'Announce764:
'Befehl 1019 &H02FB: --> Code 1A050284
'GPS D-PRS Object Data Extension
'GPS D-PRS Object Data Extension
Data "1019;os;GGPS Object Data Extension;1;0,off;1,course-speed;2,Power-hight-Gain-Directivity"
'
'Announce765:
'Befehl 1020 &H03FC: --> Code 1A050284
'D-PRS Object Data Extension
'D-PRS Object Data Extension
Data "1020;as,as1019"
'
'Announce766:
'Befehl 1021 &H02FD: --> Code 1A050285
'GPS D-PRS Object Course
'GPS D-PRS Object Course
Data "1021;os;GGPS Object Course;1;361;lin;deg"
'
'Announce767:
'Befehl 1022 &H03FE: --> Code 1A050285
'D-PRS Object Course
'D-PRS Object Course
Data "1022;as,as1021"
'
'Announce768:
'Befehl 1023 &H02FF: --> Code 1A050286
'GPS D-PRS Object speed
'GPS D-PRS Object speed
Data "1023;op;GGPS Object speed;1;1851;lin;kmh"
'
'Announce769:
'Befehl 1024 &H0400: --> Code 1A050286
'D-PRS Object speed
'D-PRS Object speed
Data "1024;ap,as1023"
'
'Announce770:
'Befehl 1025 &H0401: --> Code 1A050287
'GPS D-PRS Object power
'GPS D-PRS Object power
Data "1025;os;GPS D-PRS Object Power W;1;0,0;1,1;2,4;3,9;4,16;5,25;6,36;7,49;8,64;9,81"
'
'Announce771:
'Befehl 1026 &H0402: --> Code 1A050287
'D-PRS Object power
'D-PRS Object power
Data "1026;as,as1025"
'
'Announce772:
'Befehl 1027 &H0403: --> Code 1A050288
'GPS D-PRS Object Height
'GPS D-PRS Object Height
Data "1027;os;GPS D-PRS Object Height;1;0,3;1,6;2,12;3,24;4,49;5,98;6,195;7,390;8,780;9,1561"
'
'Announce773:
'Befehl 1028 &H0404: --> Code 1A050288
'D-PRS Object Height
'D-PRS Object Height
Data "1028;as,as1027"
'
'Announce774:
'Befehl 1029 &H0405: --> Code 1A050289
'GPS D-PRS Object Gain
'GPS D-PRS Object Gain
Data "1029;op;GPS D-PRS Object Gain;1:10;lin;dB"
'
'Announce775:
'Befehl 1030 &H0406: --> Code 1A050289
'D-PRS Object Gain
'D-PRS Object Gain
Data "10030;ap,as1029"
'
'Announce776:
'Befehl 1031 &H0407: --> Code 1A050290
'GPS D-PRS Object Directivity
'GPS D-PRS Object Directivity
Data "1031;os;GPS D-PRS Object Directivity;1:0,Omni;1,NE;2,E;3,SE;4,S;5,SW;6,W;7;NW;8;N"
'
'Announce777:
'Befehl 1032 &H0408: --> Code 1A050290
'D-PRS Object Directivity
'D-PRS Object Directivity
Data "1032;as,as1031"
'
'Announce778:
'Befehl 1033 &H0409: --> Code 1A050291
'GPS D-PRS Object SSID
'GPS D-PRS Object SSID
Data "1033;op;GPS D-PRS Object Tx SSID;1:42,{-,{0 to 15,A to Z};lin;-"
'
'Announce779:
'Befehl 1034 &H040A: --> Code 1A050291
'D-PRS Object SSID
'D-PRS Object SSID
Data "1034;ap,as1033"
'
'Announce780:
'Befehl 1035 &H040B: --> Code 1A050292
'GPS D-PRS Object Time Stamp
'GPS D-PRS Object Time Stamp
Data "1035;os;GPS D-PRS Object Tx Time Stamp;1:0,dhm;1,hms"
'
'Announce781:
'Befehl 1036 &H040C: --> Code 1A050292
'D-PRS Object Time Stamp
'D-PRS Object Time Stamp
Data "1036;as,as1035"
'
'Announce782:
'Befehl 1037 &H040D: --> Code 1A050293
'GPS D-PRS TX Item Name
'GPS D-PRS TX Item Name
Data "1037;oa;GPS D-PRS TX Item Name;1:9"
'
'Announce7083:
'Befehl 1038 &H040E: --> Code 1A050293
'D-PRS TX Item Name
'D-PRS TX Item Name
Data "1038;aa,as1037"
'
'Announce784:
'Befehl 1039 &H040F: --> Code 1A050294
'GPS D-PRS TX Data Type Item
'GPS D-PRS TX Data Type Item
Data "1039;os;GPS D-PRS TX Data Type Item;1:0,live;1,killed"
'
'Announce785:
'Befehl 1040 &H0410: --> Code 1A050294
'D-PRS TX Data Type Item
'D-PRS TX Data Type Item
Data "1040;as,as1039"
'
'Announce786:
'Befehl 1041 &H0411: --> Code 1A050295
'GPS D-PRS Tx Item Symbol
'GPS D-PRS TX Item Symbol
Data "1041;oa;GPS D-PRS TX Item Symbol;1:2"
'
'Announce787:
'Befehl 1042 &H0412: --> Code 1A050295
'D-PRS TX Data Item Symbol
'D-PRS TX Data Item Symbol
Data "1042;aa,as1041"
'
'Announce788:
'Befehl 1043 &H0413: --> Code 1A050296
'GPS D-PRS Tx Item Comment
'GPS D-PRS TX Item Comment
Data "1043;oa;GPS D-PRS TX Item Comment;1:43"
'
'Announce789:
'Befehl 1044 &H0414: --> Code 1A050296
'D-PRS TX Data Item Comment
'D-PRS TX Data Item Comment
Data "1044;aa,as1043"
'
'Announce790:
'Befehl 1045 &H0415: --> Code 1A050297
'GPS D-PRS Tx Item Position
'GPS D-PRS TX Item Position
Data "1045;op,GGPS Item Position;1;100,lat;lin;degree;60000,{0 to 59.999},lat;lin;min;2,{south,north};lin;-"
Data "1045;op;1;199,long;lin;degree;60000,{0 to 59.999},long;lin;min;2,{west,east};lin;-"
Data "1045;op;1;199999,{0 to 19999,9,alt;lin;m;2,{0,-},alt;lin;-"
'
'Announce791:
'Befehl 1046 &H0416: --> Code 1A050297
'D-PRS TX Data Item Position
'D-PRS TX Data Item Position
Data "1046;ap,as1045"
'
'Announce792:
'Befehl 1047 &H0417: --> Code 1A050298
'GPS D-PRS Tx Item Data Extension
'GPS D-PRS TX Item Data Extension
Data "1047;os,GGPS Item Data Extension;1;0,off;1,course-speed;2,power-hight-gain-directivity"
'
'Announce793:
'Befehl 1048 &H0418: --> Code 1A050298
'D-PRS TX Data Item Data Extension
'D-PRS TX Data Item Data Extension
Data "1048;as,as1047"
'
'Announce794:
'Befehl 1049 &H0419: --> Code 1A050299
'GPS D-PRS Tx Item Course
'GPS D-PRS TX Item Course
Data "1049;op,GGPS Item Course;1;361;lin;deg"
'
'Announce795:
'Befehl 1050 &H041A: --> Code 1A050299
'D-PRS TX Data Item Course
'D-PRS TX Data Item Course
Data "1050;ap,as1049"
'
'Announce796:
'Befehl 1051 &H041B: --> Code 1A050300
'GPS D-PRS Tx Item Speed
'GPS D-PRS TX Item Speed
Data "1051;op,GGPS Item Speed;1;1851;lin;deg"
'
'Announce797:
'Befehl 1052 &H041C: --> Code 1A050300
'D-PRS TX Data Item Speed
'D-PRS TX Data Item Speed
Data "1052;ap,as1051"
'
'Announce799:
'Befehl 1053 &H041D: --> Code 1A050301
'GPS D-PRS Tx Item Power
'GPS D-PRS TX Item Power
Data "1053;os;GPS D-PRS Item Power W;1;0,0;1,1;2,4;3,9;4,16;5,25;6,36;7,49;8,64;9,81"
'
'Announce799:
'Befehl 1054 &H041E: --> Code 1A050301
'D-PRS TX Data Item Power
'D-PRS TX Data Item Power
Data "1054;as,as1054"
'
'Announce800:
'Befehl 1055 &H041F: --> Code 1A050302
'GPS D-PRS Tx Item Height
'GPS D-PRS TX Item Height
Data "1055;os;GPS D-PRS Item Height;1;0,3;1,6;2,12;3,24;4,49;5,98;6,195;7,390;8,780;9,1561"
'
'Announce801:
'Befehl 1056 &H0420: --> Code 1A050302
'D-PRS TX Data Item Height
'D-PRS TX Data Item Height
Data "1056;as,as1055"
'
'Announce802:
'Befehl 1057 &H0421: --> Code 1A050303
'GPS D-PRS Tx Item Gain
'GPS D-PRS TX Item Gain
Data "1057;os;GPS D-PRS Item Gain;1;10;lin;dB"
'
'Announce803:
'Befehl 1058 &H0422: --> Code 1A050303
'D-PRS TX Data Item Gain
'D-PRS TX Data Item Gain
Data "1058;as,as1057"
'
'Announce804:
'Befehl 1059 &H0423: --> Code 1A050304
'GPS D-PRS Tx Item Directivity
'GPS D-PRS TX Item Directivity
Data "1059;os;GPS D-PRS Item Directivity;1:0,Omni;1,NE;2,E;3,SE;4,S;5,SW;6,W;7;NW;8;N"
'
'Announce805:
'Befehl 1060 &H0424: --> Code 1A050304
'D-PRS TX Data Item Directivity
'D-PRS TX Data Item Directivity
Data "1060;as,as1059"
'
'Announce806:
'Befehl 1061 &H0425: --> Code 1A050305
'GPS D-PRS Tx Item SSID
'GPS D-PRS TX Item SSID
Data "1061;op;GPS D-PRS Item SSID;1:43,{-,0 to 15,A to Z};lin,-"
'
'Announce807:
'Befehl 1062 &H0426: --> Code 1A050305
'D-PRS TX Data Item SSID
'D-PRS TX Data Item SSID
Data "1062;ap,as1061"
'
'Announce808:
'Befehl 1063 &H0427: --> Code 1A050306
'GPS D-PRS Tx Weather Symbol
'GPS D-PRS TX Weather Symbol
Data "1063;oa;GPS D-PRS Weather Symbol;1:2"
'
'Announce809:
'Befehl 1064 &H0428: --> Code 1A050306
'D-PRS TX Data Weather Symbol
'D-PRS TX Data Weather Symbol
Data "1064;aa,as1063"
'
'Announce810:
'Befehl 1065 &H0429: --> Code 1A050307
'GPS D-PRS Tx Weather SSID
'GPS D-PRS TX Weather SSID
Data "1065;op;GPS D-PRS Weather SSID;1:43,{.,0 to 15,A to Z};lin,-"
'
'Announce811:
'Befehl 1066 &H042A: --> Code 1A050307
'D-PRS TX Data Weather SSID
'D-PRS TX Data Weather SSID
Data "1066;ap,as1065"
'
'Announce812:
'Befehl 1067 &H042B: --> Code 1A050308
'GPS D-PRS Tx Weather Comment
'GPS D-PRS TX Weather Comment
Data "1067;oa;GPS D-PRS Weather Comment;1:43"
'
'Announce813:
'Befehl 1068 &H042C: --> Code 1A050308
'D-PRS TX Data Weather Comment
'D-PRS TX Data Weather Comment
Data "1068;aa,as1067"
'
'Announce814:
'Befehl 1069 &H042D: --> Code 1A050309
'GPS D-PRS Tx Weather Time Stamp
'GPS D-PRS TX Weather Time Stamp
Data "1069;os;GPS D-PRS Weather Time Stamp;1:0,off;1,dhm;2,hms"
'
'Announce815:
'Befehl 1070 &H042E: --> Code 1A050309
'D-PRS TX Data Weather Time Stamp
'D-PRS TX Data Weather Time Stamp
Data "1070;as,as1069"
'
'Announce816:
'Befehl 1071 &H042F: --> Code 1A050310
'GPS D-PRS Tx NMEA Sentence RMC
'GPS D-PRS TX NMEA Sentence RMC
Data "1071;os;GPS D-PRS NMEA Sentence RMC;1:0,off;1,on"
'
'Announce817:
'Befehl 1072 &H0430: --> Code 1A050310
'D-PRS TX Data Weather NMEA Sentence RMC
'D-PRS TX Data Weather NMEA Sentence RMC
Data "1072;as,as1071"
'
'Announce818:
'Befehl 1073 &H0431: --> Code 1A050311
'GPS D-PRS Tx NMEA Sentence CGA
'GPS D-PRS TX NMEA Sentence CGA
Data "1073;os;GPS D-PRS NMEA Sentence CGA;1:0,off;1,on"
'
'Announce819:
'Befehl 1074 &H0432: --> Code 1A050311
'D-PRS TX Data Weather NMEA Sentence CGA
'D-PRS TX Data Weather NMEA Sentence CGA
Data "1074;as,as1073"
'
'Announce820:
'Befehl 1075 &H0433: --> Code 1A050312
'GPS D-PRS Tx NMEA Sentence GLL
'GPS D-PRS TX NMEA Sentence GLL
Data "1075;os;GPS D-PRS NMEA Sentence GLL;1:0,off;1,on"
'
'Announce821:
'Befehl 1076 &H0434: --> Code 1A050312
'D-PRS TX Data Weather NMEA Sentence GLL
'D-PRS TX Data Weather NMEA Sentence GLL
Data "1076;as,as1075"
'
'Announce822:
'Befehl 1077 &H0435: --> Code 1A050313
'GPS D-PRS Tx NMEA Sentence GSA
'GPS D-PRS TX NMEA Sentence GSA
Data "1077;os;GPS D-PRS NMEA Sentence GSA;1:0,off;1,on"
'
'Announce823:
'Befehl 1078 &H0436: --> Code 1A050313
'D-PRS TX Data Weather NMEA Sentence GSA
'D-PRS TX Data Weather NMEA Sentence GSA
Data "1078;as,as1077"
'
'Announce824:
'Befehl 1079 &H0437: --> Code 1A050314
'GPS D-PRS Tx NMEA Sentence VTG
'GPS D-PRS TX NMEA Sentence VTG
Data "1079;os;GPS D-PRS NMEA Sentence VTG;1:0,off;1,on"
'
'Announce825:
'Befehl 1080 &H0439: --> Code 1A050314
'D-PRS TX Data Weather NMEA Sentence VTG
'D-PRS TX Data Weather NMEA Sentence VTG
Data "1080;as,as1079"
'
'Announce826:
'Befehl 1081 &H0439: --> Code 1A050315
'GPS D-PRS Tx NMEA Sentence GSV
'GPS D-PRS TX NMEA Sentence GSV
Data "1081;os;GPS D-PRS NMEA Sentence GSV;1:0,off;1,on"
'
'Announce827:
'Befehl 1082 &H043A: --> Code 1A050315
'D-PRS TX Data Weather NMEA Sentence GSV
'D-PRS TX Data Weather NMEA Sentence GSV
Data "1082;as,as1081"
'
'Announce828:
'Befehl 1083 &H043B: --> Code 1A050316
'GPS D-PRS Tx NMEA Message
'GPS D-PRS TX NMEA Message
Data "1083;oa;GPS D-PRS NMEA Message;1:20"
'
'Announce829:
'Befehl 1084 &H043C: --> Code 1A050316
'D-PRS TX Data Weather NMEA Message
'D-PRS TX Data Weather NMEA Message
Data "1084;aa,as1083"
'
'Announce830:
'Befehl 1085 &H043D: --> Code 1A050317
'GPS Alarm Area
'GPS Alarm Area
Data "1085;op;GPS Alarm Area;1:60000;lin;-"
'
'Announce831:
'Befehl 1086 &H043E: --> Code 1A050317
'GPS Alarm Area
'GPS Alarm Area
Data "1086;ap,as1085"
'
'Announce832:
'Befehl 1087 &H043F: --> Code 1A050318
'GPS Alarm Area RX/Memory
'GPS Alarm Area RX/Memory
Data "1087;os;GPS Alarm Area RX/Memory;1:0,limited;1,extended;2,both"
'
'Announce833:
'Befehl 1088 &H0440: --> Code 1A050318
'GPS Alarm Area RX/Memory
'GPS Alarm Area RX/Memory
Data "1088;as,as1087"
'
'Announce834:
'Befehl 1089 &H0441: --> Code 1A050319
'GPS Alarm Auto Tx
'GPS Alarm Auto Tx
Data "1089;os;GPS Auto Tx;1:0,off;1,5s;2,10s;3,30s;4,1m;5,3m;6,5m;7,10m;8,30m"
'
'Announce835:
'Befehl 1090 &H0442: --> Code 1A050319
'GPS Auto Tx
'GPS Auto Tx
Data "1090;as,as1089"
'
'Announce836:
'Befehl 1091 &H0443: --> Code 1A050320
'DTMF Speed
'DTMF Speed
Data "1091;os;DTMF Speed;1:0,100ms;1,200ms;2,300ms;3,500ms"
'
'Announce837:
'Befehl 1092 &H0444: --> Code 1A050320
'DTMF Speed
'DTMF Speed
Data "1092;as,as1091"
'
'Announce838:
'Befehl 1093 &H0445: --> Code 1A050321
'NB LEVEL (144 MHz)
'NB LEVEL (144 MHz)
Data "1093;op;NB LEVEL 144MHz;1:255,{0 to 100};lin;%"
'
'Announce839:
'Befehl 1094 &H0446: --> Code 1A050321
'NB LEVEL (144 MHz)
'NB LEVEL (144 MHz)
Data "1093;ap,as1093"
'
'Announce840:
'Befehl 1095 &H0447: --> Code 1A050322
'NB Depth (144 MHz)
'NB Depth (144 MHz)
Data "1095;op;NB Depth 144MHz;1:10,{1 to 10};lin;-"
'
'Announce841:
'Befehl 1096 &H0448: --> Code 1A050322
'NB Depth (144 MHz)
'NB Depth (144 MHz)
Data "1096;ap,as1095"
'
'Announce842:
'Befehl 1097 &H0449: --> Code 1A050323
'NB Width (144 MHz)
'NB Width (144 MHz)
Data "1097;op;NB Width 144MHz;1:255,{0 to 100};lin;%"
'
'Announce843:
'Befehl 1098 &H044A: --> Code 1A050323
'NB Width (144 MHz)
'NB Width (144 MHz)
Data "1098;ap,as1097"
'
'Announce844:
'Befehl 1099 &H044B: --> Code 1A050324
'NB LEVEL (430 MHz)
'NB LEVEL (430 MHz)
Data "1099;op;NB LEVEL 430MHz;1:255,{0 to 100};lin;%"
'
'Announce845:
'Befehl 1100 &H044C: --> Code 1A050324
'NB LEVEL (430 MHz)
'NB LEVEL (430 MHz)
Data "1100;ap,as1099"
'
'Announce846:
'Befehl 1101 &H044D: --> Code 1A050325
'NB DEPTH  (430 MHz)
'NB DEPTH  (430 MHz)
Data "1101;op;NB DEPTH 430MHz;1:10,{1 to 10};lin;-"
'
'Announce847:
'Befehl 1102 &H044E: --> Code 1A050325
'NB DEPTH  (430 MHz)
'NB DEPTH  (430 MHz)
Data "1102;ap,as1101"
'
'Announce848:
'Befehl 1103 &H044F: --> Code 1A050326
'NB WIDTH   (430 MHz)
'NB WIDTH   (430 MHz)
Data "1103;op;NB WIDTH 430MHz;1:255,{0 to 100};lin;%"
'
'Announce849:
'Befehl 1104 &H0450: --> Code 1A050326
'NB WIDTH   (430 MHz)
'NB WIDTH   (430 MHz)
Data "1104;ap,as1103"
'
'Announce850:
'Befehl 1105 &H0451: --> Code 1A050327
'NB LEVEL   (1230 MHz)
'NB LEVEL   (1230 MHz)
Data "1105;op;NB LEVEL 1230MHz;1:255,{0 to 100};lin;%"
'
'Announce851:
'Befehl 1106 &H0452: --> Code 1A050327
'NB LEVEL   (1230 MHz)
'NB LEVEL   (1230 MHz)
Data "1106;ap,as1105"
'
'Announce852:
'Befehl 1107 &H0453: --> Code 1A050328
'NB DEPTH    (1230 MHz)
'NB DEPTH    (1230 MHz)
Data "1107;op;NB DEPTH  1230MHz;1:10,{1 to 10};lin;-"
'
'Announce853:
'Befehl 1108 &H0454: --> Code 1A050328
'NB DEPTH    (1230 MHz)
'NB DEPTH    (1230 MHz)
Data "1108;ap,as1107"
'
'Announce854:
'Befehl 1109 &H0455: --> Code 1A050329
'NB WIDTH     (1230 MHz)
'NB WIDTH     (1230 MHz)
Data "1109;op;NB WIDTH  1230MHz;1:255,{0 to 100};lin;%"
'
'Announce855:
'Befehl 1110 &H0456: --> Code 1A050329
'NB WIDTH     (1230 MHz)
'NB WIDTH    (1230 MHz)
Data "1110;ap,as1109"
'
'Announce856:
'Befehl 1111 &H0457: --> Code 1A050330
'NVOX DELAY
'VOX DELAY  (1230 MHz)
Data "1111;op;VOX DELAY;1:21,{0 to 2.0};lin;sec"
'
'Announce857:
'Befehl 1112 &H0458: --> Code 1A050330
'VOX DELAY
'VOX DELAY
Data "1112;ap,as1111"
'
'Announce858:
'Befehl 1113 &H0459: --> Code 1A050331
'VOX voice  DELAY
'VOX voice  DELAY
Data "1113;os;VOX voice DELAY;1:0,off;1,short;2,mid;3,long"
'
'Announce859:
'Befehl 1114 &H045A: --> Code 1A050331
'VOX voice  DELAY
'VOX voice  DELAY
Data "1114;as,as1113"
'
'Announce860:
'Befehl 1115 &H045B: --> Code 1A050332
'PWR LIMIT (144M)
'PWR LIMIT (144M)
Data "1115;os;PWR LIMIT 144MHz;1:0,off;1,on"
'
'Announce861:
'Befehl 1116 &H045C: --> Code 1A050332
'PWR LIMIT (144M)
'PWR LIMIT (144M)
Data "1116;as,as1115"
'
'Announce862:
'Befehl 1117 &H045D: --> Code 1A050333
'PWR LIMIT (144M)
'PWR LIMIT (144M)
Data "1117;op;PWR LIMIT 144MHz;1;255,{0 to 100};lin;%"
'
'Announce863:
'Befehl 1118 &H045E: --> Code 1A050333
'PWR LIMIT (144M)
'PWR LIMIT (144M)
Data "1118;ap,as1117"
'
'Announce864:
'Befehl 1119 &H045F: --> Code 1A050334
'PWR LIMIT (430M)
'PWR LIMIT (430M)
Data "1119;os;PWR LIMIT 430MHz;1:0,off;1,on"
'
'Announce865:
'Befehl 1120 &H0460: --> Code 1A050334
'PWR LIMIT (430M)
'PWR LIMIT (430M)
Data "1120;as,as1119"
'
'Announce866:
'Befehl 1121 &H0461: --> Code 1A050335
'PWR LIMIT (430M)
'PWR LIMIT (430M)
Data "1121;op;PWR LIMIT 430MHz;1;255,{0 to 100};lin;%"
'
'Announce867:
'Befehl 1122 &H0462: --> Code 1A050335
'PWR LIMIT (430M)
'PWR LIMIT (430M)
Data "1122;ap,as1121"
'
'Announce868:
'Befehl 11123 &H0463: --> Code 1A050336
'PWR LIMIT (1230M)
'PWR LIMIT (1230M)
Data "1123;os;PWR LIMIT 1230MHz;1:0,off;1,on"
'
'Announce869:
'Befehl 1124 &H0464: --> Code 1A050336
'PWR LIMIT (1230M)
'PWR LIMIT (1230M)
Data "1124;as,as1123"
'
'Announce870:
'Befehl 1125 &H0465: --> Code 1A050337
'PWR LIMIT (1230M)
'PWR LIMIT (1230M)
Data "1125;op;PWR LIMIT 1230MHz;1;255,{0 to 100};lin;%"
'
'Announce871:
'Befehl 1126 &H0466: --> Code 1A050337
'PWR LIMIT (1230M)
'PWR LIMIT (1230M)
Data "1126;ap,as1125"
'
'Announce872:
'Befehl 1127 &H0467: --> Code 1A050338
'Received Call sign Display
'Received Call sign Display
Data "1127;os;Received Call sign Display;1;0,call;1,name"
'
'Announce873:
'Befehl 1128 &H0468: --> Code 1A050338
'Received Call sign Display
'Received Call sign Display
Data "1128;as,as1127"
'
'Announce874:
'Befehl 1129 &H0469: --> Code 1A050339
'Compass Direction
'Compass Direction
Data "1129;os;Compass Direction;1;0,heading up;1,noth up;2,south up"
'
'Announce875:
'Befehl 1130 &H046A: --> Code 1A050339
'Compass Direction
'Compass Direction
Data "1130;as,as1129"
'
'Announce876:
'Befehl 1131 &H046B: --> Code 1A06
'DATA mode
'DATA mode
'Data "1131;os,DATA mode - Filter:1;0,off;1,Fil1;2,Fil2;3,Fil3"
'
'Announce877:
'Befehl 1132 &H046C: --> Code 1A06
'DATA mode
'DATA mode
Data "1132;as,as1131"
'
'Announce878:
'Befehl 1133 &H046D: --> Code 1A08
'NTP server access
'NTP server access
'Data "1133;os,NTP server access:1;0,terminate;1,initiate"
'
'Announce879:
'Befehl 1134 &H046E --> Code 1A08
'NTP server access
'NTP server access
Data "1134;as,as1133"
'
'Announce880:
'Befehl 1135 &H046F --> Code 1A09
'NTP server access result
'NTP server access result
Data "1135;as,NTP server access result;1;0,Accessing, or have not accessed after Power ON;1,Succeeded;2,failed"
'
'Announce881:
'Befehl 1136 &H0470 --> Code 1A0A
'OVF indicator status
'OVF indicator status
Data "1136;as,OVF indicator status;1;0,off;1,on"
'
'Announce882:
'Befehl 1137 &H0471: --> Code 1B00
'repeater tone frequency
'repeater tone frequency
Data "1137;os,repeater tone frequency;101;0,67.0;1,69.3;2,71.9;3,74.4;4,77,0;5,79.7;6,82.5;7,85.4;8,88.5;9,91.5;10,94.8,11,97.4;"
Data "1137;os,repeater tone frequency;12,100.0;13,103.5;14,107,2;15,110.9;16,114.8;17,118.8;18,123.0;19,127.3;20,131.8;"
Data "1137;os,repeater tone frequency;21,136.5;22,141.3;23,146.2;24,151.4;25,156.7;26,159.8;27,162.2;28,165.5;29,167.9;"
Data "711;os,repeater tone frequency;30,171.3;31,173.8;32,177.3;33,179.9;34,183,5;35,186.2;36,189.9;37,192.8;38,196.6;"
Data "1137;os,repeater tone frequency;39,199.5;40,203.5;41,206.5;42,210.7;43,218.1;44,225,7;45,229.1;46,233.6;47,241.8;48,250.2;49,254.1"
'
'Announce883:
'Befehl 1138 &H0472: --> Code 1B00
'repeater tone frequency
'repeater tone frequency
Data "1138;as,as1137"
'
'Announce884:
'Befehl 1139 &H0473: -->9 Code 1B01
'TSQL tone frequency
'TSQL tone frequency
Data "1139;os,TSQL tone frequency;101;0,67.0;1,69.3;2,71.9;3,74.4;4,77,0;5,79.7;6,82.5;7,85.4;8,88.5;9,91.5;10,94.8,11,97.4;"
Data "1139,TSQL tone frequency;12,100.0;13,103.5;14,107,2;15,110.9;16,114.8;17,118.8;18,123.0;19,127.3;20,131.8;"
Data "1139;os,TSQL tone frequency;21,136.5;22,141.3;23,146.2;24,151.4;25,156.7;26,159.8;27,162.2;28,165.5;29,167.9;"
Data "1139;os,TSQL tone frequency;30,171.3;31,173.8;32,177.3;33,179.9;34,183,5;35,186.2;36,189.9;37,192.8;38,196.6;"
Data "1139;os,TSQL tone frequency;39,199.5;40,203.5;41,206.5;42,210.7;43,218.1;44,225,7;45,229.1;46,233.6;47,241.8;48,250.2;49,254.1"
'
'Announce885:
'Befehl 1140 &H0474: --> Code 1B01
'TSQL tone frequency
'TSQL tone frequency
Data "1140;ap,as1139"
'
'Announce886:
'Befehl 1141 &H0475 --> Code 1B02
'DTCS code and polarity
'DTCS code and polarity
Data "1141;ap,DTCS code and polarity;1;2,{rx normal,tx reverse};lin;-;2,{rx normal,tx reverse};lin;-;7;lin;-;7;lin;-;7;lin;-"
'
'Announce887:
'Befehl 1142 &H0476 --> Code 1B02
'DTCS code and polarity
'DTCS code and polarity
Data "1142;as,as1141"
'
'Announce888:
'Befehl 1143 &H0477 --> Code 1B07
'CSQL code (DV mode)
'CSQL code (DV mode)
Data "1141;ap,CSQL code DV mode;1;100;lin;-"
'
'Announce889:
'Befehl 1144 &H0478 --> Code 1B07
'CSQL code (DV mode)
'CSQL code (DV mode)
Data "1144;as,as1143"
'
'Announce890":
'Befehl 1145 &H0479: --> Code 1C00
'RX/TX
'RX/TX
Data "1145;os,PTT1;1;0:RX;1,TX"
'
'Announce891:
'Befehl 1146 &H047A: --> Code 1C00
'RX/TX
'RX/TX
Data "1146;as,as1145"
'
'Announce892:
'Befehl 1147 &H047B: --> Code 1C02
'transmit frequency monitor setting
'transmit frequency monitor setting
Data "1147;os,transmit frequency monitor;1;0:off;1,on;"
'
'Announce893:
'Befehl 1148 &H047C: --> Code 1C02
'transmit frequency monitor setting
'transmit frequency monitor setting
Data "1148;as,as71147"
'
'Announce894:
'Befehl 1149 &H047D: --> Code 1C03
'transmit frequency
'transmit frequency
Data "1149;ap,transmit frequency;1;69997000,{30000 to 69999999};lin;Hz"
'
'Announce895:
'Befehl 1150 &H047E: --> Code 1E00
'number of available TX frequency band
'number of available TX frequency band
Data "1150;ap,number of available TX frequency band;1;255;lin"
'
'Announce896:
'Befehl 1151 &H027F: --> Code 1E01
'Band edge
'Band edge
Data "1151;ap,band edge frequencies;11;70000000,{0 to 69999999;lin;Hz;70000000,{0 to 69999999};lin;Hz"
'
'Announce897:
'Befehl 1152 &H0480: --> Code 1E02
'number of available use set TX frequency band
'number of available user set TX frequency band
Data "1152;ap,number of available user set TX frequency band;1;99;lin"
'
'Announce898:
'Befehl 1153 &H0481: --> Code 1E03
'user-set TX band edge frequencies
'user-set TX band edge frequencies
Data "1153;op,user-set TX band edge frequencies;30;70000000,{0 to 69999999;lin;Hz;70000000,{0 to 69999999};lin;Hz"
'
'Announce899:
'Befehl 1154 &H0582: --> Code 1E03
'user set band edge
'user set band edge
Data "1154;ap,as1153"
'
'Announce900:
'Befehl 1155 &H0483: --> Code 1F00
'My Call Sign (DV)
'My Call Sign (DV)
Data "1155;oa,My Call Sign (DV);3;8;8;8"
'
'Announce901:
'Befehl 1156 &H0584: --> Code 1F00
'My Call Sign (DV)
'My Call Sign (DV)
Data "1156;aa,as1155"
'
'Announce902:
'Befehl 1157 &H0485: --> Code 1F01
'TX Call Sign Display
'TX Call Sign Display
Data "1157;os,TX Call Sign Display;1;0,off;1,on"
'
'Announce903:
'Befehl 1158 &H0586: --> Code 1F01
'TX Call Sign Display
'TX Call Sign Display
Data "1158;as,as1157"
'
'Announce904:
'Befehl 1159 &H0487: --> Code 1F02
'Message (DV)
'Message (DV)
Data "1159;oa,Message DV;1:20"
'
'Announce905:
'Befehl 1160 &H0488: --> Code 1F02
'Message (DV)
'Message (DV)
Data "1160;aa,as1159"
'
'Announce906:
'Befehl 1161 &H0489: --> Code 2100
'RIT frequency
'RIT frequency
Data "1161;op,RIT frequency;1:19999,{-9999 to 9999};lin;Hz"
'
'Announce907:
'Befehl 1162 &H048A: --> Code 2100
'RIT frequency
'RIT frequency
Data "1162;ap,as1161"
'
'Announce908:
'Befehl 1163 &H048B: --> Code 2101
'RIT
'RIT
Data "1163;os,RIT;1;0:off;1,on"
'
'Announce909:
'Befehl 1164 &H048C: --> Code 2101
'RIT
'RIT
Data "1164;as,as1163"
'
'Announce910:
'Befehl 1165 &H048D: --> Code 2200
'DV TX data
'DV TX data
Data "1165;oa,DV TX data;1;30"
'
'Announce911:
'Befehl 1166 &H048E: --> Code 2200
'DV TX data
'DV TX data
Data "1166;aa,as1165"
'
'Announce912:
'Befehl 1167 &H048F: --> Code 220100
'Auto DV RX data output
'Auto DV RX data output
Data "1167;os,Auto DV RX data output;1;0,off;1,on"
'
'Announce913:
'Befehl 1168 &H0490: --> Code 220100
'Auto DV RX data output
'Auto DV RX data output
Data "1168;as,as1167"
'
'Announce914:
'Befehl 1169 &H0491: --> Code 220101
'DV RX data for transceive
'DV RX data for transceive
Data "1169;oa,DV RX data for transceive;1;60"
'
'Announce915:
'Befehl 1170 &H0492: --> Code 220101
'DV RX data for transceive
'DV RX data for transceive
Data "1170;aa,as1169"
'
'Announce916:
'Befehl 1171 &H0493: --> Code 2202
'DV/DD Set > DV Data TX
'DV/DD Set > DV Data TX
Data "1171;os,DV Data TX;1;0;off;1,on"
'
'Announce917:
'Befehl 1172 &H0494: --> Code 2202
'DV/DD Set > DV Data TX
'DV/DD Set > DV Data TX
Data "1172;as,as1171"
'
'Announce918:
'Befehl 1173 &H0495: --> Code 2203
'DV Fast Data
'DV Fast Data
Data "1173;os,DV Fast Data;1;0;off;1,on"
'
'Announce919:
'Befehl 1174 &H0496: --> Code 2203
'DV Fast Data
'DV Fast Data
Data "1174;as,as1173"
'
'Announce920:
'Befehl 1175 &H0497: --> Code 2204
'DV Fast Data GPS Data Speed
'DV Fast Data GPS Data Speed
Data "1175;os,DV Fast Data GPS Data Speed;1;0;slow;1,fast"
'
'Announce921:
'Befehl 1176 &H0498: --> Code 2204
'DV Fast Data GPS Data Speed
'DV Fast Data GPS Data Speed
Data "1176;as,as1175"
'
'Announce922:
'Befehl 1177 &H0499: --> Code 2205
'DV Fast Data TX Delay (PTT)
'DV Fast Data TX Delay (PTT)
Data "1177;op,DV Fast Data TX Delay PTT;1;11;lin:sec"
'
'Announce923:
'Befehl 1178 &H049A: --> Code 2205
'DV Fast Data TX Delay (PTT)
'DV Fast Data TX Delay (PTT)
Data "1178;ap,as1177"
'
'Announce924:
'Befehl 1179 &H049B: --> Code 2300
'position status
'position status
Data "1179;op,position status;1;5,lat;lin;-;6,long;lin;-;4,alt;lin;-;2,course;lin;-;3,speed;lin;-;;7,date;lin:-"
'
'Announce925:
'Befehl 1180 &H049C: --> Code 2300
'position status
'position status
Data "1180;ap,as1179"
'
'Announce926:
'Befehl 1181 &H049D: --> Code 2301
'GPS Select
'GPS Select
Data "1181;os,GPS Select;1;off;1,external;2,manual"
'
'Announce927:
'Befehl 1182 &H049E: --> Code 2301
'GPS Select
'GPS Select
Data "1182;as,as1181"
'
'Announce928:
'Befehl 1183 &H049F: --> Code 2302
'GPS Manual Position
'GPS Manual Position
Data "1183;op,GPS Manual Position;1;100,lat;lin;degree;60000,{0 to 59.999},lat;lin;min;2,{south,north};lin;-"
Data "1183;op;1;199,long;lin;degree;60000,{0 to 59.999},long;lin;min;2,{west,east};lin;-"
Data "1183;op;1;199999,{0 to 19999,9,alt;lin;m;2,{0,-},alt;lin;-"
'
'Announce929:
'Befehl 1184 &H04A0: --> Code 2302
'GPS Manual Position
'GPS Manual Position
Data "1184;as,as1183"
'
'Announce930:
'Befehl 1185 &H04A1: --> Code 240000
'TX output power setting
'TX output power setting
Data "1185;op,TX output power setting;1;0,off;1,on"
'
'Announce931:
'Befehl 1186 &H04A2: --> Code 240000
'TX output power setting
'TX output power setting
Data "1186;as,as1185"
'
'Announce932:
'Befehl 1187 &H04A3: --> Code 240001
'TX output power setting for transceive
'TX output power setting for transceive
Data "1187;op,TX output power setting for transceive ;1;0,off;1,on"
'
'Announce933:
'Befehl 1188 &H04A4: --> Code 240001
'TX output power setting for transceive
'TX output power setting for transceive
Data "1188;as,as1187"
'
'Announce934:
'Befehl 1189 &H04A5: --> Code 25
'Main frequency
'Main frequency
Data "1189;op,Main frequency;2;69970000,{30000 to 69999999};lin;Hz"
'
'Announce935:
'Befehl 1190 &H04A6: -->0 Code 25
'Main frequncy
'Main frequency
Data "1190;ap,as1189"
'
'Announce936:
'Befehl 1191 &H04A7: --> Code 26
'Main operating mode
'Main operating mode
Data "1191;os,Main mode filter;2;0:sel;1,unsel;0,LSB;1,USB;1,AM;3,CW;4,RTTY;5,FM;6,CW-R;7,RTTY-R;8,DV;9,DD;0,Fil1;1,Fil2;2,Fil3"
'
'Announce937:
'Befehl 1192 &H04A8: --> Code 26
'Main operating mode
'Main operating mode
Data "1192;ap,as1191"
'
'Announce938:
'Befehl 1193 &H04A9: --> Code 2700
'scope data nicht verwendet
'scope data not used
Data "1193;iz"
'
'Announce939:
'Befehl 1194 &H04AA: --> Code 2710
'scope
'scope
Data "1193;os,scope;1;0 off;1 on;5,CHAPTER,scope"
'
'Announce940:
'Befehl 1195 &H04AB. --> Code 2710
'scope
'scope
Data "1195;as,as1194"
'
'Announce941:
'Befehl 1196 &H04AC: --> Code 2711
'Scope wave data output
'Scope wave data output
Data "1196;os,Scope wave data output;1;0 off;1 on;5,CHAPTER,scope"
'
'Announce942:
'Befehl 1197 &H04AD: --> Code 2711
'Scope wave data output
'Scope wave data output
Data "1197;as,as1196"
'
'Announce943:
'Befehl 1198 &H04AE: --> Code 2712
'Main or Sub scope setting
'Main or Sub scope setting
Data "1198;as,Main or Sub scope setting;1;0 main;1,sub;5,CHAPTER,scope"
'
'Announce944:
'Befehl 1199 &H04AF: --> Code 2712
'Main or Sub scope setting
'Main or Sub scope setting
Data "1199;as,as1199"
'
'Announce945:
'Befehl 1200 &H04B0: --> Code 2714
'Scope Center mode or Fixed mode
'Scope Center mode or Fixed mode
Data "1200;os,Scope Center mode or Fixed mode;2;0,main;1,sub;0 center;1,fixed;5,CHAPTER,scope"
'
'Announce946:
'Befehl 1201 &H04B1: --> Code 2714
'Scope Center mode or Fixed mode
'Scope Center mode or Fixed mode
Data "1201;as,as1200"
'
'Announce947:
'Befehl 1202 &H04B2: --> Code 2715
'span setting in the Center mode
'span setting in the Center mode
Data "1202;os,span setting in the Center mode;2;0,main;1,sub;0 2k5;1,5k;2,10k;3,25k;4,50k;5,100k;6,250k;7,500k;5,CHAPTER,scope"
'
'Announce948:
'Befehl 1203 &H04B3: --> Code 2715
'span setting in the Center mode
'span setting in the Center mode
Data "1103;as,as1102"
'
'Announce949:
'Befehl 1204 &H04B4: --> Code 2716
'Edge number setting in the Fixed mode
'Edge number setting in the Fixed mode
Data "1204;os,Edge number setting in the Fixed mode;2;0,main;1,sub;0 Edge1;1,Edge2;2,Edge3;5,CHAPTER,scope"
'
'Announce950:
'Befehl 1205 &H04B5: --> Code 2716
'Edge number setting in the Fixed mode
'Edge number setting in the Fixed mode
Data "1205;as,as1204"
'
'Announce951:
'Befehl 1206 &H04B6: --> Code 2717
'Scope hold
'Scope hold
Data "1206;os,Scope hold;2;0,main;1,sub;0,off;1,on;5,CHAPTER,scope"
'
'Announce952:
'Befehl 1207 &H04B7. --> Code 2717
'Scope hold
'Scope hold
Data "1207;as,as1206"
'
'Announce953:
'Befehl 1208 &H04B8: --> Code 2719
'Scope Reference level
'Scope Reference level
Data "1208;op,Scope Reference level;2;0,main;1,sub;81,{-20.0 to 20.0};lin;db;5,CHAPTER,scope"
'
'Announce954:
'Befehl 1209 &H04B9: --> Code 2719
'Scope Reference level
'Scope Reference level
Data "1209;ap,as1208"
'
'Announce955:
'Befehl 1210 &H04BA: --> Code 271A
'Sweep speed
'Sweep speed
Data "1210;os,Sweep speed;1;0,fast;1,mid;2,slow"
'
'Announce956:
'Befehl 1211 &H04BB: --> Code 271A
'Sweep speed
'Sweep speed
Data "1211;as,as1210"
'
'Announce957:
'Befehl 1212 &H04BC: --> Code 271B
'Scope indication during TX in the Center mode
'Scope indication during TX in the Center mode
Data "1212;os,Scope indication during TX in the Center mode;1;0,off;1,on;5,CHAPTER,scope"
'
'Announce958:
'Befehl 1213 &H04BD: --> Code 271B
'Scope indication during TX in the Center mode
'Scope indication during TX in the Center mode
Data "1213;as,as1212"
'
'Announce959:
'Befehl 1214 &H04BE: --> Code 271C
'center frequency setting in the Center mode
'center frequency setting in the Center mode
Data "1214;os,center frequency in the Center mode;1;0,Filter center;1,carrier center;2,carrier center(absolute);5,CHAPTER,scope"
'
'Announce960:
'Befehl 1215 &H04BF: --> Code 271C
'center frequency setting in the Center mode
'center frequency setting in the Center mode
Data "1215;as,as1214"
'
'Announce961:
'Befehl 1216 &H02C0: --> Code 271D
'VBW
'VBW
Data "1216;os,VBW;1;0,narrow;1,wide"
'
'Announce962:
'Befehl 1217 &H04C1: --> Code 271D
'VBW
'VBW
Data "1217;as,as1216"
'
'Announce963:
'Befehl 1218 &H02C2: --> Code 271D
'Voice TX Memory
'Voice TX Memory
Data "1218;os,Voice TX Memory;1;0,stop;1,T1;2,T2;3,T3;4,T4;5,T5;6,T6;7,T7;8,T8"
'
'Announce964
'Befehl  65520 &HFFF0
'liest announcements
'read n announcement lines
Data "65520;ln,ANNOUNCEMENTS;175;969"
'
'Announce965:                                                  '
'Befehl 65532 &HFFFC
'Liest letzten Fehler
'read last error
Data "65532;aa,LAST ERROR;20,last_error"
'
'Announce966:                                                  '
'Befehl 65533 &HFFFD
'Geraet aktiv Antwort
'Life signal
Data "65533;aa,MYC INFO;b,ACTIVE"
'
'Announce967:
'Befehl 65534 &HFFFE <n><data>
'eigene Individualisierung schreiben
'write individualization
Data "65534;ka,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,23,{0 to 127};a,SERIAL,1"
'
'Announce968:
'Befehl 65535  &FFHFF <n>
'eigene Individualisierung lesen
'read individualization
Data "65535 ;la,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,23,{0 to 127};a,SERIAL,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1"
'