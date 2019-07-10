'name : infrarot_tx _philips_tv_2908.bas
'Version V05.0, 20190710
'purpose : Programm to send RC5 Codes to Philips TV 2908
'This Programm workes as I2C slave or serial interface
'Can be used with hardware rs232_i2c_interface Version V05.0 by DK1RI
'++++++++++++++++++++++++++++++++++++++++++++++++++++
'
' ---> Description / name of program
'
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
' To run the compiler the directory comon_1,7 must be copied to the directory of this file!
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
'
'----------------------------------------------------
$include "common_1.7\_Introduction_master_copyright.bas"
'
'----------------------------------------------------
'
'Used Hardware:
' serial
' I2C
'-----------------------------------------------------
' Inputs /Outputs : see file __config
' For announcements and rules see Data section at the end
'
'------------------------------------------------------
'Missing/errors:
'
'------------------------------------------------------
'$regfile = "m168pdef.dat"
$regfile = "m328pdef.dat"
$crystal = 20000000
'
'-----------------------------------------------------
$include "common_1.7\_Processor.bas"
'
'----------------------------------------------------
'
' 8: for 8/32pin, ATMEGAx8; 4 for 40/44pin, ATMEGAx4 packages
' used for reset now: different portnumber of SPI SS pin
Const Processor = "8"
Const Command_is_2_byte    = 0
'1...127:
Const I2c_address = 15
Const No_of_announcelines = 47
'announcements start with 0 -> minus 1
Const Tx_factor = 10
' For Test:10 (~ 10 seconds), real usage:1 (~ 1 second)
' ---> Specific constants
'
'----------------------------------------------------
$include "common_1.7\_Constants_and_variables.bas"
'
'----------------------------------------------------
Dim Togglebit As Byte
Dim Rc5_adress As Byte
'
'----------------------------------------------------
$include "common_1.7\_Macros.bas"
'
'----------------------------------------------------
$include "common_1.7\_Config.bas"
'
'----------------------------------------------------
$include "common_1.7\_Main.bas"
'
'----------------------------------------------------
$include "common_1.7\_Loop_start.bas"
'
'----------------------------------------------------
$include "common_1.7\_Serial.bas"
'
'----------------------------------------------------
$include "common_1.7\_I2c.bas"
'
'----------------------------------------------------
'
' End Main start subs
'
'----------------------------------------------------
$include "common_1.7\_Reset.bas"
'
'----------------------------------------------------
$include "common_1.7\_Init.bas"
'
'----------------------------------------------------
$include "common_1.7\_Subs.bas"
$include "common_1.7\_Sub_reset_i2c.bas"      
'
'----------------------------------------------------
Send_rc5:
printbin b_Temp1
Rc5send Togglebit, Rc5_adress, b_Temp1
Set Ir_led
'Switch of IR LED
Return
'
'----------------------------------------------------
   $include "common_1.7\_Commandparser.bas"
'
'-----------------------------------------------------
   Case 1
'Befehl &H01
'an / aus
'on / off
'Data "1;ou,An/Aus;0;1,An/Aus"
      b_Temp1 = &H0C
      Gosub Send_rc5
      Gosub Command_received
'
   Case 2
'Befehl &H02
'o
'o
'Data "2;ou,o;0;1,o"
      b_Temp1 = &H18
      Gosub Send_rc5
      Gosub Command_received
'
   Case 3
'Befehl &H03
'||
'||
'Data "3;ou,||;0;1,||"
      b_Temp1 = &H31
      Gosub Send_rc5
      Gosub Command_received
'
   Case 4
'Befehl &H04
'<<
'<<
'Data "4;ou,<<;0;1,<<"
      b_Temp1 = &H1B
      Gosub Send_rc5
      Gosub Command_received
'
   Case 5
'Befehl &H05
'>
'>
'Data "5;ou,>;0;1,>"
      b_Temp1 = &H19
      Gosub Send_rc5
      Gosub Command_received
'
   Case 6
'Befehl &H06
'>>
'>>
'Data "6;ou,>>;0;1,>>"
      b_Temp1 = &H1C
      Gosub Send_rc5
      Gosub Command_received
'
   Case 7
