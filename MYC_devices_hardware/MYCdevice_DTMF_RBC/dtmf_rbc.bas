'-----------------------------------------------------------------------
'name : dtmf_rbc_bascom.bas
'Version V04.0, 20191014
'purpose : Programm for sending MYC protocol as DTMF Signals for remote Shack of MFJ (TM)
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
' Inputs /Outputs : see file __config
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
'$regfile = "m168def.dat"
$regfile = "m328pdef.dat"
'for ATMega328
'
'-----------------------------------------------------
$crystal = 10000000
$include "common_1.7\_Processor.bas"
'
'----------------------------------------------------
'
' 8: for 8/32pin, ATMEGAx8; 4 for 40/44pin, ATMEGAx4 packages
' used for reset now: different portnumber of SPI SS pin
Const Processor = "8"
Const Command_is_2_byte    = 0
'1...127:
Const I2c_address = 28
Const No_of_announcelines = 61
'announcements start with 0 -> minus 1
Const Tx_factor = 10
' For Test:10 (~ 10 seconds), real usage:1 (~ 1 second)
'
'----------------------------------------------------
$include "common_1.7\_Constants_and_variables.bas"
'
Dim Templ As Dword
Dim Templl As Dword
Dim Templll As Dword
Dim Templlll As Dword
Dim New_commandmode As Byte
Dim Commandmode As byte
' ! there is command_mode as well !!!!!
Dim Dtmf_duration As Byte
Dim Dtmfchar As Byte
Dim Dtmf_duration_eeram As Eram Byte
Dim Dtmf_pause As Byte
Dim Dtmf_pause_eeram As Eram Byte
Dim Vfo_a_b As Byte
Dim Memory_set_recall As Byte
Dim Antenna As Byte
Dim Func As Byte
Dim Ta As Byte
Dim Tb As Long
Dim Tc As Byte
Dim Td As Dword
Dim Te As Byte
Dim Tf As Byte
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
Dtmf:
   Dtmfout Dtmfchar , Dtmf_duration
   Printbin Dtmfchar
   Waitms Dtmf_pause
   Set DTMF_
Return
'
Send_dtmf:
'Convert Command_b -> Te digits
'Tb: limit
'Tc: Start DTMF character
'Td: highest divisor
'Te: number of digits
'Tf: end Dtmf character
'
Templ = Command_b(2)
If Ta > 2 Then
   'create Templ (Dword) from Ta - 1 bytes
   For B_temp1 = 3 To Ta
      Templ = Templ * 256
      Templ = Templ + Command_b(B_temp1)
   Next B_temp1
End If
If Templ < Tb Then
   'check limit
   If New_commandmode < 10 Then Gosub Setcommandmode
   If Tc < 255 Then
      Dtmfchar = Tc
      Gosub Dtmf
     End If
   'convert to Te  digits
   Templl = Td
   For B_temp1 = 1 To Te
      Templlll = Templ / Templl
      DTMFchar = Templlll
      Gosub Dtmf
      Templll = Dtmfchar * Templl
      Templ = Templ - Templll
      Templl = Templl / 10
   Next B_temp1
   If Tf < 255 Then
      Dtmfchar = Tf
      Gosub Dtmf
   End If
Else
   Error_no = 4
   Error_cmd_no = Command_no
End If
Gosub Command_received
Return
'
Frequency:
'long word / 4 byte 0 to 9999999 -> 7 digits
New_commandmode = 1
Tb = 10000000
Tc = Vfo_a_b
Td = 1000000
Te = 7
Tf = Vfo_a_b
Gosub Send_dtmf
Return
'
Memory:
'1 byte, 0 to 99 -> 2 digits
New_commandmode = 1
Tb = 100
Tc = Memory_set_recall
Td = 10
Te = 2
Tf = 255
Gosub Send_dtmf
Return
'
Single_dtmf_char:
   Gosub Setcommandmode
   DTMFchar = b_Temp1
   Gosub Dtmf
   Gosub Command_received
Return
'
Command3_1_5:
Gosub Setcommandmode
Select Case Command_b(2)
   Case 0                                       'off: 0 Func
      Dtmfchar = 0
      Gosub Dtmf
      Dtmfchar = Func
      Gosub Dtmf
   Case 1                                       'on: Func
      Dtmfchar = Func
      Gosub Dtmf
   Case Else
      Error_no = 4
      Error_cmd_no = Command_no
