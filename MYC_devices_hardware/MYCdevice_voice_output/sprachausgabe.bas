'name : sprachausgabe.bas
'Version V04.0 20190827
'purpose : Play 10 voice/music amples from ELV MSM4 module
'This Programm workes as I2C slave or using RS232
'Can be used with  sprachausgabe Version V02.0 by DK1RI
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
' MSM4 Modul input voltage must not exceed 3.3V! -> use open collector!
'------------------------------------------------------
'Missing/errors:
'
'------------------------------------------------------
$regfile = "m88pdef.dat"
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
Const Command_is_2_byte    = 0
'1...127:
Const I2c_address = 20
Const No_of_announcelines = 12
'announcements start with 0 -> minus 1
Const Tx_factor = 10
' For Test:10 (~ 10 seconds), real usage:1 (~ 1 second)
'
'----------------------------------------------------
$include "common_1.7\_Constants_and_variables.bas"
'
'stop for Timer1
Const T_factor = 1953
'20MHz / 1024 / 1953 = 10  Hz -> 100ms
Const T_Short = 3906
'0,2s
Const T_long = 50778
'2.6 s
'
Dim Timer_started As Byte
Dim Time_ As Word
Dim Time2 As Byte
' Time for pressed button
Dim Voicea As Byte
Dim Voiceb As Byte
Dim Mode_ As Byte
' During 10 seconds of transmit show transmit code
Dim Moduss As Byte
Dim Moduss_eeram As Eram Byte
' Playmode
Dim Pressed As Byte
' Button pressed for Modess = 2 or 3
'
'----------------------------------------------------
$include "common_1.7\_Macros.bas"
'
'----------------------------------------------------
$include "common_1.7\_Config.bas"
'
Wait 5
'----------------------------------------------------
$include "common_1.7\_Main.bas"
'
'----------------------------------------------------
$include "common_1.7\_Loop_start.bas"
'
'----------------------------------------------------
'check timer
If Timer_started = 1 Then
   If Timer1 > Time_ Then
      If Time2 > 0 Then
         Decr Time2
         If Time2 = 0 Then
            Gosub Control_sound_off
         Else
            TIMER1 = 0
            Start Timer1
         End If
      Else
         Gosub Control_sound_off
      End If
   End If
End If
'
'----------------------------------------------------
$include "common_1.7\_Serial.bas"
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
Control_sound:
' reset pins - > DDR to output -> set DDR
Timer_started = 1
Start Timer1
Select Case Voicea
   Case 1
      Set Voice1
   Case 2
      Set Voice2
   Case 3
      Set Voice3
   Case 4
      Set Voice4
   Case 5
      Set Voice5
   Case 6
      Set Voice6
   Case 7
      Set Voice7
   Case 8
      Set Voice8
   Case 9
      Set Voice9
   Case 10
      Set Voice10
End Select
If Time2 > 0 Then
   Select Case Voiceb
      Case 1
         Set Voice1
      Case 2
         Set Voice2
      Case 3
         Set Voice3
      Case 4
         Set Voice4
      Case 5
         Set Voice5
      Case 6
         Set Voice6
      Case 7
         Set Voice7
      Case 8
         Set Voice8
      Case 9
         Set Voice9
      Case 10
         Set Voice10
   End Select
End If
Return
'
Control_sound_off:
' open pins - > DDR to input -> reset DDR
Stop Timer1
Timer1 = 0
Timer_started = 0
Time_ = 0
Time2 = 0
Mode_ = 0
Pressed = 0
' Set to Input
ReSet Voice1
Reset Voice2
Reset Voice3
Reset Voice4
Reset Voice5
Reset Voice6
Reset Voice7
Reset Voice8
Reset Voice9
Reset Voice10
Return
'
'----------------------------------------------------
   $include "common_1.7\_Commandparser.bas"
'
'-----------------------------------------------------
   Case 1
'Befehl &H01 0 to 9
'spielt Sprache/Musik
'play voice/music
'Data "1;os,,sound;1;0;1;2;3;4;5;6;7;8;9"
      If Commandpointer >= 2 Then
         If Command_b(2) < 10 Then
            If Time2 = 0 Then
               ' T_modus must not interrupted
               If Moduss = 2 Or Moduss = 3 Then
                  If Pressed = 0 Then
                     Gosub Control_sound
                     Pressed = 1
                  Else
                     Gosub Control_sound_off
                     Pressed = 0
                  End If
               Else
                  Gosub Control_sound_off
                  Time_ = T_short
                  Voicea = Command_b(Commandpointer) + 1
                  'start Music
                  Gosub Control_sound
               End If
            Else
               Not_valid_at_this_time
            End If
         Else
            Parameter_error
         End If
         Gosub Command_received
      Else_Incr_Commandpointer
'
      Case 2