'Befehl &H07
'source
'source
'Data "7;ou,source;0;1,source"
      b_Temp1 = &H38
      Gosub Send_rc5
      Gosub Command_received
'
   Case 8
'Befehl &H08
'tv
'tv
'Data "8;ou,tv;0;1,tv"
      b_Temp1 = &H3F
      Gosub Send_rc5
      Gosub Command_received
'
   Case 9
'Befehl &H09
'format
'format
'Data "9;ou,format;0;1,format"
      b_Temp1 = &H0B
      Gosub Send_rc5
      Gosub Command_received
'
   Case 10
'Befehl &H0A
'home
'home
'Data "10;ou,home;0;1,home"
      b_Temp1 = &H30
      Gosub Send_rc5
      Gosub Command_received
'
   Case 11
'Befehl &H0B
'list
'list
'Data "11;ou,list;0;1,list"
      b_Temp1 = &H26
      Gosub Send_rc5
      Gosub Command_received
'
   Case 12
'Befehl &H0C
'info
'info
'Data "12;ou,info;0;1,info"
      b_Temp1 = &H12
      Gosub Send_rc5
      Gosub Command_received
'
   Case 13
'Befehl &H0D
'adjust
'adjust
'Data "13;ou,adjust;0;1,adjust"
      b_Temp1 = &H33
      Gosub Send_rc5
      Gosub Command_received
'
   Case 14
'Befehl &H0E
'options
'options
'Data "14;ou,options;0;1,options"
      b_Temp1 = &H0F
      Gosub Send_rc5
      Gosub Command_received
'
   Case 15
'Befehl &H0F
'auf
'up
'Data "15;ou,up;0;1,up"
      b_Temp1 = &H14
      Gosub Send_rc5
      Gosub Command_received
'
   Case 16
'Befehl &H10
'links
'left
'Data "16;ou,left;0;1,left"
      b_Temp1 = &H15
      Gosub Send_rc5
      Gosub Command_received
'
   Case 17
'Befehl &H11
'rechts
'right
'Data "17;ou,right;0;1,right"
      b_Temp1 = &H16
      Gosub Send_rc5
      Gosub Command_received
'
   Case 18
'Befehl &H12
'ab
'down
'Data "18;ou,down;0;1,down"
      b_Temp1 = &H13
      Gosub Send_rc5
      Gosub Command_received
'
   Case 19
'Befehl &H13
'zurueck
'back
'Data "19;ou,back;0;1,back"
      b_Temp1 = &H0A
      Gosub Send_rc5
      Gosub Command_received
'
   Case 20
'Befehl &H14
'ch-
'ch-
'Data "20;ou,ch-;0;1,ch-"
      b_Temp1 = &H21
      Gosub Send_rc5
      Gosub Command_received
'
   Case 21
'Befehl &H15
'ch+
'ch+
'Data "21;ou,ch+;0;1,ch+"
      b_Temp1 = &H20
      Gosub Send_rc5
      Gosub Command_received
'
   Case 22
'Befehl &H16
'laut-
'loud-
'Data "22;ou,loud-;0;1,loud-"
      b_Temp1 = &H11
      Gosub Send_rc5
      Gosub Command_received
'
   Case 23
'Befehl &H17
'Ton aus
'loud off
'Data "23;ou,loud off;0;1,loud off"
      b_Temp1 = &H0D
      Gosub Send_rc5
      Gosub Command_received
'
   Case 24
'Befehl &H18
'laut+
'loud+
'Data "24;ou,loud+;0;1,loud+"
      b_Temp1 = &H10
      Gosub Send_rc5
      Gosub Command_received
'
   Case 25
'Befehl &H19
'rot
'red
'Data "25;ou,red;0;1,red"
      b_Temp1 = &H37
      Gosub Send_rc5
      Gosub Command_received
'
   Case 26
'Befehl &H1A
'gruen
'green
'Data "26;ou,green;0;1,green"
      b_Temp1 = &H36
      Gosub Send_rc5
      Gosub Command_received
'
   Case 27
'Befehl &H1B
'gelb
'yellow
'Data "27;ou,yellow;0;1,yellow"
      b_Temp1 = &H32
      Gosub Send_rc5
      Gosub Command_received
'
   Case 28
