' annoucements
' 20251201
'
Announce:
'Befehl &H00
'basic annoumement wird gelesen
'basic announcement is read
Data "0;m;DK1RI;serial to wireless interface;V01.0;1;230;1;16;1-1;14,CHAPTER,ADMINISTRATION"
'
'Announce1:
'Frequenz RFM95
'frequncy RFM95
Data "1;op,frequency 433MHz Lora ;1;1700,{1_433000to434700};lin;kHz"
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
Data "3;op,frequncy;1;128,{1_2400to2527};lin;MHz"
'
'Announce4:
'Frequenz nRF24
'frequency nRF24
Data "4;ap,as3"
'
'Announce5:
'Befehl &HF0
'announcement aller Befehle lesen
'read announcement lines
Data "240;an,ANNOUNCEMENTS;100;16,start;11,elements;16,CHAPTER,ADMINISTRATION"
'
'Announce6:                                                  '
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
'
'Announce7:                                                  '
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
'Announce8:
'Befehl &HFE
'eigene Individualisierung schreiben
'write individualization
Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,RS232,1;a,USB,1;b,radiotype;4,radioname,radix;a,I2Cactiv,1,4;b,I2caddress,28;14,CHAPTER,ADMINISTRATION" 
'
'Announce9:
'Befehl &HFF
'eigene Individualisierung lesen
'read individualization
Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,RS232,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;a,USB,1;b,radiotype,4;5,radioname,radix;a,I2Cactiv,1;b,I2caddress,28;14,CHAPTER,ADMINISTRATION"
'