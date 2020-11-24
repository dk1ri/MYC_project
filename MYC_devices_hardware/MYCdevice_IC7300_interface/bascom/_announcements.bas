' name : _announcements.bas
' 202001113
'
Announce:
'Befehl &H00
'eigenes basic 'Announcement lesen
'basic 'Announcement is read to I2C or output
Data "0;m;DK1RI;IC7300 Interface;V01.3;1;175;2;569;1-1"
'
'Announce1:
'Befehl 256 &H0100 0 to 69970000: --> Code 00 (05) (&H25 used)
'Frequenz schreiben
'write Frequency
Data "256;op,freqency;1;69970000,{30000 to 69999999};lin;Hz"
'
'Announce2:
'Befehl 257 &H0101 0 to 69970000: -->  Code 03
'Frequenz lesen
'read Frequency
Data "257;ap,as256"
'
'Announce3:
'Befehl 258 &H0102: -->Code 01 (06)
'Mode schreiben
'write mode
Data "258;os,mode;2;0,LSB;1,USB;1,AM;3,CW;4,RTTY;5,FM;6,CW-R;7,RTTY-R;0,FIL1;1,FIL2;2.FIL3"
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
'Befehl 263 &H0107 0 to 101: --> Code 08
'set memory mode
'set memory mode
Data "263;ou,set memory mode;1;0.idle;1,memory mode"
'
'Announce9:
'Befehl 264 &H0108 0 to 101: --> Code 08
'select memory
'select memory
Data "264;op,vfo to memory;1;101,{1 to 99,P1,P2};lin;-"
'
'Announce10:
'Befehl 265 &H0109: --> Code 09
'Vfo und Mode nach memory schreiben
'write vfo and mode to memory
Data "265;ou,copy vfo and mode to memory;1;0,idle;1,copy to memory"
'
'Announce11:
'Befehl 266 &H010A: --> Code 0A
'memory nach Vfo und mode schreiben
'write memory to vfo and mode
Data "266;ou,copy memory to vfo and mode;1;0,idle;1,copy to vfo and mode"
'
'Announce12:
'Befehl 267 &H010B: --> Code 0B
'memory loeschen
'clear memory
Data "267;ou,clear memory;1;0,idle;1,clear memory"
'
'Announce13:
'Befehl 268 &H010C: --> Code 0E00..
'start scan mode
'start scan mode
Data "268;os,start scan mode;1;0,stop;1,prog memory;2,prog;3,frequncy;4,fine;5,fine delta;6,memory;7,select memory"
'
'Announce14:
'Befehl 269 &H010D: --> Code 0E A1 - A7
'scan span waehlen
'select scan span
Data "269;os,select scan span;1;0,5kHz;1,10kHz;2,20kHz;3,50kHz;4,100kHz;5,500kHz;6,1MHz"
'
'Announce15:
'Befehl 270 &H010E:--> Code 0EB0
'set as chanal
'set as chanal
Data "270,ou,set as non select chanal;1;0,idle;1,set"
'
'Announce16:
'Befehl 271 &H010F: --> Code 0EB1
'select chanal
'select chanal
Data "271,os,select chanal;1;0,,previous;1,1;2,2;3,3"
'
'Announce17:
'Befehl 272 &H0110: --> Code 0EB2
'Set for select memory scan
'Set for select memory scan
Data "272,os,Set for select memory scan;1;0,all;1,sel1;2,sel2;3,sel3"
'
'Announce18:
'Befehl 273 &H0111: --> Code 0ED1, 0ED3
'scan resume
'scan resume
Data "273;os,scan resume;1;0,off;1,on"
'
'Announce19:
'Befehl 274 &H0112: Code 0F
'split
'split
Data "274;os,split;1;0,off;1,on"
'
'Announce20:
'Befehl 275 &H0113: --> Code 0F
'split
'split
Data "275;as,as274"
'
'Announce21:
'Befehl 276 &H0114: -->Code 10
'tuning step
'tuning step
Data "276;os,tuning step;1;0,off;1,100;2,1k;3,5k;4,9k;5,10k;6,12.5k;7,20k;8,25k"
'
'Announce22:
'Befehl 277 &H0115:  --> Code 10
'tuning step
'tuning step
Data "277;as,as276"
'
'Announce23:
'Befehl 278 &H0116: -->  Code 11
'Abschwaecher
'attenuator
Data "278;os,attenuator;1;0,off;1,20dB"
'
'Announce24:
'Befehl 279 &H0117: --> Code 11
'Abschwaecher
'attenuator
Data "279;as,as278"
'
'Announce25:
'Befehl 280 &H0118: --> Code 13
'aktuelle Sprachausgabe
'actual speech
Data "280;os,speech;1;0,all;1,freq and smeter;2,mode"
'
'Announce26:
'Befehl 281 &H0119: --> Code 1401
'Lautstaerke
'AF level
Data "281;op,AF level;1;256;lin;%"
'
'Announce27:
'Befehl 282 &H011A: --> Code 1401
'Lautstaerke
'AF level
Data "282;ap,as281"
'
'Announce28:
'Befehl 283 &H011B: --> Code 1402
'Hf Pegel
'RF level
Data "283;op,RF level;1;256;lin;%"
'
'Announce29:
'Befehl 284 &H011C: --> Code 1402
'Hf Pegel
'RF level
Data "284;ap,as283"
'
'Announce30:
'Befehl 285 &H011D: --> Code 1403
'Squelch
'Squelch
Data "285;op,Squelch;1;256,{0 to 100};lin;%"
'
'Announce31:
'Befehl 286 &H011E: --> Code 1403
'Squelch
'Squelch
Data "286;ap,as285"
'
'Announce32:
'Befehl 287 &H011F: --> Code 1406
'Noise reduction
'Noise reduction
Data "287;op,Noise reduction;1;256;lin;%"
'
'Announce33:
'Befehl 288 &H0120: --> Code 1406
'Noise reduction
'Noise reduction
Data "288;ap,as287"
'
'Announce34:
'Befehl 289 &H0121: --> Code 1407
'inner Twin PBT
'inner Twin PBT
Data "289;op,inner Twin PBT;1;256;lin;-"
'
'Announce35:
'Befehl 290 &H0122: --> Code 1407
'inner Twin PBT
'inner Twin PBT
Data "290;ap,as289"
'
'Announce36:
'Befehl 291 &H0123: --> Code 1408
'outer Twin PBT
'outer Twin PBT
Data "291;op,outer Twin PBT;1;256;lin;-"
'
'Announce37:
'Befehl 292 &H0124: --> Code 1408
'outer Twin PBT
'outer Twin PBT
Data "292;ap,as291"
'
'Announce38:
'Befehl 293 &H0125: --> Code 1409
'CW Pitch
'CW Pitch
Data "293;op,CW Pitch;1;256,{300 to 900};lin;Hz"
'
'Announce39:
'Befehl 294 &H0126: --> Code 1409
'CW Pitch
'CW Pitch
Data "294;ap,as293"
'
'Announce40:
'Befehl 295 &H0127: --> Code 140A
'Hf Leistung
'Rf power
Data "295;op,Rf power;1;256,{0 to 100};lin;%"
'
'Announce41:
'Befehl 296 &H0128: --> Code 140A
'Hf Leistung
'Rf power
Data "296;ap,as295"
'
'Announce42:
''Befehl 297 &H0129: --> Code 140B
'Mic Pegel
'Mic level
Data "297;op,Mic level;1;256,{0 to 100};lin;%"
'
'Announce43:
'Befehl 298 &H012A: --> Code 140B
'Mic Pegel
'Mic level
Data "298;ap,as297"
'
'Announce44:
'Befehl 299 &H012B : --> Code 140C
'CW Geschwindigkeit
'key speed
Data "299;op,key speed;1;256,{6 to 48};lin;wpm"
'
'Announce45:
'Befehl 300 &H012C: --> Code 140C
'CW Geschwindigkeit
'key speed
Data "300;ap,as299"
'
'Announce46:
'Befehl 301 &H012D: --> Code 140D
'Notch
'Notch
Data "301;op,Notch;1;256,{0 to 100};lin;%"
'
'Announce47:
'Befehl 302 &H012E: --> Code 140D
'Notch
'Notch
'Data "302;ap,as301"
'
'Announce48:
'Befehl 303 &H012F: --> Code 140E
'Comp
'Comp
Data "303;op,comp;1;256,{0 to 10};lin;-"
'
'Announce49:
'Befehl 304 &H0130: --> Code 140E
'Comp
'Comp
Data "304;ap,as303"
'
'Announce50:
'Befehl 305 &H0131: --> Code 140F
'Break in delay
'Break in delay
Data "305;op,break in delay;1;256,{2.0 to 13.0};lin;d"
'
'Announce51:
'Befehl 306 &H0132: --> Code 140F
'Break in delay
'Break in delay
Data "306;ap,as305"
'
'Announce52:
'Befehl 307 &H0133: --> Code 1412
'NB Pegel
'NB level
Data "307;op,NB level;1;256,{0 to 100};lin;%"
'
'Announce53:
'Befehl 308 &H0134: --> Code 1412
'NB Pegel
'NB level
Data "308;ap,as307"
'
'Announce54:
'Befehl 309 &H0135: --> Code 1415
'Monitor Pegel
'monitor level
Data "309;op,monitor level;1;256,{0 to 100};lin;%"
'
'Announce55:
'Befehl 310 &H0136: --> Code 1415
'Monitor Pegel
'monitor level
Data "310;ap,as309"
'
'Announce56:
'Befehl 311 &H0137: --> Code 1416
'VOX Pegel
'VOX level
Data "311;op,vox level;1;256,{0 to 100};lin;%"
'
'Announce57:
'Befehl 312 &H0138: --> Code 1416
'VOX Pegel
'VOX level
Data "312;ap,as311"
'
'Announce58:
'Befehl 313 &H0139: --> Code 1417
'AnitVOX Pegel
'AntiVOX level
Data "313;op,antivox level;1;256,{0 to 100};lin;%"
'
'Announce59:
'Befehl 314 &H013A:  --> Code 1417
'AnitVOX Pegel
'AntiVOX level
Data "314;ap,as313"
'
'Announce60:
'Befehl 315 &H013B: --> Code 1419
'Helligkeit
'brightness
Data "315;op,brightness;1;256,{0 to 100};lin;%"
'
'Announce61:
'Befehl 316 &H013C: --> Code 1419
'Helligkeit
'brightness
Data "316;ap,as315"
'
'Announce62:
'Befehl 317 &H013D: --> Code 1501
'noise or S-meter squelch status
'noise or S-meter squelch status
Data "317;as,noise or S-meter squelch status;1;0,off;1,on "
'
'Announce63:
'Befehl 318 &H013E: --> Code 1502
'S meter Pegel
's meter level
Data "318;as,s meter level;1;256,{121{0 to 9},135{0 to 62}}"
'
'Announce64:
'Befehl 319 &H013F 2 Byte / 3 Byte -->  Code 1505
'various squelch functions status
'various squelch functions status
Data "319;as;various squelch functions status;1;0,off;1,on "
'
'Announce65:
'Befehl 320 &H0140: -->  Code 1511
'Leistung
'PO meter
Data "320;ap,PO meter;1;256,{143,{0 TO 50},113,{51 to 150};lin;%"
'
'Announce66:
'Befehl 321 &H0141: -->  Code 1512
'SWR meter
'SWR meter
Data "321;ap;SWR meter;1;256,49,{1.00 to 1.50},32,{1,51 to 2.00},40,{2,01 to 3,00},135,{3,01 to 6.00};lin;-"
'
'Announce67:
'Befehl 322 &H0142: --> Code 1513
'ALC meter
'ALC meter
Data "322;ap;ALC meter;1;121,{0 to 100};lin;%"
'
'Announce68:
'Befehl 323 &H0143: -->  Code 1514
'Comp meter
'comp meter
Data "323;ap;comp meter;1;256,130,{0 to 15.0},126,{15,1 to 30.0};lin;dB"
'
'Announce69:
'Befehl 324 &H0144: --> Code 1515
'Vsupply meter
'vsupply meter
Data "324;ap;v supply;1;256,14,{0 to 10},246,{10 to 17};lin;V"
'
'Announce70:
'Befehl 325 &H0145: --> Code 1516
'Isupply meter
'isupply meter
Data "325;ap;i supply;1;256,98,{0 to 10.0},158,{10.1 to 26.0};lin;A"
'
'Announce71:
'Befehl 326 &H0146: --> Code 1602
'Preamp
'Preamp
Data "326;os,preamp;1;0,off;1,preamp1;2,preamp2"
'
'Announce72:
'Befehl 327 &H0147: --> Code 1602
'Preamp
'Preamp
Data "327;as,as326"
'
'Announce73:
'Befehl 328 &H0148: --> Code 1612
'AGC
'AGC
Data "328;os,AGC;1;0,off;1,fast;2,med;3,slow"
'
'Announce74:
'Befehl 329 &H0149: --> Code 1612
'AGC
'AGC
Data "329;as,as328"
'
'Announce75:
'Befehl 330 &H014A: --> Code 1622
'Noise blanker
'Noise blanker
Data "330;os,Noise blanker;1;0,off;1,on"
'
'Announce76:
'Befehl 331 &H014B: --> Code 1622
'Noise blanker
'Noise blanker
Data "331;as,as330"
'
'Announce77:
'Befehl 332 &H014C: --> Code 1640
'Noise reduction
'Noise reduction
Data "332;os,Noise reduction;1;0,off;1,on"
'
'Announce78:
'Befehl 333 &H014D: --> Code 1640
'Noise reduction
'Noise reduction
Data "333;as,as332"
'
'Announce79:
'Befehl 334 &H014E: --> Code 1641
'Auto notch
'Auto notch
Data "334;os,Auto notch;1;0,off;1,on"
'
'Announce80:
'Befehl 335 &H014F: --> Code 1641
'Auto notch
'Auto notch
Data "335;as,as334"
'
'Announce81:
'Befehl 336 &H0150: --> Code 1642
'Repeater tone
'Repeater tone
Data "336;os,Repeater tone;1;0,off;1,on"
'
'Announce82:
'Befehl 337 &H0151: -->  Code 1642
'Repeater tone
'Repeater tone
Data "337;as,as336"

