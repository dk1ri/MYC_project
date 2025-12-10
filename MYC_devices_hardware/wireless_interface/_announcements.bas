' annoucements
' 20251201
'
Announce:
'Befehl &H00
'basic annoumement wird gelesen
'basic announcement is read
Data "0;m;DK1RI;serial to wireless interface;V01.0;1;230;1;14;1-1"
'
'Announce1:
'Frequenz RFM95
'frequncy RFM95
Data "1;op,frequency 433MHz Lora ;1;1700,,{1_433000to434700};lin;kHz"
'
'
'Announce2:
'Frequenz RFM95
'frequncy RFM95
Data "2;ap,as1"
'
'Announce3:
'Frequenz nRF24
'frequncy nRF24
Data "3;op,frequency;1;128,,{1_2400to2527};lin;MHz"
'
'Announce4:
'Frequenz nRF24
'frequency nRF24
Data "4;ap,as310"
'
''Announce5:
'Konfiguration
'config mode
Data "5;as,configuration;1;0,off;1,on"
'
Announce6:
'Befehl &HF0
'announcement aller Befehle lesen
'read announcement lines
Data "240;an,ANNOUNCEMENTS;100;12,start;14,elements;14,CHAPTER,ADMINISTRATION"
'
'Announce7:
'Befehl &HF6 :
'Uebertragungsparamter schreiben
'write communication parameters
Data "246;oa,COM;b,RS232_BAUD,0,{19k20,48k4,115k};3,RS232_BITS,8n1;b,RADIO_TYPE,,1,{no,Lora,wlan,rfya689,nrf25,bluetooth};4,RADIO_NAME,,radix;,4;b,I2CADRESS,28;22,CHAPTER,ADMINISTRATION"
'
'Announce8:
'Befehl &HF7 :
'Uebertragungsparamter lesen
'read communication parameters
Data "247;aa,as246"
'
'Announce9:                                                  '
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
'
'Announce10:                                                  '
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
'Announce11:
'Befehl &HFE
'eigene Individualisierung schreiben
'write individualization
Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,RS232,1;a,USB,1;a,RADIO,4;a,I2C,1;22,CHAPTER,ADMINISTRATION"
'
'Announce12:
'Befehl &HFF
'eigene Individualisierung lesen
'read individualization
Data "255;aa,as254"
'
'Announce13:
Data "R;!$1 !$2 !$3 !$4 !$246 !$254 IF $5=0"