End Select
Gosub Command_received
'
Tx_function:
New_commandmode = 4
Gosub Setcommandmode
Select Case Command_b(2)
   Case 0
      Dtmfchar = Func
      Gosub Dtmf
      Dtmfchar = 1
      Gosub Dtmf
   Case 1
      Dtmfchar = Func
      Gosub Dtmf
      Dtmfchar = 2
      Gosub Dtmf
   Case 2
      Dtmfchar = Func
      Gosub Dtmf
      Dtmfchar = 3
      Gosub Dtmf
   Case 3
      If Func = 9 Then
         Dtmfchar = Func
         Gosub Dtmf
         Dtmfchar = 4
         Gosub Dtmf
      Else
         Error_no = 4
         Error_cmd_no = Command_no
      End If
   Case Else
      Error_no = 4
      Error_cmd_no = Command_no
End Select
Gosub Command_received
Return
'
Command6_:
New_commandmode = 6
Gosub Setcommandmode
Select Case Command_b(2)
   Case 0
      Dtmfchar = Func
      Gosub Dtmf
      Dtmfchar = 0
      Gosub Dtmf
   Case 1
      Dtmfchar = Func
      Gosub Dtmf
      Dtmfchar = 1
      Gosub Dtmf
   Case Else
      Error_no = 4
      Error_cmd_no = Command_no
End Select
Gosub Command_received
'
Setcommandmode:
   If Commandmode <> New_commandmode Then
      Commandmode = New_commandmode
      Dtmfchar = 11
      Gosub Dtmf
      Dtmfchar = New_commandmode
      Gosub Dtmf
   End If
Return
'
'
'----------------------------------------------------
   $include "common_1.7\_Commandparser.bas"
'
'-----------------------------------------------------
'
   Case 1
'Befehl &H01
'setzt FrequenzVFO A, command * VFOA  *
'set frequency
'Data "1;op,set frequency;1;10000000,{0 to 999999900};lin;Hz"
      If Commandpointer >= 5 Then
         Vfo_a_b = 10
         Gosub Frequency
      Else
         Incr Commandpointer
      End If
'
   Case 2
'Befehl &H02
'setzt Frequenz VFO B, command * VFOB #
'set frequency
'Data "2;op,set frequency;1;10000000,{0 to 999999900};lin;Hz"
      If Commandpointer >= 5 Then
         Vfo_a_b = 11
         Gosub Frequency
      Else_Incr_Commandpointer
'
   Case 3
'Befehl &H03
'gibt frequenz ausVFO A (als Sprache),  command **
'play frequency VFOA
'Data "3;ou,frequency VFO A;1;0;idle;1 play"
      Dtmfchar = 10
      Gosub Dtmf
      '*
      Gosub Dtmf
      Gosub Command_received
'
   Case 4
'Befehl &H04
'gibt frequenz aus (als Sprache),  command ##
'play frequency VFOB
'Data "4;ou,frequency VFOB;1;0,idle;1 play"
      Dtmfchar = 11
      Gosub Dtmf
      '#
      Gosub Dtmf
      Gosub Command_received
'
'Menu 1 RX
'
   Case 5
'Befehl &H05   0 to 3
'Aendert Frequenz um 1 Step; command #1 1 4 8 0
'change frequency 1 step
'Data"5;os,change frequency;1;0,+100;1,-100;2,+500;3,-500"
      If Commandpointer >= 2 Then
         If Command_b(2) < 4 Then
            New_commandmode = 1
            Gosub Setcommandmode
            Select Case Command_b(2)
               Case 0
                  Dtmfchar = 1
                  Gosub Dtmf
               Case 1
                  Dtmfchar = 4
                  Gosub Dtmf
               Case 2
                  Dtmfchar = 8
                  Gosub Dtmf
               Case 3
                  Dtmfchar = 0
                  Gosub Dtmf
            End Select
         Else
            Parameter_error
         End If
         Gosub Command_received
      Else_Incr_Commandpointer
'
   Case 6
'Befehl &H06    0 to 4
'startet scan,  command #1 2 3 5 6 0
'start scan
'Data"6;os,scan;0,medium up;1;1,fast up;2,medium down;3,fast down;4,stop"
      If Commandpointer = 2 Then
         If Command_b(2) < 5 Then
            New_commandmode = 1
            Gosub Setcommandmode
            Select Case Command_b(2)
               Case 0
                  Dtmfchar = 2
                  Gosub Dtmf
               Case 1
                  Dtmfchar = 3
                  Gosub Dtmf
               Case 2
                  Dtmfchar = 5
                  Gosub Dtmf
               Case 3
                  Dtmfchar = 6
                  Gosub Dtmf
               Case 4
                  Dtmfchar = 0
                  Gosub Dtmf
            End Select
         Else
           Parameter_error
         End If
         Gosub Command_received
      Else_Incr_Commandpointer
'
   Case 7
'Befehl &H07   0 to 99
'setzt memory, command #1 7 x x
'set memory
'Data "7;op,set memory;1;100,{0 to 99};lin;-"
      If Commandpointer >= 5 Then
         Memory_set_recall = 7
         Gosub Memory
      Else_Incr_Commandpointer
'
   Case 8