'Announce83:
'Befehl 338 &H0152: --> Code 1643
'Tone squelch
'Tone squelch
Data "338;os,Tone squelch;1;0,off;1,on"
'
'Announce84:
'Befehl 339 &H0153: -->  Code 1643
'Tone squelch
'Tone squelch
Data "339;as,as338"
'
'Announce85:
'Befehl 340 &H0154: --> Code 1644
'Speech compressor
'Speech compressor
Data "340;os,speech compressor;1;0,off;1,on"
'
'Announce86:
'Befehl 341 &H0155: --> Code 1644
'Speech compressor
'Speech compressor
Data "341;as,as340"
'
'Announce87:
'Befehl 342 &H0156: --> Code 1645
'Monitor
'Monitor
Data "342;os,Monitor;1;0,off;1,on"
'
'Announce88:
'Befehl 343 &H0157: --> Code 1645
'Monitor
'Monitor
Data "343;as,as342"
'
'Announce89:
'Befehl 344 &H0158: --> Code 1646
'VOX
'VOX
Data "344;os,VOX;1;0,off;1,on"

'Announce90:
'Befehl 345 &H0159: --> Code 1646
'VOX
'VOX
Data "345;as,as344"
'
'Announce91:
'Befehl 346 &H015A: --> Code 1647
'BK
'BK
Data "346;os,BK;1;0,off;1,semi;2,full"
'
'Announce92:
'Befehl 347 &H015B: --> Code 1647
'BK
'BK
Data "347;as,as346"
'
'Announce93:
'Befehl 348 &H015C: --> Code 1648
'Manual notch
'Manual notch
Data "348;os,manual notch;1;0,off;1,on"
'
'Announce94:
'Befehl 349 &H015D: --> Code 1648
'Manual notch
'Manual notch
Data "349;as,as348"
'
'Announce95:
'Befehl 350 &H015E: --> Code 164F
'Twin Peak Filter
'Twin Peak Filter
Data "350;os,Twin Peak Filter;1;0,off;1,on"
'
'Announce96:
'Befehl 351 &H015F: --> Code 164F
'Twin Peak Filter
'Twin Peak Filter
Data "351;as,as350"
'
'Announce97:
'Befehl 352 &H0160: --> Code 1650
'Dial lock
'Dial lock
Data "352;os,Dial lock;1;0,off;1,on"
'
'Announce98:
'Befehl 353 &H0161:  --> Code 1650
'Dial lock
'Dial lock
Data "353;as,as352"
'
'Announce99:
'Befehl 354 &H0162: --> Code 1656
'DSP filter type
'DSP filter type
Data "354;os,DSP filter type;1;0,sharp;1,soft"
'
'Announce100:
'Befehl 355 &H0163: --> Code 1656
'DSP filter type
'DSP filter type
Data "355;as,as354"
'
'Announce101:
'Befehl 356 &H0164: --> Code 1657
'Manual notch width
'Manual notch width
Data "356;os,Manual notch width;1;0,wide;1,mid;2,narrow"
'
'Announce102:
'Befehl 357 &H0165: --> Code 1657
'Manual notch width
'Manual notch width
Data "357;as,as356"
'
'Announce103:
'Befehl 358 &H0166: --> Code 1658
'SSB transmit bandwidth
'SSB transmit bandwidth
Data "358;os,SSB transmit bandwidth;1;0,wide;1,mid;2,narrow"
'
'Announce104:
'Befehl 359 &H0167: --> Code 1658
'SSB transmit bandwidth
'SSB transmit bandwidth
Data "359;as,as358"
'
'Announce105:
'Befehl 360 &H168: --> Code 17
'Cw message
'Cw message
Data "360;om,Cw message ;30,{0 to 9,a to z, A to Z,/,?,.,;,(,),-,=,+, ,0x27,0x2C,0x22,@}"
'
'Announce106:
'Befehl 361 &H0169: --> Code 18
'Aus / Einschalten
'switch off / on
Data "361;os,main switch;1;0,off;1,on"
'
'Announce107:
'Befehl 362 &H016A: --> Code 19
'ID
'Id
Data "362;aa,id;b"
'
'Announce108:
'Befehl 363 &H016B: --> Code 1A02
'8 Kanal memory keyer
'8 chanal memory keyer
Data "363;om,memory keyer;8;70,{0 to 9, A to Z, ,/,?,.,0x2c,0x5e,*,@}"
'
'Announce109:
'Befehl 364 &H016C: -> Code 1A02
'8 Kanal memory keyer
'8 chanal memory keyer
Data "364,am,as363"
'
'Announce110:
'Befehl 365 &H016D: --> Code 1A03
'selected AM Filter Bandbreite
'selected AM filter width
Data "365;op,AM filter width;1;51,{200 to 10000};lin;Hz"
'
'Announce111:
'Befehl 366 &H016E: --> Code 1A03
'selected AM Filter Bandbreite
'selected AM 'filter width
Data "366,ap,as365"
'
'Announce112:
'Befehl 367 &H016F --> Code 1A03
'selected non AM Filter Bandbreite
'selected non AM filter width
Data "367;op,non AM filter width;1;41,{50 to 3600};lin;Hz"
'
'Announce113:
'Befehl 368 &H0170: --> Code 1A03
'selected non AM Filter Bandbreite
'selected non AM 'filter width
Data "368,ap,as367"

'Announce114:
'Befehl 369 &H0171: --> Code 1A04
'selected AM AGC Zeitkonstante
'selected AM AGC time constant
Data "369;op,AM time comstant;1;14,1,{off},13,{0 to 8.0};lin;Hz"
'
'Announce115:
'Befehl 370 &H0172: --> Code 1A04
'selected AM AGC Zeitkonstante
'selected AM AGC time constant
Data "370,ap,as369"
'
'Announce116:
'Befehl 371 &H0173: --> Code 1A04
'selected non AM AGC Zeitkonstante
'selected non AM AGC time constant
Data "371;op,non AM AGC time comstant;1;14;1,{off},13,{0 to 6.0};lin;s"
'
'Announce117:
'Befehl 372 &H0174: --> Code 1A04
'selected non AM AGC Zeitkonstante
'selected non AM AGC time constant
Data "372,ap,as371"
'
'Announce118:
'Befehl 373 &H0175: --> Code 1A050001
'HPF / LPF SSB
'HPF / LPF SSB
Data "373;op,SSB HPF / LPF;1;20,{through,100 to 2000};lin;Hz;20,{500 to 2400},though;lin;Hz"
'
'Announce119:
'Befehl 374 &H0176: --> Code 1A0500001
'HPF / LPF SSB
'HPF / LPF SSB
Data "374;ap;as373"
'
'Announce120:
'Befehl 375 &H0177: --> Code 1A050002
'SSB Bass Level
'SSB Bass Level
Data "375;op,SSB Bass Level;1;11,{-5 to 5};lin;-"
'
'Announce121:
'Befehl 376 &H0178: --> Code 1A050002
'SSB Bass Level
'SSB Bass Level
Data "376;ap,as375"
'
'Announce122:
'Befehl 377 &H0179: --> Code 01A05003
'SSB Hoehen Level
'SSB Treble Level
Data "377;op,SSB Treble Level;1;11,{-5 to 5};lin;-"
'
'Announce123:
'Befehl 378 &H017A: --> Code 1A050003
'SSB Hoehen Level
'SSB Treble Level
Data "378;ap,as377"
'
'Announce124:
'Befehl 379 &H017B: --> Code 01A050004
'HPF / LPF AM
'HPF / LPF AM
Data "379;op,HPF / LPF AM;1;20,{through,100 to 2000};lin;Hz;20,{500 to 2400,though};lin;Hz"
'
'Announce125:
'Befehl 380 &H017C: --> Code 1A050004
'HPF / LPF AM
'HPF / LPF AM
Data "380;ap;as379"
'
'Announce126:
'Befehl 381 &H017D: --> Code 01A050005
'AM Bass Level
'AM Bass Level
Data "381;op,AM Bass Level;1;10,{-5 to 5};lin;-"
'
'Announce127:
'Befehl 382 &H017E: --> Code 1A050005
'AM Bass Level
'AM Bass Level
Data "382;ap,as381"
'
'Announce128:
'Befehl 383 &H017F: --> Code 1A050006
'AM Hoehen Level
'AM Treble Level
Data "383;op,AM Treble Level;1;10,{-5 to 5};lin;-"
'
'Announce129:
'Befehl 384 &H0180: --> Code 1A050006
'AM Hoehen Level
'AM Treble Level
Data "384;ap,as383"
'
'Announce130:
'Befehl 385 &H0181: --> Code 1A050007
'HPF / LPF FM
'HPF / LPF FM
Data "385;op,HPF / LPF FM;1;20,{through,100 to 2000};lin;Hz;20,{500 to 2400,though};lin;Hz"
'
'Announce131:
'Befehl 386 &H0182: --> Code 1A050007
'HPF / LPF FM
'HPF / LPF FM
Data "386;ap;as385"
'
'Announce132:
'Befehl 387 &H0183: --> Code 1A050008
'FM Bass Level
'FM Bass Level
Data "387;op,FM Bass Level;1;10,{-5 to 5};lin;-"
'
'Announce133:
'Befehl 388 &H0184: --> Code 1A050008
'FM Bass Level
'FM Bass Level
Data "388;ap,as387"
'
'Announce134:
'Befehl 389 &H0185: --> Code 1A050009
'FM Hoehen Level
'FM Treble Level
Data "389;op,FM Treble Level;1;10,{-5 to 5};lin;-"
'
'Announce135:
'Befehl 390 &H0186: --> Code 1A050009
'FM Hoehen Level
'FM Treble Level
Data "390;ap,as389"
'
'Announce136:
'Befehl 391 &H0187: --> Code 1A050010
'HPF / LPF CW
'HPF / LPF CW
Data "391;op,HPF / LPF CW;1;20,{through,100 to 2000};lin;Hz;20,{500 to 2400,though};lin; Hz"
'
'Announce137:
'Befehl 392 &H0188: --> Code 1A050010
'HPF / LPF CW
'HPF / LPF CW
Data "392;ap;as391"
'
'Announce138:
'Befehl 393 &H0189: --> Code 1A050011
'HPF / LPF RTTY
'HPF / LPF RTTY
Data "393;op,HPF / LPF RTTY;1;20,{through,100 to 2000};lin;Hz;20,{500 to 2400,though};lin; Hz"
'
'Announce139:
'Befehl 394 &H018A: --> Code 1A050011
'HPF / LPF RTTY
'HPF / LPF RTTY
Data "394;ap;as393"
'
'Announce140:
'Befehl 395 &H018B: --> Code 1A050012
'SSB TX Bass Level
'SSB TX Bass Level
Data "395;op,SSB Tx Bass Level;1;10,{-5 to 5};lin;-"
'
'Announce141:
'Befehl 396 &H018C: --> Code 1A050012
'SSB Tx Bass Level
'SSB Tx Bass Level
Data "396;ap,as395"
'
'Announce142:
'Befehl 397 &H018D: --> Code 1A050013
'SSB Tx Hoehen Level
'SSB Tx Treble Level
Data "397;op,SSB Tx Treble Level;1;10,{-5 to 5};lin;-"
'
'Announce143:
'Befehl 398 &H018E: --> Code 1A050013
'SSB Tx Hoehen Level
'SSB Tx Treble Level
Data "398;ap,as397"
'
'Announce144:
'Befehl 399 &H018F: --> Code 1A050014
'SSB Tx wide  Bandbreite
'SSB Tx wide bandwidth
Data "399;os,SSB Tx wide bandwidth;2;0,0k1;1,0k2;2,0k3;3,0k5;0,2k5;1,2k7;2,2k8;3,2k9"
'
'Announce145:
'Befehl 400 &H0190: --> Code 1A050014
'SSB Tx wide  Bandbreite
'SSB Tx wide bandwidth
Data "400;as,as399"
'
'Announce146:
'Befehl 401 &H0191: --> Code 1A050015
'SSB Tx mid  Bandbreite
'SSB Tx mid bandwidth
Data "401;os,SSB Tx mid bandwidth;2;0,0k1;1,0k2;2,0k3;3,0k5;0,2k5;1,2k7;2,2k8;3,2k9"
'
'Announce147:
'Befehl 402 &H0192: --> Code 1A050015
'SSB Tx mid  Bandbreite
'SSB Tx wide bandwidth
Data "402;as,as401"
'
'Announce148:
'Befehl 403 &H0193: --> Code 1A050016
'SSB Tx narrow  Bandbreite
'SSB Tx narrow bandwidth
Data "403;os,SSB Tx narrow bandwidth;2;0,0k1;1,0k2;2,0k3;3,0k5;0,2k5;1,2k7;2,2k8;3,2k9"
'
'Announce149:
'Befehl 404 &H0194: --> Code 1A050016
'SSB Tx narrow  Bandbreite
'SSB Tx narrow bandwidth
Data "404;as,as403"
'
'Announce150:
'Befehl 405 &H0195: --> Code 1A050017
'AM TX Bass Level
'AM TX Bass Level
Data "405;op,AM TX Bass Level;1;10,{-5 to 5};lin;-"
'
'Announce151:
'Befehl 406 &H0196: --> Code 1A050017
'AM TX Bass Level
'AM TX Bass Level
Data "406;ap,as405"
'
'Announce152:
'Befehl 407 &H0197: --> Code 1A050018
'AM Tx Hoehen Level
'AM Tx Treble Level
Data "407;op,AM TX Treble Level;1;10,{-5 to 5};lin;-"
'
'Announce153:
'Befehl 408 &H0198: --> Code 1A050018
'AM Tx Hoehen Level
'AM Tx Treble Level
Data "408;ap,as407"
'
'Announce154:
'Befehl 409 &H0199: --> Code 1A050019
'FM Tx Bass Level
'FM Tx Bass Level
Data "409;op,FM Tx Bass Level;1;10,{-5 to 5};lin;-"
'
'Announce155:
'Befehl 410 &H019A: --> Code 1A050019
'FM Tx Bass Level
'FM Tx Bass Level
Data "410;ap,as409"
'
'Announce156:
'Befehl 411 &H019B: --> Code 1A050020
'FM Tx Hoehen Level
'FM Tx Treble Level
Data "411;op,FM Tx Treble Level;1;10,{-5 to 5};lin;-"
'
'Announce157:
'Befehl 412 &H019C: --> Code 1A050020
'FM Tx Hoehen Level
'FM Tx Treble Level
Data "412;ap,as411"

