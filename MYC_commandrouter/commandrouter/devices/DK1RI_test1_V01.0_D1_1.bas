DATA "0;m;DK1RI;test1;V01.0;1;145;1;134;1-1"
1;os,mode;1;0,off;1,V;2,I;3,P;4,R;5,calibrate V;6,calibrate I
2;as,as1
3;os,mode;6;0,off;3,V;2,I;3,P;4,R;5,calibrate V;6,calibrate I
4;as,as3
5;or,on off mode;1;0,off;1,regulated;2,fixed;3,x
6;ar,as5
7;or,on off mode;5;0,off;1,regulated;2,fixed;3,e;4,w>>
8;ar,as7
9;op,required voltage;1;896;lin;V
10;ap,as9
11;oo,ext5;1;12,steps;10,size;12,time;a;5,LIMIT;sec
12;op,required voltage;5;896;lin;V
13;ap,as12
14;op,x;1;15,;lin;A;20;lin;B
15;ap,as14
16;op,y;5;15,;lin;A;20;lin;B
17;ap,as16
18;oa,10;i
19;aa,as18
20;oa,20;a;b;w
21;aa,as20
22;oa,22;20
23;aa,as22
24;oa,24;20;10;i
25;aa,as24
27;oa,27;a;a
28;oa,28;5
29;oa,29;b,;a,
30;oa,30;i;w,
31;oa,31;e
32;oa,32;L;s
33;oa,33;d;d;d,
34;oa,34;250,yyy;b,
35;oa,35;3;2
36;aa,36;b
37;aa,37;b;e,yyy;b
38;aa,38;2;5;4;6
39;ob,39;a
40;ob,40;5,
41;ob,41;a;b
42;ob,42;5;w
43;ob,43;e;5;b;3;w;a
44;ab,44;b
45;ab,45;5;b
46;ab,46;b;e,yyy;b;w
47;of,47;a;3
48;of,48;b;250,yyy
49;of,49;w,;120
50;of,50;w,;120
51;of,51;b;3
52;af,52;L;4
53;af,53;s;4
54;af,54;d;10,xxx
55;om,55;a;3
56;om,56;b;250,yyy
57;om,78;i;3
58;om,89;w;3
59;om,590;e;3
60;om,60;L;256
61;om,61;s;65536
62;om,62;d;257,xxx
63;om,63;d;257,xxx
64;om,64;4,;4,
65;am,65;b,;257
66;am,66;a;3
67;am,67;b;257,yyy
68;on,68;a;5;5
69;on,68;b;3;3
70;on,70;i;100;100
71;on,71,;w;100,;100,
72;on,72;3;3,;3
73;an,73,;3;2;2
74;an,74;b;5;5
75;an,75;10;2;2
76;op,76;1;100;lin;Hz,unit;1000,{100 to4000};log;Hz;10;lin;Hz;3,CHAPTER,123
77;ap,as76
78;oo,ext63;1;9,steps;9,stepsize;100,time;a;4,LOOP;unit;9,steps;9,stepsize;100,time;a;4,LOOP;unit;9,steps;9,stepsize;100,time;a;4,LOOP;unit
79;op,79;2;100;lin;Hz,unit;1000,{100 to 4000};log;Hz;10;lin;Hz
80;ap,as79
81;oo,ext65;2;40,steps;10,stepsize;100,time;a;4,LOOP;unit;40,steps;10,stepsize;100,time;a;4,LOOP;unit;5,steps;5,stepsize;100,time;a;4,LOOP;unit
82;ap,82;1;1000;lin;Hz;1000;lin;Hz
83;or,83;1;0,on,;4,CHAPTER,edrf
84;or,84;1;0,on,;4,CHAPTER,edrf
85;or,85;1;0,on;1,aus;2,idle;3,other
86;or,86;2;0,on;1,aus;2,idle;3,other
87;os,87;1;0,on;1,aus
88;os,88;1;0,on;1,aus;2,idle;3,other
89;os,89;2;0,on;1,aus;2,idle;3,other80
90;ar,90;1;0,on;1,off
91;aa,91;12
R;!$1 !$3 !$5 IF 2=1
R;!$~ IF 4=1=1
R;!!$~ IF 4=0=0
R;!$20 IF 2=1
R;!$20 IF 4=4=1
R;!$20 IF 4<3=1
R;!$22 IF 4>3=1
R;!$22 IF 4!3=1
R;!$24 IF 4=~=1
R;!$22 IF 4=1TO2=1
R;!$24 IF 6=2=1
R;!$24 UNLESS 6=2=1
R;!$24 IF 8=4=3=1
R;!$20 IF 8<2=3=1
R;!$20 IF 8=3<2=1
R;!$22 IF 8>2=3=1
R;!$22 IF 8=3>2=1
R;!$24 IF 8!2=3=1
R;!$20 IF 8=2TO4=3=1
R;!$20 IF 8=4=2TO3=1
R;!$20 IF 10=10
R;!$20 IF 10=200
R;!$20 IF 10!200
R;!$20 IF 10=2TO4
R;!$20 IF 13=2=200
R;!$20 IF 13>2=200
R;!$22 IF 13<2<200
R;!$24 IF 13!2=200
R;!$24 IF 13=1TO2=200
R;!$20 IF 15=3=14
R;!$20 IF 15<3>10
R;!$22 IF 15<3!10
R;!$22 IF 15<3=2TO7
R;!$22 IF 15=3TO4=2TO7
R;!$20 IF 17!4>10=14
R;!$20 IF 19=1
R;!$20 IF 21=1=16
R;!$20 IF 23=st
R;!$20 IF 25=1=st
R;!$20 IF 25=0TO1=st
R;!$20 IF 25=2=10
R;!$20 IF 4=2=1 OR 6=2=1
R;!$30 IF 10=10 AND 8=3=1=0
R;!$30 IF 10=4 AND ! 6=2=1
' This command 02 ! (transmitted token 03)
R;030201 IF 2=1
R;?030201 IF 2=1
R;!20 IF 77=1=1=1
R;!20 IF 80=1=1=1=1
L;test1;test2;text3
'Befehl &HF0
'announcement aller Befehle lesen
'read announcement lines
240;an,ANNOUNCEMENTS;100;134,start;134,elements;22,CHAPTER,ADMINISTRATION
'
'Announce19:
'Befehl &HF6 :
'Uebertragungsparamter schreiben
'write communication parameters
246;oa,COM;b,RS232_BAUD,0,{19k20,48k4,115k};3,RS23_BITS,8n1;b,RADIO_TYPE,,1,{no,Lora,wlan,rfya689,nrf25,bluetooth};4,RADIO_NAME,,radix;b,I2CADRESS,28;22,CHAPTER,ADMINISTRATION
'
'Befehl &HF7 :
'Uebertragungsparamter lesen
'read communication parameters
247;aa,as246
'                                                  '
'Befehl &HFC
'Liest letzten Fehler
'read last error
252;aa,LAST ERROR;20,last_error
'                                                '
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
253;aa,MYC INFO;b,ACTIVE
'
'Befehl &HFE
'eigene Individualisierung schreiben
'write individualization
254;oa,INDIVIDUALIZATION;20,NAME,D1;b,NUMBER,1;a,RS232,1;a,USB,1;a,RADIO,4;a,I2C,1;22,CHAPTER,ADMINISTRATION
'
'Befehl &HFF
'eigene Individualisierung lesen
'read individualization
255;aa,as254
'