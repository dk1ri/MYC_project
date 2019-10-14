'-----------------------------------------------------------------------
'name : relaisteuerung_basom.bas
'Version V05.0, 20191014
'purpose : Control of a board with 4 Relais and 11 Inputs
'Can be used with hardware relaisteuerung Version V03.0 by DK1RI
'Pin description was changed with V03,0, so it is not compatible with earlier boards!!
'
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
' To run the compiler the directory comon_1,7 with includefiles must be copied to the directory of this file!
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
' Inputs: see below
' AD Converter 0 - 3
' Outputs : see below
' I/O : I2C
' For announcements and rules see Data section at the end
'
'------------------------------------------------------
'Missing/errors:
'
'------------------------------------------------------
'
' Detailed description
'
'----------------------------------------------------
'$regfile = "m168pdef.dat"
$regfile = "m328pdef.dat"
'
'-----------------------------------------------------
$crystal = 20000000
$include "common_1.7\_Processor.bas"
'
'----------------------------------------------------
'
' 8: for 8/32pin, ATMEGAx8; 4 for 40/44pin, ATMEGAx4 packages
' used for reset now: different portnumber of SPI SS pin
Const Processor = "8"
Const Command_is_2_byte = 0
'1...127:
Const I2c_address = 8
Const No_of_announcelines = 32
'announcements start with 0 -> minus 1
Const Tx_factor = 10
' For Watchdog: For Test:10 (~ 10 seconds), real usage:1 (~ 1 second)
'
'----------------------------------------------------
$include "common_1.7\_Constants_and_variables.bas"
'
Dim Adc_value As Word
Dim Adc_reference As Byte
Dim Adc_reference_eeram As Eram Byte
'
'----------------------------------------------------
$include "common_1.7\_Macros.bas"
'
'----------------------------------------------------
Config PinB.2 = Input
Reset__ Alias PinB.2
$include "common_1.7\_Config.bas"
'
'----------------------------------------------------
' procedures at start
'
'----------------------------------------------------
$include "common_1.7\_Main.bas"
'
'----------------------------------------------------
$include "common_1.7\_Loop_start.bas"
'
'----------------------------------------------------
'
' ---> Specific actions
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
'
Send_input_2:
Start Adc
Select Case Tx_b(1)
   Case &H0C
      Adc_value = Getadc(3)
      Adc_value = Getadc(3)
   Case &H0D
      Adc_value = Getadc(2)
      Adc_value = Getadc(2)
   Case &H0E
      Adc_value = Getadc(1)
      Adc_value = Getadc(1)
   Case &H0F
      Adc_value = Getadc(0)
      Adc_value = Getadc(0)
End Select
Stop Adc
Tx_b(2) = High(adc_value)
Tx_b(3) = Low(adc_value)
Tx_busy = 2
Tx_time = 1
Tx_write_pointer = 4
If Command_mode = 1 Then Gosub Print_tx
Gosub Command_received
Return
'
'----------------------------------------------------
   $include "common_1.7\_Commandparser.bas"
'
'-----------------------------------------------------
'
   Case 1
'Befehl &H01
'liest digital Wert INP1
'read digital INP1
'Data"1;as,INP1;1;0,0;1,1"
      Tx_b(2) = Inp1
      Answer1
'
   Case 2
'Befehl &H02
'liest digital Wert INP2
'read digital INP2
'Data"2;as,INP2;1;0,0;1,1"
      Tx_b(2) = Inp2
      Answer1
'
   Case 3
'Befehl &H03
'liest digital Wert INP3
'read digital INP3
'Data"3;as,INP3;1;0,0;1,1"
      Tx_b(2) = Inp3
      Answer1
'
   Case 4
'Befehl &H04
'liest digital Wert INP4
'read digital INP4
'Data "4;as,INP4;1;0,0;1,1"
      Tx_b(2) = Inp4
      Answer1
'
   Case 5
'Befehl &H05
'liest digital Wert INP5
'read digital INP5
'Data"5;as,INP5;1;0,0;1,1"
      Tx_b(2) = Inp5
      Answer1
'
   Case 6
'Befehl &H06
'liest digital Wert INP6
'read digital INP6
'Data "6;as,INP6;1;0,0;1,1"
      Tx_b(2) = Inp6
      Answer1
'
   Case 7
'Befehl &H07
'liest digital Wert INP7
'read digital INP7
'Data"7;as,INP7;1;0,0;1,1"
      Tx_b(2) = Inp7
      Answer1
'
   Case 8
'Befehl &H08
'liest digital Wert INP8
'read digital INP8
'Data "8;as,INP8;1;0,0;1,1"
      Tx_b(2) = Inp8
      Answer1
'
   Case 9
'Befehl &H09
'liest digital Wert INP9
'read digital INP9
'Data "9;as,INP9;1;0,0;1,1"
      Tx_b(2) = Inp9
      Answer1
'
      Case 10
'Befehl &H0A
'liest digital Wert INP10
'read digital INP10
'Data "10;as,INP10;1;0,0;1,1"
      Tx_b(2) = Inp10
      Answer1