'Announce158:
'Befehl 413 &H019D: --> Code 1A050021
'Beep Pegel
'Beep gain
Data "413;op,beep gain;1;255;lin;-"
'
'Announce159:
'Befehl 414 &H019E: --> Code 1A050021
'Beep Pegel
'Beep gain
Data "414;ap,as413"
'
'Announce160:
'Befehl 415 &H019F: --> Code 1A050022
'Beep Pegel Grenze
'Beep gain limit
Data "415;os,beep gain limit;1;0,off;1;,on"
'
'Announce161:
'Befehl 416 &H01A0: --> Code 1A050022
'Beep Pegel Grenze
'Beep gain limit
Data "416;as,as415"
'
'Announce162:
'Befehl 417 &H01A1: --> Code 1A050023
'Bestaetigungston
'confirmation beep
Data "417;os,confirmation beep;1;0,off;1,on"
'
'Announce163:
'Befehl 418 &H01A2: --> Code 1A050023
'Bestaetigungston
'confirmation beep
Data "418;as,as417"
'
'Announce164:
'Befehl 419 &H01A3: --> Code 1A050024
'Bandgrenze: Beep mode
'bandedge beep mode
Data "419;os,bandedge beep mode;1;0,off;1,amateur bands;2,user defined;3,user Tx defined"
'
'Announce165:
'Befehl 420 &H01A4: --> Code 1A050024
'Bandgrenze: Beep mode
'bandedge beep mode
Data "420;as,as419"
'
'Announce166:
'Befehl 421 &H01A5: --> Code 1A050025
'Rf / SQL
'RF / SQL
Data "421;os,RF/SQL;1;0,auto;1,SQL;2,SQL+RF"
'
'Announce167:
'Befehl 422 &H01A6: --> Code 1A050025
'Rf / SQL
'RF / SQL
Data "422;as,as421"
'
'Announce168:
'Befehl 423 &H01A7: --> Code 1A050026
'Hf Tx Verzoegerung
'HF Tx delay
Data "423;os,Hf Tx delay;1;0,off;1,10ms;2,15ms;3,20ms;4,25ms;5,30ms"
'
'Announce169:
'Befehl 424 &H01A8: --> Code 1A050026
'HF Tx Verzoegerung
'HF Tx delay
Data "424;as,as423"
'
'Announce170:
'Befehl 425 &H01A9: --> Code 1A050027
'50MHz Tx Verzoegerung
'50MHz Tx delay
Data "425;os,50MHz Tx delay;1;0,off;1,10ms;2,15ms;3,20ms;4,25ms;5,30ms"
'
'Announce171:
'Befehl 426 &H01AA: --> Code 1A050027
'50MHz Tx Verzoegerung
'50MHz Tx delay
Data "426;as,as425"
'
'Announce172:
'Befehl 427 &H01AB: --> Code 1A050028
'70MHz Tx Verzoegerung
'70MHz Tx delay
Data "427;os,70MHz Tx delay;1;0,off;1,10ms;2,15ms;3,20ms;4,25ms;5,30ms"
'
'Announce173:
'Befehl 428 &H01AC: --> Code 1A050028
'70MHz Tx Verzoegerung
'70MHz Tx delay
Data "428;as,as427"
'
'Announce174:
'Befehl 429 &H01AD: --> Code 1A050029
'Timeout
'Timeout
Data "429;os,Timeout;1;0,off;1,3min;2,5min;3,10mi;4,20min;5,30min"
'
'Announce175:
'Befehl 430 &H01AE: --> Code 1A050029
'Timeout
'Timeout
Data "430;as,as429"
'
'Announce176:
'Befehl 431 &H01AF: --> Code 1A050030
'Quick split
'Quick split
Data "431;os,Quick split;1;0,off;1,on"
'
'Announce177:
'Befehl 432 &H01B0: --> Code 1A050030
'Quick split     :
'Quick split
Data "432;as,as431"
'
'Announce178:
'Befehl 433 &H01B1: --> Code 1A050031
'FM split offset HF
'FM split offset HF
Data "433;op,FM split offset HF;1;19999,{-9.999 to 9.999};lin;MHz"
'
'Announce179:
'Befehl 434 &H01B2: --> Code 1A050031
'FM split offset HF
'FM split offset HF
Data "434;ap,as433"
'
'Announce180:
'Befehl 435 &H01B3: --> Code 1A050032
'FM split offset 50MHz
'FM split offset 50MHz
Data "435;op,FM split offset 50MHz;1;19999,{-9.999 to 9.999};lin;MHz"
'
'Announce181:
'Befehl 436 &H01B4: --> Code 1A050032
'FM split offset 50MHz
'FM split offset 50MHz
Data "436;ap,as435"
'
'Announce182:
'Befehl 437 &H01B5: --> Code 1A050033
'split lock
'split lock
Data "437;os,split lock;1;0,off;1,on"
'
'Announce183:
'Befehl 438 &H01B6: --> Code 1A050033
'split lock
'split lock
Data "438;as,as437"
'
'Announce184:
'Befehl 439 &H01B7: --> Code 1A050034
'Tuner Schalter
'Tuner switch
Data "439;os,Tuner;1;0,manual;1,auto"
'
'Announce185:
'Befehl 440 &H01B8: --> Code 1A050034
'Tuner Schalter
'Tuner switch
Data "440;as,as439"
'
'Announce186:
'Befehl 441 &H01B9: --> Code 1A050035
'PTT Tune
'PTT Tune
Data "441;os,PTT Tune;1;0,off;1,on"
'
'Announce187:
'Befehl 442 &H01BA: --> Code 1A050035
'PTT Tune
'PTT Tune
Data "442;as,as441"
'
'Announce188:
'Befehl 443 &H01BB: --> Code 1A050036
'RTTY mark freqency
'RTTY mark freqency
Data "443;os,RTTY mark freqency;1;0,1275Hz;1,1615Hz;2,2125Hz"
'
'Announce189:
'Befehl 444 &H01BC: --> Code 1A050036
'RTTY mark freqency
'RTTY mark freqency
Data "444;as,as443"
'
'Announce190:
'Befehl 445 &H01BD: --> Code 1A050037
'RTTY shift width
'RTTY shift width
Data "445;os,RTTY shift width;1;0,170Hz;1,200Hz;2,425Hz"
'
'Announce191:
'Befehl 446 &H01BE: --> Code 1A050037
'RTTY shift width
'RTTY shift width
Data "446;as,as445"
'
'Announce192:
'Befehl 447 &H01BF: --> Code 1A050038
'RTTY polaritaet
'RTTY polarity
Data "447;os,RTTY polarity;1;0,normal;1,reverse"
'
'Announce193:
'Befehl 448 &H01C0: --> Code 1A050038
'RTTY polaritaet
'RTTY polarity
Data "448;as,as447"
'
'Announce194:
'Befehl 449 &H01C1: --> Code 1A050039
'Sprache
'language
Data "449;os,language;1;0,english;1,japanese"
'
'Announce195:
'Befehl 450 &H01C2: --> Code 1A050039
'Sprache
'language
Data "450;as,as449"
'
'Announce196:
'Befehl 451 &H01C3: --> Code 1A050040
'Sprachgeschwindigkeit
'language speed
Data "451;os,language speed;1;0,low;1,high"
'
'Announce197:
'Befehl 452 &H01C4: --> Code 1A050040
'Sprachgeschwindigkeit
'language speed
Data "452;as,as451"
'
'Announce198:
'Befehl 453 &H01C5: --> Code 1A050041
'S meter Sprachausgabe
'S meter speech
Data "453;os,s meter speech;1;0,off;1,on"
'
'Announce199:
'Befehl 454 &H01C6: --> Code 1A050041
'S meter Sprachausgabe
'S meter speech
Data "454;as,as453"
'
'Announce200:
'Befehl 455 &H01C7: --> Code 1A050042
'mode Sprachausgabe
'mode speech
Data "455;os,mode speech;1;0,off;1,on"
'
'Announce201:
'Befehl 456 &H01C8: --> Code 1A050042
'mode Sprachausgabe
'mode speech
Data "456;as,as455"
'
'Announce202:
'Befehl 457 &H01C9: --> Code 1A050043
'Sprach Pegel
'speech level
Data "457;op,speech level;1;256;lin;-"
'
'Announce203:
'Befehl 458 &H01CA: --> Code 1A050043
'Sprach Pegel
'speech level
Data "458;ap,as457"
'
'Announce204:
'Befehl 459 &H01CB: --> Code 1A050044
'Speech / lock Taste
'speech / lock key
Data "459;os,speech / lock key;1;0,push:speech lock;1,lock speech"
'
'Announce205:
'Befehl 460 &H01CC: --> Code 1A050044
'Speech / lock Taste
'speech / lock key
Data "460;as,as459"
'
'Announce206:
'Befehl 461 &H01CD: --> Code 1A050045
'lock Funktion
'lock function
Data "461;os,lock function;1;0,main dial;1,panel"
'
'Announce207:
'Befehl 462 &H01CE: ->> Code 1A050045
'lock Funktion
'lock function
Data "462;as,as461"
'
'Announce208:
'Befehl 463 &H01CF: --> Code 1A050046
'Zahl der memory pads
'number of memory pads
Data "463;os,number of memory pads;1;0,5ch;1,10ch"
'
'Announce209:
'Befehl 464 &H01D0: --> Code 1A050046
'Zahl der memory pads
'number of memory pads
Data "464;as,as463"
'
'Announce210:
'Befehl 465 &H01D1: --> Code 1A050047
'Main Dial auto TS
'Main Dial auto TS
Data "465;os,Main Dial auto TS;1;0,off;1,low;2,high"
'
'Announce211:
'Befehl 466 &H01D2: --> Code 1A050047
'Main Dial auto TS
'Main Dial auto TS
Data "466;as,as465"
'
'Announce212:
'Befehl 467 &H01D3: --> Code 1A050048
'mic up/down Geschwindigkeit
'mic up/down speed
Data "467;os,mic up/down speed;1;0,slow;1,fast"
'
'Announce213:
'Befehl 468 &H01D4: --> Code 1A050048
'mic up/down Geschwindigkeit
'mic up/down speed
Data "468;as,as467"
'
'Announce214:
'Befehl 469 &H01D5: --> Code 1A050049
'quick RIT/dTX clear function
'quick RIT/dTX clear function
Data "469;os,quick RIT/dTX clear function;1;0,low;1,high"
'
'Announce215:
'Befehl 470 &H01D6: --> Code 1A050049
'quick RIT/dTX clear function
'quick RIT/dTX clear function
Data "470;as,as469"
'
'Announce216:
'Befehl 471 &H01D7: --> Code 1A050050
'SSB notch
'SSB notch
Data "471;os,SSB notch;1;0,auto;1,manual;2,auto/manual"
'
'Announce217:
'Befehl 472 &H01D8: --> Code 1A050050
'SSB notch
'SSB notch
Data "472;as,as471"
'
'Announce218:
'Befehl 473 &H01D9: --> Code 1A050051
'AM notch
'AM notch
Data "473;os,AM notch;1;0,auto;1,manual;2,auto/manual"
'
'Announce219:
'Befehl 474 &H01DA: --> Code 1A050051
'AM notch
'AM notch
Data "474;as,as473"
'
'Announce220:
'Befehl 475 &H01DB: --> Code 1A050052
'SSB/CW synchronous tuning
'SSB/CW synchronous tuning
Data "475;os,SSB/CW synchronous tuning;1;0,off;1,on"
'
'Announce221:
'Befehl 476 &H01DC: --> Code 1A050052
'SSB/CW synchronous tuning
'SSB/CW synchronous tuning
Data "476;as,as475"
'
'Announce222:
'Befehl 477 &H01DD: --> Code 1A050053
'CW normal side
'CW normal side
Data "477;os,CW normal side;1;0,LSB;1,USB"
'
'Announce223:
'Befehl 478 &H01DE: --> Code 1A050053
'CW normal side
'CW normal side
Data "478;as,as477"
'
'Announce224:
'Befehl 479 &H01DF: --> Code 1A050054
'power Schalter Schnappschuss
'screen capture by the POWER switch
Data "479;os,screen capture by the POWER switch;1;0,0ff;1,on"
'
'Announce225:
'Befehl 480 &H01E0: --> Code 1A050054
''power Schalter Schnappschuss
'screen capture by the POWER switch
Data "480;as,as479"
'
'Announce226:
'Befehl 481 &H01E1: --> Code 1A050055
'Bild Format
'Image format
Data "481;os,image format;1;0,PNG;1,BPM"
'
'Announce227:
'Befehl 482 &H01E2: --> Code 1A050055
'Bild Format
'Image format
Data "482;as,as481"
'
'Announce228:
'Befehl 483 &H01D3: --> Code 1A050056
'Keyboard Typ
'Keyboard type
Data "483;os,Keyboard type;1;0,10 key;1,full"
'
'Announce229:
'Befehl 484 &H01E4: --> Code 1A050056
'Keyboard Typ
'Keyboard type
Data "484;as,as483"
'
'Announce230:
'Befehl 485 &H01E5: --> Code 1A050057
'calibration marker
'calibration marker
Data "485;os,calibration marker;1;0,off;1,on"
'
'Announce231:
'Befehl 486 &H01E6: --> Code 1A050057
'calibration marker
'calibration marker
Data "486;as,as485"
'
'Announce232:
'Befehl 487 &H01E7: --> Code 1A050058
'Referenz Frequenz
'reference frequency
Data "487;op,reference frequency;1;256;lin;-"
'
'Announce233:
'Befehl 488 &H01E8: --> Code 1A050058:
'Referenz Frequenz
'reference frequency
Data "488;ap,as487"
'
'Announce234:
'Befehl 489 &H01E9: --> Code 1A050059
'AF signal output to ACC/USB
'AF signal output to ACC/USB
Data "489;os,AF output to ACC/USB;1;0,AF;1,IF"
'
'Announce235:
'Befehl 490 &H01EA: --> Code 1A050059
'AF/IF signal output to ACC/USB
'AF/IF signal output to ACC/USB
Data "490;as,as489"
'
'Announce236:
'Befehl 491 &H01EB: --> Code 1A050060
'AF signal output Pegel to ACC/USB
'AF signal output levelto ACC/USB
Data "491;op,AF signal output level to ACC/USB;1;256;lin;-"
'
'Announce237:
'Befehl 492 &H01EC: --> Code 1A050060
'AF signal output Pegel to ACC/USB
'AF signal output levelto ACC/USB
Data "492;ap,as491"
'
'Announce238:
'Befehl 493 &H01ED: --> Code 1A050061
'squelch function for the AF signal output to ACC/USB
'squelch function for the AF signal output to ACC/USB
Data "493;os,ACC/USB AF squelch;1;0,off;1,on"
'
'Announce239:
'Befehl 494 &H01EE: --> Code 1A050061
'squelch function for the AF signal output to ACC/USB
'squelch function for the AF signal output to ACC/USB
Data "494;as,as493"
'
'Announce240:
'Befehl 495 &H01EF: --> Code 1A000062
'beep and speech output setting to ACC/USB
'beep and speech output setting to ACC/USB
Data "495;os,beep and speech output setting to ACC/USB;1;0,off;1,on"
'
'Announce241:
'Befehl 496 &H01F0: --> Code 1A050062
'beep and speech output setting to ACC/USB
'beep and speech output setting to ACC/USB
Data "496;as,as495"
'
'Announce242:
'Befehl 497 &H01F1: --> Code 1A050063
'IF signal output level to ACC/USB
'IF signal output level to ACC/USB
Data "497;op,IF signal output level to ACC/USB;1:256;lin;-"
'
'Announce243:
'Befehl 498 &H01F2. --> Code 1A050063
'IF signal output level to ACC/USB
'IF signal output level to ACC/USB
Data "498;ap,as497"
'
'Announce244:
'Befehl 499 &H01F3: --> Code 1A050064
'Mod input level from ACC
'Mod input level from ACC
Data "499;op,ACC mod input level;1:256;lin;-"
'
'Announce245:
'Befehl 500 &H01F4: --> Code 1A050064
'Mod input level from ACC
'Mod input level from ACC
Data "500;ap,as499"
'
'Announce246:
'Befehl 501 &H01F5: --> Code 1A050065
'Mod input level from USB
'Mod input level from USB
Data "501;op,Mod input level from USB;1:256;lin;-"
'
'Announce247:
'Befehl 502 &H01F6: --> Code 1A050065
'Mod input level from USB
'Mod input level from USB
Data "502;ap,as501"
'
'Announce248:
'Befehl 503 &H01F7: --> Code 1A050066
'MOD input connector during  DATA OFF
'MOD input connector during  DATA OFF
Data "503;os,MOD input for DATA OFF;1;0,Mic;1,ACC;2,Mic/ACC;3,USB"
'
'Announce249:
'Befehl 504 &H01F8: --> Code 1A050066
'MOD input connector during  DATA OFF
'MOD input connector during  DATA OFF
Data "504;as,as503"
'
'Announce250:
'Befehl 505 &H01F9: --> Code 1A050067
'MOD input connector during  DATA
'MOD input connector during  DATA
Data "505;os,MOD input connector for DATA;1;0,Mic;1,ACC;2,Mic/ACC;3,USB"
'
'Announce251:
'Befehl 506 &H01FA: --> Code 1A050067
'MOD input connector during  DATA
'MOD input connector during  DATA
Data "506;as,as505"
'
'Announce252:
'Befehl 507 &H01FB: --> Code 1A050068
'external keypad setting for VOICE
'external keypad setting for VOICE
Data "507;os,external keypad for VOICE;1;0,off;1,on"
'
'Announce253:
'Befehl 508 &H01FC: --> Code 1A050068
'external keypad setting for VOICE
'external keypad setting for VOICE
Data "508;as,as507"
'
'Announce254:
'Befehl 509 &H01FD: --> Code 1A050069
'external keypad setting for keyer
'external keypad setting for keyer
Data "509;os,external keypad for keyer;1;0,off;1,on"
'
'Announce255:
'Befehl 510 &H01FE: --> Code 1A050069
'external keypad setting for keyer
'external keypad setting for keyer
Data "510;as,as509"
'
'Announce256:
'Befehl 511 &H01FF: --> Code 1A050070
'external keypad setting for RTTY
'external keypad setting for RTTY
Data "511;os,external keypad setting for RTTY;1;0,off;1,on"
'
'Announce257:
'Befehl 512 &H0200: --> Code 1A050070
'external keypad setting for RTTY
'external keypad setting for RTTY
Data "512;as,as511"
'
'Announce258:
'Befehl 513 &H0201: --> Code 1A050071
'CI-V transceive
'CI-V transceive
Data "513;os,CI-V transceive;1;0,off;1,on"
'
'Announce259:
'Befehl 514 &H0202: --> Code 1A050071
'CI-V transceive
'CI-V transceive
Data "514;as,as513"
'
'Announce260:
'Befehl 515 &H0203: --> Code 1A050072
'transceive CI-V Address for USB to REMOTE
'transceive CI-V Address for USB to REMOTE
Data "515;op,transceive CI-V Address for USB;1;224;lin;-"
'
'Announce261:
'Befehl 516 &H0204: --> Code 1A050072
'transceive CI-V Address for USB to REMOTE
'transceive CI-V Address for USB to REMOTE
Data "516;ap,as515"
'
'Announce262:
'Befehl 517 &H0205: --> Code 1A050073
'CI-V info bei RX / TX Aenderung
'CI-V info when RX / TX changes
Data "517;os,CI-V info for rx/tx change;1;0,off;1,on"
'
'Announce263:
'Befehl 518 &H0206: --> Code 1A050073
'CI-V info bei RX / TX Aenderung
'CI-V info when RX / TX changes
Data "518;as,as517"
'
'Announce264:
'Befehl 519
Data "519;iz"
'
'Announce265:
'Befehl 520 &H0208: --> Code 1A050074
'CI-V USB port
'CI-V USB port
Data "520;as,CI-V USB port;1;0,Link to [REMOTE];1,Unlink to [REMOTE]"
''
'Announce266:
'Befehl 521 &H0209: --> Code 1A050075
'echo setting for CI-V operation from USB
'echo setting for CI-V operation from USB
Data "521;os,echo for CI-V USB;1;0,off;1,on"
'
'Announce267:
'Befehl 522 &H020A: --> Code 1A050075
'echo setting for CI-V operation from USB
'echo setting for CI-V operation from USB
Data "522;as,as521"
'
'Announce268:
'Befehl 523 &H020B: --> Code 1A050076
'USB (serial port) Funktion
'USB (serial port) function
Data "523;os,USB (serial port) function;1;0,CIV;1,RTTY decode"
'
'Announce269:
'Befehl 524 &H020C: --> Code 1A050076
'USB (serial port) Funktion
'USB (serial port) function
Data "524;as,as523"
'
'Announce270:
'Befehl 525 &H020D: --> Code 1A050077
'Data transfer speed for RTTY decode output
'data transfer speed for RTTY decode output
Data "525;os,data transfer speed for RTTY decode output;1;0,4800;1,9600:2,19200;3,38400"
'
'Announce271:
'Befehl 526 &H020E: --> Code 1A050077
'data transfer speed for RTTY decode output
'data transfer speed for RTTY decode output
Data "526;as,as525"
'
'Announce272:
'Befehl 527 &H020F: --> Code 1A050078
'USB  transmission control
'USB  transmission control
Data "527;os,USB transmission control;1;0,off;1,DTTR:2,RTS"
'
'Announce273:
'Befehl 528 &H0210: --> Code 1A050078
'USB  transmission control
'USB  transmission control
Data "528;as,as527"
'
'Announce274:
'Befehl 529 &H0211: --> Code 1A050079
'USB CW keying line setting
'USB CW keying line setting
Data "529;os,CW keying line for USB;1;0,off;1,DTTR:2,RTS"
'
'Announce275:
'Befehl 530 &H0212: --> Code 1A050079
'USB CW keying line setting
'USB CW keying line setting
Data "530;as,as529"
'
'Announce276:
'Befehl 531 &H0213: --> Code 1A050080
'USB RTTY keying line setting
'USB RTTY keying line setting
Data "531;os,RTTY keying line for USB;1;0,off;1,DTTR:2,RTS"
'
'Announce277:
'Befehl 532 &H0214: --> Code 1A050080
'USB RTTY keying line setting
'USB RTTY keying line setting
Data "532;as,as531"
'
'Announce278:
'Befehl 533 &H0215: --> Code 1a050081
'LCD Helligkeit
'LCD unit backlight brightness
Data "533;op,LCD unit backlight brightness;1;256,{0 to 100};lin;%"
'
'Announce279:
'Befehl 534 &H0216: --> Code 1A050081
'LCD Helligkeit
'LCD unit backlight brightness
Data "534;ap,as533"
'
'Announce280:
'Befehl 535 &H0217: --> Code 1A050082
'screen image type
'screen image type
Data "535;os,screen image type;1;0,A;1,B"
'
'Announce281:
'Befehl 536 &H0218: --> Code 1A050082
'screen image type
'screen image type
Data "536;as,as535"
'
'Announce282:
'Befehl 537 &H0219: --> Code 1A050083
'frequency readout font
'frequency readout font
Data "537;os,frequency font;1;0,basic;1,round"
'
'Announce283:
'Befehl 538 &H021A: --> Code 1A050083
'frequency readout font
'frequency readout font
Data "538;as,as537"
'
'Announce284:
'Befehl 539 &H021B: --> Code 1A050084
'peak hold set for meter
'peak hold set for meter
Data "539;os,peak hold set for meter;1;0,off;1,on"
'
'Announce285:
'Befehl 540 &H021C: --> Code 1A050084
'peak hold set for meter
'peak hold set for meter
Data "540;as,as539"
'
'Announce286:
'Befehl 541 &H021D: --> Code 1A050085
'memory name indication
'memory name indication
Data "541;os,memory name indication;1;0,off;1,on"
'
'Announce287:
'Befehl 542 &H021E: --> Code 1A050085
'memory name indication
'memory name indication
Data "542;as,as541"
'
'Announce288:
'Befehl 543 &H021F: --> Code 1A050086
'manual notch width pop-up
'manual notch width pop-up
Data "543;os,manual notch width pop-up;1;0,off;1,on"
'
'Announce289:
'Befehl 544 &H0220: --> Code 1A050086
'manual notch width pop-up
'manual notch width pop-up
Data "544;as,as543"
'
'Announce290:
'Befehl 545 &H0221: --> Code 1A050087
'PBT shifting value display setting while rotating [TWIN PBT]
'PBT shifting value display setting while rotating [TWIN PBT]
Data "545;os,PBT BW popup;1;0,off;1,on"
'
'Announce291:
'Befehl 546 &H0222: --> Code 1A050087
'PBT shifting value display setting while rotating [TWIN PBT]
'PBT shifting value display setting while rotating [TWIN PBT]
Data "546;as,as545"
'
'Announce292:
'Befehl 547 &H0223: --> Code 1A050088
'IF filter width and shifting value display setting when the IF filter is switched
'IF filter width and shifting value display setting when the IF filter is switched
Data "547;os,IF filter BW popup;1;0,off;1,on"
'
'Announce293:
'Befehl 548 &H0224: --> Code 1A050088
'IF filter width and shifting value display setting when the IF filter is switched
'IF filter width and shifting value display setting when the IF filter is switched
Data "548;as,as547"
'
'Announce294:
'Befehl 549 &H0225: --> Code 1A050089
'Bildschirmschoner
'screen saver
Data "549;os,screen saver;1;0,off;1,15min;2,30min;3,60min"
'
'Announce295:
'Befehl 550 &H0226: --> Code 1A050089
'Bildschirmschoner
'screen saver
Data "550;as,as549"
'
'Announce296:
'Befehl 551 &H0227: --> Code 1A050090
'opening message indication
'opening message indication
Data "551;os,opening message;1;0,off;1,on"
'
'Announce297:
'Befehl 552 &H0228: --> Code 1A050090
'opening message indication
'opening message indication
Data "552;as,as551"
'
'Announce298:
'Befehl 553 &H0229: --> Code 1A050091
'opening message
'opening message
Data "553;oa,my call;10,{A to Z, 1 to 9,-,/,.,@, "
'
'Announce299:
'Befehl 554 &H022A: --> Code 1A050091
'opening message
'opening message
Data "554;aa,as553"
'
'Announce300:
'Befehl 555 &H022B: --> Code 1A050092
'Power on check
'Power on check
Data "555;os,Power on check;1;0,off;1,on"
'
'Announce301:
'Befehl 556 &H022C: --> Code 1A050092
'Power on check
'Power on check
Data "556;as,as555"
'
'Announce302:
'Befehl 557 &H022D: --> Code 1A050093
'Display Sprache
'display language
Data "557;os,display language;1;0,english;1,japanese"
'
'Announce303:
'Befehl 558 &H022E: --> Code 1A050093
'Display Sprache
'display language
Data "558;as,as557"
'
'Announce304:
'Befehl 559 &H022F: --> Code 1A050094
'Datum
'date
Data "559;op,date;1;100,{0 to 99};lin;year;12,{1 to 12};lin;month;31,{1 to 31};lin;day"
'
'Announce305:
'Befehl 560 &H0230: --> Code 1A050094
'Datum
'date
Data "560;ap,as559"
'
'Announce306:
'Befehl 561 &H031: --> Code 1A050095
'Zeit
'time
Data "561;op,time;1;24,{0 to 23};lin;hour;60,{0 to 59};lin;min"
'
'Announce307:
'Befehl 562 &H0232: --> Code 1A050095
'Zeit
'time
Data "562;ap,as561"
'
'Announce308:
'Befehl 563 &H0233: --> Code 1A050096
'UTC offset
'UTC offset
Data "563;op,UTC offset;1:1682,{-14:00 to +14:00};lin,h"
'
'Announce309:
'Befehl 564 &H0234: --> Code 1A050096
'UTC offset
'UTC offset
Data "564;ap,as563"
'
'Announce310:
'Befehl 565 &H0235: --> Code 1A050097
'scope indication during TX
'scope indication during TX
Data "565;os,scope indication during TX;1;0,off;1,on"
'
'Announce311:
'Befehl 566 &H0236: --> Code 1A050097
'scope indication during TX
'scope indication during TX
Data "566;as,as565"
'
'Announce312:
'Befehl 567 &H0237: --> Code 1A050098
'scope max. hold
'scope max. hold
Data "567;os,scope max. hold;1;0,off;1,10s;2,on"
'
'Announce313:
'Befehl 568 &H0238: --> Code 1A050098
'scope max. hold
'scope max. hold
Data "568;as,as567"
'
'Announce314:
'Befehl 569 &H0239: --> Code 1A050099
'scope center frequency
'scope max. hold  scope center frequency
Data "569;os,scope center frequency;1;0,filter center;1,carrier point center;2,carrier point center (Abs. Freq.)"
'
'Announce315:
'Befehl &570 H023A: --> Code 1A050099
'scope center frequency
'scope max. hold  scope center frequency
Data "570;as,as569"
'
'Announce316:
'Befehl 571 &H023B: --> Code 1A050100
'scope marker position
'scope marker position
Data "571;os,scope marker position;1;0,filter center;1,carrier point"
'
'Announce317:
'Befehl 572 &H023C: --> Code 1A050100
'scope marker position
'scope marker position
Data "572;as,as571"
'
'Announce318:
'Befehl 573 &H023D: --> Code 1A050101
'external monitor signal width
'external monitor signal width
Data "573;os,external monitor VBW;1;0,narrow;1,wide"
'
'Announce319:
'Befehl 574 &H023E: --> Code 1A050101
'external monitor signal width
'external monitor signal width
Data "574;as,as573"
'
'Announce320:
'Befehl 575 &H023F: --> Code 1A050102
'averaging function for spectrum scope
'averaging function for spectrum scope
Data "575;os,averaging for spectrum scope;1;0,off;1,2;2,3;3,4"
'
'Announce321:
'Befehl 576 &H0240: --> Code 1A050102
'averaging function for spectrum scope
'averaging function for spectrum scope
Data "576;as,as575"
'
'Announce322:
'Befehl 577 &H0241: --> Code 1A050103
'spectrum display type
'spectrum display type
Data "577;os,spectrum display type;1;0,fill;1,fill+line"
'
'Announce323:
'Befehl 578 &H0242: --> Code 1A050103
'spectrum display type
'spectrum display type
Data "578,as,as577"
'
'Announce324:
'Befehl 579 &H0243: --> Code 1A050104
'spectrum fill color
'spectrum fill color
Data "579;op,spectrum color;1;256,red;lin;-;256,yellow;lin;-;256,blue,lin,-"
'
'Announce325:
'Befehl580  &H0244: --> Code 1A050104
'spectrum fill color
'spectrum fill color
Data "580;ap,as579"
'
'Announce326:
'Befehl 581 &H0245: --> Code 1A050105
'spectrum line color
'spectrum line color
Data "581;op,spectrum line color;1;256,red;lin;-;256,yellow;lin;-;256,blue,lin,-"
'
'Announce327:
'Befehl 582 &H0246: --> Code 1A050105
'spectrum line color
'spectrum line color
Data "582;ap,as581"
'
'Announce328:
'Befehl 583 &H0247: --> Code 1A050106
'spectrum color for peak hold
'spectrum color for peak hold
Data "583;op,spectrum color for peak hold;1;256,red;lin;-;256,yellow;lin;-;256,blue,lin,-"
'
'Announce329:
'Befehl 584 &H0248: --> Code 1A050106
'spectrum color for peak hold
'spectrum color for peak hold
Data "584;ap,as583"
'
'Announce330:
'Befehl 685 &H0249: --> Code 1A050107
'waterfall set for spectrum scope
'waterfall set for spectrum scope
Data "585;os,waterfall;1;0,off;1,on"
'
'Announce331:
'Befehl 586 &H024A: -_> Code 1A050107
'waterfall set for spectrum scope
'waterfall set for spectrum scope
Data "586;as,as585"
'
'Announce332:
'Befehl 587 &H024B: --> Code 1A050108
'wasserfall Geschwindigkeit
'waterfall speed
Data "587;os,waterfall speed;1;0,slow;1,mid:2,high"
'
'Announce333:
'Befehl 588 &H024C: --> Code 1A050108
'wasserfall Geschwindigkeit
'waterfall speed
Data "588;as,as587"
'
'Announce334:
'Befehl 289 &H024D: --> Code 1A050109
'wasserfall Hoehe
'waterfall  height when expanded scope is selected
Data "589;os,waterfall height (expanded);1;0,small;1,mid:2,larger"
'
'Announce335:
'Befehl 590 &H024E: --> Code 1A050109
'wasserfall Hoehe
'waterfall  height when expanded scope is selected
Data "590;as,as589"
'
'Announce336:
'Befehl 591 &H024F: --> Code 1A050110
'peak color level set for waterfall of the spectrum scope
'peak color level set for waterfall of the spectrum scope
Data "591;os,peak color level set for waterfall;1;0,grid1;1,grid2:2,grid3;3,grid4;4,grid5;5,grid6;6,grid7;7,grid8"
'
'Announce337:
'Befehl 592 &H0250: --> Code 1A050110
'peak color level set for waterfall of the spectrum scope
'peak color level set for waterfall of the spectrum scope
Data "592;as,as5891"
'
'Announce338:
'Befehl 593 &H0251: --> Code 1A050111
'scope waterfall marker auto-hide
'scope waterfall marker auto-hide
Data "593;os,waterfall marker auto-hide;1;0,off;1,on"
'
'Announce339:
'Befehl 594 &H0252: --> Code 1A050111
'scope waterfall marker auto-hide
'scope waterfall marker auto-hide
Data "594;as,as593"
'
'Announce340:
'Befehl 595 &H0253: --> Code 1A050112
'scope edge frequencies for 0.03 to 1.60 MHz band
'scope edge frequencies for 0.03 to 1.60 MHz band
Data "595;op,scope edge frequencies for 0.03 to 1.60 MHz band;3;1566,{30 to 1595},low edge;lin;kHz;995,{5 to 1000},span;lin;kHz"
'
'Announce341:
'Befehl 596 &H0254: --> Code 1A050112
'scope edge frequencies for 0.03 to 1.60 MHz band
'scope edge frequencies for 0.03 to 1.60 MHz band
Data "596;ap,as595"
'
'Announce342:
'Befehl 597 &H0255: --> Code 1A050115
'scope edge frequencies for 1.60 to 2.00 MHz band
'scope edge frequencies for 1.60 to 2.00 MHz band
Data "597;op,scope edge frequencies for 1.60 to 2.00 MHz band;3;3996,{1600 to 1995},low edge;lin;kHz;995,{5 to 1000},span;lin;kHz"
'
'Announce343:
'Befehl 598 &H0256: --> Code 1A050115
'scope edge frequencies for 1.60 to 2.00 MHz band
'scope edge frequencies for 1.60 to 2.00 MHz band
Data "598;ap,as597"
'
'Announce344:
'Befehl 599 &H0257: --> Code 1A050118:
'scope edge frequencies for  2.00 to 6.00 MHz band
'scope edge frequencies for  2.00 to 6.00 MHz band
Data "599;op,scope edge frequencies for 2.00 to 6.00 MHz band;3;3996,{2000 to 5995},low edge;lin;kHz;995,{5 to 1000},span;lin;kHz"
'
'Announce345:
'Befehl 600 &H0258: --> Code 1A050118
'scope edge frequencies for 2.00 to 6.00 MHz band
'scope edge frequencies for 2.00 to 6.00 MHz band
Data "600;ap,as599"
'
'Announce346:
'Befehl 601 &H0259: --> Code 1A050121
'scope edge frequencies for 6.00 to 8.00 MHz band
'scope edge frequencies for 6.00 to 8.00 MHz band
Data "601;op,scope edge frequencies for 6.00 to 8.00 MHz band;3;1996,{6000 to 7995},low edge;lin;995,{5 to 1000},span;lin;kHz"
'
'Announce347:
'Befehl 602 &H025A: --> Code 1A050121
'scope edge frequencies for 6.00 to 8.00 MHz band
'scope edge frequencies for 6.00 to 8.00 MHz band
Data "602;ap,as601"
'
'Announce348:
'Befehl 603 &H025B: --> Code 1A050124
'scope edge frequencies for 8.00 to 11.00 MHz band
'scope edge frequencies for 8.00 to 11.00 MHz band
Data "603;op,scope edge frequencies for 8.00 to 11.00 MHz band;3;2996,{8000 to 10995},low edge;lin;995,{5 to 1000},span;lin;kHz"
''
'Announce349:
'Befehl 604 &H025C: --> Code 1A050124
'scope edge frequencies for 8.00 to 11.00 MHz band
'scope edge frequencies for 8.00 to 11.00 MHz band
Data "604;ap,as603"
'
'Announce350:
'Befehl 605 &H025D: --> Code 1A050127
'scope edge frequencies for 11.00 to 15.00 MHz band
'scope edge frequencies for 11.00 to 15.00 MHz band
Data "605;op,scope edge frequencies for 11.00 to 15.00 MHz band;3;3996,{11000 to 14995},low edge;lin;995,{5 to 1000},span;lin;kHz"
'
'Announce351:
'Befehl 606 &H025E: --> Code 1A050127
'scope edge frequencies for 11.00 to 15.00 MHz band
'scope edge frequencies for 11.00 to 15.00 MHz band
Data "606;ap,as605"
'
'Announce352:
'Befehl 607 &H025F: --> Code 1A050130
'scope edge frequencies for 15.00 to 20.00 MHz band
'scope edge frequencies for 15.00 to 20.00 MHz band
Data "607;op,scope edge frequencies for 15.00 to 20.00 MHz band;3;4996,{15000 to 199995},low edge;lin;kHz;995,{5 to 1000},span;lin;kHz"
'
'Announce353:
'Befehl 608 &H0260: --> Code 1A050130
'scope edge frequencies for 15.00 to 20.00 MHz band
'scope edge frequencies for 15.00 to 20.00 MHz band
Data "608;ap,as607"