'Befehl &H08   0 to 99
'recall memory, command #1 9 x x
'recall memory
'Data "8;op,recall memory frequency;1;100,{0 to 99};lin;-"
      If Commandpointer >= 5 Then
         Memory_set_recall = 9
         Gosub Memory
      Else_Incr_Commandpointer
'
'=================================================0
'Menu 2  Antenna
'
   Case 9
'Befehl &H09
'Ant 1 ein, command #2 1
'Ant 1 on
'Data"9;ou,Ant1;1;0,idle;1,Ant1"
      New_commandmode = 2
      b_Temp1 = 1
      Gosub Single_dtmf_char
'
   Case 10
'Befehl &H0A
'Ant 2 ein command #2 2
'Ant 2 on
'Data "10;ou,Ant2;1.0;idle;1,Ant2"
      New_commandmode = 2
      b_Temp1 = 2
      Gosub Single_dtmf_char
'
   Case 11
'Befehl &H0B
'Tuner an, command #2 3
'Tuner on
'Data"11;ou,Tuner on;1;0,idle;1,tuner on"
      New_commandmode = 2
      b_Temp1 = 3
      Gosub Single_dtmf_char
'
   Case 12
'Befehl &H0C
'Tuner aus, command #2 6
'Tuner off
'Data"12;ou,Tuner off;1;0,idle;1,tuner off"
      New_commandmode = 2
      b_Temp1 = 6
      Gosub Single_dtmf_char
'
   Case 13
'Befehl &H0D
'Aux1 an, command #2 7
'Aux1 on
'Data"13;ou,Aux1 on;1;0,idle;1,aux1 on"
      New_commandmode = 2
      b_Temp1 = 7
      Gosub Single_dtmf_char
'
   Case 14
'Befehl &H0E
'Aux1 aus, command #2 8
'Aux1 off
'Data"13;ou,Aux1 off;1;0,idle;1,aux1 off"
      New_commandmode = 2
      b_Temp1 = 8
      Gosub Single_dtmf_char
'
   Case 15
'Befehl &H0F
'Tune Antenne command #2 9
'Tune Antenna
'Data"15;ou,Tune Antenna on;1;0,idle;1,tune antenna on"
      New_commandmode = 2
      b_Temp1 = 9
      Gosub Single_dtmf_char
'
   Case 16
'Befehl &H10
'0 to 359 dreht Antenne1, command #2 4 x x x
'Rotate Ant1
'Data "16;op,rotate Antenna 1;1;360,{0 to 359}"
      If Commandpointer >= 3 Then
         New_commandmode = 2
         Antenna = 4
         Tb = 361
         Tc = Antenna
         Td = 100
         Te = 3
         Tf = 255
         Gosub Send_dtmf
      Else_Incr_Commandpointer
'
   Case 17
'Befehl &H11
'0 to 359 dreht Antenne2, command #2 5 x x x
'Rotate Ant2
'Data "17;op,rotate Antenna 2;1;360,{0 to 359}"
      If Commandpointer >= 3 Then
         New_commandmode = 2
         Antenna = 5
         Tb = 361
         Tc = Antenna
         Td = 100
         Te = 3
         Tf = 255
         Gosub Send_dtmf
      Else_Incr_Commandpointer
'
   Case 18
'Befehl &H12
'stoppt Rotor, command #2 0
'stops rotation
'Data"18;ou,stop ratation;1;0,idle;1,stop antenna"
      New_commandmode = 2
      b_Temp1 = 0
      Gosub Single_dtmf_char
'
'=================================================0
'Menu 3  Filter
'
   Case 19
'Befehl &H13   0,1
'Abschwächer, command #3 1  or #3 0 1
'Attenuator
'Data"19;ou,Attenuator;1;0.idle;1,attenuator"
      If Commandpointer >= 2 Then
         New_commandmode = 3
         Func = 1
         Gosub Command3_1_5
      Else_Incr_Commandpointer
'
   Case 20
'Befehl &H14   0,1
'Vorverstärker, command #3 2 Or #3 0 2
'Preamp
'Data"20;ou,Preamp;1;0.idle;1,preamp"
      If Commandpointer >= 2 Then
         New_commandmode = 3
         Func = 2
         Gosub Command3_1_5
      Else_Incr_Commandpointer
'
   Case 21
'Befehl &H15   0,1
'Noiseblanker,command #3 3 Or #3 0 3
'Noiseblanker
'Data"21;ou,Noise blanker;1;0.idle;1,noise blanke"
      If Commandpointer >= 2 Then
         New_commandmode = 3
         Func = 3
         Gosub Command3_1_5
      Else_Incr_Commandpointer
'
   Case 22
