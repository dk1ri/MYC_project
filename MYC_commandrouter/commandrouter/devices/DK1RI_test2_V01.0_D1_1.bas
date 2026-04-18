' announcements
' 20260225
'
Announce:
DATA "0;m;DK1RI;test2;V01.0;1;145;1;84;1-1"
1;as,mode;1;0,off;1,V;2,I;3,P;4,R;5,calibrate V;6,calibrate I
2;as,mode;6;0,off;3,V;2,I;3,P;4,R;5,calibrate V;6,calibrate I
3;ar,on off mode;1;0,off;1,regulated;2,fixed;3,x
4;ar,on off mode;5;0,off;1,regulated;2,fixed;3,e;4,w>>
5;ap,required voltage;1;896;lin;V
7;ap,required voltage;5;896;lin;V
8;ap,x;1;15,;lin;A;20;lin;B
9;ap,y;5;15,;lin;A;20;lin;B
10;aa,10;i
11;aa,11;a;b;w
12;aa,12;20
13;aa,13;20;10;i
14;aa,14;a;a
15;aa,15;5
16;aa,16;b,;a,
17;aa,17;i;w,
18;aa,18;e
19;aa,19;L;s
20;aa,20;d;d;d,
21;aa,21;250,yyy;b,
22;aa,22;3;2
23;aa,23;b
24;aa,24;b;e,yyy;b
25;aa,25;2;5;4;6
26;ab,26;a
27;ab,27;5,
28;ab,28;a;b
29;ab,29;5;w
30;ab,30;e;5;b;3;w;a
31;ab,31;b
32;ab,32;5;b
33;ab,33;b;e,yyy;b;w
34;af,34;a;3
35;af,35;b;250,yyy
36;af,36;w,;120
37;af,37;w,;120
38;af,38;b;3
39;af,39;L;4
40;af,40;s;4
41;af,41;d;10,xxx
42;am,42;a;3
43;am,43;b;250,yyy
44;am,44;i;3
45;am,45;w;3
46;am,46;e;3
47;am,47;L;256
48;am,48;s;65536
49;am,49;d;257,xxx
50;am,50;d;257,xxx
51;am,51;4,;4,
52;am,52;b,;257
53;am,53;a;3
54;am,54;b;257,yyy
55;an,55;a;5;5
56;an,56;b;3;3
57;an,57;i;100;100
58;an,58,;w;100,;100,
59;an,59;3;3,;3
60;an,60,;3;2;2
61;an,61;b;5;5
62;an,62;10;2;2
63;ap,63;1;100;lin;Hz,unit;1000,{100 to 4000};log;Hz;10;lin;Hz;3,CHAPTER,123
65;ap,65;2;100;lin;Hz,unit;1000,{100 to 4000};log;Hz;10;lin;Hz
68;ap,68;1;1000;lin;Hz;1000;lin;Hz
69;ar,69;1;0,on,;4,CHAPTER,edrf
70;ar,70;1;0,on,;4,CHAPTER,edrf
71;ar,71;1;0,on;1,aus;2,idle;3,other
72;ar,72;2;0,on;1,aus;2,idle;3,other
73;as,73;1;0,on;1,aus
74;as,74;1;0,on;1,aus;2,idle;3,other
75;as,75;2;0,on;1,aus;2,idle;3,other80
L;text5,Text6
'
'Befehl &HF0
'announcement aller Befehle lesen
'read announcement lines
'
Data "240;an,ANNOUNCEMENTS;100;84,start;84,elements;22,CHAPTER,ADMINISTRATION"
'Befehl &HF6 :
'Uebertragungsparamter schreiben
'write communication parameters
Data "246;oa,COM;b,RS232_BAUD,0,{19k20,48k4,115k};3,RS23_BITS,8n1;b,RADIO_TYPE,,1,{no,Lora,wlan,rfya689,nrf25,bluetooth};4,RADIO_NAME,,radix;b,I2CADRESS,28;22,CHAPTER,ADMINISTRATION"
'
'Befehl &HF7 :
'Uebertragungsparamter lesen
'read communication parameters
Data "247;aa,as246"
'                                                 '
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
'                                              '
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
'Befehl &HFE
'eigene Individualisierung schreiben
'write individualization
Data "254;oa,INDIVIDUALIZATION;20,NAME,D1;b,NUMBER,1;a,RS232,1;a,USB,1;a,RADIO,4;a,I2C,1;22,CHAPTER,ADMINISTRATION"
'

'Befehl &HFF
'eigene Individualisierung lesen
'read individualization
Data "255;aa,as254"
'