'Announce354:
'Befehl 609 &H0261: --> Code 1A050133
'scope edge frequencies for 20.00 to 22.00 MHz band
'scope edge frequencies for 20.00 to 22.00 MHz band
Data "609;op,scope edge frequencies for 20.00 to 22.00 MHz band;3;1996,{20000 to 21995},low edge;lin;kHz;995,{5 to 1000},span;lin;kHz"
'
'Announce355:
'Befehl 610 &H0262: --> Code 1A050133
'scope edge frequencies for 20.00 to 22.00 MHz band
'scope edge frequencies for 20.00 to 22.00 MHz band
Data "610;ap,as609"
'
'Announce356:
'Befehl 611 &H0263: --> Code 1A050136
'scope edge frequencies for 22.00 to 26.00 MHz band
'scope edge frequencies for 22.00 to 26.00 MHz band
Data "611;op,scope edge frequencies for 22.00 to 26.00 MHz band;3;3996,{22000 to 25995},low edge;lin;kHz;995,{5 to 1000},span;lin;kHz"
'
'Announce357:
'Befehl 612 &H0264: --> Code 1A050136
'scope edge frequencies for 22.00 to 26.00 MHz band
'scope edge frequencies for 22.00 to 26.00 MHz band
Data "612;ap,as611"