'
   Case 11
'Befehl &H0B
'liest digital Wert INP11
'read digital INP11
      Tx_b(2) = Inp11
      Answer1
'
   Case 12
'Befehl &H0C
'liest analog Wert INP1
'read analog INP1
'Data "12;ap,INP1;1;1024;lin;-"
      Tx_b(1) = &H0C
      Gosub Send_input_2
'
   Case 13
'Befehl &H0D
'liest analog Wert INP2
'read analog INP2
'Data "13;ap,INP2;1;1024;lin;-"
      Tx_b(1) = &H0D
      Gosub Send_input_2
'
   Case 14
'Befehl &H0E
'liest analog Wert INP3
'read analog INP3
'Data"14;ap,INP3;1;1024;lin;-"
      Tx_b(1) = &H0E
      Gosub Send_input_2
'
   Case 15
'Befehl &H0F
'liest analog Wert INP4
'read analog INP4
'Data"14;ap,INP4;1;1024;lin;-"
      Tx_b(1) = &H0F
      Gosub Send_input_2
'
   Case 16
'Befehl &H10
'liest digital alle
'read digital all
'Data"16;am,all;w,{0 to 4095}"
      b_Temp1 = 0
      If Inp1 = 1 Then b_Temp1 = 1
      If Inp2 = 1 Then b_Temp1 = b_Temp1 + 2
      If Inp3 = 1 Then b_Temp1 = b_Temp1 + 4
      If Inp4 = 1 Then b_Temp1 = b_Temp1 + 8
      If Inp5 = 1 Then b_Temp1 = b_Temp1 + 16
      If Inp6 = 1 Then b_Temp1 = b_Temp1 + 32
      If Inp7 = 1 Then b_Temp1 = b_Temp1 + 64
      If Inp8 = 1 Then b_Temp1 = b_Temp1 + 128
      Tx_b(1) = &H10
      Tx_b(3) = b_Temp1
      b_Temp1 = 0
      If Inp9 = 1 Then b_Temp1 = 1
      If Inp10 = 1 Then b_Temp1 = b_Temp1 + 2
      If Inp11 = 1 Then b_Temp1 = b_Temp1 + 4
      Tx_b(2) = b_Temp1
'
      Tx_busy = 2
      Tx_time = 1
      Tx_write_pointer = 4
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
'
   Case 17
'Befehl &H11
'schaltet Relais1
'switch relais1
'Data "17;os,relais1;1;0,off;1,on"
      If Commandpointer > 1 Then
         If Command_b(2) = 1 Then
            Set Relais1
         Else
            Reset Relais1
         End If
         Gosub Command_received
      Else_incr_commandpointer
'
   Case 18
'Befehl &H12
'liest Status Relais1
'read state relais1
'Data "18;as;as17"
      Tx_b(2) = Relais1
      Answer1
'
   Case 19
'Befehl &H13
'schaltet Relais2
'switch relais2
'Data "19;os,relais2;1;0,off;1,on"
      If Commandpointer > 1 Then
         If Command_b(2) = 1 Then
            Set Relais2
         Else
            Reset Relais2
         End If
         Gosub Command_received
      Else_incr_commandpointer
'
   Case 20
'Befehl &H14
'liest Status Relais2
'read state relais2
'Data "20;as;as19"
      Tx_b(2) = Relais2
      Answer1
'
   Case 21
'Befehl &H15
'schaltet Relais3
'switch relais3
'Data "21;os,relais3;1;0,off;1,on"
      If Commandpointer > 1 Then
         If Command_b(2) = 1 Then
            Set Relais3
         Else
            Reset Relais3
         End If
         Gosub Command_received
      Else_incr_commandpointer
'
   Case 22
'Befehl &H16
'liest Status Relais3
'read state relais3
'Data "22;as;as21"
      Tx_b(2) = Relais3
      Answer1
'
   Case 23
'Befehl &H17
'schaltet Relais4
'switch relais4
'Data "23;os,relais4;1;0,off;1,on"
      If Commandpointer > 1 Then
         If Command_b(2) = 1 Then
            Set Relais4
         Else
            Reset Relais4
         End If
         Gosub Command_received
      Else_incr_commandpointer
'
   Case 24
'Befehl &H18
'liest Status Relais4
'read state relais4
'Data "24;as;as23"
      Tx_b(2) = Relais4
      Answer1
'
   Case 238
'Befehl &HEE
'schreibt Referenz default: 0:5V 1: 1.1V
'write reference voltage
'Data "238;oa;a"
      If Commandpointer > 1 Then
         Select Case Command_b(2)
            Case 0
               Adc_reference = 0
               Adc_reference_eeram = Adc_reference
               Config Adc = Single , Prescaler = Auto , Reference = Avcc
            Case 1
               Adc_reference = 1
               Adc_reference_eeram = Adc_reference
               Config Adc = Single , Prescaler = Auto , Reference = Internal_1.1
            Case Else
               Parameter_error
         End Select
         Gosub Command_received
      Else_incr_commandpointer