'Befehl &H16   0,1
'Rauschunterdrückung, command #3 4 Or #3 0 4
'Noise reduction
'Data"22;ou,Noise reduction;1;0.idle;1,noise reduction"
      If Commandpointer >= 2 Then
         New_commandmode = 3
         Func = 4
         Gosub Command3_1_5
      Else_Incr_Commandpointer
'
   Case 23
'Befehl &H17   0,1
'Auto Notch #3 5 Or #3 0 5
'Auto notch
'Data"23;ou,Auto Notch;1;0.idle;1,auto notxh"
      If Commandpointer >= 2 Then
         New_commandmode = 3
         Func = 5
         Gosub Command3_1_5
      Else_Incr_Commandpointer
'
   Case 24
'Befehl &H18   0 to 2
'setzt filter, command #3 7.. 8... 9
'set filter
'Data"24;os,Filter;1;0,narrow;1,medium;2,wide"
      If Commandpointer >= 2 Then
         New_commandmode = 3
         Gosub Setcommandmode
         Select Case Command_b(2)
            Case 0
               Dtmfchar = 7
               Gosub Dtmf
            Case 1
               Dtmfchar = 8
               Gosub Dtmf
            Case 2
               Dtmfchar = 9
               Gosub Dtmf
            Case Else
               Error_no = 4
               Error_cmd_no = Command_no
         End Select
         Gosub Command_received
      Else_Incr_Commandpointer
'
   Case 25
'Befehl &H19
'alle Function aus, command #3 0 0
'all functions off
'Data"25;ou,all filter functions off;1;0,idle;1,all filter off"
      New_commandmode = 3
      Gosub Setcommandmode
      Dtmfchar = 0
      Gosub Dtmf
      Gosub Dtmf
      Gosub Command_received
'
   Case 26
'Befehl &H1A   0 to 4
'setzt Betriebsart, command #3 6 1, 2, 3, 4, 5
'set mode
'Data"26;os,Mode;1;0,LSB;1,USB;2,AM;3,CW;4,FM"
      If Commandpointer >= 2 Then
         If Command_b(2) < 5 Then
            New_commandmode = 3
            Gosub Setcommandmode
            Dtmfchar = 6
            Gosub Dtmf
            Select Case Command_b(2)
               Case 0
                  Dtmfchar = 1
                  Gosub Dtmf
               Case 1
                  Dtmfchar = 2
                  Gosub Dtmf
               Case 2
                  Dtmfchar = 3
                  Gosub Dtmf
               Case 3
                  Dtmfchar = 4
                  Gosub Dtmf
               Case 4
                  Dtmfchar = 5
                  Gosub Dtmf
            End Select
         Else
            Error_no = 4
            Error_cmd_no = Command_no
         End If
         Gosub Command_received
      Else_Incr_Commandpointer
'
'=================================================0
'Menu 4 TX
'
   Case 27
'Befehl &H1B   0,1
'Sprachkompressor, command #4 2 Or #4 0 2
'speech compressor
'Data"27;ou,spech compressor;1;0.idle;1,speech compressor"
      If Commandpointer >= 2 Then
         New_commandmode = 4
         Func = 2
         Gosub Command3_1_5
      Else_Incr_Commandpointer
'
   Case 28
'Befehl &H1C   0,1
'VOX, command #4 3 Or #4 0 3
'VOX
'Data"28;ou,VOX;1;0.idle;1,vox"
      If Commandpointer >= 2 Then
         New_commandmode = 4
         Func = 3
         Gosub Command3_1_5
      Else_Incr_Commandpointer
'
   Case 29
'Befehl &H1D   0,1
'Tone, command #4 4 Or #4 0 4
'Tone
'Data"29;ou,Tone;1;0.idle;1,tone"
      If Commandpointer >= 2 Then
         New_commandmode = 4
         Func = 4
         Gosub Command3_1_5
      Else_Incr_Commandpointer
'
   Case 30
'Befehl &H1E   0,1
'split, command #4 5 Or #4 0 5
'split
'Data"30;ou,split;1;0.idle;1,split"
      If Commandpointer >= 2 Then
         New_commandmode = 4
         Func = 5
         Gosub Command3_1_5
      Else_Incr_Commandpointer
'
   Case 31
'Befehl &H1F   0,1
'Vertärker #4 6 Or #4 0 6
'Amplifier
'Data"31;ou,Amplifier;1;0.idle;1,amplifier"
      If Commandpointer >= 2 Then
         New_commandmode = 4
         Func = 6
         Gosub Command3_1_5
      Else_Incr_Commandpointer

   Case 32
'Befehl &H20
'alle Sendefunctionen aus, command #4 0 0
'all tx functions off
'Data"32;ou,all TX functions off;1;0.idle;1,tx function off"
      New_commandmode = 4
      Gosub Setcommandmode
      Dtmfchar = 0
      Gosub Dtmf
      Gosub Dtmf
      Gosub Command_received