'Announce358:
'Befehl 613 &H0265: --> Code 1A050139
'scope edge frequencies for 26.00 to 30.00 MHz band
'scope edge frequencies for 26.00 to 30.00 MHz band
Data "613;op,scope edge frequencies for 26.00 to 30.00 MHz band;3;3996,{26000 to 29995},low edge;lin;kHz;995,{5 to 1000},span;lin;kHz"
'
'Announce359:
'Befehl 614 H0266: --> Code 1A050139
'scope edge frequencies for 26.00 to 30.00 MHz band
'scope edge frequencies for 26.00 to 30.00 MHz band
Data "614;ap,as613"
'
'Announce360::
'Befehl 615 &H0267: --> Code 1A050142
'scope edge frequencies for 30.00 to 45.00 MHz band
'scope edge frequencies for 30.00 to 45.00 MHz band
Data "615;op,scope edge frequencies for 30.00 to 45.00 MHz band;3;14995,{30000 to 45995,low edge;lin;kHz;995,{5 to 1000},span;lin;kHz"
'
'Announce361:
'Befehl 616 &H0268: --> Code 1A050142
'scope edge frequencies for 30.00 to 45.00 MHz band
'scope edge frequencies for 30.00 to 45.00 MHz band
Data "616;ap,as615"
'
'Announce362:
'Befehl 617  &H0269: --> Code 1A050145
'scope edge frequencies for 45.00 to 60.00 MHz band
'scope edge frequencies for 45.00 to 60.00 MHz band
Data "617;op,scope edge frequencies for 45.00 to 60.00 MHz band;3;14996,{45000 to 59995},low edge;lin;kHz;995,{5 to 1000},span;lin;kHz"
'
'Announce363:
'Befehl 618 &H026A: --> Code 1A050145
'scope edge frequencies for 45.00 to 60.00 MHz band
'scope edge frequencies for 45.00 to 60.00 MHz band
Data "618;ap,as617"
'
'Announce364:
'Befehl 619 &H026B: --> Code 1A050148
'scope edge frequencies for 60.00 to 74.80 MHz band
'scope edge frequencies for 60.00 to 74.80 MHz band
Data "619;op,scope edge frequencies for 60.00 to 74.80 MHz band;3;14795,{60000 to 74795},low edge;lin;kHz;995,{5 to 1000},span;lin;kHz"
'
'Announce365:
'Befehl 620 &H026C: --> Code 1A050148
'scope edge frequencies for 60.00 to 74.80 MHz band
'scope edge frequencies for 60.00 to 74.80 MHz band
Data "620;ap,as619"
'
'Announce366:
'Befehl 621 &H026D: --> Code 1A050151
'audio FFT scope
'audio FFT scope
Data "621;os,audio FFT scope;1;0,line;1,fill"
'
'Announce367:
'Befehl 622 &H026E: --> Code 1A050151
'audio FFT scope
'audio FFT scope
Data "622;as,as621"
'
'Announce368:
'Befehl 623 &H026F: --> Code 1A050152
'audio FFT fill color
'audio FFT fill color
Data "623;op,audio FFT fill color;1;256,red;lin;-;256,yellow;lin;-;256,blue,lin,-"
'
'Announce369:
'Befehl 624 &H0270: --> Code 1A050152
'audio FFT fill color
'audio FFT fill color
Data "624;ap,as623"
'
'Announce370:
'Befehl 625 &H0271: --> Code 1A050153
'Audio FFT scope waterfall
'Audio FFT scope waterfall
Data "625;os,Audio FFT scope waterfall;1;0,off;1,on"
'
'Announce371:
'Befehl &626 H0272: --> Code 1A050153
'Audio FFT scope waterfall
'Audio FFT scope waterfall
Data "626;as,as625"
'
'Announce372:
'Befehl 627 &H073: --> Code 1A050154
'Audio Oscilloscope scope color
'Audio Oscilloscope scope color
Data "627;op,Audio Oscilloscope scope color;1;256,red;lin;-;256,yellow;lin;-;256,blue,lin,-"
'
'Announce373:
'Befehl 628 &H0274: --> Code 1A050154
'Audio Oscilloscope scope color
'Audio Oscilloscope scope color
Data "628;ap,as627"
'
'Announce374:
'Befehl 629 &H0275: --> Code 1A050155
'contest number style
'contest number style
Data "629;os,contest number style;1;0,normal;1,190-ANO;2,190-ANT;3,90-NO;4,90-NT"
'
'Announce375:
'Befehl 630 &H0276: --> Code 1A050155
'contest number style
'contest number style
Data "630;as,as629"
'
'Announce376:
'Befehl 631 &H0277: --> Code 1A050156
'count up trigger channel
'count up trigger channel
Data "631;os,count up trigger channel;1;0,M1;1,M2;2,M3;3,M4;4,M5;5,M6;6,M7;7,M8"
'
'Announce377:
'Befehl 632 &H0278: --> Code 1A050156
'count up trigger channel
'count up trigger channel
Data "632;as,as631"
'
'Announce378:
'Befehl 633 &H0279: --> Code 1A050157
'present number
'present number
Data "633;op,present number;1;9998{1 to 9999};lin;-"
'
'Announce379:
'Befehl 634 &H027A: --> Code 1A050157
'present number
'present number
Data "634;ap,as633"
'
'Announce380:
'Befehl 635 &H027C: --> Code 1A050158
'CW side tone gain
'CW side tone gain
Data "635;op,CW side tone level;1;255,{0 to 100};lin;%"
'
'Announce381:
'Befehl 636 &H027C: --> Code 1A050158
'CW side tone gain
'CW side tone gain
Data "636;ap,as635"
'
'Announce382:
'Befehl 637 &H027D: --> Code 1A050159
'CW side tone gain limit
'CW side tone gain limit
Data "637;os,CW side tone level limit;1;0,off;1,on"
'
'Announce383:
'Befehl 638 &H027E: --> Code 1A050159
'CW side tone gain limit
'CW side tone gain limit
Data "638;as,as637"
'
'Announce384:
'Befehl 639 &H027F: --> Code 1A05160
'CW keyer repeat time
'CW keyer repeat time
Data "639;op,CW keyer repeat time;1;59{1 to 60};lin;sec"
'
'Announce385:
'Befehl 640 &H0280: --> Code 1A050160
'CW keyer repeat time
'CW keyer repeat time
Data "640;ap,as639"
'
'Announce386:
'Befehl 641 &H0281: --> Code 1A050161
'CW keyer dot/dash ratio
'CW keyer dot/dash ratio
Data "641;op,CW keyer dot/dash ratio;1;18{2.8 to 4.5};lin;sec"
'
'Announce387:
'Befehl 642 &H0282: --> Code 1A050161
'CW keyer dot/dash ratio
'CW keyer dot/dash ratio
Data "642;ap,as641"
'
'Announce388:
'Befehl 643 &H0283: --> Code 1A050162
'rise time
'rise time
Data "643;os,rise time;1;0,2ms;1,4ms;2,6ms;3,8ms"
'
'Announce389:
'Befehl 644 &H0284: --> Code 1A050162
'rise time
'rise time
Data "644;as,as643"
'
'Announce390:
'Befehl 645 &H0285: --> Code 1A050163
'paddle polarity
'paddle polarity
Data "645;os,paddle polarity;1;0,normal;1,reverse"
'
'Announce391:
'Befehl 646 &H0286: --> Code 1A050163
'paddle polarity
'paddle polarity
Data "646;as,as645"
'
'Announce392:
'Befehl 647 &H0287: --> Code 1A050164
'keyer type
'keyer type
Data "647;os,keyer type;1;0,straight;1,bug;2,paddle"
'
'Announce393:
'Befehl 648 &H0288: --> Code 1A050164
'keyer type
'keyer type
Data "648;as,as647"
'
'Announce394:
'Befehl 649 &H0289: --> Code 1A050165
'mic. up/down keyer
'mic. up/down keyer
Data "649;os,mic.up/down keyer;1;0,off;1,on"
'
'Announce395:
'Befehl 650 &H028A: --> Code 1A050165
'mic. up/down keyer
'mic. up/down keyer
Data "650;as,as649"
'
'Announce396:
'Befehl 651 &H028B: --> Code 1A050166
'averaging function for RTTY FFT
'averaging function for RTTY FFT
Data "651;os,averaging function for RTTY FFT;1;0,off;1,2;2,3;3,4"
'
'Announce397:
'Befehl 652 &H028C: --> Code 1A050166
'averaging function for RTTY FFT
'averaging function for RTTY FFT
Data "652;as,as551"
'
'Announce398:
'Befehl 653 &H028D: --> Code 1A050167
'RTTY FFT scope waveform color
'RTTY FFT scope waveform color
Data "653;op,RTTY FFT scope waveform color;1;256,red;lin;-;256,yellow;lin;-;256,blue,lin,-"
'
'Announce399:
'Befehl 654 &H028E: --> Code 1A050167
'RTTY FFT scope waveform color
'RTTY FFT scope waveform color
Data "654;ap,as653"
'
'Announce400:
'Befehl 655 &H028F: --> Code 1A050168
'RTTY decode USOS
'RTTY decode USOS
Data "655;os,RTTY decode USOS;1;0,off;1,on"
'
'Announce401:
'Befehl 656 &H0290: --> Code 1A050168
'RTTY decode USOS
'RTTY decode USOS
Data "656;as,as655"
'
'Announce402:
'Befehl 657 &H0291: --> Code 1A050169
'RTTY decode new line code
'RTTY decode new line code
Data "657;os,RTTY decode new line code;1;0,Cr,LF,CR+LF;1,CR+LF"
'
'Announce403:
'Befehl 658 &H0292: --> Code 1A050169
'RTTY decode new line code
'RTTY decode new line code
Data "658;as,as657"
'
'Announce404:
'Befehl 659 &H0293: --> Code 1A050170
'RTTY TX USOS
'RTTY TX USOS
Data "659;os,RTTY TX USOS;1;0,off;1,on"
'
'Announce405:
'Befehl 660 &H0294: --> Code 1A050170
'RTTY TX USOS
'RTTY TX USOS
Data "660;as,as659"
'
'Announce406:
'Befehl 661 &H0295: --> Code 1A050171
'received RTTY text font color
'received RTTY text font color
Data "661;op,received RTTY text font color;1;256,red;lin;-;256,yellow;lin;-;256,blue,lin,-"
'
'Announce407:
'Befehl 662 &H0296: --> Code 1A050171
'received RTTY text font color
'received RTTY text font color
Data "662;ap,as661"
'
'Announce408:
'Befehl 663 &H0297: --> Code 1A050172
'transmitted RTTY text font color
'transmitted RTTY text font color
Data "663;op,transmitted RTTY text font color;1;256,red;lin;-;256,yellow;lin;-;256,blue,lin,-"
'
'Announce409:
'Befehl 664 &H0298: --> Code 1A050172
'transmitted RTTY text font color
'transmitted RTTY text font color
Data "664;ap,as663"
'
'Announce410:
'Befehl 665 &H0299: --> Code 1A050173
'RTTY log function
'RTTY log function
Data "665;os,RTTY log;1;0,off;1,on"
'
'Announce411:
'Befehl 666 &H029A: --> Code 1A050173
'RTTY log function
'RTTY log function
Data "666;as,as665"
'
'Announce412:
'Befehl 667 &H029B: --> Code 1A050174
'file saving format for the  RTTY log
'file saving format for the  RTTY log
Data "667;os,file saving format for the  RTTY log;1;0,text;1,HTML"
'
'Announce413:
'Befehl 668 &H029C: --> Code 1A050174
'file saving format for the  RTTY log
'file saving format for the  RTTY log
Data "668;as,as667"
'
'Announce414:
'Befehl 669 &H029D: --> Code 1A050175
'RTTY time stamp set
'RTTY time stamp set
Data "669;os,RTTY time stamp;1;0,off;1,on"
'
'Announce415:
'Befehl 670 &H029E: --> Code 1A050175
'RTTY time stamp set
'RTTY time stamp set
Data "670;as,as669"
'
'Announce416:
'Befehl 671 &H029F: --> Code 1A050176
'RTTY Decode Log Time Stamp
'RTTY Decode Log Time Stamp
Data "671;os,RTTY Decode Log Time Stamp;1;0,local;1,UTC"
'
'Announce417:
'Befehl 672 &H02A: -->0 Code 1A050176
'RTTY Decode Log Time Stamp
'RTTY Decode Log Time Stamp
Data "672;as,as671"
'
'Announce418:
'Befehl 673 &H02A1: --> Code 1A050177
'RTTY frequency stamp
'RTTY frequency stamp
Data "673;os,RTTY frequency stamp;1;0,off;1,on"
'
'Announce419:
'Befehl 674 &H02A2: --> Code 1A050177
'RTTY frequency stamp
'RTTY frequency stamp
Data "674;as,as673"
'
'Announce420:
'Befehl 675 &H02A3: --> Code 1A050178
'scan speed
'scan speed
Data "675;os,scan speed;1;0,low;1,high"
'
'Announce421:
'Befehl 676 &H02A4. --> Code 1A050178
'scan speed
'scan speed
Data "676;as,as675"
'
'Announce422:
'Befehl 677 &H02A5: --> Code 1A050179
'scan resume
'scan resume
Data "677;os,scan resume;1;0,off;1,on"
'
'Announce423:
'Befehl 678 &H02A6: --> Code 1A050179
'scan resume
'scan resume
Data "678;as,as677"
'
'Announce424:
'Befehl 679 &H02A7: --> Code 1A050180
'auto monitor function setting when transmitting a recorded voice memory
'auto monitor function setting when transmitting a recorded voice memory
Data "679;os,auto monitor function setting when transmitting a recorded voice memory;1;0,off;1,on"
'
'Announce425:
'Befehl 680 &H02A8: --> Code 1A050180
'auto monitor function setting when transmitting a recorded voice memory
'auto monitor function setting when transmitting a recorded voice memory
Data "680;as,as679"
'
'Announce426:
'Befehl 681 &H02A9: --> Code 1A050181
'repeat interval to transmit recorded voice audio
'repeat interval to transmit recorded voice audio
Data "681;op,repeat interval to transmit recorded voice audio;1:15;{1 to 15};lin;sec"
'
'Announce427:
'Befehl 682 &H02AA: --> Code 1A050181
'repeat interval to transmit recorded voice audio
'repeat interval to transmit recorded voice audio
Data "682;ap,as681"
'
'Announce428:
'Befehl 683 &H02AB: --> Code1A050182
'recording mode for QSO recorder
'recording mode for QSO recorder
Data "683;os,recording mode for QSO recorder;1;0,TX+RX;1,RX"
'
'Announce429:
'Befehl 684 &H02AC: --> Code 1A050182
'recording mode for QSO recorder
'recording mode for QSO recorder
Data "684;as,as683"
'
'Announce430:
'Befehl 685 &H02AD: --> Code 1A050183
'recording TX audio for QSO recorder
'recording TX audio for QSO recorder
Data "685;os,recording TX audio;1;0,direct;1,Monitor"
'
'Announce431:
'Befehl 686 &H02AE: --> Code 1A050183
'recording TX audio for QSO recorder
'recording TX audio for QSO recorder
Data "686;as,as685"
'
'Announce432:
'Befehl 687 &H02AF: --> Code 1A050184
'squelch relation to recording RX audio for QSO recorder
'squelch relation to recording RX audio for QSO recorder
Data "687;os.squelch relation RX audio;1;0,always;1,squelch auto"
'
'Announce433:
'Befehl 688 &H02B0: --> Code 1A050184
'squelch relation to recording RX audio for QSO recorder
'squelch relation to recording RX audio for QSO recorder
Data "688;as,as687"
'
'Announce434:
'Befehl 689 &H02B1: --> Code 1A050185
'QSO record file split
'QSO record file split
Data "689;os,QSO record file split;1;0,off;1,on"
'
'Announce435:
'Befehl 690 &H02B2: --> Code 1A050185
'QSO record file split
'QSO record file split
Data "690;as,as689"
'
'Announce436:
'Befehl 691 &H02B3: --> Code 1A050186
'PTT Automatic Recording function
'PTT Automatic Recording function
Data "691;os,PTT Automatic Recording function;1;0,off;1,on"
'
'Announce437:
'Befehl 692 &H02B4: --> Code 1A050186
'PTT Automatic Recording function
'PTT Automatic Recording function
Data "692;as,as691"
'
'Announce438:
'Befehl 693 &H02B5: --> Code 1A050187
'RX audio recording status for PTT Automatic Recording function, records the RX audio just before
'RX audio recording status for PTT Automatic Recording function, records the RX audio just before
Data "693;os,records the RX audio just before;1;0,off;1,5s;2,10s;3,15s"
'
'Announce439:
'Befehl 694 &H02B6: --> Code 1A050187
'RX audio recording status for PTT Automatic Recording function, records the RX audio just before
'RX audio recording status for PTT Automatic Recording function, records the RX audio just before
Data "694;as,as693"
'
'Announce440:
'Befehl 695 &H02B7: --> Code 1A050188
'QSO PLAY Skip time
'QSO PLAY Skip time
Data "695;os,QSO PLAY Skip time;1;0,3s;1,5s;2,10s;3,30s"
'
'Announce441:
'Befehl 696 &H02B8: --> Code 1A050188
'QSO PLAY Skip time
'QSO PLAY Skip time
Data "696;as,as695"
'
'Announce442:
'Befehl 697 &H02B9: --> Code 1A050189
'NB depth
'NB depth
Data "697;op,NB depth;1;10,lin;-"
'
'Announce443:
'Befehl 698 &H02BA: --> Code 1A050189
'NB depth
'NB depth
Data "698;ap,as697"
'
'Announce444:
'Befehl 699 &H02BB: --> Code 1A050190
'NB width
'NB width
Data "699;op,NB width;1;256,{1 to 100},lin;-"
'
'Announce445:
'Befehl 700 &H02BC: --> Code 1A050190
'NB width
'NB width
Data "700;ap,as699"
'
'Announce446:
'Befehl 701 &H02BD: --> Code 1A050191
'VOX delay
'VOX delay
Data "701;op,VOX delay;1;21,{0 to 2.0},lin;s"
'
'Announce447:
'Befehl 702 &H02BE: --> Code 1A050191
'VOX delay
'VOX delay
Data "702;ap,as701"
'
'Announce448:
'Befehl 703 &H02BF: --> Code 1A050192
'VOX voice delay
'VOX voice delay
Data "703;os,VOX voice delay;1;0,off;1,short;2,mid;3,long"
'
'Announce449:
'Befehl 704 &H02C0: --> Code 1A050192
'VOX voice delay
'VOX voice delay
Data "704;as,as703"
'
'Announce450:
'Befehl 705 &H02C1: --> Code 1A050193
'MF band attenuator
'MF band attenuator
Data "705;os,MF band attenuator;1;0,off;1,on"
'
'Announce451:
'Befehl 706 &H02C2: --> Code 1A050193
'MF band attenuator
'MF band attenuator
Data "706;as,as705"
'
'Announce452:
'Befehl 707 &H02C3: --> Code 1A06
'DATA mode
'DATA mode
'Data "707;os,DATA mode with;1;0,off;1,Fil1;2,Fil2;3,Fil3"
'
'Announce453:
'Befehl 708 &H02C4: --> Code 1A06
'DATA mode
'DATA mode
Data "708;as,as707"
'
'Announce454:
'Befehl 709 &H02C5: --> Code 1A07
'IP+ function
'IP+ function
Data "709;os,IP+ function;1;0,off;1,on"
'
'Announce455:
'Befehl 710 &H02C6: --> Code 1A07
'IP+ function
'IP+ function
Data "710;as,as709"
'
'Announce456:
'Befehl 711 &H02C7: --> Code 1B00
'repeater tone frequency
'repeater tone frequency
Data "711;os,repeater tone frequency;101;0,67.0;1,69.3;2,71.9;3,74.4;4,77,0;5,79.7;6,82.5;7,85.4;8,88.5;9,91.5;10,94.8,11,97.4;"
Data "711;os,repeater tone frequency;12,100.0;13,103.5;14,107,2;15,110.9;16,114.8;17,118.8;18,123.0;19,127.3;20,131.8;"
Data "711;os,repeater tone frequency;21,136.5;22,141.3;23,146.2;24,151.4;25,156.7;26,159.8;27,162.2;28,165.5;29,167.9;"
Data "711;os,repeater tone frequency;30,171.3;31,173.8;32,177.3;33,179.9;34,183,5;35,186.2;36,189.9;37,192.8;38,196.6;"
Data "711;os,repeater tone frequency;39,199.5;40,203.5;41,206.5;42,210.7;43,218.1;44,225,7;45,229.1;46,233.6;47,241.8;48,250.2;49,254.1"
'
'Announce457:
'Befehl 712 &H02C8: --> Code 1B00
'repeater tone frequency
'repeater tone frequency
Data "712;as,as711"
'
'Announce458:
'Befehl 713 &H02C0: -->9 Code 1B01
'TSQL tone frequency
'TSQL tone frequency
Data "713;os,TSQL tone frequency;101;0,67.0;1,69.3;2,71.9;3,74.4;4,77,0;5,79.7;6,82.5;7,85.4;8,88.5;9,91.5;10,94.8,11,97.4;"
Data "713os,TSQL tone frequency;12,100.0;13,103.5;14,107,2;15,110.9;16,114.8;17,118.8;18,123.0;19,127.3;20,131.8;"
Data "713;os,TSQL tone frequency;21,136.5;22,141.3;23,146.2;24,151.4;25,156.7;26,159.8;27,162.2;28,165.5;29,167.9;"
Data "713;os,TSQL tone frequency;30,171.3;31,173.8;32,177.3;33,179.9;34,183,5;35,186.2;36,189.9;37,192.8;38,196.6;"
Data "713;os,TSQL tone frequency;39,199.5;40,203.5;41,206.5;42,210.7;43,218.1;44,225,7;45,229.1;46,233.6;47,241.8;48,250.2;49,254.1"
'
'Announce459:
'Befehl 714 &H02CA: --> Code 1B01
'TSQL tone frequency
'TSQL tone frequency
Data "714;as,as713"
'
'Announce460:
'Befehl 715 &H02CB: --> Code 1C00
'RX/TX
'RX/TX
Data "715;os,PTT1;1;0:RX;1,TX"
'
'Announce461:
'Befehl 716 &H02CC: --> Code 1C00
'RX/TX
'RX/TX
Data "716;as,as715"
'
'Announce462:
'Befehl 717 &H02CD: --> Code 1C01
'Antenna Tuner
'Antenna Tuner
Data "717;os,Antenna Tuner;1;0:off;1,on;2,tune"
'
'Announce463:
'Befehl 718 &H02CE: --> Code 1C01
'Antenna Tuner
'Antenna Tuner
Data "718;as,as717"
'
'Announce464:
'Befehl 719 &H02CF: --> Code 1C02
'transmit frequency monitor setting
'transmit frequency monitor setting
Data "719;os,transmit frequency monitor;1;0:off;1,on;"
'
'Announce465:
'Befehl 720 &H02D0: --> Code 1C02
'transmit frequency monitor setting
'transmit frequency monitor setting
Data "720;as,as719"
'
'Announce466:
'Befehl 721 &H02D1: --> Code 1C03
'transmit frequency
'transmit frequency
Data "721;ap,transmit frequency;1;69997000,{30000 to 69999999};lin;Hz"
'
'Announce467:
'Befehl 722 &H02D2: --> Code 1C04
'Send Antenna controller status
'Send Antenna controller status
Data "722;os,Send Antenna controller status;1;0:off;1,on"
'
'Announce468:
'Befehl 723 &H02D3: --> Code 1C04
'Send Antenna controller status
'Send Antenna controller status
Data "723;as,as722"
'
'Announce469:
'Befehl 724 &H02D4: --> Code 1E00
'number of available TX frequency band
'number of available TX frequency band
Data "724;ap,number of available TX frequency band;1;255;lin"
'
'Announce470:
'Befehl 725 &H02D5: --> Code 1E01
'Band edge
'Band edge
Data "725;ap,band edge frequencies;11;70000000,{0 to 69999999;lin;Hz;70000000,{0 to 69999999};lin;Hz"
'
'Announce471:
'Befehl 726 &H02D6: --> Code 1E02
'number of available use set TX frequency band
'number of available user set TX frequency band
Data "726;ap,number of available user set TX frequency band;1;99;lin"
'
'Announce472:
'Befehl 727 &H02D7: --> Code 1E03
'user-set TX band edge frequencies
'user-set TX band edge frequencies
Data "727;op,user-set TX band edge frequencies;30;70000000,{0 to 69999999;lin;Hz;70000000,{0 to 69999999};lin;Hz"
'
'Announce473:
'Befehl 728 &H02D8: --> Code 1E03
'user set band edge
'user set band edge
Data "728;ap,as727"
'
'Announce474:
'Befehl 729 &H02D9: --> Code 2100
'RIT frequency
'RIT frequency
Data "729;op,RIT frequency;1:19999,{-9999 to 9999};lin;Hz"
'
'Announce475:
'Befehl 730 &H02DA: --> Code 2100
'RIT frequency
'RIT frequency
Data "730;ap,as729"
'
'Announce476:
'Befehl 731 &H02DB: --> Code 2101
'RIT
'RIT
Data "731;os,RIT;1;0:off;1,on"
'
'Announce477:
'Befehl 732 &H02DC: --> Code 2101
'RIT
'RIT
Data "732;as,as731"
'
'Announce478:
'Befehl 733 &H02DD:--> Code 2102
'dTX
'dTX
Data "733;os,dTX;1;0:off;1,on"
'
'Announce479:
'Befehl 734 &H02DE: --> Code 2102
'dTX
'dTX
Data "734;as,as733"
'
'Announce480:
'Befehl 735 &H02DF: --> Code 25
'selected VFOAs frequency
'selected VFOAs frequency
Data "735;op,selected VFOAs operating frequency;2;69970000,{30000 to 69999999};lin;Hz"
'
'Announce481:
'Befehl 736 &H02E: -->0 Code 25
'selected VFOAs frequncy
'selected VFOAs frequency
Data "736;ap,as735"
'
'Announce482:
'Befehl 737 &H02E1: --> Code 26
'unselected / selected VFOAs operating mode
'unselected / selected VFOAs operating mode
Data "737;os,mode of sel / unsel VFO;2;0:sel;1,unsel;0,LSB;1,USB;1,AM;3,CW;4,RTTY;5,FM;6,CW-R;7,RTTY-R;8,LSB-D;9,USB-D;10,AM-D;11,FM-D;0,Fil1;1,Fil2;2,Fil3"
'
'Announce483:
'Befehl 738 &H02E2: --> Code 26
'unselected / selected VFOAs operating mode
'unselected / selected VFOAs operating mode
Data "738;ap,as737"
'
'Announce484:
'Befehl 739 &H02E3: --> Code 2700
'scope data nicht verwendet
'scope data not used
Data "739;iz"
'
'Announce485:
'Befehl 740 &H02E4: --> Code 2710
'send scope data
'send scope data
Data "740;os,send scope data;1;0 off;1 on;5,CHAPTER,scope"
'
'Announce486:
'Befehl 741 &H02E5. --> Code 2710
'send scope data
'send scope data
Data "741;as,as740"
'
'Announce487:
'Befehl 742 &H02E6: --> Code 2711
'Scope wave data output*4
'Scope wave data output*4
Data "742;os,Scope wave data output*4;1;0 off;1 on;5,CHAPTER,scope"
'
'Announce488:
'Befehl 743 &H02E7: --> Code 2711
'Scope wave data output*4
'Scope wave data output*4
Data "743;as,as742"
'
'Announce489:
'Befehl 744 &H02E8: --> Code 2712
'Main or Sub scope setting
'Main or Sub scope setting
Data "744;as,Main or Sub scope setting;1;0 main;1,sub;5,CHAPTER,scope"
'
'Announce490:
'Befehl 745 &H02E9: --> Code 2713
'Single/Dual scope setting
'Single/Dual scope setting
Data "745;as,Single/Dual scope setting;1;0 single;1,dual;5,CHAPTER,scope"
'
'Announce491:
'Befehl 746 &H02EA: --> Code 2714
'Scope Center mode or Fixed mode
'Scope Center mode or Fixed mode
Data "746;os,Scope Center mode or Fixed mode;1;0 center;1,fixed;5,CHAPTER,scope"
'
'Announce492:
'Befehl 747 &H0B: -->2E Code 2714
'Scope Center mode or Fixed mode
'Scope Center mode or Fixed mode
Data "747;as,as746"
'
'Announce493:
'Befehl 748 &H02EC: --> Code 2715
'span setting in the Center mode
'span setting in the Center mode
Data "748;os,span setting in the Center mode;1;0 2k5;1,5k;2,10k;3,25k;4,50k;5,100k;6,250k;7,500k;5,CHAPTER,scope"
'
'Announce494:
'Befehl 749 &H02ED: --> Code 2715
'span setting in the Center mode
'span setting in the Center mode
Data "749;as,as748"
'
'Announce495:
'Befehl 750 &H02EE: --> Code 2716
'Edge number setting in the Fixed mode
'Edge number setting in the Fixed mode
Data "750;os,Edge number setting in the Fixed mode;1;0 Edge1;1,Edge2;2,Edge3;5,CHAPTER,scope"
'
'Announce496:
'Befehl 751 &H02EF: --> Code 2716
'Edge number setting in the Fixed mode
'Edge number setting in the Fixed mode
Data "751;as,as750"
'
'Announce497:
'Befehl 752 &H02F0: --> Code 2717
'Scope hold
'Scope hold
Data "752;os,Scope hold;1;0,off;1,on;5,CHAPTER,scope"
'
'Announce498:
'Befehl 753 &H02F1. --> Code 2717
'Scope hold
'Scope hold
Data "753;as,as752"
'
'Announce499:
'Befehl 754 &H02F2: --> Code 2719
'Scope Reference level
'Scope Reference level
Data "754;op,Scope Reference level;1;81,{-20.0 to 20.0};lin;db;5,CHAPTER,scope"
'
'Announce500:
'Befehl 755 &H02F3: --> Code 2719
'Scope Reference level
'Scope Reference level
Data "755;ap,as754"
'
'Announce501:
'Befehl 756 &H02F4: --> Code 271A
'Sweep speed
'Sweep speed
Data "756;os,Sweep speed;1;0,fast;1,mid;2,slow"
'
'Announce502:
'Befehl 757 &H02F5: --> Code 271A
'Sweep speed
'Sweep speed
Data "757;as,as756"
'
'Announce503:
'Befehl 758 &H02F6: --> Code 271B
'Scope indication during TX in the Center mode
'Scope indication during TX in the Center mode
Data "758;os,Scope indication during TX in the Center mode;1;0,off;1,on;5,CHAPTER,scope"
'
'Announce504:
'Befehl 759 &H02F7: --> Code 271B
'Scope indication during TX in the Center mode
'Scope indication during TX in the Center mode
Data "759;as,as758"
'
'Announce505:
'Befehl 760 &H02F8: --> Code 271C
'center frequency setting in the Center mode
'center frequency setting in the Center mode
Data "760;os,center frequency in the Center mode;1;0,Filter center;1,carrier center;2,carrier center(absolute);5,CHAPTER,scope"
'
'Announce506:
'Befehl 761 &H02F9: --> Code 271C
'center frequency setting in the Center mode
'center frequency setting in the Center mode
Data "761;as,as760"
'
'Announce507:
'Befehl 762 &H02FA: --> Code 271D
'VBW
'VBW
Data "762;os,VBW;1;0,narrow;1,wide"
'
'Announce508:
'Befehl 763 &H02FB: --> Code 271D
'VBW
'VBW
Data "763;as,as762"
'
'Announce509:
'Befehl 764 &H02FC: --> Code 1A00
'memory Frequenz schreiben
'Write Memory frequency
Data "764;op,memory frequency;101;69970000,{30000 to 69999999};lin;Hz"
'
'Announce510:
'Befehl 765 &H02FD: --> Code 1A00
'memory Frequenz lesen
'read memory frequency
Data "765;ap,as764"

