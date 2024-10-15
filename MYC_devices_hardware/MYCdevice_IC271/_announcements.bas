' name: _announcements.bas
' 20241014
'
Announce:
'Befehl &H00
'eigenes basic Announcement lesen
'basic 'Announcement is read to I2C or output
Data "0;m;DK1RI;IC271 Interface;V01.4;1;175;1;20;1-1"
'
'Announce1:
'Befehl &H01 0 to 1999999 Code 00 (05)
'Frequenz schreiben
'write Frequency
Data "1;op,frequency;1;2000000,,{1_144000000to145999999};lin;Hz"
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
Data "3;os,mode;1;0,FIL1 LSB;1,FIL1 USB;2,Fil1 AM;3,FIL1 CW;4,FIL2 LSB;4,FIL2 USB;5,Fil2 AM;6,FIL2 CW"
'
'Announce4:
'Befehl &H04: --> Code 04
'Mode lesen
'read mode
Data "4;as,as3"
'
'Announce5:
'Befehl &H05: -->  Code 02
'Bandgrenze lesen
'read band edge
Data "5;ap,band_edge_frequencies;1;200000,low,{10_144000000to145999999};lin;*10Hz;200000,high,{1_144000000to145999999};lin;*10Hz"
'
'Announce6:
'Befehl &H06  --> Code 07
'Vfo Mode setzen
'set vfo mode
Data "6;ou,vfo;1;0,idle;1,set"
'
'Announce7:
'Befehl &H07 --> Code 08
'set memory mode
'set memory mode
Data "7;ou,memory;1;0,idle;1,set"
'
'Announce8:
'Befehl &H08 --> Code 09
'Vfo und Mode nach memory schreiben
'write vfo and mode to memory
Data "8;ou,copy_vfo_and_mode_to_memory;1;0,idle;1,copy"
'
'Announce9:
'Befehl &H09 --> Code 0A
'memory nach Vfo und mode schreiben
'write memory to vfo and mode
Data "9;ou,copy_memory_to_vfo_and_mode;1;0,idle;1,copy"
'
'Announce10:
'Befehl &H0A 0 - 1999 --> Code 0D
'Offset schreiben
'write offset
Data "10;op,ofset;1;20000;lin;*100Hz"
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
Data "240;an,ANNOUNCEMENTS;145;20,start at;20,elements;14,CHAPTER,ADMINISTRATION"
'
'Announce13:                                                  '
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;60,last_error"
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
Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,29,{1_0to127};a,SERIAL,1;14,CHAPTER,ADMINISTRATION"
'
'Announce16:
'Befehl  &HFF <n>
'eigene Individualisierung lesen
'read individualization
Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,29,{1_0to127};a,SERIAL,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;14,CHAPTER,ADMINISTRATION"
'
'Announce17:
Data "L;language name;english;deutsch"
'
'Announce18:
Data "L;frequency;frequency;Frequenz;band_edge_frequencies;band edge frequencies;Bandgrenzen;"
'
'Announce19:
Data "L;copy_vfo_and_mode_to_memory;copy vfo and mode to memory;VFO und Mode speichern;copy_memory_to_vfo_and_mode;copy memory to vfo and mode;VFO und Mode lesen"