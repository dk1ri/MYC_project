' _announcements.bas
' 20220113
'
Announce:
'Befehl &H00
'eigenes basic 'Announcement lesen
'basic 'Announcement is read to I2C or output
Data "0;m;DK1RI;IC7000 Interface;V01.2;1;175;2;545;1-1"
'
'Announce1:
'Befehl 256 &H0100: 6 byte / - Code 00 05
'Frequenz schreiben
'write Frequency
Data "256;op,freqency;1;269070000,{30000 to 199999999,400000000 to 469999999};lin;Hz"
'
'Announce2:
'Befehl 257 &H0101: -->  Code 03
'Frequenz lesen
'read Frequency
Data "257;ap,as256"
'
'Announce3:
'Befehl 258 &H0102: -->Code 01 + 06
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
Data "260;ap,band edge frequencies;1;470000000,{0 to 469999999},low;lin;Hz;70000000,{0 to 469999999},high;lin;Hz"
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
'Befehl 263 &H0107: --> Code 08
'set memory mode
'set memory mode
Data "263;ou,set memory mode;1;0.idle;1,memory mode"
'
'Announce9:
'Befehl 264 &H0108: --> Code 08
'select memory
'select memory
Data "264;op,memory;1;107,{P1 to P105,C1,C2};lin;-"
'
'Announce10:
'Befehl 265 &H0109:  --> Code 08
'select memory bank
'select memory bank
Data "264;op,memory bank;1;5,{A to E};lin;-"
'
'Announce11:
'Befehl 266 &H010A: --> Code 9
'Vfo und Mode nach memory schreiben
'write vfo and mode to memory
Data "266;ou,copy vfo and mode to memory;1;0,idle;1,copy to memory"
'
'Announce12:
'Befehl 267 &H010B: --> Code 0A
'memory nach Vfo und mode schreiben
'write memory to vfo and mode
Data "267;ou,copy memory to vfo and mode;1;0,idle;1,copy to vfo"
'
'Announce13:
'Befehl 268 &H010C: --> Code 0B
'memory loeschen
'clear memory
Data "268;ou,clear memory;1;0,idle;1,clear memory"
'
'Announce14:
'Befehl 269 &H010D: --> Code 0D
'Offset schreiben
'write offset
Data "269;op,write offset;1;1000000{0 To 99999,9;lin;kHz"
'
'Announce15:
'Befehl 270 &H010E: --> Code 0C
'Offset lesen
'read offset
Data "270;ap,as269"
'
'Announce16:
'Befehl 271 &H010F: - --> Code 0E00
'start scan mode
'start scan mode
Data "271;os,start scan mode;1;0,stop;1,prog memory;2,prog;3,memory;4,select memory"
'
'Announce17:
'Befehl 272 &H0110: --> Code 0EB0
'set as chanal
'set as chanal
Data "272,ou,set as non select chanal;1;0,idle;1,set"
'
'Announce18:
'Befehl 273 &H0111: --> Code 0EB1
'select chanal
'select chanal
Data "273,os,select as select  chanal;1;0,idle;1,set"
'
'Announce19:
'Befehl 274 &H0112:- --> Code 0ED1, 0ED3
'scan resume
'scan resume
Data "274;os,scan resume;1;0,off;1,on"
'
'Announce20:
'Befehl 275 &H0113:  Code 0F
'split/dup
'split/dup
Data "274;os,split/duplex;1;0,off;1,on;2,simplx;3,-Dup;4,+Dup"
'
'Announce21:
'Befehl 276 &H0114: -->Code 10
'tuning step
'tuning step
Data "276;os,tuning step;1;0,off/10;1,100;2,1k;3,5k;4,9k;5,10k;6,12.5k;7,20k;8,25k;9,100k;10,1M"
'
'Announce22:
'Befehl 277 &H0115: --> Code 11
'Abschwächer
'attenuator
Data "277;os,attenuator;1;0,off;1,12dB"
'
'Announce23:
'Befehl 278 &H0116: --> Code 11
'Abschwächer
'attenuator
Data "278;as,as277"
'
'Announce24:
'Befehl 279 &H0117: --> Code 13
'aktuelle Sprachausgabe
'actual speech
Data "279;os,speech;1;0,all;1,freq and smeter;2,mode"
'
'Announce25:
'Befehl 280 &H0118: --> Code 1401
'Lautstaerke
'AF level
Data "280;op,AF level;1;256;lin;%"
'
'Announce26:
'Befehl 281 &H0119: --> Code 1401
'Lautstaerke
'AF level
Data "281;ap,as280"
'
'Announce27:
'Befehl 282 &H011A: --> (Code 1402) used 1A050001
'RF level
Data "282;op,RF level;256,;lin;%"
'
'Announce28:
'Befehl 283 &H011B: --> (Code 1402) used 1A050001
'Hf Pegel
'RF level
Data "283;ap,as282"
'
'Announce29:
'Befehl 284 &H011C: --> code 1403
'Squelch
'Squelch
Data "284;op,Squelch;256,{0 to 100};lin;%"
'
'Announce30:
'Befehl 285 &H011D: --> Code 1403
'Squelch
'Squelch
Data "285;ap,as284"
'
'Announce31:
'Befehl 286 &H011E: --> code 1406
'Noise reduction
'Noise reduction
Data "286;op,Noise reduction;256;lin;%"
'
'Announce32:
'Befehl 287 &H011F: --> Code 1406
'Noise reduction
'Noise reduction
Data "287;ap,as287"
'
'Announce33:
'Befehl 288 &H0120: --> code 1407
'inner Twin PBT
'inner Twin PBT
Data "288;op,inner Twin PBT;256;lin;-"
'
'Announce34:
'Befehl 289 &H0121: --> Code 1408
'inner Twin PBT
'inner Twin PBT
Data "289;ap,as288"
'
'Announce35:
 'Befehl 290 &H0124: --> code 1408
