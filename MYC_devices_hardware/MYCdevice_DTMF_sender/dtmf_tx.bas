'-----------------------------------------------------------------------
'name : dtmf_sender.bas
'Version V05.1, 20191018
'purpose : Programm for sending MYC protocol as DTMF Signals
'This Programm workes as I2C slave or serial protocoll
'Can be used with hardware rs232_i2c_interface Version V05.1 by DK1RI
'
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
' To run the compiler the directory comon_1,10 with includefiles must be copied to the directory of this file!
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
'
'----------------------------------------------------
$include "common_1.10\_Introduction_master_copyright.bas"
'
'----------------------------------------------------
'
'Used Hardware:
' serial
' I2C
'-----------------------------------------------------
' Inputs /Outputs : see file __config
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
$include "common_1.10\_Processor.bas"
'
'----------------------------------------------------
'
'1...127:
Const I2c_address = 7
Const No_of_announcelines = 13
Const Tx_factor = 15
' For Test:15 (~ 10 seconds), real usage:2 (~ 1 second)
Const S_length = 32
'
'----------------------------------------------------
$include "__use.bas"
$include "common_1.10\_Constants_and_variables.bas"
'
Dim Dtmf_duration As Byte
Dim Dtmf_duration_eeram As Eram Byte
Dim Dtmf_pause As Byte
Dim Dtmf_pause_eeram As Eram Byte
Dim Dtmf_char As Byte
Dim Dtmf_string As String * Stringlength
Dim Dtmf_string_b(Stringlength) As Byte At Dtmf_string Overlay
'
'----------------------------------------------------
$include "common_1.10\_Macros.bas"
'
'----------------------------------------------------
$include "common_1.10\_Config.bas"
'
'----------------------------------------------------
$include "common_1.10\_Main.bas"
'
'----------------------------------------------------
$include "common_1.10\_Loop_start.bas"
'
'----------------------------------------------------
'RS232 got data?
If New_data = 1 Then
   New_data = 0
   If no_myc = 1 Then
      Commandpointer = Command_pointer
      If Command_b(Command_pointer) > 7 And Command_b(Command_pointer) < 240 Then
         If Command_b(Command_pointer) = Lf Then
            ' LF found
            Stop Watchdog
            For B_temp1 = 1 To Command_pointer
               Dtmf_char = Command_b(B_temp1)
               Gosub Send_dtmf
            Next B_temp1
            Start Watchdog
            Gosub Command_received
         End If
      Else
         'switch to myc mode again
         no_myc = 0
         no_myc_eeram = no_myc
         Gosub Check_command
      End If
   Else
      Gosub Check_command
   End If
End If
'
Stop Watchdog                                               '
Goto Loop_
'
'----------------------------------------------------
'
' End Main start subs
'
'----------------------------------------------------
$include "common_1.10\_Reset.bas"
'
'----------------------------------------------------
$include "common_1.10\_Init.bas"
'
'----------------------------------------------------
$include "common_1.10\_Subs.bas"
'
Check_command:
      If Command_b(1) = 0 Then
         Gosub Commandparser
      Else
            If Command_b(1) = &HFF And Command_b(2) = 254 Then
               Commandpointer = Command_pointer
               Gosub Commandparser
            Else
               If Serial_active = 1 And Command_mode = 1 Then
                  Commandpointer = Command_pointer
                  Gosub Commandparser
               Else
                  If I2c_active = 1 And Command_mode = 2 Then
                     Commandpointer = Command_pointer
                     Gosub Commandparser
                  Else
                     Command_pointer = 0
                     Not_valid_at_this_time
                  End If
               End If
            End If
      End If
Return
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
     Dtmfout B_temp3, Dtmf_duration
     Waitms dtmf_pause
   End If
Return
'
'----------------------------------------------------
$include "_Commands.bas"
$include "common_1.10\_Commands_required.bas"
'
$include "common_1.10\_Commandparser.bas"
'
'-----------------------------------------------------
' End
'
$include "_announcements.bas"
'