'Announce511:
'Befehl 766 &H02FE: --> Code 1A00
'memory mode schreiben
'Write Memory mode
Data "766;os, mode;101;0,LSB;1,USB;1,AM;3,CW;4,RTTY;5,FM;6,CW-R;7,RTTY-R"
'
'Announce512::
'Befehl 767 &H02FF: --> Code 1A00
'memory mode lesen
'read Memory mode
Data "767;as,as766"
'
'Announce513:
'Befehl 768 &H0300: --> Code 1A00
'memory filter schreiben
'Write Memory filter
Data "768;os, filter;101;0,Fil1,1;Fil2;2,Fil3"
'
'Announce514::
'Befehl 769 &H0301: --> Code 1A00
'memory filter lesen
'read Memory filter
Data "769;as,as768"
'
'Announce515:
'Befehl 770 &H0302: --> Code 1A00
'memory tone schreiben
'Write Memory tone
Data "770;os, tone;101;0.off;1;tone;2;tsql"
'
'Announce516::
'Befehl 771 &H0303: --> Code 1A00
'memory tone lesen
'read Memory tone
Data "771;as,as770"
'
'Announce517:
'Befehl 772 &H0304: --> Code 1A00
'memory data mode schreiben
'Write Memory data mode
Data "772;os,memory data mode;101;0,off;1,on"
'
'Announce518:
'Befehl 773 &H0305: --> Code 1A00
'memory data mode lesen
'read Memory data mode
Data "773;as,as772"
'
'Announce519:
'Befehl 774 &H0306: --> Code 1A00
'memory tone frequenz schreiben
'Write Memory tone frequency
Data "774;os,memory tone frequency;101;0,67.0;1,69.3;2,71.9;3,74.4;4,77,0;5,79.7;6,82.5;7,85.4;8,88.5;9,91.5;10,94.8,11,97.4;"
Data "774;os,memory tone frequency;12,100.0;13,103.5;14,107,2;15,110.9;16,114.8;17,118.8;18,123.0;19,127.3;20,131.8;"
Data "774;os,memory tone frequency;21,136.5;22,141.3;23,146.2;24,151.4;25,156.7;26,159.8;27,162.2;28,165.5;29,167.9;"
Data "774;os,memory tone frequency;30,171.3;31,173.8;32,177.3;33,179.9;34,183,5;35,186.2;36,189.9;37,192.8;38,196.6;"
Data "774;os,memory tone frequency;39,199.5;40,203.5;41,206.5;42,210.7;43,218.1;44,225,7;45,229.1;46,233.6;47,241.8;48,250.2;49,254.1"
'
'Announce520:
'Befehl 775 &H0307: --> Code 1A00
'memory tone frequenz lesen
'read memory tone frequency
Data "775;as,as774"
'
'Announce521:
'Befehl 776 &H0308: --> Code 1A00
'memory tone squelch schreiben
'Write memory tone squelch
Data "776;os,memory tone squelch;101;0,67.0;1,69.3;2,71.9;3,74.4;4,77,0;5,79.7;6,82.5;7,85.4;8,88.5;9,91.5;10,94.8,11,97.4;"
Data "776;os,memory tone squelch;12,100.0;13,103.5;14,107,2;15,110.9;16,114.8;17,118.8;18,123.0;19,127.3;20,131.8;"
Data "776;os,memory tone squelch;21,136.5;22,141.3;23,146.2;24,151.4;25,156.7;26,159.8;27,162.2;28,165.5;29,167.9;"
Data "776;os,memory tone squelch;30,171.3;31,173.8;32,177.3;33,179.9;34,183,5;35,186.2;36,189.9;37,192.8;38,196.6;"
Data "776;os,memory tone squelch;39,199.5;40,203.5;41,206.5;42,210.7;43,218.1;44,225,7;45,229.1;46,233.6;47,241.8;48,250.2;49,254.1"
'
'Announce522:
'Befehl 777 &H0309: --> Code 1A00
'memory tone squelch lesen
'read memory tone squelch
Data "777;as,as776"
'
'Announce523:
'Befehl 778 &H030A: --> Code 1A00
'memory Frequenz schreiben split
'Write Memory frequency split
Data "778;op,memory frequency split;101;69970000,{30000 to 69999999};lin;Hz"
'
'Announce524:
'Befehl 779 &H030B: --> Code 1A00
'memory Frequenz lesen split
'read memory frequency split
Data "779;ap,as778"