'
   Case 33
'Befehl  &H21  0 to 9999
'setzt tone Frequenz, command #4 7 x x x x
'set tone frequency
'Data "33;op,tone frequency;1;1000,{0 to 999,9};lin;Hz"
      If Commandpointer >= 3 Then
         New_commandmode = 4
         Tb = 10000
         Tc = 7
         Td = 1000
         Te = 4
         Tf = 255
         Gosub Send_dtmf
      Else_Incr_Commandpointer
'
   Case 34:
'Befehl &H22   0 to 2
'setzt shift,command #4 8 x
'set shift
'Data"34;os,Shift;1;0,simplex;1,+;2,-"
      If Commandpointer >= 2 Then
         Func = 8
         Gosub Tx_function
      Else_Incr_Commandpointer
'
   Case 35
'Befehl &H23      0 to 3
'Ausgangsleistung, command #4 9 x
'set power
'Data"35;os,power;1;0,25%;1,50%;2,75%;3,100%"
      If Commandpointer >= 2 Then
         Func = 9
         Gosub Tx_function
      Else_Incr_Commandpointer
'
'=================================================0
'Menu 6 Aux
'
   Case 36
'Befehl &H24   0,1
'AUX2 an au, command #6 2 0 Or #6 2 1
'AUX2 on off
'Data"36;ou,AUX2;1;0.idle;1,aux2"
      If Commandpointer >= 2 Then
         Func = 2
         Gosub Command6_
      Else_Incr_Commandpointer
'
   Case 37
'Befehl &H25   0,1         #
'AUX3 an au, command #6 3 0 Or #6 3 1
'AUX3 on off
'Data"37;ou,AUX3;1;0.idle;1,aux3"
      If Commandpointer >= 2 Then
         Func = 3
         Gosub Command6_
      Else_Incr_Commandpointer
'
   Case 38
'Befehl &H26   0,1
'AUX4 an au, command #6 4 0 Or #6 4 1
'AUX4 on off
'Data"38;ou,AUX4;1;0.idle;1,aux4"
      If Commandpointer >= 2 Then
         Func = 4
         Gosub Command6_
      Else_Incr_Commandpointer
'
   Case 39
'Befehl &H27   0,1
'AUX5 an au, command #6 5 0 Or #6 5 1
'AUX5 on off
'Data"39;ou,AUX5;1;0.idle;1,aux5"
      If Commandpointer >= 2 Then
         Func = 5
         Gosub Command6_
      Else_Incr_Commandpointer
'
   Case 40
'Befehl &H28   0,1
'AUX6 an au, command #6 6 0 Or #6 6 1
'AUX6 on off
'Data"40;ou,AUX6;1;0.idle;1,aux6"
      If Commandpointer >= 2 Then
         Func = 6
         Gosub Command6_
      Else_Incr_Commandpointer
'
   Case 41
'Befehl &H29   0,1
'AUX7 an au, command #6 7 0 Or #6 7 1
'AUX7 on off
'Data"41;ou,AUX7;1;0.idle;1,aux7"
      If Commandpointer >= 2 Then
         Func = 7
         Gosub Command6_
      Else_Incr_Commandpointer
'
   Case 42
'Befehl &H2A   0,1
'AUX8 an au, command #6 8 0 Or #6 8 1
'AUX8 on off
'Data"42;ou,AUX8;1;0.idle;1,aux8"
      If Commandpointer >= 2 Then
         Func = 8
         Gosub Command6_
      Else_Incr_Commandpointer
'
   Case 43
'Befehl &H2B   0,1
'AUX9 an au, command #6 9 0 Or #6 9 1
'AUX9 on off
'Data"43;ou,AUX9;1;0.idle;1,aux9"
      If Commandpointer >= 2 Then
         Func = 9
         Gosub Command6_
      Else_Incr_Commandpointer
'
'=================================================0
'menu 5: Settings
'
   Case 44
'Befehl &H2C
'reset, command #5 5
'reset
'Data"44;ou,reset;1;0.idle;1,reset"
      New_commandmode = 5
      Gosub Setcommandmode
      Dtmfchar = 5
      Gosub Dtmf
      Gosub Command_received
'
   Case 45
'Befehl &H2D
'Sprachlautstärke auf, command #5 8
'voice volume up
'Data"45;ou,voice volume up;1;0.idle;1,volume up"
      New_commandmode = 5
      Gosub Setcommandmode
      Dtmfchar = 8
      Gosub Dtmf
      Gosub Command_received
'
   Case 46
'Befehl &H2E
'Sprachlautstärke ab, command #5 0
'voice volume down
'Data"46;ou,voice volume down;1;0.idle;1,volume down"
      New_commandmode = 5
      Gosub Setcommandmode
      Dtmfchar = 0
      Gosub Dtmf
      Gosub Command_received
