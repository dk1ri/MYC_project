' announcements
' 20230705
'
Announce:
'Befehl &H00
'eigenes basic announcement lesen
'basic announcement is read to I2C or output
Data "0;m;DK1RI;RTC;V04.0;1;145;1;16;1-1"
'
'Announce1:
'Befehl  &H01
'liest UNIX Uhrzeit
'read Unixtime
Data "1;aa,UNIX time;L,,{CODING,UNIXTIME4}"
'
'Announce2:
'Befehl  &H02
'liest Uhrzeit
'read time
Data "2;aa,time;8"
'
'Announce3:
'Befehl  &H03
'liest Uhrzeit
'read time
Data "3;aa,time;k,{CODING,DAYSEC}"
'
'Announce4:
'Befehl  &H04
'liest Jahr
'read year
Data "4;aa,year;w,year,{CODING,YEAR0}"

'Announce5:
'Befehl  &H05
'liest Monat
'read month
Data "5;aa,month;n,month,{CODING,MONTH}"
'
'Announce6:
'Befehl  &H06
'liest Tag
'read day
Data "6;aa,day;n,day,{CODING,DAY}"
'
'Announce7:
'Befehl  &H07
'schreibt register
'write register
Data "7;om,register;b,1 byte;15,register;14,CHAPTER,ADMINISTRATION"
'
'Announce8:
'Befehl  &H08
'liest register
'read register
Data "8;am,as7"
'
'Announce9:
'Befehl &HF0
'liest announcements
'read n announcement lines
Data "240;an,ANNOUNCEMENTS;145;16,start at;16,lines;14,CHAPTER,ADMINISTRATION"
'
'Announce10:                                                  '
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
'
'Announce11:                                                  '
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
'Announce12:
'Befehl &HFE:
'eigene Individualisierung schreiben
'write individualization
Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,19,{1_0to127};a,SERIAL,1;14,CHAPTER,ADMINISTRATION"
'
'Announce13:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,19,{1_0to127};a,SERIAL,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;14,CHAPTER,ADMINISTRATION"
'
'Announce14;
Data "L;language name;english;deutsch"
'
'Announce15;
Data "L;UNIX time;UNIX time;UNIX Zeit;time;time;Zeit;year;year;Jahr;month;month;Monat;day;day;Tag"