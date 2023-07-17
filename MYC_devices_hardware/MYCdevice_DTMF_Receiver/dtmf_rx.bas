'name : dtmf_receiver.bas
'Version V07.0, 20200715
'purpose : Programm for receiving DTMF Signals
'This Programm workes as I2C slave, or serial
'Can be used with hardware dtmf_receiver Version V03.0 by DK1RI
'
'++++++++++++++++++++++++++++++++++++++++++++++++++++
'
' ---> Description / name of program
'
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
' To run the compiler the directory comon_1,13 with includefiles must be copied to the directory of this file!
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
'
'----------------------------------------------------
$include "common_1.13\_Introduction_master_copyright.bas"
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
$regfile = "m88def.dat"
'
'-----------------------------------------------------
$crystal = 20000000
$include "common_1.13\_Processor.bas"
'
'----------------------------------------------------
'
'1...127:
Const I2c_address = 32
Const No_of_announcelines = 9
Const Tx_factor = 15
' For Test:15 (~ 10 seconds), real usage:2 (~ 1 second)
Const S_length = 32
'----------------------------------------------------
$include "__use.bas"
$include "common_1.13\_Constants_and_variables.bas"
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
$include "common_1.13\_Macros.bas"
'
'----------------------------------------------------
$include "common_1.13\_Config.bas"
'
'----------------------------------------------------
' procedures at start
'
'----------------------------------------------------
$include "common_1.13\_Main.bas"
'
'----------------------------------------------------
$include "common_1.13\_Loop_start.bas"
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
$include "common_1.13\_Main_end.bas"
'
'----------------------------------------------------
'
' End Main start subs
'
'----------------------------------------------------
$include "common_1.13\_Reset.bas"
'
'----------------------------------------------------
$include "common_1.13\_Init.bas"
'
'----------------------------------------------------
$include "common_1.13\_Subs.bas"
'----------------------------------------------------
'
$include "_Commands.bas"
$include "common_1.13\_Commands_required.bas"
'
$include "common_1.13\_Commandparser.bas"
'
'-----------------------------------------------------
' End
'
$include "_announcements.bas"
'