'
   Case 47
'Befehl &H2F   0 to 9
'Zahl der Ruftone, command#5 7 x
'number of ring
'Data"47;op,number of ring;1;10,{0 to 9}"
      If Commandpointer >= 2 Then
         New_commandmode = 5
         Tb = 10
         Tc = 7
         Td = 1
         Te = 1
         Tf = 255
         Gosub Send_dtmf
      Else_Incr_Commandpointer
'
   Case 48
'Befehl &H30   0 to 9999
'passwort festlegen, command #5 4 x x x x
'set password
'Data"48;om,set password;L,{0 to 9999}"
      If Commandpointer >= 3 Then
         New_commandmode = 5
         Tb = 10000
         Tc = 4
         Td = 1000
         Te = 4
         Tf = 255
         Gosub Send_dtmf
      Else_Incr_Commandpointer
'
'=================================================0
'Menu 4 Transmit
'
   Case 49
'Befehl &H31
'Sende ein, command #4 1
'transmit
'Data"49;ou,transmit;1;0.idle;1,transmit"
      New_commandmode = 4
      Gosub  Setcommandmode
      DTMFchar = 1
      Gosub Dtmf
      Gosub Command_received
'
   Case 50
'Befehl &H32
'Spielt Ch1 beim Senden, command #4 1
'play Ch1
'Data"50;ou,play Ch1;1;0.idle;1,play ch 1"
      New_commandmode = 4
      Gosub  Setcommandmode
      DTMFchar = 3
      Gosub Dtmf
      Gosub Command_received
'
'=================================================0
'Start
'
   Case 51
'Befehl &H33
'Start, command *
' start
'Data"51;ou,start;1;0.idle;1,start"
      DTMFchar = 10
      Gosub Dtmf
      Gosub Init
      Gosub Command_received
'
   Case 234
'Befehl &HEA
'DTMF Länge schreiben
'write DTMF length
'Data "234;ka,DTMF Duration;b"
      If Commandpointer = 2 Then
         Dtmf_duration = Command_b(2)
         Dtmf_duration_eeram = Dtmf_duration
         Gosub Command_received
      Else_Incr_Commandpointer
'
   Case 235
'Befehl &HEB
'Dtmf duration lesen
'read DTMF Länge
'Data "235;la,as234"
      Tx_busy = 2
      Tx_time = 1
      Tx_b(1) = &HEB
      Tx_b(2) = Dtmf_duration
      Tx_write_pointer = 3
      If Command_mode = 1 Then Gosub Print_Tx
      Gosub Command_received
'
   Case 236
'Befehl &HEC
'Dtmf Pause schreiben
'write DTMF Pause
'Data "236;ka,DTMF Pause;b"
      If Commandpointer >= 2 Then
         Dtmf_pause = Command_b(2)
         Dtmf_pause_eeram = Dtmf_pause
         Gosub Command_received
      Else_Incr_Commandpointer
'
   Case 237
'Befehl &HED
'Dtmf Pause lesen
'read DTMF Pause
'Data "237;la,as236"
      Tx_busy = 2
      Tx_time = 1
      Tx_b(1) = &HEB
      Tx_b(2) = Dtmf_pause
      Tx_write_pointer = 3
      If Command_mode = 1 Then Gosub Print_Tx
      Gosub Command_received
