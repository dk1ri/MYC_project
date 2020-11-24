' name: _announcements.bas
' 20200211
'
Announce:
'Befehl &H00
'eigenes basic Announcement lesen
'basic 'Announcement is read to I2C or output
Data "0;m;DK1RI;IC271 Interface;V01.3;1;175;1;17;1-1"
'
'Announce1:
'Befehl &H01 0 to 1999999 Code 00 (05)
'Frequenz schreiben
'write Frequency
Data "1;op,freqency;1;2000000,{144000000 to 145999999};lin;Hz"
'
'Announce2:
'Befehl &H02 0 to 1999999: --> Code 03
'Frequenz lesen
'read Frequency
Data "2;ap,as1"
'
'Announce3:
'Befehl &H03 : -->Code 01 (06)
'Mode schreiben
'write mode
Data "3;os,mode;2;0,LSB;1,USB;1,AM;3,CW;0,FIL1;1,FIL2"
'
'Announce4:
'Befehl &H04: --> Code 04
'Mode lesen
'read mode
Data "4,as3"
'
'Announce5:
'Befehl &H05: -->  Code 02
'Bandgrenze lesen
'read band edge
Data "5;ap,band edge frequencies;1;1,{144000000},low;lin;Hz;1,{146000000},high;lin;*10Hz"
'
'Announce6:
'Befehl &H06  --> Code 07
'Vfo Mode setzen
'set vfo mode
Data "6;ou,set vfo mode;1;0,idle;1,VFO mode"
'
'Announce7:
'Befehl &H07 --> Code 08
'set memory mode
'set memory mode
Data "7;ou,set memory mode;1;0.idle;1,memory mode"
'
'Announce8:
'Befehl &H08 --> Code 09
'Vfo und Mode nach memory schreiben
'write vfo and mode to memory
Data "8;ou,copy vfo and mode to memory;1;0,idle;1,copy to memory"
'
'Announce9:
'Befehl &H09 --> Code 0A
'memory nach Vfo und mode schreiben
'write memory to vfo and mode
Data "9;ou,copy memory to vfo and mode;1;0,idle;1,copy to vfo and mode"
'
'Announce10:
'Befehl &H0A 0 - 1999 --> Code 0D
'Offset schreiben
'write offset
Data "10;op,write offset;1;20000;lin;*100Hz"
'
'Announce11:
'Befehl &H0B 0 - 1999  --> Code 0C
'Offset lesen
'read offset
Data "11;ap,as10"
'
'Announce12:
'Befehl  &F0
'liest announcements
'read n announcement lines
Data "240;ln,ANNOUNCEMENTS;175;17"
'
'Announce13:                                                  '
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
'
'Announce14:                                                  '
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
'Announce15:
'Befehl &HFE <n><data>
'eigene Individualisierung schreiben
'write individualization
Data "254;ka,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,29,{0 to 127};a,SERIAL,1"
'
'Announce16:
'Befehl  &HFF <n>
'eigene Individualisierung lesen
'read individualization
Data "255 ;la,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,29,{0 to 127};a,SERIAL,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1"
'