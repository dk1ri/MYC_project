' announcements
' 20251208
'Data linelength is limited to 254 Byte
'
Announce:
'Befehl &H00
'basic annoumement wird gelesen
'basic announcement is read
Data "0;m;DK1RI;V I sensor with radio interface;V03.0;1;145;1;21;1-1"
'
'Announce1:
'Befehl &H01
'liest Spannung
'read voltage
Data "1;ap,shunt voltage;1;66536,,{0.1_-3276.7to3276.6};lin;mV"
'
'Announce2:
'Befehl &H02
'liest Spannung
'read voltage
Data "2;ap,bus voltage;1;3328,,{1_0to26000};lin;mV"
'
'Announce3:
'Befehl &H03
'liest Strom
'read currect
Data "3;ap,current;1;3328,,{0.1_-3276.7to3276.6};lin;mA"
'
'Announce4:
'Befehl &H04
'liest Leistung
'read power
Data "4;ap,power;1;100,;lin;W"
'
'Announce5:
'Befehl &H05
'liest Leistung
'read power
Data "5;ap,power;1;7500000,,{0.01_0to75000.00};lin;mW"
'
'Announce6:
'register
'register
Data "6;oa,INA calibration register;w"

'Announce7:
'register
'register
Data "7;aa,as6"
'
'Announce8:
'Frequenz RFM95
'frequncy RFM95
Data "8;op,frequency 433MHz Lora ;1;1700,,{1_433000to434700};lin;kHz"
'
'
'Announce9:
'Frequenz RFM95
'frequncy RFM95
Data "9;ap,as8"
'
'Announce10:
'Frequenz nRF24
'frequncy nRF24
Data "10;op,frequency;1;128,,{1_2400to2527};lin;MHz"
'
'Announce11:
'Frequenz nRF24
'frequency nRF24
Data "11;ap,as10"
'
'Announce12:
'Konfiguration
'config mode
Data "12;as,configuration;1;0,off;1,on"
'
'Announce13:
'Befehl &HF0
'liest announcements
'read m announcement lines
' start at and elements must be identical
Data "240;an,ANNOUNCEMENTS;145;21,start at;21,elements;22,CHAPTER,ADMINISTRATION"
'
'Announce14:
'Befehl &HF6 :
'Uebertragungsparamter schreiben
'write communication parameters
Data "246;oa,COM;b,RS232_BAUD,0,{19k20,48k4,115k};3,RS232_BITS,8n1;b,RADIO_TYPE,,1,{no,Lora,wlan,RYFA689,nrf25,bluetooth};4,RADIO_NAME,,radix;,4;b,I2CADRESS,28;22,CHAPTER,ADMINISTRATION"
'
'Announce15:
'Befehl &HF7 :
'Uebertragungsparamter lesen
'read communication parameters
Data "247;aa,as246"
'
'Announce16:
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;60,last_error"
'
'Announce17:
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
'Announce18:
'Befehl &HFE :
'eigene Individualisierung schreiben
'write individualization
Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,RS232,1;a,USB,1;a,RADIO,1;a,I2C,1;22,CHAPTER,ADMINISTRATION"
'
'Announce19:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;aa,as254"
'
'Announce20:
Data "R;!$7 !$8 !$9 !10 !$11 !$12 !$13 !$14 !$14 !$15 !$16 IF $175=1"