'outer Twin PBT
'outer Twin PBT
Data "290;op,outer Twin PBT;256;lin;-"
'
'Announce36:
'Befehl 291 &H0123: --> Code 1408
'outer Twin PBT
'outer Twin PBT
Data "291;ap,as290"
'
'Announce37:
'Befehl 292 &H0124: --> code 1409
'CW Pitch
'CW Pitch
Data "292;op,CW Pitch;1;256,{300 to 900};lin;Hz"
'
'Announce38:
'Befehl 293 &H0125: --> Code 1409
'CW Pitch
'CW Pitch
Data "293;ap,as292"
'
'Announce39:
'Befehl 294 &H0126: --> code 140A
'Hf Leistung
'Rf power
Data "294;op,Rf power;1;256,{0 to 100};lin;%"
'
'Announce40:
'Befehl 295 &H0127: --> Code 140A
'Hf Leistung
'Rf power
Data "295;ap,as294"
'
'Announce41:
''Befehl 296 &H0128: --> code 140B
'Mic Pegel
'Mic level
Data "296;op,Mic level;1;256,{0 to 100};lin;%"
'
'Announce42:
'Befehl 297 &H0129: --> Code 140B
'Mic Pegel
'Mic level
Data "297;ap,as296"
'
'Announce43:
'Befehl 298 &H012A: --> code 140C
'CW Geschwindigkeit
'key speed
Data "298;op,key speed;1;256,{6 to 48};lin;wpm"
'
'Announce44:
'Befehl 299 &H012B: --> Code 140C
'CW Geschwindigkeit
'key speed
Data "299;ap,as298"
'
'Announce45:
'Befehl 300 &H012C: --> code 140D
'Notch
'Notch
Data "300;op,Notch;1;256,{0 to 100};lin;%"
'
'Announce46:
'Befehl 301 &H012D: --> Code 140D
'Notch
'Notch
Data "301;ap,as300"
'
'Announce47:
'Befehl 302 &H012E: --> code 140E
'Comp
'Comp
Data "302;op,comp;1;256,{0 to 10};lin;-"
'
'Announce48:
'Befehl 303 &H013F: --> Code 140E
'Comp
'Comp
Data "303;ap,as302"
'
'Announce49:
'Befehl 304 &H0130: --> code 140F
'Break in delay
'Break in delay
Data "304;op,break in delay;1;256,{2.0 to 13.0};lin;d"
'
'Announce50:
'Befehl 305 &H0131: --> Code 140F
'Break in delay
'Break in delay
Data "305;ap,as304"
'
'Announce51:
'Befehl 306 &H0132: --> code 1412
'NB Pegel
'NB level
Data "306;op,NB level;1;256,{0 to 100};lin;%"
'
'Announce52:
'Befehl 307 &H0133: --> Code 1412
'NB Pegel
'NB level
Data "307;ap,as306"
'
'Announce53:
'Befehl 308 &H0134: --> code 1415
'Monitor Pegel
'monitor level
Data "308;op,monitor level;1;256,{0 to 100};lin;%"
'
'Announce54:
'Befehl 309 &H0135: --> Code 1415
'Monitor Pegel
'monitor level
Data "309;ap,as308"
'
'Announce55:
'Befehl 310 &H0136: --> code 1416
'VOX Pegel
'VOX level
Data "310;op,vox level;1;256,{0 to 100};lin;%"
'
'Announce56:
'Befehl 311 &H0137: --> Code 1416
'VOX Pegel
'VOX level
Data "311;ap,as310"
'
'Announce57:
'Befehl 312 &H0138: --> code 1417
'AnitVOX Pegel
'AntiVOX level
Data "312;op,antivox level;1;256,{0 to 100};lin;%"
'
'Announce58:
'Befehl 313 &H0139: --> Code 1417
'AnitVOX Pegel
'AntiVOX level
Data "313;ap,as312"
'
'Announce59:
'Befehl 314 &H013A: --> code 1418
'Kontrast
'contrast
Data "314;op,contrast;1;256,{0 to 100};lin;%"
'
'Announce60:
'Befehl 315 &H013B: --> Code 1418
'Kontrast
'contrast
Data "315;ap,as314"
'
'Announce61:
'Befehl 316 &H013C: --> code 1419
'Helligkeit
'brightness
Data "316;op,brightness;1;256,{0 to 100};lin;%"
'
'Announce62:
'Befehl 317 &H013D: --> Code 1419
'Helligkeit
'brightness
Data "317;ap,as316"
'
'Announce63:
'Befehl 318 &H013E: --> code 141A
'Notch NF2
'Notch NF2
Data "318;op,Notch NF2;1;256,{0 to 100};lin;%"
'
'Announce64:
'Befehl 319 &H013F: --> Code 141A
'Notch NF2
'Notch NF2
Data "319;ap,as318"
'
'Announce65:
'Befehl 320 &H0140: -->  Code 1501
'squelch status
'squelch status
Data "320;as,squelch status;1;0,off;1,on "
'
'Announce66:
'Befehl 321 &H0141: -->  Code 1502
'S meter Pegel
's meter level
Data "321;ap,s meter level;1;256,{121{0 to 9},135{0 to 62}}"
'
'Announce67:
'Befehl 322 &H0142: -->  Code 1511
'Leistung
'PO meter
Data "322;ap,PO meter;1;256,{143,{0 TO 50},113,{51 TO 150};lin;%"
'
'Announce68:
'Befehl 323 &H0143: -->  Code 1512
'SWR meter
Data "323;ap;SWR meter;1;256,49,{1.00 to 1.50},32[1,51 to 2.00},40{2,01 to 3,00},135{3,01to 6};lin;-"
'
'Announce69:
'Befehl 324 &H0144: -->  Code 1513
'ALC meter
'ALC meter
Data "324;ap;ALC meter;1;121,{0 to 100};lin;%"
'
'Announc70:
'Befehl 325 &H0145: -->  Code 1514
'Comp meter
'comp meter
Data "325;ap;comp meter;1;256,130,{0 to 15.0},126,{15.1 to 30};lin;dB"
'
'Announce71:
'Befehl 326 &H0146:  -->  Code 1602
'Preamp
'Preamp
Data "326;os,preamp;1;0,off;1,preamp1;2,preamp2"
'
'Announce72:
'Befehl 327 &H0147:  -->  Code 1602
'Preamp
'Preamp
Data "327;as,as326"
'
'Announce73:
'Befehl 328 &H01478:  -->  Code 1612
'AGC
'AGC
Data "328;os,AGC;1;0,off;1,fast;2,med;3,slow"
'
'Announce74:
'Befehl 329 &H0149: -->  Code 1612
'AGC
'AGC
Data "329;as,as328"
'
'Announce75:
'Befehl 330 &H014A: -->  Code 1622
'Noise blanker
'Noise blanker
Data "330;os,Noise blanker;1;0,off;1,on"
'
'Announce76:
'Befehl 331 &H014B: -->  Code 1622
'Noise blanker
'Noise blanker
Data "331;as,as330"
'
'Announce77:
'Befehl 332 &H014C: -->  Code 1640
'Noise reduction
'Noise reduction
Data "332;os,Noise reduction;1;0,off;1,on"
'
'Announce78:
'Befehl 333 &H014D: -->  Code 1640
'Noise reduction
'Noise reduction
Data "333;as,as332"
'
'Announce79:
'Befehl 334 &H014E:  -->  Code 1641
'Auto notch
'Auto notch
Data "334;os,Auto notch;1;0,off;1,on"
'
'Announce80:
'Befehl 335 &H014F:  -->  Code 1641
'Auto notch
'Auto notch
Data "335;as,as334"
'
'Announce81:
'Befehl 336 &H0150: -->  Code 1642
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
'Befehl 338 &H0152 -->  Code 1643
'Tone squelch
'Tone squelch
Data "338;os,Tone squelch;1;0,off;1,on"
'
'Announce84:
'Befehl 339 &H0153:  -->  Code 1643
'Tone squelch
'Tone squelch
'Data "339;as,as338"
'
'Announce85:
'Befehl 340 &H0154:  -->  Code 1644
'Speech compressor
'Speech compressor
Data "340;os,speech compressor;1;0,off;1,on"
'
'Announce86:
'Befehl 341 &H0155: -->  Code 1644
'Speech compressor
'Speech compressor
Data "341;as,as340"
'
'Announce87:
'Befehl 342 &H0156: -->  Code 1645
'Monitor
'Monitor
Data "342;os,,Monitor;1;0,off;1,on"
'
'Announce88:
'Befehl 343 &H0157: -->  Code 1645
'Monitor
'Monitor
Data "343;as,as342"
'
'Announce89:
'Befehl 344 &H0158:  -->  Code 1646
'VOX
'VOX
Data "344;os,VOX;1;0,off;1,on"

'Announc90:
'Befehl 345 &H0159: -->  Code 1646
'VOX
'VOX
Data "345;as,as344"
'
'Announce91:
'Befehl 346 &H015A: -->  Code 1647
'BK
'BK
Data "346;os,BK;1;0,off;1,semi;2,full"
'
'Announce92:
'Befehl 347 &H015B: -->  Code 1647
'BK
'BK
Data "347;as,as346"
'
'Announce93:
'Befehl 348 &H015C: --> Code 1648
'Manueller notch
'Manual notch
Data "348;os,manual notch;1;0,off;1,on"
'
'Announce94:
'Befehl 349 &H015D: --> Code 1648
'Manueller notch
'Manual notch
Data "349;as,as348"
'
'Announce95:
'Befehl 350 &H015E: --> Code 164B
'DTCS
'DTCS
Data "350;os,DTCS;1;0,off;1,on"
'
'Announce96:
'Befehl 351 &H015F: --> Code 164B
'DTCS
'DTCS
Data "351;as,as350"
'
'Announce97:
'Befehl 352 &H0160: --> Code 164C
'VSC
'VSC
Data "352;os,Twin Peak Filter;1;0,off;1,on"
'
'Announce98:
'Befehl 353 &H0161 2 byte / 3 byte  -->  Code 164C
'VSC
'VSC
Data "353;as,as352"
'
'Announce99:
'Befehl 354 &H0162: --> Code 164F
'Twin Peak Filter
'Twin Peak Filter
Data "354;os,Twin Peak Filter;1;0,off;1,on"
'
'Announce100:
'Befehl 355 &H0163:  --> Code 164F
'Twin Peak Filter
'Twin Peak Filter
Data "355;as,as354"
'
'Announce101:
'Befehl 356 &H0164: --> Code 1650
'Dial lock
'Dial lock
Data "356;os,Dial lock;1;0,off;1,on"
'
'Announce102:
'Befehl 357 &H0165: --> Code 1650
'Dial lock
'Dial lock
Data "357;as,as356"
'
'Announce103:
'Befehl 358 &H0166: -->  Code 1651
'manual notch NF2
'manual notch NF2
Data "358;os,manual notch NF2;1;0,off;1,on"
'
'Announce104:
'Befehl 359 &H0167: -->  Code 1651
'manual notch NF2
'manual notch NF2
Data "359;as,as358"
'
'Announce105:
'Befehl 360 &H0168: --> Code 19
'ID
'Id
Data "359;aa,id;b"
'
'Announce106:
'Befehl 361 &H0169: --> Code 1A00
'Speicher Inhalt
'memory content
Data "361;om,memory content;s;103,{0 to 99,P1,P2,P3}"
'
'Announce107:
'Befehl 362 &H016A: --> Code 1A00
'Speicher Inhalt
'memory content
Data "362;am,as361"
'
'Announce108:
'Befehl 363 &H016B: --> Code 1A01
'band stack
'band stack
Data "363;op,band stack;39,{3,{1,2,3}MUL13,band};269070000,{30000 to 199999999,400000000 to 469999999};lin;Hz""
'
'Announce109:
'Befehl 364 &H016C: --> Code 1A01
'band stack
'band stack
Data "364;ap,as363"
'
'Announce110:
'Befehl 365 &H016D: --> (1502) used: Code 1A050002
'4 Kanal memory keyer
'4 chanal memory keyer
Data "365;om,memory keyer;4;70,{0 to 9, A to Z, ,/,?,.,0x2c,0x5e,*,@}"
'
'Announce111:
'Befehl 366 &H016E: -> Code (1502) used:1A050002
'4 Kanal memory keyer
'4 chanal memory keyer
Data "366,am,as365"
'
'Announce112:
'Befehl 367 &H016F: --> Code 1A03
'selected AM Filter Bandbreite
'selected AM filter width
Data "367;op,AM filter width;1;50{200 to 10000};lin;Hz"
'
'Announce113:
'Befehl 368 &H0170: --> Code 1A03
'selected AM Filter Bandbreite
'selected AM 'filter width
Data "367,ap,as366"
'
'Announce114:
'Befehl 369 &H0171: --> Code 1A03
'selected non AM Filter Bandbreite
'selected non AM filter width
Data "369;op,non AM filter width;1;41{50 to 3600};lin;Hz"
'
'Announce115:
'Befehl 370 &H0172: --> Code 1A03
'selected non AM Filter Bandbreite
'selected non AM 'filter width
Data "370,ap,as369"

