'-----------------------------------------------------------------------
'name : dtmf_sender.bas
'Version V05.0, 20191014
'purpose : Programm for sending MYC protocol as DTMF Signals
'This Programm workes as I2C slave or serial protocoll
'Can be used with hardware rs232_i2c_interface Version V05.0 by DK1RI
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
$regfile = "m88pdef.dat"
'$regfile = "m328pdef.dat"
'
'-----------------------------------------------------
$crystal = 10000000
$include "common_1.7\_Processor.bas"
'
'----------------------------------------------------
'
' 8: for 28/32pin, ATMEGAx8; 4 for 40/44pin, ATMEGAx4 packages
' used for reset now: different portnumber of SPI SS pin
Const Processor = "8"
Const Command_is_2_byte    = 0
'1...127:
Const I2c_address = 14
Const No_of_announcelines = 13
'announcements start with 0 -> minus 1
Const Tx_factor = 10
' For Test:10 (~ 10 seconds), real usage:1 (~ 1 second)
'
'----------------------------------------------------
$include "common_1.7\_Constants_and_variables.bas"
'
Dim Dtmf_duration As Byte
Dim Dtmf_duration_eeram As Eram Byte
Dim Dtmf_pause As Byte
Dim Dtmf_pause_eeram As Eram Byte
Dim Dtmf_char As Byte
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
$include "common_1.7\_Main.bas"
'
'----------------------------------------------------
$include "common_1.7\_Loop_start.bas"
'
'----------------------------------------------------
'RS232 got data?
Serial_in = Ischarwaiting()
If Serial_in = 1 Then
   Serial_in = Inkey()
   If no_myc = 1 Then
      If Serial_in = 32 Then
      'switch to myc mode again
         no_myc=0
         no_myc_eeram = no_myc
      Else
         Dtmf_char = Serial_in
         Gosub Send_dtmf
      End If
   Else
      If Serial_active = 1 Or Command_b(1) = 254 Then
         Command_mode = 1
         If Tx_busy = 0 Then
            Command_b(Commandpointer) = Serial_in
            Command_mode = 1
            Gosub Commandparser
         Else
            'do nothing
            Not_valid_at_this_time
         End If
      Else
         'do nothing
         Not_valid_at_this_time
      End If
   End If
End If
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
Send_dtmf:
   B_temp3 = 255
   Select Case Dtmf_char
     Case 48 to 57
        B_temp3 = Dtmf_char - 48
     Case  42
        B_temp3 = 10
     Case 35
        B_temp3 = 11
     Case 65 to 68
        B_temp3 = Dtmf_char - 53
     Case 97 to 100
        B_temp3 = Dtmf_char - 85
     Case Else
        Parameter_error
   End Select
   If B_temp3 <> 255 Then
     Printbin Dtmf_char
     Stop Watchdog
     Dtmfout B_temp3, dtmf_duration
     Start Watchdog
   End If
Return
'
'----------------------------------------------------
   $include "common_1.7\_Commandparser.bas"
'
   Case 1
'Befehl &H01
'liest string von I2C oder serial und sendet als DTMF
'read string from I2C or serial and send as DTMF
'Data "1;oa,send dtmf;250,{0 to 9,*,#,A to D}"
     If Commandpointer >= 2 Then
         If Commandpointer = 2 Then
            Incr Commandpointer
            If Command_b(2) = 0 Then Gosub Command_received
         Else
            B_temp1 = Command_b(2) + 2
            'Length
            If Commandpointer = B_temp1 Then
            'string finished
               For B_temp2 = 3 To B_temp1
                  Dtmf_char = Command_b(B_temp2)
                  Gosub Send_dtmf
                  If B_temp2 < B_temp1 Then
                     Stop Watchdog
                     Waitms dtmf_pause
                     Start Watchdog
                  End If
               Next B_temp2
               Gosub Command_received
            Else_Incr_Commandpointer
         End If
     Else_Incr_Commandpointer
'
   Case 234
'Befehl &HEA
'DTMF Länge schreiben
'write DTMF length
'Data "234;ka,DTMF Duration;b"
      If Commandpointer >= 2 Then
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
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
'                                          l
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
      Tx_b(1) = &HED
      Tx_b(2) = Dtmf_pause
      Tx_write_pointer = 3
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
'
   Case 238
'Befehl &HEE
'nomyc schreiben
'write nomyc
'Data "238;ka,no_myc;a"
      If Commandpointer >= 2 Then
         If Command_b(2) < 2 Then
            no_myc = Command_b(2)
            no_myc_eeram = no_myc
         Else
            Error_no = 4
            Error_cmd_no = Command_no
         End If
         Gosub Command_received
      Else_Incr_Commandpointer
'
   Case 239
'Befehl &HEF
'nomyc lesen
'read nomyc
'Data "239;la,as238"
      Tx_busy = 2
      Tx_time = 1
      Tx_b(1) = &HEF
      Tx_b(2) = no_myc
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
' ---> Rules announcements
                    Announce0:
'Befehl &H00
'basic annoumement wird gelesen
'basic announcement is read
Data "0;m;DK1RI;DTMF_sender;V05.0;1;145;1;13;1-1"
'
Announce1:
'Befehl &H01
'liest string von I2C oder serial und sendet als DTMF
'read string from I2C or serial and send as DTMF
Data "1;oa,send dtmf;250,{0 to 9,*,#,A to D}"
'
Announce2:
'Befehl &HEA
'DTMF Länge schreiben
'write DTMF length
Data "234;ka,DTMF Duration;b"
'
Announce3:
'Befehl &HEB
'Dtmf duration lesen
'read DTMF Länge
Data "235;la,as234"
'
Announce4:
'Befehl &HEC
'Dtmf Pause schreiben
'write DTMF Pause
Data "236;ka,DTMF Pause;b"
'
Announce5:
'Befehl &HED
'Dtmf Pause lesen
'read DTMF Pause
Data "237;la,as236"
'
Announce6:
'Befehl &HEE
'nomyc schreiben
'write nomyc
Data "238;ka,no_myc;a"
'
Announce7:
'Befehl &HEF
'nomyc lesen
'read nomyc
Data "239;la,as238"
'
Announce8:
'Befehl &HF0<n><m>
'announcement aller Befehle lesen
'read m announcement lines
Data "240;ln,ANNOUNCEMENTS;145;13"
'
Announce9:                                                  '
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
'
Announce10:                                                  '
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
Announce11:
'Befehl &HFE <n> <n>
'Individualisierung schreiben
'write indivdualization
Data "254;ka,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,7,{0 to 127};a,SERIAL,1"
'
Announce12:
'Befehl &HFF
'Individualisierung lesen
'read indivdualization
Data "255;la,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,7,{0 to 127};a,SERIAL,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1"
'