'Announce525:
'Befehl 780 &H030C: --> Code 1A00
'memory mode schreiben split
'Write Memory mode split
Data "780;os, mode split;101;0,LSB;1,USB;1,AM;3,CW;4,RTTY;5,FM;6,CW-R;7,RTTY-R"
'
'Announce526:
'Befehl 781 &H030D: --> Code 1A00
'memory mode lesen split
'read Memory mode split
Data "781;as,as780"
'
'Announce527:
'Befehl 782 &H030E Code 1A00
'memory filter schreiben split
'Write Memory filter split
Data "782;os, filter split;101;0,LSB;1,Fil;1,Fil2;2,Fil3"
'
'Announce528:
'Befehl 783 &H030F: --> Code 1A00
'memory filter lesen split
'read Memory filter split
Data "783;as,as782"
'
'Announce529:
'Befehl 784 &H0310: --> Code 1A00
'memory tone schreiben split
'Write Memory tone split
Data "784;os, tone;101;0.off;1;tone;2;tsql"
'
'Announce530::
'Befehl 785 &H0311: --> Code 1A00
'memory tone lesen split
'read Memory tone split
Data "785;as,as784"
'
'Announce531:
'Befehl 786 &H0312: --> Code 1A00
'memory data mode schreiben split
'Write Memory data mode split
Data "786;os,memory data mode101;101;0,off;1,on"
'
'Announce532:
'Befehl 787 &H0313: --> Code 1A00
'memory data mode lesen split
'read Memory data mode split
Data "787;as,as786"
'
'Announce533:
'Befehl 788 &H0314: --> Code 1A00
'memory tone frequenz schreiben split
'Write Memory tone frequency split
Data "788;os,memory tone frequency;101;0,67.0;1,69.3;2,71.9;3,74.4;4,77,0;5,79.7;6,82.5;7,85.4;8,88.5;9,91.5;10,94.8,11,97.4;"
Data "788;os,memory tone frequency;12,100.0;13,103.5;14,107,2;15,110.9;16,114.8;17,118.8;18,123.0;19,127.3;20,131.8;"
Data "788;os,memory tone frequency;21,136.5;22,141.3;23,146.2;24,151.4;25,156.7;26,159.8;27,162.2;28,165.5;29,167.9;"
Data "788;os,memory tone frequency;30,171.3;31,173.8;32,177.3;33,179.9;34,183,5;35,186.2;36,189.9;37,192.8;38,196.6;"
Data "788;os,memory tone frequency;39,199.5;40,203.5;41,206.5;42,210.7;43,218.1;44,225,7;45,229.1;46,233.6;47,241.8;48,250.2;49,254.1"
'
'Announce534:
'Befehl 789 &H0315: --> Code 1A00
'memory tone frequenz lesen
'read memory tone frequency
Data "789;as,as788"
'
'Announce535:
'Befehl 790 &H0316: --> Code 1A00
'memory tone squelch schreiben
'Write memory tone squelch
Data "790;os,memory tone squelch;101;0,67.0;1,69.3;2,71.9;3,74.4;4,77,0;5,79.7;6,82.5;7,85.4;8,88.5;9,91.5;10,94.8,11,97.4;"
Data "790;os,memory tone squelch;12,100.0;13,103.5;14,107,2;15,110.9;16,114.8;17,118.8;18,123.0;19,127.3;20,131.8;"
Data "790;os,memory tone squelch;21,136.5;22,141.3;23,146.2;24,151.4;25,156.7;26,159.8;27,162.2;28,165.5;29,167.9;"
Data "790;os,memory tone squelch;30,171.3;31,173.8;32,177.3;33,179.9;34,183,5;35,186.2;36,189.9;37,192.8;38,196.6;"
Data "790;os,memory tone squelch;39,199.5;40,203.5;41,206.5;42,210.7;43,218.1;44,225,7;45,229.1;46,233.6;47,241.8;48,250.2;49,254.1"
'
'Announce536:
'Befehl 791 &H0317: --> Code 1A00
'memory tone squelch lesen
'read memory tone squelch
Data "791;as,as790"

