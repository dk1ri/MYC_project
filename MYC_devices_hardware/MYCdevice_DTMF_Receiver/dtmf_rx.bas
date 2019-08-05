'name : dtmf_receiver.bas
'Version V04.0, 20190806
'purpose : Programm for receiving DTMF Signals
'This Programm workes as I2C slave, or serial
'Can be used with hardware dtmf_receiver Version V04.1 by DK1RI
'
'++++++++++++++++++++++++++++++++++++++++++++++++++++
'
' ---> Description / name of program
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
Const I2c_address = 16
Const No_of_announcelines = 9
'announcements start with 0 -> minus 1
Const Tx_factor = 10
' For Test:10 (~ 10 seconds), real usage:1 (~ 1 second)
'
'----------------------------------------------------
$include "common_1.7\_Constants_and_variables.bas"
'
Const Dtmf_length = Stringlength - 2
Dim Daten as Byte
Dim Valid_adress As Byte
Dim Valid_adress_eeram As Eram Byte
'
Dim Last_std As Byte
Dim DTMF_tone As Byte
Dim Dtmf_buffer As String * Dtmf_length
Dim Dtmf_buffer_b(Dtmf_length) As Byte At Dtmf_buffer Overlay
Dim Dtmf_read_pointer As Byte
Dim Dtmf_write_pointer As Byte
'DTMF Buffer pointer
'
'----------------------------------------------------
$include "common_1.7\_Macros.bas"
'
'----------------------------------------------------
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
'check DTMF
'STD goes high when detecting a signal
'must be low before
If Last_std = 0 Then
   If Std_ = 1 Then
   'new signal detected
      Dtmf_tone = 0
      DTMF_tone.3 = Q4
      DTMF_tone.2 = Q3
      DTMF_tone.1 = Q2
      DTMF_tone.0 = Q1
      Select Case DTMF_tone
      'recode to 0-9, *,#,A-D
         case 10
         '0
            DTMF_tone = 48
         Case 0
         'D
            DTMF_tone = 68
         Case 1 to 9
         ' 1 to 9
            DTMF_tone = DTMF_tone + 48
         Case 11
         '*
            Dtmf_tone = 42
         Case 12
         '#
            Dtmf_tone = 35
         Case 13 to 15
         'A-C
            DTMF_tone = DTMF_tone + 52
      End Select
      Last_std = 1
      If no_myc = 1 Then
         Printbin Dtmf_tone
      Else
         Dtmf_buffer_b(Dtmf_write_pointer) = Dtmf_tone
         Incr  Dtmf_write_pointer
         If Dtmf_write_pointer > Dtmf_length Then Dtmf_write_pointer = 1
         'Old data are overwritten
         If Dtmf_write_pointer = Dtmf_read_pointer Then Incr Dtmf_read_pointer
         If Dtmf_read_pointer >= Dtmf_length Then Dtmf_read_pointer = 1
      End If
   End If
Else
'Wait for Std_ to go Low
   If Std_ = 0 Then
   'DTMF Signal lost
      Last_std = 0
   End If
End If
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
'----------------------------------------------------
   $include "common_1.7\_Commandparser.bas"
'
'-----------------------------------------------------
'
   Case 1
'Befehl  &H01
'liest den DTMF-Speicher
'read DTMF buffer
'Data "1;aa,DTMF buffer;252,{0 to 9,*,#,A to D}"
      Tx_busy = 2
      Tx_time = 1
      Tx_b(1) = &H01
      B_temp1 = 3
      While Dtmf_write_pointer <> Dtmf_read_pointer
         Tx_b(B_temp1) = Dtmf_buffer_b(Dtmf_read_pointer)
         Incr Dtmf_read_pointer
         If Dtmf_read_pointer >= Dtmf_length Then Dtmf_read_pointer = 1
         Incr B_temp1
      Wend
      Tx_Write_pointer = B_temp1
      B_temp1 = B_temp1 - 3
      Tx_b(2) = B_temp1
      'Length
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
'
   Case 238
'Befehl  &HEE
'schaltet MYC / no_MYC mode
'switches MYC / no_MYC mode
'Data "238;ka,no_myc;a"
      If Commandpointer >= 2 Then
         If Command_b(2) < 2 Then
            no_myc = Command_b(2)
            no_myc_eeram = no_myc
         Else
            Parameter_error
         End If
         Gosub Command_received
      Else_Incr_Commandpointer
'
   Case 239
'Befehl  &HEF
'liest MYC / no_MYC mode
'read MYC / no_MYC mode
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
Announce0:
'Befehl &H00
'eigenes basic announcement lesen
'basic announcement is read to I2C or output
Data "0;m;DK1RI;DTMF receiver;V04.0;1;145;1;9;1-1"
'
Announce1:
'Befehl  &H01
'liest den DTMF-Speicher
'read DTMF buffer
Data "1;aa,DTMF buffer;252,{0 to 9,*,#,A to D}"
'
Announce2:
'Befehl  &HEE
'schaltet MYC / no_MYC mode
'switches MYC / no_MYC mode
Data "238;ka,no_myc;a"
'
Announce3:
'Befehl  &HEF
'liest MYC / no_MYC mode
'read MYC / no_MYC mode
Data "239;la,as238"
'
Announce4:
'Befehl &HF0<n><m>
'liest announcements
'read m announcement lines
Data "240;ln,ANNOUNCEMENTS;145;9"
'
Announce5:
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
'
Announce6:
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
Announce7:
'Befehl &HFE :
'eigene Individualisierung schreiben
'write individualization
Data "254;ka,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,16,{0 to 127};a,SERIAL,1"
'
Announce8:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;la,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,16,{0 to 127};a,SERIAL,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1"
'