'Befehl &H1C
'blau
'blue
'Data "28;ou,blue;0;1,blue"
      b_Temp1 = &H34
      Gosub Send_rc5
      Gosub Command_received
'
   Case 29
'Befehl &H1D
'1
'1
'Data "29;ou,1;0;1,1"
      b_Temp1 = &H01
      Gosub Send_rc5
      Gosub Command_received
'
   Case 30
'Befehl &H1E
'2
'2
'Data "30;ou,2;0;1,2"
      b_Temp1 = &H02
      Gosub Send_rc5
      Gosub Command_received
'
   Case 31
'Befehl &H1F
'3
'3
'Data "31;ou,3;0;1,3"
      b_Temp1 = &H03
      Gosub Send_rc5
      Gosub Command_received
'
   Case 32
'Befehl &H20
'4
'4
'Data "32;ou,4;0;1,4"
      b_Temp1 = &H04
      Gosub Send_rc5
      Gosub Command_received
'
    Case 33
'Befehl &H21
'5
'5
'Data "33;ou,5;0;1,5"
      b_Temp1 = &H05
      Gosub Send_rc5
      Gosub Command_received
'
   Case 34
'Befehl &H22
'6
'6
'Data "34;ou,6;0;1,6"
      b_Temp1 = &H06
      Gosub Send_rc5
      Gosub Command_received
'
   Case 35
'Befehl &H23
'7
'7
'Data "35;ou,7;0;1,7"
      b_Temp1 = &H07
      Gosub Send_rc5
      Gosub Command_received
'
   Case 36
'Befehl &H24
'8
'8
'Data "36;ou,8;0;1,8"
      b_Temp1 = &H08
      Gosub Send_rc5
      Gosub Command_received
'
   Case 37
'Befehl &H25
'9
'9
'Data "37;ou,9;0;1,9"
      b_Temp1 = &H09
      Gosub Send_rc5
      Gosub Command_received
'
   Case 38
'Befehl &H26
'0
'0
'Data "38;ou,0;0;1,0"
      b_Temp1 = &H00
      Gosub Send_rc5
      Gosub Command_received
'
   Case 39
'Befehl &H27
'subtitle
'subtitle
'Data "39;ou,0;subtitle;1,subtitle"
      b_Temp1 = &H1F
      Gosub Send_rc5
      Gosub Command_received
'
   Case 40
'Befehl &H28
'text
'text
'Data "40;ou,0;text;1,text"
      b_Temp1 = &H3C
      Gosub Send_rc5
      Gosub Command_received
'
   Case 41
'Befehl &H29
'ok
'ok
'Data "41;ou,0;ok;1,ok"
      b_Temp1 = &H35
      Gosub Send_rc5
      Gosub Command_received