'Befehl &H02 0 to 9
'spielt Playliste
'play playlist
'Data "2;os,playlist;1;0;1;2;3;4;5;6;7;8;9"
         If Commandpointer >= 2 Then
            If Command_b(2) < 10 Then
               If Time2 = 0 Then
                  Gosub Control_sound_off
                  Time_ = T_long
                  Voicea = Command_b(Commandpointer) + 1
                  'start playlist
                  Gosub Control_sound
               Else
                  Not_valid_at_this_time
               End If
            Else
               Parameter_error
            End If
            Gosub Command_received
         Else_Incr_Commandpointer
'
      Case 3
'Befehl &H03 0 to 8
'Modi
'set modes
'Data "3;ou,modi;1;0,idle; 1,12;2,1+3;3.1+4;4,1+5;5,1+6;6,1+7;7,1+8;8,1+9;9,1+10;10,2+10"
         If Commandpointer >= 2 Then
            If Command_b(2) < 11 Then
               If Time2 = 0 Then
                  Gosub Control_sound_off
                  Time_ = T_long
                  Time2 = 6
                  Mode_ = Command_b(2)
                  If Mode_ = 10 Then
                     Voicea = 2
                     Voiceb = 10
                  Else
                     Voicea = 1
                     Voiceb = Command_b(2) + 2
                  End If
                  Gosub Control_sound
                  Pressed = 0
               Else
                  Parameter_error
               End If
            Else
               Parameter_error
            End If
            Gosub Command_received
         Else_Incr_Commandpointer
'
      Case 4
'Befehl &H04
'Modus Uebertragung
' read mode transmission
'Data "4;as,mode transmission;1;0,idle; 1,12;2,1+3;3.1+4;4,1+5;5,1+6;6,1+7;7,1+8;8,1+9;9,1+10;10,2+10;11,2+x"
         Tx_busy = 2
         Tx_time = 1
         Tx_b(1) = &H04
         If Time2 > 0 Then
            Tx_b(2) = 11
         Else
            Tx_b(2) = Mode_
         End If
         Tx_write_pointer = 3
         If Command_mode = 1 Then Gosub Print_tx
         Gosub Command_received
'
      Case 5
'Befehl &H03 0 to 8
'Modi
'set modes
'Data "3;os,modi;1;0,2+3;1,2+4;2,2+5;3,2+6;4,2+7;5,2+8;6,2+9"
         If Commandpointer >= 2 Then
            If Command_b(2) < 7 Then
               If Time2 = 0 Then
                  Moduss = Command_b(2)
                  Gosub Control_sound_off
                  Time_ = T_long
                  Time2 = 6
                  Voicea = 2
                  Voiceb = Command_b(2) + 3
                  Gosub Control_sound
               Else
                  Not_valid_at_this_time
               End If
            Else
               Parameter_error
            End If
            Gosub Command_received
         Else_Incr_Commandpointer
'
      Case 6
'Befehl &H04
'liest Modus
' read mode
'Data "6;au,as5"
         Tx_busy = 2
         Tx_time = 1
         Tx_b(1) = &H06
         Tx_b(2) = Moduss
         Tx_write_pointer = 3
         If Command_mode = 1 Then Gosub Print_tx
         Gosub Command_received
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
Announce0:
'Befehl &H00
'basic annoumement wird gelesen
'basic announcement is read
Data "0;m;DK1RI;Sprachausgabe;V04.0;1;145;1;13;1-1"
'
Announce1:
'Befehl &H01 0 to 9
'spielt Sprache/Musik
'play voice/music
Data "1;os,,sound;1;0;1;2;3;4;5;6;7;8;9"
'
Announce2:
'Befehl &H02 0 to 9
'spielt Playliste
'play playlist
Data "2;os,playlist;1;0;1;2;3;4;5;6;7;8;9"
'
Announce3:
'Befehl &H03 0 to 8
'Modi
'set modes
Data "3;ou,modi;1;0,idle; 1,12;2,1+3;3.1+4;4,1+5;5,1+6;6,1+7;7,1+8;8,1+9;9,1+10;10,2+10"
'
Announce4:
'Befehl &H04
'Modus Uebertragung
' read mode transmission
Data "4;as,mode transmission;1;0,idle; 1,12;2,1+3;3.1+4;4,1+5;5,1+6;6,1+7;7,1+8;8,1+9;9,1+10;10,2+10;11,2+x"
'
Announce5:
'Befehl &H03 0 to 8
'Modi
'set modes
Data "3;ot,modi;1;0,idle; 1,12;2,1+3;3.1+4;4,1+5;5,1+6;6,1+7;7,1+8;8,1+9;9,1+10; 10,2+10"
'
Announce6:
'Befehl &H04
'liest Modus
' read mode
Data "6;au,as5"
'
Announce7:
'Befehl &HF0<n><m>
'liest announcements
'read n announcement lines
Data "240;ln,ANNOUNCEMENTS;145;13"
'
Announce8:                                                  '
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
'
Announce9:                                                  '
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
Announce10:
'Befehl &HFE :
'eigene Individualisierung schreiben
'write individualization
Data "254;ka,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,20,{0 to 127};,SERIAL,1"
'
Announce11:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;la,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,20,{0 to 127};a,SERIAL,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1"
'
Announce12:
Data "R !$1 !$2 !R3 !R5 IF $4 > 0"