'Announce116:
'Befehl 371 &H0173: --> Code 1A04
'selected AM AGC Zeitkonstante
'selected AM AGC time constant
Data "371;op, AM time comstant;1;14;1{off},13{0 to 8.0};lin;Hz"
'
'Announce117:
'Befehl 372 &H0174: --> Code 1A04
'selected AM AGC Zeitkonstante
'selected AM AGC time constant
Data "372,ap,as371"
'
'Announce118:
'Befehl 373 &H0175: --> Code 1A04
'selected non AM AGC Zeitkonstante
'selected non AM AGC time constant
Data "373;op, non AM AGC time comstant;1;14;1{off},13{0 to 6.0};lin;s"
'
'Announce119:
'Befehl 374 &H0176: --> Code 1A04
'selected non AM AGC Zeitkonstante
'selected non AM AGC time constant
Data "374,ap,as373"
'
'Announce120:
'Befehl 375 &H0177: --> Code 1A050003
'SSB TX bandwidth (lower edge) for wide
'SSB TX bandwidth (lower edge) for wide
Data "375;os,SB TX bandwidth (lower edge) for wide;1;0,100,1,200,2,500"
'
'Announce121:
'Befehl 376 &H0178: -->Code 1A050003
'SSB TX bandwidth (lower edge) for wide
'SSB TX bandwidth (lower edge) for wide
Data "376;as,as375"
'
'Announce122:
'Befehl 377 &H0179: --> Code 1A050004
'SSB TX bandwidth (high edge) for wide
'SSB TX bandwidth (high edge) for wide
Data "377;os,SSB TX bandwidth (high edge) for wide;1;0,2700,1,2800,2,2900"
'
'Announce123:
'Befehl 378 &H017A: -->Code 1A050004
'SSB TX bandwidth (high edge) for wide
'SSB TX bandwidth (high edge) for wide
Data "378;as,as377"
'
'Announce124:
'Befehl 379 &H017B: --> Code 1A0005
'SSB TX bandwidth (lower edge) for middle
'SSB TX bandwidth (lower edge) for middle
Data "379;os,SSB TX bandwidth (lower edge) for middle;1;0,10;1,200;2,300;3,500"
'
'Announce125:
'Befehl 380 &H017C: --> Code 01a0005
'SSB TX bandwidth (lower edge) for middle
'SSB TX bandwidth (lower edge) for middle
Data "380;as,as379"
'
'Announce126:
'Befehl 381 &H017D: --> Code 1A050006
'SSB TX bandwidth (high edge) for middle
'SSB TX bandwidth (high edge) for middle
Data "381;os,SSB TX bandwidth (high edge) for middle;1;0,2700;1,2800;2,2900"
'
'Announce127:
'Befehl 382 &H017E: --> Code 01a050006
'SSB TX bandwidth (high edge) for middle
'SSB TX bandwidth (high edge) for middle
Data "382;as,as381"
'
'Announce128:
'Befehl 383 &H017F: --> Code 1A050007
'SSB TX bandwidth (lower edge) for norrow
'SSB TX bandwidth (lower edge) for norrow
Data "383;osSSB TX bandwidth (lower edge) for norrow;1;0,100;1,200;2,300;3,500"
'
'Announce129:
'Befehl 384 &H0180: --> Code 01a050007
'SSB TX bandwidth (lower edge) for norrow
'SSB TX bandwidth (lower edge) for norrow
Data "384;as,as383"
'
'Announce130:
'Befehl 385 &H0181: --> Code 1A050008
'SSB TX bandwidth high edge) for norrow
'SSB TX bandwidth high edge) for norrow
Data "385;os,SSB TX bandwidth (high edge) for norrow;1;0,2700;1,2800;2,2900;3,500"
'
'Announce131:
'Befehl 386 &H0182: --> Code 01a050008
'SSB TX bandwidth high edge) for norrow
'SSB TX bandwidth high edge) for norrow
Data "386;as,as385"
'
'Announce132:
'Befehl 387 &H083: --> Code 1A050009
'Twin Peak Filter
'Twin Peak Filter
Data "387;os,Twin Peak Filter;1;0,off;1,on"
'
'Announce133:
'Befehl 388 &H0184: --> Code 1A050009
'Twin Peak Filter
'Twin Peak Filter
Data "388;as,as387"
'
'Announce134:
'Befehl 389 &H0185: --> Code 1A05010
'RTTY mark frequency
'RTTY mark frequency
Data "389;os,RTTY mark frequency;1;0,1275;1,1615;2,2125"
'
'Announce135:
'Befehl 390 &H0186: --> Code 1A050010
'RTTY mark frequency
'RTTY mark frequency
Data "390;as,as389"
'
'Announce136:
'Befehl 391 &H0187: --> Code 1A050011
'RTTY shift width
'RTTY shift width
Data "391;os,RTTY shift width;1;0,170;1,200;2,425"
'
'Announce137:
'Befehl 392 &H0188: --> Code 1A050011
'RTTY shift width
'RTTY shift width
Data "392;as,as391"
'
'Announce138:
'Befehl 3923 &H0189: --> Code 1A050012
'RTTY keying polarity
'RTTY keying polarity
Data "393;os,RTTY keying polarity;1;0,normal;1,reverse"
'
'Announce139:
'Befehl 394 &H018A: --> Code 1A050012
' RTTY keying polarity
' RTTY keying polarity
Data "394;as,as393"
'
'Announce140:
'Befehl 395 &H018B: --> Code 1A050013
'CW key speed
'CW key speed
Data "395;op,CW key speed;1;256,{0.6 to 60};lin;WPM"
'
'Announce141:
'Befehl 396 &H018C: --> Code 1A050013
'CW key speed
'CW key speed
Data "396;ap,as395"
'
'Announce142:
'Befehl 397 &H018D: --> Code 1A050014
'CW Pitch
'CW Pitch
Data "397;op,CW Pitch;1;121,{300 to 900};lin;Hz"
'
'Announce143:
'Befehl 398 &H018E: --> Code 1A050014
'CW Pitch
'CW Pitch
Data "398;ap,as397"
'
'Announce144:
'Befehl 399 &H018F: --> Code 1A050015
'CW side tone level
'CW side tone level
Data "399;op,CW side tone level;1;256;lin;-"
'
'Announce145:
'Befehl 400 &H0190: --> Code 01a050015
'CW side tone level
'CW side tone level
Data "400;ap,as399"
'
'Announce146:
'Befehl 401 &H0191: --> Code 1A050016
'CW side tone level limit
'CW side tone level limit
Data "401;os,CW side tone level limit;0;off;1,on"
'
'Announce147:
'Befehl 402 &H0192: --> Code 1A050016
'CW side tone level limit
'CW side tone level limit
Data "402;as,as401"
'
'Announce148:
'Befehl 403 &H0193: --> Code 1A050017
'LCD Kontrast
'LCD contrast
Data "403;op,LCDconbtrast;1;256;lin;-"
'
'Announce149:
'Befehl 404 &H0194: --> Code 1A050017
'LCD Kontrst
'LCD contrast
Data "404;ap,as403"
'
'Announce150:
'Befehl 405 &H0195: --> Code 1A050018
'LCD Helligkeit
'LCD brigt
Data "405;op,LCD flicker level;1;256;lin;-"
'
'Announce151:
'Befehl 406 &H0196: --> Code 1A050018
'LCD Helligkeit
'LCD bright
Data "406;ap,as405"
'
'Announce152:
'Befehl 407 &H0197: --> Code 1A050019
'LCD unit bright
'LCD unit bright
Data "407;op,LCD unit bright ;1;256;lin;-"
'
'Announce153:
'Befehl 408 &H0198: --> Code 1A050019
'LCD unit bright
'LCD unit bright
Data "408;ap,as407"
'
'Announce154:
'Befehl 409 &H0199: --> Code 1A050020
'LCD flicker level
'LCD flicker level
Data "409;op,LCD flicker level;1;256;lin;-"
'
'Announce155:
'Befehl 410 &H019A: --> Code 1A050020
'LCD flicker level
'LCD flicker level
Data "410;ap,as409"
'
'Announce156:
'Befehl 411 &H019B: --> Code 1A050021
'switch backlight
'switch backlight
Data "411;op,switch backlight;1;256;lin;-"
'
'Announce157:
'Befehl 412 &H019C: --> Code 01a050021
'switch backlight
'switch backlight
Data "412;ap,as411"
'
'Announce158:
'Befehl 413 &H019D: --> Code 1A050022
'display type
'display type
Data "413;os,display type;1;0,A;1,B;2,C"
'
'Announce159:
'Befehl 414 &H019E: --> Code 01a050022
'display type
'display type
Data "414;as,as413"
'
'Announce160:
'Befehl 415 &H019F: --> Code 1A050023
'display font type
'display font type
Data "415;os,display font type;1;0,basic;1,italic"
'
'Announce161:
'Befehl 416 &H01A0: --> Code 01A050023
'display font type
'display font type
Data "416;as,as415"
'
'Announce162:
'Befehl 417 &H01A1: --> Code 01A050024
'display font size
'display font size
Data "418;os,display font size;1;0,normal;1,large"