'Announce537:
'Befehl 792 &H0318: --> Code 1A00
'memory name schreiben
'Write Memory name
Data "792;om,memory name;101;10"
'
'Announce538:
'Befehl 793 &H0319: --> Code 1A00
'memory name lesen
'read memory name
Data "793;am,as792"
'
'Announce539:
'Befehl 794 &H031A: --> Code 1A00
'memory select schreiben
'Write Memory name
Data "794;om,memory name;101;10"
'
Announce540:
'Befehl 795 &H031B: --> Code 1A00
'memory select lesen
'read memory name
Data "795;am,as794"
'
'Announce541:
'Befehl 796 &H031C: --> Code 1A01
' kopiert Band Stack 2 oder 3 nach 1
' copy band stack 2 or 3 to 1
Data "796;os;2;0;1,oldest;0,160m;1,80m;2.40m;3,30m;4,20m;5,17m;6,15m;7,12m;8:10m;9,6m;10,others"
'
'Announce542
'Befehl 797 &H031D: --> Code 0H2800
' Transmits Voice TX memory Inhalt
' Transmits the Voice TX memory content
Data "797;os;1;0,Cancel;1,0;2,1;3,2;4,3;5,4;6,5;7,6;8,7;9,8"
'
'Announce543:
'Befehl 798 &H031E: -->  Code 1507
'OVF status
'Read the OVF icon status
Data "798;as;OVF icon status;1;0,off;1,on"
'
'Announce544:
'Befehl 799 &H031F 2 Byte / 3 Byte -->
'VfO / memory
'VFO / memory
Data "799;as;VFO / memory;1;0,VFO;1,memory"
'
'Announce545
'Befehl  65520 &HFFF0
'liest announcements
'read n announcement lines
Data "65520;ln,ANNOUNCEMENTS;175;545"
'
'Announce547:                                                  '
'Befehl 65532 &HFFFC
'Liest letzten Fehler
'read last error
Data "65532;aa,LAST ERROR;20,last_error"
'
'Announce548:                                                  '
'Befehl 65533 &HFFFD
'Geraet aktiv Antwort
'Life signal
Data "65533;aa,MYC INFO;b,ACTIVE"
'
'Announce549:
'Befehl 65534 &HFFFE <n><data>
'eigene Individualisierung schreiben
'write individualization
Data "65534;ka,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,23,{0 to 127};a,SERIAL,1"
'
'Announce550:
'Befehl 65535  &FFHFF <n>
'eigene Individualisierung lesen
'read individualization
Data "65535 ;la,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,23,{0 to 127};a,SERIAL,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1"
'
Data "R !268&06 !268&07 IF $799 = 1"
Data "R !$360 UNLESS $259&0 = 3"
Data "R!$365, !$366, !$369, !$370 UNLESS 259&0 = 1"
Data "!$367, !$368, !$371, !$372 IF 259&0 = 1"
Data "R $595&0 + $595$1 < 1661"
Data "R $597&0 + $597$1 < 4991"
Data "R $599&0 + $599$1 < 4991"
Data "R $601&0 + $601$1 < 2991"
Data "R $603&0 + $603$1 < 3991"
Data "R $605&0 + $605$1 < 4991"
Data "R $607&0 + $607$1 < 5991"
Data "R $609&0 + $609$1 < 2991"
Data "R $611&0 + $611$1 < 4991"
Data "R $613&0 + $613$1 < 4991"
Data "R $615&0 + $615$1 < 15991"
Data "R $617&0 + $617$1 < 15991"
Data "R $619&0 + $619$1 < 15991"
Data "R !727 IF $727&1a&2B < $725&1a&2B AND $727&1a&3C < $725&1a&3C"