'
'-----------------------------------------------------
$include "common_1.7\_Command_240.bas"
'
'-----------------------------------------------------
$include "common_1.7\_Command_252.bas"
'
'-------------------------------------------------
$include "common_1.7\_Command_253.bas"
'
'-----------------------------------------------------
$include "common_1.7\_Command_254.bas"
'
'-----------------------------------------------------
$include "common_1.7\_Command_255.bas"
'
'-----------------------------------------------------
$include "common_1.7\_End.bas"
'
'announce text
'
Announce0:
'Befehl &H00
'eigenes basic announcement lesen
'basic announcement is read to I2C or output
Data "0;m;DK1RI;philips_tv_2908;V05.0;1;145;1;47;1-1"
'
Announce1:
'Befehl &H01
'an / aus
'on / off
Data "1;ou,An/Aus;0;1,An/Aus"
'
Announce2:
'Befehl &H02
'o
'o
'Data "2;ou,o;0;1,o"
'
Announce3:
'Befehl &H03
'||
'||
Data "3;ou,||;0;1,||"
'
Announce4:
'Befehl &H04
'<<
'<<
Data "4;ou,<<;0;1,<<"
'
Announce5:
'Befehl &H05
'>
'>
Data "5;ou,>;0;1,>"
'
Announce6:
'Befehl &H06
'>>
'>>
Data "6;ou,>>;0;1,>>"
'
Announce7:
'Befehl &H07
'source
'source
Data "7;ou,source;0;1,source"
'
Announce8:
'Befehl &H08
'tv
'tv
Data "8;ou,tv;0;1,tv"
'
Announce9:
'Befehl &H09
'format
'format
Data "9;ou,format;0;1,format"
'
Announce10:
'Befehl &H0A
'home
'home
Data "10;ou,home;0;1,home"
'
Announce11:
'Befehl &H0B
'list
'list
Data "11;ou,list;0;1,list"
'
Announce12:
'Befehl &H0C
'info
'info
Data "12;ou,info;0;1,info"
'
Announce13:
'Befehl &H0D
'adjust
'adjust
Data "13;ou,adjust;0;1,adjust"
'
Announce14:
'Befehl &H0E
'options
'options
Data "14;ou,options;0;1,options"
'
Announce15:
'Befehl &H0F
'auf
'up
Data "15;ou,up;0;1,up"
'
Announce16:
'Befehl &H10
'links
'left
Data "16;ou,left;0;1,left"
'
Announce17:
'Befehl &H11
'rechts
'right
Data "17;ou,right;0;1,right"
'
Announce18:
'Befehl &H12
'ab
'down
Data "18;ou,down;0;1,down"
'
Announce19:
'Befehl &H13
'zurueck
'back
Data "19;ou,back;0;1,back"
'
Announce20:
'Befehl &H14
'ch-
'ch-
Data "20;ou,ch-;0;1,ch-"
'
Announce21:
'Befehl &H15
'ch+
'ch+
Data "21;ou,ch+;0;1,ch+"
'
Announce22:
'Befehl &H16
'laut-
'loud-
Data "22;ou,loud-;0;1,loud-"
'
Announce23:
'Befehl &H17
'Ton aus
'loud off
Data "23;ou,loud off;0;1,loud off"
'
Announce24:
'Befehl &H18
'laut+
'loud+
Data "24;ou,loud+;0;1,loud+"
'
Announce25:
'Befehl &H19
'rot
'red
Data "25;ou,red;0;1,red"
'
Announce26:
'Befehl &H1A
'gruen
'green
Data "26;ou,green;0;1,green"
'
Announce27:
'Befehl &H1B
'gelb
'yellow
Data "27;ou,yellow;0;1,yellow"
'
Announce28:
'Befehl &H1C
'blau
'blue
Data "28;ou,blue;0;1,blue"
'
Announce29:
'Befehl &H1D
'1
'1
Data "29;ou,1;0;1,1"
'
Announce30:
'Befehl &H1E
'2
'2
Data "30;ou,2;0;1,2"
'
Announce31:
'Befehl &H1F
'3
'3
Data "31;ou,3;0;1,3"
'
Announce32:
'Befehl &H20
'4
'4
Data "32;ou,4;0;1,4"
'
Announce33:
'Befehl &H21
'5
'5
Data "33;ou,5;0;1,5"
'
Announce34:
'Befehl &H22
'6
'6
Data "34;ou,6;0;1,6"
'
Announce35:
'Befehl &H23
'7
'7
Data "35;ou,7;0;1,7"
'
Announce36:
'Befehl &H24
'8
'8
Data "36;ou,8;0;1,8"
'
Announce37:
'Befehl &H25
'9
'9
Data "37;ou,9;0;1,9"
'
Announce38:
'Befehl &H26
'0
'0
Data "38;ou,0;0;1,0"
'
Announce39:
'Befehl &H27
'subtitle
'subtitle
Data "39;ou,0;subtitle;1,subtitle"
'
Announce40:'
'Befehl &H28
'text
'text
Data "40;ou,0;text;1,text"
'
Announce41:
'Befehl &H29
'ok
'ok
Data "41;ou,0;ok;1,ok"
'
Announce42:                                              '
'Befehl &HF0<n><m>
'announcement aller Befehle lesen
'read m announcement lines
Data "240;ln,ANNOUNCEMENTS;145;47"
'
Announce43:                                                  '
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
'
Announce44:
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
Announce45:
'Befehl &HFE :
'eigene Individualisierung schreiben
'write individualization
Data "254;ka,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,15,{0 to 127};a,SERIAL,1"
'
Announce46:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;la,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,15,{0 to 127};a,SERIAL,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1"
'