'Announce163:
'Befehl 418 &H01A2: --> Code 1A050024
'display font size
'display font size
Data "418;as,as417"
'
'Announce164:
'Befehl 419 &H01A3: --> Code 1A050025
'meter peak hold
'meter peak hold
Data "419;os,display font size;1;0,off;1,on"
'
'Announce165:
'Befehl 420 &H01A4: --> Code 1A050025
'meter peak hold
'meter peak hold
Data "420;as,as419"
'
'Announce166:
'Befehl 421  &H01A5: --> Code 1A050026
'filter pop up indication for PBT shifting
'filter pop up indication for PBT shifting
Data "421;os,filter pop up indication for PBT shifting;1;0,off;1,on"
'
'Announce167:
'Befehl 422 &H01A6: --> Code 1A050026
'filter pop up indication for PBT shifting
'filter pop up indication for PBT shifting
Data "422;as,as421"
'
'Announce168:
'Befehl 423 &H01A7: --> Code 1A050027
'pop up indication for IF filter setting
'pop up indication for IF filter setting
Data "423;os,pop up indication for IF filter setting;1;0,off;1,on"
'
'Announce169:
'Befehl 424 &H01A8: --> Code 1A050027
'pop up indication for IF filter setting
'pop up indication for IF filter setting
Data "424;as,as423"
'
'Announce170:
'Befehl 425 &H01A9: --> Code 1A050028
'pop up indication for 1 Hz mode
'pop up indication for 1 Hz mode
Data "425;os,pop up indication for 1 Hz mode;1;0,off;1,on"
'
'Announce171:
'Befehl 426 &H01AA: --> Code 1A050028
'pop up indication for 1 Hz mode
'pop up indication for 1 Hz mode
Data "426;as,as425"
'
'Announce172:
'Befehl 427 &H01AB: --> Code 1A050029
'pop up indication for scope center/fix
'pop up indication for scope center/fix
Data "427;os,pop up indication for scope center/fix;1;0,off;1,on"
'
'Announce173:
'Befehl 428 &H01AC: --> Code 1A050029
'pop up indication for scope center/fix
'pop up indication for scope center/fix
Data "428;as,as427"
'
'Announce174:
'Befehl 429 &H01AD: --> Code 1A 050030
'TV pop up indication for channel Up/Down
'TV pop up indication for channel Up/Down
Data "429;os,TV pop up indication for channel Up/Down;1;0,off;1,on"
'
'Announce175:
'Befehl 430 &H01AE: --> Code 1A 050030
'TV pop up indication for channel Up/Down
'TV pop up indication for channel Up/Down
Data "430;as,as429"
'
'Announce176:
'Befehl 431 &H01AF: --> Code 1A050031
'TV pop up indication for P.AMP/ATT
'TV pop up indication for P.AMP/ATT
Data "431;os,TV pop up indication for P.AMP/ATT;1;0,off;1,on"
'
'Announce177:
'Befehl 432 &H01B0: --> Code 1A050031 3 Byte / -
'TV pop up indication for P.AMP/ATT
'TV pop up indication for P.AMP/ATT
Data "432;as,as431"
'
'Announce178:
'Befehl 433 &H01B1: --> Code 1A050032
'indication of the voice TX memory channel names
'indication of the voice TX memory channel names
Data "433;os,indication of the voice TX memory channel names;1;0,off;1,on"
'
'Announce179:
'Befehl 434 &H01B2: --> Code 1A050032
'indication of the voice TX memory channel names
'indication of the voice TX memory channel names
Data "434;as,as433"
'
'Announce180:
'Befehl 435 &H01B3: --> Code 1A050033
'indication of the keyer memory names
'indication of the keyer memory names
Data "435;os,indication of the keyer memory names;1;0,off;1,on"
'
'Announce181:
'Befehl 436 &H01B4: --> Code 1A050033
'indication of the keyer memory names
'indication of the keyer memory names
Data "436;as,as435"
'
'Announce182:
'Befehl 437 &H01B5: --> Code 1A050034
'indication of the DTMF memory names
'indication of the DTMF memory names
Data "437;os,indication of the DTMF memory names;1;0,off;1,on"
'
'Announce183:
'Befehl 438 &H01B6: --> Code 1A050034
'indication of the DTindication of the DTMF memory names FM split offset HF
Data "438;as,as437"
'
'Announce184:
'Befehl 439 &H01B7: --> Code 1A050035
'external display setting
'external display setting
Data "439;os,external display setting;1;0,1:1.8;1,1:1.6"
'
'Announce185:
'Befehl 440 &H01B8: --> Code 1A050035
'external display setting
'external display setting
Data "440;as,as439"
'
'Announce186:
'Befehl 441 &H01B9: --> Code 1A050036
'opening message
'opening message
Data "441;os,opening message;1;0,off;1,on"
'
'Announce187:
'Befehl 442 &H01BA: --> Code 1A050036
'opening message
'opening message
Data "442;as,as441"
'
'Announce188:
'Befehl 443 &H01BB: --> Code 1A050037
'call sign
'call sign
Data "443;om,call sign;10,{A to Z, 1 to 9,-,/,.,@, "
'
'Announce189:
'Befehl 444 &H01BC: --> Code 1A050037
'call sign
'call sign
Data "444;as,as443"
'
'Announce190:
'Befehl 445 &H01BD: --> Code 1A050038
'power ON check
'power ON check
Data "445;os,power ON check;1;0,off;1,on"
'
'Announce191:
'Befehl 446 &H01BE: --> Code 1A050038
'power ON check
'power ON check
Data "446;as,as445"
'
'Announce192:
'Befehl 447 &H01BF: --> Code 1A050039
'Jahr
'current year
Data "447;op,current year;1;100{2000 to 2099};lin;year"
'
'Announce193:
'Befehl 448 &H01C0: --> Code 1A050039
'Jahr
'current year
Data "448;ap,as447"
'
'Announce194:
'Befehl 449 &H01C1: --> Code 1A050040
'current date
'current date
Data "449;op,current date;1;12,{1 to 12};lin;month;31,{1 to 31};lin;day"
'
'Announce195:
'Befehl 450 &H01C2: --> Code 1A050040
'current date
'current date
Data "450;ap,as449"
'
'Announce196:
'Befehl 451 &H01C3: --> Code 1A050041
'current time
'current time
Data "451;op,current time;1;24,{0 to 23};lin;hour;60,{0 to 59};lin;min"
'
'Announce197:
'Befehl 452 &H01C4: --> Code 1A050041
'current time
'current time
Data "452;ap,as451"
'
'Announce198:
'Befehl 453 &H01C5: --> Code 1A050042
'clock2 function
'clock2 function
Data "453;os,clock2 function;1;0,off;1,on"
'
'Announce199:
'Befehl 454 &H01C6: --> Code 1A050042
'clock2 function
'clock2 function
Data "454;as,as453"
'
'Announce200:
'Befehl 455 &H01C7: --> Code 1A050043
'offset time for clock2
'offset time for clock2
Data "455;op,offset time for clock2;1;2880{-24:00 to 24:00};lin;hour"
'
'Announce201:
'Befehl 456 &H01C8: --> Code 1A050043
'offset time for clock2
'offset time for clock2
Data "456;ap,as455"
'
'Announce202:
'Befehl 457 &H0C9: --> Code 1A050044
'auto power OFF period
'auto power OFF period
Data "457;os,auto power OFF period;1;0,off;1,30min;2,60min;3,90min"
'
'Announce203:
'Befehl 458 &H01CA: --> Code 1A050044
'auto power OFF period
'auto power OFF period
Data "458;as,as457"
'
'Announce204:
'Befehl 459 &H01CB: --> Code 1A050045
'TX monitor
'TX monitor
Data "459;os,TX monitor;1;0,off;1,on"
'
'Announce205:
'Befehl 460 &H01CC: --> Code 1A050045
'TX monitor
'TX monitor
Data "460;as,as459"
'
'Announce206:
'Befehl 461 &H01CD: --> Code 1A050046
'TX monitor gain
'TX monitor gain
Data "461;op,TX monitor gain;1;256;lin;-"
'
'Announce207:
'Befehl 4562 &H01CE: --> Code 1A050046
'TX monitor gain
'TX monitor gain
Data "462;ap,as4616"
'
'Announce208:
'Befehl 463 &H01CF: --> Code 1A050047
'confirmation beep
'confirmation beep
Data "463;os,confirmation beep;1;0,off;1,on"
'
'Announce209:
'Befehl 464 &H01D0: --> Code 1A050047
'confirmation beep
'confirmation beep
Data "464;as,as463"
'
'Announce210:
'Befehl 465 &H01D1: --> Code 1A050048
'band edge beep
'band edge beep
Data "465;os,confirmation beep;1;0,off;1,on"
'
'Announce211:
'Befehl 466 &H01D2: --> Code 1A050048
'band edge beep
'band edge beep
Data "466;as,as465"
'
'Announce212:
'Befehl 467 &H01D3: --> Code 1A050049
'beep gain
'beep gain
Data "467;op,beep gain;1;256;lin;-"
'
'Announce213:
'Befehl 468 &H01D4: --> Code 1A050049
'beep gain
'beep gain
Data "468;ap,as467"
'
'Announce214:
'Befehl 469 &H01D5: --> Code 1A050050
'beep gain limit
'beep gain limit
Data "469;os,beep gain limit;1;0,off;1,on"
'
'Announce215:
'Befehl 470 &H01D6: --> Code 1A050050
'beep gain limit
'beep gain limit
Data "470;as,as469"
'
'Announce216:
'Befehl 471 &H01D7: --> Code 1A050051
'RF/SQL control set
'RF/SQL control set
Data "471;os,RF/SQL control;1;0,auto;1,SQL;2,RF+SQL"
'
'Announce217:
'Befehl 472 &H01D8: --> Code 1A050051
'RF/SQL control set
'RF/SQL control set
Data "472;as,as471"
'
'Announce218:
'Befehl 473 &H0D9: --> Code 1A000052
'quick split
'quick split
Data "473;os,quick split;1;0,off;1,on"
'
'Announce219:
'Befehl 474 &H01DA. --> Code 1A050052
'quick split
'quick split
Data "474;as,as473"
'
'Announce220:
'Befehl 475 &H01DB: --> Code 1A050053
'split offset
'split offset
Data "475;op,split offset;1;20000,{-9.999 To 9.999};lin;KHz"
'
'Announce221:
'Befehl 476 &H01DC: --> Code 1A050053
'split offset
'split offset
Data "476;ap,as475"
'
'Announce222:
'Befehl 477 &H01DD: --> Code 1A050054
'split lock
'split lock
Data "477;os,quick split;1;0,off;1,on"
'
'Announce223:
'Befehl 478 &H01DE: --> Code 1A050054
'split lock
'split lock
Data "478;as,as477"
'
'Announce224:
'Befehl 479 &H01DF: --> Code 1A050055
'duplex offset HF
'duplex offset HF
Data "479;op,duplex offset HF;1;10000,{0 To 9.999};lin;MHz"
'
'Announce225:
'Befehl 480 &H01E0 Code 1A050055 3 Byte / -
'duplex offset HF
'duplex offset HF
Data "480;ap,as479"
'
'Announce226:
'Befehl 481 &H01E1: --> Code 1A050056
'duplex offset 50MHz
'duplex offset 50MHz
Data "481;op,duplex offset 50MHz;1;10000,{0 To 9.999};lin;MHz"
'
'Announce227:
'Befehl 482 &H01E2: --> Code 1A050056
'duplex offset 50MHz
'duplex offset 50MHz
Data "482;ap,as41"
'
'Announce228:
'Befehl 483 &H01E3: --> Code 1A050057
'duplex offset 144MHz
'duplex offset 144MHz
Data "483;op,duplex offset 144MHz;1;10000,{0 To 9.999};lin;MHz"
'
'Announce229:
'Befehl 484 &H01E4: --> Code1A 050057
'duplex offset 144MHz
'duplex offset 144MHz
Data "484;ap,as483"
'
'Announce230:
'Befehl 485 &H01E5: --> Code 1A050058
'duplex offset 430MHz
'duplex offset 430MHz
Data "485;op,duplex offset 430MHz;1;10000,{0 To 9.999};lin;MHz"
'
'Announce231:
'Befehl 486 &H01E6: --> Code 1A050058
'duplex offset 430MHz
'duplex offset 430MHz
Data "486;ap,as485"
'
'Announce232:
'Befehl 487 &H01E7: --> Code 1A050059
'one touch repeate
'one touch repeater
Data "487;os,one touch repeater;1;0,DUP-;1,DUP+"
'
'Announce233:
'Befehl 488 &H01E8: --> Code 1A050059
'one touch repeater
'one touch repeater
Data "488;as,as487"
'
'Announce234:
'Befehl 489 &H01E9: --> Code 1A050060
'auto repeater
'auto repeater
Data "489;os,auto repeater;1;0,off;1,on;2,on-2"
'
'Announce235:
'Befehl 490 &H01EA: --> Code 1A050060
'auto repeater
'auto repeater
Data "490;as,as489"
'
'Announce236:
'Befehl 491 &H01EB: --> Code 1A050061
'tuner auto start
'tuner auto start
Data "491;os,tuner auto start;1;0,off;1,on"
'
'Announce237:
'Befehl 492 &H01EC: --> Code 1A050061
'tuner auto start
'tuner auto start
Data "492;as,as491"
'
'Announce238:
'Befehl 493 &H01ED: --> Code 1A050062
'PTT tune
'PTT tune
Data "493;os,tuner auto start;1;0,off;1,on"
'
'Announce239:
'Befehl 494 &H01EE: --> Code 1A050062
'PTT tune
'PTT tune
Data "494;as,as493"
'
'Announce240:
'Befehl 495 &H01EF: --> Code 1A050063
'TUNER/CALL key action
'TUNER/CALL key action
Data "495;os,TUNER/CALL] key action;1;0,manual;1,auto"
'
'Announce241:
'Befehl 496 &H01F0: --> Code 1A050063
'TUNER/CALL key action
'TUNER/CALL key action
Data "496;as,as495"
'
'Announce242:
'Befehl 497 &H01F1: --> Code 1A050064
'ACC (pin 7) output VSEND
'ACC (pin 7) output VSEND
Data "497;os,ACC pin 7 output VSEND;1;0,off;1,UHF only;2,on"
'
'Announce243:
'Befehl 498 &H01F2: --> Code 1A050064
'ACC (pin 7) output VSEND
'ACC (pin 7) output VSEND
Data "498;as,as497"
'
'Announce244:
'Befehl 499 &H01F3: --> Code 1A050065
'speech level
'speech level
Data "499;op,speech level;1;256;lin;-"
'
'Announce245:
'Befehl 500 &H01F4: --> Code 1A000065
'speech level
'speech level
Data "500;ap,as499"
'
'Announce246:
'Befehl 501 &H01F5: --> Code 1A050066
'speech language
'speech language
Data "501;os,speech language;1;0,japanese;1,english"
'
'Announce247:
'Befehl 502 &H01F6: --> Code 1A050066
'speech language
'speech language
Data "502;as,as501"
'
'Announce248:
'Befehl 503 &H01F7: --> Code 1A050067
'speech speed
'speech speed
Data "503;os,speech speed;1;0,slow;1,fast"
'
'Announce249:
'Befehl 504 &H01F8: --> Code 1A050067
'speech speed
'speech speed
Data "504;as,as503"
'
'Announce250:
'Befehl 505 &H01F9: --> Code 1A050068
'S-level speech
'S-level speech
Data "505;os,S-level speech;1;0,off;1,on"
'
'Announce251:
'Befehl 506 &H01FA: --> Code 1A050068
'S-level speech
'S-level speech
Data "506;as,as505"
'
'Announce252:
'Befehl 507 &H01FB: --> Code 1A050069
'speech capability with MODE key operation
'speech capability with MODE key operation
Data "507;os,speech capability with MODE key operation;1;0,off;1,on"
'
'Announce253:
'Befehl 508 &H01FC: --> Code 1A050069
'speech capability with MODE key operation
'speech capability with MODE key operation
Data "508;as,as507"
'
'Announce254:
'Befehl 509 &H01FD: --> Code 1A050070
'memopad numbers
'memopad numbers
Data "509;os,memopad numbers;1;0,off;1,on"
'
'Announce255:
'Befehl 510 &H01FE: --> Code 1A050070
'memopad numbers
'memopad numbers
Data "510;as,as509"
'
'Announce256:
'Befehl 511 &H01FF: --> Code 1A050071
'scan speed
'scan speed
Data "511;os,scan speed;1;0,low;1,high"
'
'Announce257:
'Befehl 512 &H0200: --> Code 1A050071
'scan speed
'scan speed
Data "512;as,as511"
'
'Announce258:
'Befehl 513 &H0201: --> Code 1A050072
'scan resume
'scan resume
Data "513;os,scan resume;1;0,off;1,on"
'
'Announce259:
'Befehl 514 &H0202: --> Code 1A050072
'scan resume
'scan resume
Data "514;as,as513"
'
'Announce260:
'Befehl 515 &H0203: --> Code 1A050073
'main dial auto TS
'main dial auto TS
Data "515;os,main dial auto TS;1;0,off;1,on"
'
'Announce261:
'Befehl 516 &H0204: --> Code 1A050073
'main dial auto TS
'main dial auto TS
Data "516;as,as516"
'
'Announce262:
'Befehl 517 &H0205: --> Code 1A050074
'F-1 key assigment of the HM-151
'F-1 key assigment of the HM-151
Data "517;os,F-1 key assigment of the HM151;1;0,PAMPATT;1,NB;2,NR;3,MNF;4,ANF;5,TS;6,SPL;7,AB"
Data "517;os;8,MCL;9,BNK;10,COM;11,AGC;12,TBW;13,DUP;14,TON;15,MET;16,VSC;17,MPW;18MPR;19,SCOPE;20,METER"
'
'Announce263:
'Befehl 518 &H0206: --> Code 1A050074
'F-1 key assigment of the HM-151
'F-1 key assigment of the HM-151
Data "518;as,as517"
'
'Announce264:
'Befehl 519 &H0207: --> Code 1A050075
'F-2 key assigment of the HM-151
'F-2 key assigment of the HM-151
Data "519;os,F-2 key assigment of the HM151;1;0,PAMPATT;1,NB;2,NR;3,MNF;4,ANF;5,TS;6,SPL;7,AB"
Data "519;os;8,MCL;9,BNK;10,COM;11,AGC;12,TBW;13,DUP;14,TON;15,MET;16,VSC;17,MPW;18MPR;19,SCOPE;20,METER"
'
'Announce265:
'Befehl 520 &H0208: --> Code 1A050075
'F-2] key assigment of the HM-151
'F-2] key assigment of the HM-151
Data "520;as,as519"
'
'Announce266:
'Befehl 521 &H0209: --> Code 1A050076
'mic. up/down speed
'mic. up/down speed
Data "521;os,mic. up/down speed;1;0,low;1,high"
'
'Announce267:
'Befehl 522 &H020A: --> Code 1A050076
'mic. up/down speed
'mic. up/down speed
Data "522;as,as521"
'
'Announce268:
'Befehl 523 &H020B: --> Code 1A050077
'quick RIT/?TX clear
'quick RIT/?TX clear
Data "523;os,quick RIT/?TX clear;1;0,off;1,on"
'
'Announce269:
'Befehl 524 &H020C: --> Code 1A050077
'quick RIT/?TX clear
'quick RIT/?TX clear
Data "524;as,as523"
'
'Announce270:
'Befehl 525 &H020D: --> Code 1A05000078
'SSB/CW synchronous tuning function
'SSB/CW synchronous tuning function
Data "525;os,SSB/CW synchronous tuning function;1;0,off;1,on"
'
'Announce271:
'Befehl 526 &H020E: --> Code 1A050078
'SSB/CW synchronous tuning function
'SSB/CW synchronous tuning function
Data "526;as,as525"
'
'Announce272:
'Befehl 527 &H020F: --> Code 1A050079
'CW normal side
'CW normal side
Data "527;os,CW normal side;1;0,LSB;1,USB"
'
'Announce273:
'Befehl 528 &H0210: --> Code 1A050079
'CW normal side
'CW normal side
Data "528;as,as527"
'
'Announce274:
'Befehl 529 &H0211. --> Code 1A050080
'voice recorder
'voice recorder
Data "529;os,voice recorder;1;0,root;1,RX/TX"
'
'Announce275:
'Befehl 530 &H0212: --> Code 1A050080
'voice recorder
'voice recorder
Data "530;as,as529"
'
'Announce276:
'Befehl 531 &H0213: --> Code 1A050081
'keyer 1st menu
'keyer 1st menu
Data "531;os,keyer 1st menu;1;0,root;1,keyer"
'
'Announce277:
'Befehl 532 &H0214: --> Code 1A050081
'keyer 1st menu
'keyer 1st menu
Data "532;as,as531"
'
'Announce278:
'Befehl 533 &H0215: --> Code 1A050082
'DTMF 1st menu
'DTMF 1st menu
Data "533;os,DTMF 1st menu;1;0,root;1,DTMF"
'
'Announce279:
'Befehl 534 &H0216: --> Code 1A050082
'DTMF 1st menu
'DTMF 1st menu
Data "534;as,as533"
'
'Announce280:
'Befehl 535 &H0217: --> Code 1A050083
'SSB mode selectability
'SSB mode selectability
Data "535;os,SSB mode selectability;1;0,inhibit;1,selectable"
'
'Announce281:
'Befehl 536 &H02018: --> Code 1a050083
'SSB mode selectability
'SSB mode selectability
Data "536;as,as535"
'
'Announce282:
'Befehl 537 &H0219: --> Code 1A050084
'CW mode selectability
'CW mode selectability
Data "537;os,CW mode selectability;1;0,inhibit;1,selectable"
'
'Announce283:
'Befehl 538 &H021A: --> Code 1a050084
'CW mode selectability
'CW mode selectability
Data "538;as,as537"
'
'Announce284:
'Befehl 539 &H021B: --> Code 1A050085
'RTTY mode selectability
'RTTY mode selectability
Data "539;os,RTTY mode selectability;1;0,inhibit;1,selectable"
'
'Announce285:
'Befehl 540 &H021C: --> Code 1A050085
'RTTY mode selectability
'RTTY mode selectability
Data "540;as,as539"
'
'Announce286:
'Befehl 541 &H021D: --> Code 1A050086
'AM mode selectability
'AM mode selectability
Data "541;os,AM mode selectability;1;0,inhibit;1,selectable"
'
'Announce287:
'Befehl 542 &H021E: --> Code 1A050086
'AM mode selectability
'AM mode selectability
Data "542;as,as541"
'
'Announce288:
'Befehl 543 &H021F: --> Code 1A050087
'FM mode selectability
'FM mode selectability
Data "543;os,FM mode selectability;1;0,inhibit;1,selectable"
'
'Announce289:
'Befehl 544 &H0220: --> Code 1A050087
'FM mode selectability
'FM mode selectability
Data "544;as,as543"
'
'Announce290:
'Befehl 545 &H0221: --> Code 1A050088
'WFM mode selectability
'WFM mode selectability
Data "545;os,WFM mode selectability;1;0,inhibit;1,selectable"
'
'Announce291:
'Befehl 546 &H0222: --> Code 1A050088
'WFM mode selectability
'WFM mode selectability
Data "546;as,as545"
'
'Announce292:
'Befehl 547 &H0223: --> Code 1A050089
'external keypad for voice memory
'external keypad for voice memory
Data "547;os,external keypad for voice memory;1;0,off;1,on"
'
'Announce293:
'Befehl 548 &H0224: --> Code 1A050089
'external keypad for voice memory
'external keypad for voice memory
Data "548;as,as547"
'
'Announce294:
'Befehl 549 &H0225: --> Code 1A00090
'external keypad for keyer memory
'external keypad for keyer memory
Data "549;os,external keypad for keyer memory;1;0,off;1,on"
'
'Announce295:
'Befehl 550 &H0226: --> Code 1A00090
'external keypad for keyer memory
'external keypad for keyer memory
Data "550;as,as549"
'
'Announce296:
'Befehl 551 &H0227: --> Code 1A050091
'external keypad type connected to [MIC] connector of controller
'external keypad type connected to [MIC] connector of controller
Data "551;os,external keypad type connected to MIC connector of controller;1;0,DOT_DASH;1,EXT"
'
'Announce297:
'Befehl 552 &H0228: --> Code 1A050091
'external keypad type connected to [MIC] connector of controller
'external keypad type connected to [MIC] connector of controller
Data "552;as,as551"
'
'Announce298:
'Befehl 553 &H0229: --> Code 1A050092
'CI-V transceive
'CI-V transceive
Data "553;os,CI-V transceive;1;0,off;1,on"
'
'Announce299:
'Befehl 554 &H022A: --> Code 1A050092
'CI-V transceive
'CI-V transceive
Data "554;as,as553"
'
'Announce300:
'Befehl 555 &H022B: --> Code 1A050093
'reference frequency
'reference frequency
Data "555;op,reference frequency;1;256;lin;-"
'
'Announce301:
'Befehl 556 &H022C: --> Code 1A050093
'reference frequency
'reference frequency
Data "556;ap,as555"
'
'Announce302:
'Befehl 557 &H022D: --> Code 1A050094
'speech compresser level
'speech compresser level
Data "557;op,speech compresser level;1;11;lin;-"
'
'Announce303:
'Befehl 558 &H022E: --> Code 1A050094
'speech compresser level
'speech compresser level
Data "558;ap,as557"
'
'Announce304:
'Befehl 559 &H022F: --> Code 1A050095
'auto voice monitor
'auto voice monitor
Data "559;os,auto voice monitor;1;0,off;1,on"
'
'Announce305:
'Befehl 560 &H0230: --> Code 1A050095
'auto voice monitor
'auto voice monitor
Data "560;as,as559"
'
'Announce306:
'Befehl 561 &H0231: --> Code 1A050096
'MIC memo function
'MIC memo function
Data "561;os,MIC memo function;1;0,off;1,on"
'
'Announce307:
'Befehl 562 &H0232: --> Code 1A050096
'MIC memo function
'MIC memo function
Data "562;as,as561"
'
'Announce308:
'Befehl 563 &H0233: --> Code 1A050097
'contest number style
'contest number style
Data "563;os,contest number style;1;0,normal;1,190ANO;2,190ANT;3,90NO;4,90NT"
'
'Announce309:
'Befehl 564 &H0234: --> Code 1A050097
'contest number style
'contest number style
Data "564;as,as563"
'
'Announce310:
'Befehl 565 &H0235: --> Code 1A050098
'up trigger channel
'up trigger channel
Data "565;os,up trigger channel;1;0,M1;1,M2;2,M3;3,M4"
'
'Announce311:
'Befehl 566 &H036: --> Code 1A050098
'up trigger channel
'up trigger channel
Data "566;as,as565"
'
'Announce312:
'Befehl 567 &H0237: --> Code 1A050099
'present number
'present number
Data "567;op,present number;1;9999,{1 to 9999};lin;-"
'
'Announce313:
'Befehl 568 &H0238: --> Code 1A050099
'present number
'present number
Data "568;ap,as567"
'
'Announce314:
'Befehl 569 &H0239: --> Code 1A050100
'CW keyer repeat time
'CW keyer repeat time
Data "569;op,CW keyer repeat time;1;60{1 to 60};lin;sec"
'
'Announce315:
'Befehl 570 &H023A Code 1A050100 3 Byte / -
'CW keyer repeat time
'CW keyer repeat time
Data "570;ap,as569"
'
'Announce316:
'Befehl 571 &H0233B: --> Code 1A050101
'CW keyer dot/dash
'CW keyer dot/dash
Data "571;op,CW keyer dot/dash;1;18{2.8 To 4.5};lin;sec"
'
'Announce317:
'Befehl 572 &H023C Code 1A050101 3 Byte / -
'CW keyer dot/dash
'CW keyer dot/dash
Data "572;ap,as571"
'
'Announce318:
'Befehl 573 &H023D: --> Code 1A050102
'rise time
'rise time
Data "573;os,rise time;1;0,2;1,4;2,6;3,8"
'
'Announce319:
'Befehl 574 &H023E: --> Code 1A050102
'rise time
'rise time
Data "574;as,as573"
'
'Announce320:
'Befehl &575 H023F: --> Code 1A050103
'CW paddle polarity
'CW paddle polarity
Data "575;os,CW paddle polarity;1;0,normal,1,reverse"
'
'Announce321:
'Befehl 576 &H0240: --> Code 1A050103
'CW paddle polarity
'CW paddle polarity
Data "576;as,as575"
'
'Announce322:
'Befehl 577 &H0241: --> Code 1A050104
'CW keyer type
'CW keyer type
Data "577;os,CW keyer type;1;0,straight;1,BUG;2,EL"
'
'Announce323:
'Befehl 578 &H0242: --> Code 1A050104
'CW keyer type
'CW keyer type
Data "578;as,as577"
'
'Announce324:
'Befehl 579 &H0243: --> Code 1A050105
'MIC up/down keyer (HM-103)
'MIC up/down keyer (HM-103)
Data "579;os,MIC up/down keyer HM-103;1;0,off;1,on"
'
'Announce325:
'Befehl 580 &H0244: --> Code 1A050105
'MIC up/down keyer (HM-103)
'MIC up/down keyer (HM-103)
Data "580;as,as579"
'
'Announce326:
'Befehl 581 &H0245: --> Code 1A050106
'RTTY decode USOS
'RTTY decode USOS
Data "581;os,RTTY decode USOS;1;0,off;1,on"
'
'Announce327:
'Befehl 582 &H0246: --> Code 1A050106
'RTTY decode USOS
'RTTY decode USOS
Data "582;as,as581"
'
'Announce328:
'Befehl 583 &H0247: --> Code 1A050107
'RTTY decode new line code
'RTTY decode new line code
Data "583;os,RTTY decode new line code;1;0,CR.CR+LF.LF;1,CR+LF"
'
'Announce329:
'Befehl 584 &H0248: --> Code 1A050107
'RTTY decode new line code
'RTTY decode new line code
Data "584;as,as583"
'
'Announce330:
'Befehl585  &H0249: --> Code 1A050108
'scope max. hold
'scope max. hold
Data "585;os,scope max. hold;1;0,off;1,on"
'
'Announce331:
'Befehl 586 &H024A: --> Code 1A050108
'scope max. hold
'scope max. hold
Data "586;as,as585"
'
'Announce332:
'Befehl 587 &H024B: --> Code 1A050109
'scope size
'scope size
Data "587;os,scope size;1;0,normal;1,wide"
'
'Announce333:
'Befehl 588 &H024C: --> Code 1A050109
'scope size
'scope size
Data "588;as,as587"
'
'Announce334:
'Befehl 589 &H024D: --> Code 1A050110
'fast sweep
'fast sweep
Data "589;os,fast sweep;1;0,1 sweep;1,continous"
'
'Announce335:
'Befehl 690 &H024E: --> Code 1A050110
'fast sweep
'fast sweep
Data "590;as,as589"
'
'Announce336:
'Befehl 591 &H024F: --> Code 1A05011
'fast sweep audio level
'fast sweep audio level
Data "591;os,fast sweep audio level;1;0,0dB;1,-10dB;2,off"
'
'Announce337:
'Befehl 592 &H0250: --> Code 1A050111
'fast sweep audio level
'fast sweep audio level
Data "592;as,as591"
'
'Announce338:
'Befehl 593 &H0251: --> Code 1A050112
'NB level
'NB level
Data "593;op,NB level;1;255;lin;-"
'
'Announce339:
'Befehl 294  &H0252: --> Code 1A050112
'NB level
'NB level
Data "594;ap,as593"
'
'Announce340:
'Befehl 595 &H0253: --> Code 1A050113
'NB width
'NB width
Data "595;op,NB width;1;255;lin;-"
'
'Announce341:
'Befehl 596 &H0254:--> Code 1A050113
'NB width
'NB width
Data "596;ap,as595"
'
'Announce342:
'Befehl 597 &H0255: --> Code 1A050114
'NR level
'NR level
Data "597;op,NR level;1;16;lin;-"
'
'Announce343:
'Befehl 598 &H0256: --> Code 1A050114
'NR level
'NR level
Data "598;ap,as597"
'
'Announce344:
'Befehl 599 &H0257: --> Code 1A050115
'VOX gain
'VOX gain
Data "599;op,VOX gain;1;256;lin;-"
'
'Announce345:
'Befehl 600 &H0258: --> Code 1A050115
'VOX gain
'VOX gain
Data "600;ap,as599"
'
'Announce346:
'Befehl 601 &H0259: --> Code 1A050116
'anti VOX gain
'anti VOX gain
Data "601;op,anti VOX gain;1;256,{0 To 100};lin;%"
'
'Announce347:
'Befehl 602 &H025A Code 1A050116
'anti VOX gain
'anti VOX gain
Data "602;ap,as601"
'
'Announce348:
'Befehl 603 &H025B: --> Code 1A050117
'VOX delay
'VOX delay
Data "603;op,VOX delay;1;21,{0.0 To 2.0};lin;sec"
'
'Announce349:
'Befehl 604 &H025C: --> Code 1A050117
'VOX delay
'VOX delay
Data "604;ap,as603"
'
'Announce350:
'Befehl 605 &H025D: --> Code 1A050118
'DTMF speed
'DTMF speed
Data "605;os,DTMF speed;1;0,100ms;1,200ms;2,300ms;3,500ms"
'
'Announce351:
'Befehl 606 &H025E: --> Code 1A050118
'DTMF speed
'DTMF speed
Data "606;as,as605"
'
'Announce352:
'Befehl 607 &H025F: --> Code 1A050119
'Break-IN delay
'Break-IN delay
Data "607;op,Break-IN delay;1;111,{2.0 To 13.0};lin;-"
'
'Announce353:
'Befehl 608 &H0260: --> Code 1A050119
'Break-IN delay
'Break-IN delay
Data "608;ap,as607"
'
'Announce354:
'Befehl 609 &H0261: --> Code 1A06
'SSB transmit bandwidth
'SSB transmit bandwidth
Data "609;os,SSB transmit bandwidth;1;0,wide;1,mid;2,narrow"
'
'Announce355:
'Befehl 610 &H0262: --> Code 1A06
'SSB transmit bandwidth
'SSB transmit bandwidth
Data "610;as,as609"
'
'Announce356:
'Befehl 611 &H0263: --> Code 1A07
'DSP filter shape
'DSP filter shape
Data "611;os,DSP filter shape;1;0,sharp;1,soft"
'
'Announce357:
'Befehl 612 &H0264: --> Code 1A07
'DSP filter shape
'DSP filter shape
Data "612;as,as611"
'
'Announce358:
'Befehl 613 &H0265: --> Code 1A08
'manual notch filter1 bandwidth
'manual notch filter1 bandwidth
Data "613;os,manual notch filter1 bandwidth;1;0,wide;1,mid;2,narrow"
'
'Announce359:
'Befehl 614 &H0266: --> Code 1A08
'manual notch filter1 bandwidth
'manual notch filter1 bandwidth
Data "614;as,as613"
'
'Announce360:
'Befehl 615 &H0267: --> Code 1A09
'manual notch filter2 bandwidth
'manual notch filter2 bandwidth
Data "615;os,manual notch filter2 bandwidth;1;0,wide;1,mid;2,narrow"
'
'Announce361:
'Befehl 616 &H0268: --> Code 1A09
'manual notch filter2 bandwidth
'manual notch filter2 bandwidth
Data "616;as,as615"
'
'Announce362:
'Befehl 617 &H0269: --> Code 1A0A
'9600 bps mode
'9600 bps mode
Data "617;os,9600 bps mode;1;0,off;1,on"
'
'Announce363:
'Befehl 618 &H026A: --> Code 1A0A
'9600 bps mode
'9600 bps mode
Data "618;as,as617"
'
'Announce364:
'Befehl 619 &H026B: --> Code 1A1B00
'repeater tone frequency
'repeater tone frequency
Data "619;op,repeater tone frequency;1;4000,{0 To 399.9};lin;Hz"

