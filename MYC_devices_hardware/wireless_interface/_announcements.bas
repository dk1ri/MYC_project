' annoucements
' 20241128
'
Announce:
'Befehl &H00
'basic annoumement wird gelesen
'basic announcement is read
Data "0;m;DK1RI;serial to wireless interface;V01.0;1;145;1;14;1-1"
'
'Announce2:
'Befehl &HEB
'MYC Mode
'MYC mode
Data "235;as,MYC mode;0,Interface;1,MYC"
'
'Announce3:
'Befehl &HEC
'Umschaltung
'MYC Interface mode switch
Data "236;os,enable change to MYC mode;0,disable;1,enable"
'
'Announce4:
'Befehl &HED
'Umschaltung
'MYC Interface mode switch
Data "237;as,as236"
'
'Announce5:
'Befehl &HEE
'Radi type
'Radio Type
Data "238;as,radio type;1:0,RFM95;1;RYFA689"
'
'Announce6:
'Befehl &HEF
'Radio Name
'radio name
Data "239;aa,radio name;20"

'Announce7:
'Befehl &HF0
'announcement aller Befehle lesen
'read announcement lines
Data "240;an,ANNOUNCEMENTS;100;14,start;14,elements;14,CHAPTER,ADMINISTRATION"
'
'Announce8:
'Befehl &HF8
'MYC / Interface Mode
'MYC / Interface mode
Data "248;oa,TRANS,transpatent MYC mode / radio name;32"
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
'Befehl &HFE :
'eigene Individualisierung schreiben
'write individualization
Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,RS232,1;a,USB,1,1;14,CHAPTER,ADMINISTRATION"
'
'Announce12:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,RS232,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;a,USB,17;14,CHAPTER,ADMINISTRATION"
'
'Announce13:
Data "L;language name;english;deutsch"
'
'Announce14:
Data "L;enable change to MYC mode;enable change to MYC mode;Wechsel nach MYC mode zulasse n;"