'
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
'announce text
'
Announce0:
'Befehl &H00
'eigenes basic announcement lesen
'basic announcement is read to I2C or output
Data "0;m;DK1RI;MFJ RBC Interface(TM);V04.0;1;145;1;61;1-1"
'
Announce1:
'Befehl &H01
'setzt FrequenzVFO A, command * VFOA  *
'set frequency
Data "1;op,set frequency;1;10000000,{0 to 999999900};lin;Hz"
'
Announce2:
'Befehl &H02
'setzt Frequenz VFO B, command * VFOB #
'set frequency
Data "2;op,set frequency;1;10000000,{0 to 999999900};lin;Hz"
'
Announce3:
'Befehl &H03
'gibt frequenz ausVFO A (als Sprache),  command **
'play frequency VFOA
Data "3;ou,frequency VFO A;1;0;idle;1 play"
'
Announce4:
'Befehl &H04
'gibt frequenz aus (als Sprache),  command ##
'play frequency VFOB
Data "4;ou,frequency VFOB;1;0,idle;1 play"
'
Announce5:
'Befehl &H05   0 to 3
'Aendert Frequenz um 1 Step; command #1 1 4 8 0
'change frequency 1 step
Data"5;os,change frequency;1;0,+100;1,-100;2,+500;3,-500"
'
Announce6:
'Befehl &H06    0 to 4
'startet scan,  command #1 2 3 5 6 0
'start scan
Data"6;os,scan;0,medium up;1;1,fast up;2,medium down;3,fast down;4,stop"
'
Announce7:
'Befehl &H07   0 to 99
'setzt memory, command #1 7 x x
'set memory
Data "7;op,set memory;1;100,{0 to 99};lin;-"
'
Announce8:
'Befehl &H08   0 to 99
'recall memory, command #1 9 x x
'recall memory
Data "8;op,recall memory frequency;1;100,{0 to 99};lin;-"
'
Announce9:
'Befehl &H09
'Ant 1 ein, command #2 1
'Ant 1 on
Data"9;ou,Ant1;1;0,idle;1,Ant1"
'
Announce10:
'Befehl &H0A
'Ant 2 ein command #2 2
'Ant 2 on
Data "10;ou,Ant2;1.0;idle;1,Ant2"
'
Announce11:
'Befehl &H0B
'Tuner an, command #2 3
'Tuner on
Data"11;ou,Tuner on;1;0,idle;1,tuner on"
'
Announce12:
'Befehl &H0C
'Tuner aus, command #2 6
'Tuner off
Data"12;ou,Tuner off;1;0,idle;1,tuner off"
'
Announce13:
'Befehl &H0D
'Aux1 an, command #2 7
'Aux1 on
Data"13;ou,Aux1 on;1;0,idle;1,aux1 on"
'
Announce14:
'Befehl &H0E
'Aux1 aus, command #2 8
'Aux1 off
Data"13;ou,Aux1 off;1;0,idle;1,aux1 off"
'
Announce15:
'Befehl &H0F
'Tune Antenne command #2 9
'Tune Antenna
Data"15;ou,Tune Antenna on;1;0,idle;1,tune antenna on"
'
Announce16:
'Befehl &H10
'0 to 359 dreht Antenne1, command #2 4 x x x
' Rotate Ant1
Data "16;op,rotate Antenna 1;1;360,{0 to 359}"
'
Announce17:
'Befehl &H11
'0 to 359 dreht Antenne2, command #2 5 x x x
'Rotate Ant2
Data "17;op,rotate Antenna 2;1;360,{0 to 359}"
'
Announce18:
'Befehl &H12
'stoppt Rotor, command #2 0
'stops rotation
Data"18;ou,stop ratation;1;0,idle;1,stop antenna"
'
Announce19:
'Befehl &H13   0,1
'Abschwächer, command #3 1  or #3 0 1
'Attenuator
Data"19;ou,Attenuator;1;0.idle;1,attenuator"
'
Announce20:
'Befehl &H14   0,1
'Vorverstärker, command #3 2 Or #3 0 2
'Preamp
Data"20;ou,Preamp;1;0.idle;1,preamp"
'
Announce21:
'Befehl &H15   0,1
'Noiseblanker,command #3 3 Or #3 0 3
'Noiseblanker
Data"21;ou,Noise blanker;1;0.idle;1,noise blanke"
'
Announce22:
'Befehl &H16   0,1
'Rauschunterdrückung, command #3 4 Or #3 0 4
'Noise reduction
Data"22;ou,Noise reduction;1;0.idle;1,noise reduction"
'
Announce23:
'Befehl &H17   0,1
'Auto Notch #3 5 Or #3 0 5
'Auto notch
Data"23;ou,Auto Notch;1;0.idle;1,auto notxh"
'
Announce24:
'Befehl &H18   0 to 2
'setzt filter, command #3 7.. 8... 9
'set filter
Data"24;os,Filter;1;0,narrow;1,medium;2,wide"
'
Announce25:
'Befehl &H19
'alle Function aus, command #3 0 0
'all functions off
Data"25;ou,all filter functions off;1;0,idle;1,all filter off"
'
Announce26:
'Befehl &H1A   0 to 4
'setzt Betriebsart, command #3 6 1, 2, 3, 4, 5
'set mode
Data"26;os,Mode;1;0,LSB;1,USB;2,AM;3,CW;4,FM"
'
Announce27:
'Befehl &H1B   0,1
'Sprachkompressor, command #4 2 Or #4 0 2
'speech compressor
Data"27;ou,spech compressor;1;0.idle;1,speech compressor"
'
Announce28:
'Befehl &H1C   0,1
'VOX, command #4 3 Or #4 0 3
'VOX
Data"28;ou,VOX;1;0.idle;1,vox"
'
Announce29:
'Befehl &H1D   0,1
'Tone, command #4 4 Or #4 0 4
'Tone
Data"29;ou,Tone;1;0.idle;1,tone"
'
Announce30:
'Befehl &H1E   0,1
'split, command #4 5 Or #4 0 5
'split
Data"30;ou,split;1;0.idle;1,split"
'
Announce31:
'Befehl &H1F   0,1
'Vertärker #4 6 Or #4 0 6
'Amplifier
Data"31;ou,Amplifier;1;0.idle;1,amplifier"
'
Announce32:
'Befehl &H20
'alle Sendefunctionen aus, command #4 0 0
'all tx functions off
Data"32;ou,all TX functions off;1;0.idle;1,tx function off"
'
Announce33:
'Befehl  &H21  0 to 9999
'setzt tone Frequenz, command #4 7 x x x x
'set tone frequency
Data "33;op,tone frequency;1;1000,{0 to 999,9};lin;Hz"
'
Announce34:
'Befehl &H22   0 to 2
'setzt shift,command #4 8 x
'set shift
Data"34;os,Shift;1;0,simplex;1,+;2,-"
'
Announce35:
'Befehl &H23      0 to 3
'Ausgangsleistung, command #4 9 x
'set power
Data"35;os,power;1;0,25%;1,50%;2,75%;3,100%"
'
Announce36:
'Befehl &H24   0,1
'AUX2 an au, command #6 2 0 Or #6 2 1
'AUX2 on off
Data"36;ou,AUX2;1;0.idle;1,aux2"
'
Announce37:
'Befehl &H25   0,1         #
'AUX3 an au, command #6 3 0 Or #6 3 1
'AUX3 on off
Data"37;ou,AUX3;1;0.idle;1,aux3"
'
Announce38:
'Befehl &H26   0,1
'AUX4 an au, command #6 4 0 Or #6 4 1
'AUX4 on off
Data"38;ou,AUX4;1;0.idle;1,aux4"
'
Announce39:
'Befehl &H27   0,1
'AUX5 an au, command #6 5 0 Or #6 5 1
'AUX5 on off
Data"39;ou,AUX5;1;0.idle;1,aux5"
'
Announce40:
'Befehl &H28   0,1
'AUX6 an au, command #6 6 0 Or #6 6 1
'AUX6 on off
'
Announce41:
'Befehl &H29   0,1
'AUX7 an au, command #6 7 0 Or #6 7 1
'AUX7 on off
Data"41;ou,AUX7;1;0.idle;1,aux7"
'
Announce42:
'Befehl &H2A   0,1
'AUX8 an au, command #6 8 0 Or #6 8 1
'AUX8 on off
Data"42;ou,AUX8;1;0.idle;1,aux8"
'
Announce43:
'Befehl &H2B   0,1
'AUX9 an au, command #6 9 0 Or #6 9 1
'AUX9 on off
Data"43;ou,AUX9;1;0.idle;1,aux9"
'
Announce44:
'Befehl &H2C
'reset, command #5 5
'reset
Data"44;ou,reset;1;0.idle;1,reset"
'
Announce45:
'Befehl &H2D
'Sprachlautstärke auf, command #5 8
'voice volume up
Data"45;ou,voice volume up;1;0.idle;1,volume up"
'
Announce46:
'Befehl &H2E
'Sprachlautstärke ab, command #5 0
'voice volume down
Data"46;ou,voice volume down;1;0.idle;1,volume down"
'
Announce47:
'Befehl &H2F   0 to 9
'Zahl der Ruftone, command#5 7 x
'number of ring
Data"47;op,number of ring;1;10,{0 to 9}"
'
Announce48:
'Befehl &H30   0 to 9999
'passwort festlegen, command #5 4 x x x x
'set password
Data"48;om,set password;L,{0 to 9999}"
'
Announce49:
'Befehl &H31
'Sende ein, command #4 1
'transmit
Data"49;ou,transmit;1;0.idle;1,transmit"
'
Announce50:
'Befehl &H32
'Spielt Ch1 beim Senden, command #4 1
'play Ch1
Data"50;ou,play Ch1;1;0.idle;1,play ch 1"
'
Announce51:
'Befehl &H33
'Start, command *
' start
Data"51;ou,start;1;0.idle;1,start"
'
Announce52:
'Befehl &HEA
'DTMF Länge schreiben
'write DTMF length
Data "234;ka,DTMF Duration;b"
'
Announce53:
'Befehl &HEB
'Dtmf duration lesen
'read DTMF Länge
Data "235;la,as234"
'
Announce54:
'Befehl &HEC
'Dtmf Pause schreiben
'write DTMF Pause
Data "236;ka,DTMF Pause;b"
'
Announce55:
'Befehl &HED
'Dtmf Pause lesen
'read DTMF Pause
Data "237;la,as236"
'
Announce56:
'Befehl &HF0<n><m>
'liest announcements
'read m announcement lines
Data "240;ln,ANNOUNCEMENTS;145;61"
'
Announce57:
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
'
Announce58:
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
Announce59:
'Befehl &HFE :
'eigene Individualisierung schreiben
'write individualization
Data "254;ka,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,14,{0 to 127};a,SERIAL,1"
'
Announce60:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;la,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,14,{0 to 127};a,SERIAL,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1"