'Announce365:
'Befehl 620 &H026C: --> Code 1A1B00
'repeater tone frequency
'repeater tone frequency
Data "620;ap,as619"
'
'Announce366:
'Befehl 621 H026D: --> Code 1A1B01
'TSQL tone frequency
'TSQL tone frequency
Data "621;op,TSQL tone frequency;1;4000,{0.1 To 399.9};lin;Hz"
'
'Announce367::
'Befehl 622 &H026E: --> Code 1A1B01
'TSQL tone frequency
'TSQL tone frequency
Data "622;ap,as621"
'
'Announce368:
'Befehl 623 &H026F: --> Code 1A1B02
'DTCSS tone frequency
'DTCSS tone frequency
Data "623;op,DTCS tone frequency;1;256;lin;-"
'
'Announce369:
'Befehl 624  &H0270: --> Code 1A1B02
'DTCSS tone frequency
'DTCSS tone frequency
Data "624;ap,as623"
'
'Announce370:
'Befehl 625 &H0271: --> Code 1A1B02
'DTCSS tone polarity
'DTCSS tone polarity
Data "625;op,DTCS tone polarity;2,{transmit, receive};0,normal;1,reverse;0,normal;1,rverse;0,normal;1,reverse;0,normal;1,rverse"
'
'Announce371:
'Befehl 626 &H0272: --> Code 1A1B02
'DTCSS tone polarity
'DTCSS tone polarity
Data "626;as,as625"
'
'Announce372:
'Befehl 627 &H0273: --> Code 1A1C00
'transceiver’s condition
'transceiver’s condition
Data "627;os,transceivers condition;1;0,RX;1,TX"
'
'Announce373:
'Befehl 628 &H0274: --> Code 1A1C00
'transceiver’s condition
'transceiver’s condition
Data "628;as,as621"
'
'Announce374:
'Befehl 629 &H0275: --> Code 1A050151
'antenna tuner condition
'antenna tuner condition
Data "629;os,antenna tuner condition;1;0,off;1,on;2,start tuning"
'
'
'Announce375:
'Befehl 630 &H0276: --> Code 1A050152
'antenna tuner condition
'antenna tuner condition
Data "630;as,as629"
'
'Announce376:
'Befehl  65520 &Hfff0
'liest announcements
'read n announcement lines
Data "65520;ln,ANNOUNCEMENTS;175;545"
'
'Announce377:                                                  '
'Befehl 65532 &Hfffc
'Liest letzten Fehler
'read last error
Data "65532;aa,LAST ERROR;20,last_error"
'
'Announce378:                                                  '
'Befehl 65533 &Hfffd
'Geraet aktiv Antwort
'Life signal
Data "65533;aa,MYC INFO;b,ACTIVE"
'
'Announce379:
'Befehl 65534 &HFFFE <n><data>
'eigene Individualisierung schreiben
'write individualization
Data "65534;ka,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,32,{0 to 127};a,SERIAL,1"
'
'Announce379:
'Befehl 65535  &FFHFF <n>
'eigene Individualisierung lesen
'read individualization
Data "65535;la,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,32,{0 to 127};a,SERIAL,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1"