'
   Case 239
'Befehl &HEF
'liest Referenz default: 0:5V 1: 1.1V
'read reference voltage
'Data "239;aa;as238"
      Tx_b(2) = Adc_reference
      Answer1                         '
'
'-----------------------------------------------------
$include "common_1.7\_Command_240.bas"
'
'-----------------------------------------------------
$include "common_1.7\_Command_252.bas"
'
'-----------------------------------------------------
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
' ---> Rules announcements
'
Announce0:
'Befehl &H00
'basic annoumement wird gelesen
'basic announcement is read
Data "0;m;DK1RI; 4 Relais Bord;V05.0;1;190;1;32;1-1"
'
Announce1:
'Befehl &H01
'liest digital Wert INP1
'read digital INP1
Data"1;as,INP1;1;0,0;1,1"
'
Announce2:
'Befehl &H02
'liest digital Wert INP2
'read digital INP2
Data"2;as,INP2;1;0,0;1,1"
'
Announce3:
'Befehl &H03
'liest digital Wert INP3
'read digital INP3
Data"3;as,INP3;1;0,0;1,1"
'
Announce4:
'Befehl &H04
'liest digital Wert INP4
'read digital INP4
Data "4;as,INP4;1;0,0;1,1"
'
Announce5:
'Befehl &H05
'liest digital Wert INP5
'read digital INP5
Data"5;as,INP5;1;0,0;1,1"
'
Announce6:
'Befehl &H06
'liest digital Wert INP6
'read digital INP6
Data "6;as,INP6;1;0,0;1,1"
'
Announce7:
'Befehl &H07
'liest digital Wert INP7
'read digital INP7
Data"7;as,INP7;1;0,0;1,1"
'
Announce8:
'Befehl &H08
'liest digital Wert INP8
'read digital INP8
Data "8;as,INP8;1;0,0;1,1"
'
Announce9:
'Befehl &H09
'liest digital Wert INP9
'read digital INP9
Data "9;as,INP9;1;0,0;1,1"
'
Announce10:
'Befehl &H0A
'liest digital Wert INP10
'read digital INP10
Data "10;as,INP10;1;0,0;1,1"
'
Announce11:
'Befehl &H0B
'liest digital Wert INP11
'read digital INP11
Data "11;as,INP11;1;0,0;1,1"
'
Announce12:
'Befehl &H0C
'liest analog Wert INP1
'read analog INP1
Data "12;ap,INP1;1;1024;lin;-"
'
Announce13:
'Befehl &H0D
'liest analog Wert INP2
'read analog INP2
Data "13;ap,INP2;1;1024;lin;-"
'
Announce14:
'Befehl &H0E
'liest analog Wert INP3
'read analog INP3
Data "14;ap,INP3;1;1024;lin;-"
'
Announce15:
'Befehl &H0F
'liest analog Wert INP4
'read analog INP4
Data "15;ap,INP4;1;1024;lin;-"
'
Announce16:
'Befehl &H10
'liest digital alle
'read digital all
Data"16;am,all;w,{0 to 4095}"
'
Announce17:
'Befehl &H11
'schaltet Relais1
'switch relais1
Data "17;os,relais1;1;0,off;1,on"
'
Announce18:
'Befehl &H12
'liest Status Relais1
'read state relais1
Data "18;as;as17"
'
Announce19:
'Befehl &H13
'schaltet Relais2
'switch relais2
Data "19;os,relais2;1;0,off;1,on"
'
Announce20:
'Befehl &H14
'liest Status Relais2
'read state relais2
Data "20;as;as19"
'
Announce21:
'Befehl &H15
'schaltet Relais3
'switch relais3
Data "21;os,relais3;1;0,off;1,on"
'
Announce22:
'Befehl &H16
'liest Status Relais3
'read state relais3
Data "22;as;as21"
'
Announce23:
'Befehl &H17
'schaltet Relais4
'switch relais4
Data "23;os, relais4;1;0,off;1,on"
'
Announce24:
'Befehl &H18
'liest Status Relais4
'read state relais4
Data "24;as;as23"
'
Announce25:
'Befehl &HEE
'schreibt Referenz default: 0:5V 1: 1.1V
'write reference voltage
Data "238;oa;a"
'
Announce26:
'Befehl &HEF
'liest Referenz default: 0:5V 1: 1.1V
'read reference voltage
Data "239;aa;as238"
'
Announce27:
'Befehl &HF0
'announcement aller Befehle lesen
'read announcement lines
Data "240;ln,ANNOUNCEMENTS;190;32"
'
Announce28:
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
'
Announce29:
'Befehl &HFD
'Geraet aktiv antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
Announce30:
'Befehl &HFE :
'eigene Individualisierung schreiben
'write individualization
Data "254;ka,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,8,{0 to 127};a,SERIAL,1"
'
Announce31:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;la,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,8,{0 to 127};a,SERIAL,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1"