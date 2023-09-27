'name : FS20_8Kanal_rx.bas
'Version V07.0, 20230926
'purpose : Programm for receiving FS20 Signals
'Can be used with hardware FS20_interface V03.4 by DK1RI
'
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
' To run the compiler the directory common_1.13 with includefiles must be copied to the directory of this file!
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
'
'------------------------------------------------------
'Missing/errors:
'
'------------------------------------------------------
' Detailed description
'
'----------------------------------------------------
$regfile = "m1284pdef.dat"
'for ATMega1284
'
'-----------------------------------------------------
$crystal = 20000000
$include "common_1.13\_Processor.bas"
'
'----------------------------------------------------
'
'1...127:
Const I2c_address = 13
Const No_of_announcelines = 12
Const Tx_factor = 15
' For Test:15 (~ 10 seconds), real usage:2 (~ 1 second)
Const S_length = 32
'
'20MHz / 1024 / 1953 = 10  Hz -> 100ms
'stop for Timer1
Const T_factor = 1953
Const T_Short = 2
'0,2s
Const T_long = 50
'5 s
'
'----------------------------------------------------
$include "__use.bas"
$include "common_1.13\_Constants_and_variables.bas"
'
Dim K As Word
Dim Kk As Byte
Dim Switch As Byte
Dim Switch_status_old1 As Byte
Dim Switch_status_old2 As Byte
Dim Switch_status_old3 As Byte
Dim Switch_status_old4 As Byte
Dim Switch_status_old5 As Byte
Dim Switch_status_old6 As Byte
Dim Switch_status_old7 As Byte
Dim Switch_status_old8 As Byte
Dim Last_switch As Byte
Dim Last_status As Byte
Dim Busy As Byte
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
Gosub Check_input_status
'
'check timer
If Timer1 > T_factor Then
   Timer1 = 0
   Incr Kk
   If Kk > K Then Gosub Switch_off
End If
'
$include "common_1.13\_Main_end.bas"
'
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
'
'----------------------------------------------------
'
Check_input_status:
'This will not interrupt the F0 command
If Number_of_lines > 0 Then Return
B_temp1 = Not Out1
If Switch_status_old1 <> B_temp1 Then
   Last_switch = 1
   Last_status = B_temp1
   Switch_status_old1 = B_temp1
   Gosub status_changed
Else
   B_temp1 = Not Out2
   If Switch_status_old2 <> B_temp1 Then
      Last_switch = 2
      Last_status = B_temp1
      Switch_status_old2 = B_temp1
      Gosub Status_changed
   Else
      B_temp1 = Not Out3
      If Switch_status_old3 <> B_temp1 Then
         Last_switch = 3
         Last_status = B_temp1
         Switch_status_old3 = B_temp1
         Gosub Status_changed
      Else
         B_temp1 = Not Out4
         If Switch_status_old4 <> B_temp1 Then
            Last_switch = 4
            Last_status = B_temp1
            Switch_status_old4 = B_temp1
            Gosub Status_changed
         Else
            B_temp1 = Not Out5
            If Switch_status_old5 <> B_temp1 Then
               Last_switch = 5
               Last_status = B_temp1
               Switch_status_old5 = B_temp1
               Gosub Status_changed
            Else
               B_temp1 = Not Out6
               If Switch_status_old6 <> B_temp1 Then
                  Last_switch = 6
                  Last_status = B_temp1
                  Switch_status_old6 = B_temp1
                  Gosub status_changed
               Else
                  B_temp1 = Not Out7
                  If Switch_status_old7 <> B_temp1 Then
                     Last_switch = 7
                     Last_status = B_temp1
                     Switch_status_old7 = B_temp1
                     Gosub Status_changed
                  Else
                     B_temp1 = Not Out8
                     If Switch_status_old8 <> B_temp1 Then
                        Last_switch = 8
                        Last_status = B_temp1
                        Switch_status_old8 = B_temp1
                        Gosub Status_changed
                     End If
                  End If
               End If
            End If
         End If
      End If
   End If
End If
Return
'
Status_changed:
Tx_b(1) = &H06
Tx_b(2) = 2
Tx_b(3) = Last_switch + &H30
Tx_b(4) = Last_status + &H30
Tx_write_pointer = 5
If Command_mode = 1 Then Gosub Print_tx
Return
'
Switch_on:
   Select Case Switch
      Case 1:
         Config Ta1 = Output
         Reset Ta1
      Case 2:
         Config Ta2 = Output
         Reset Ta2
      Case 3:
         Config Ta3 = Output
         Reset Ta3
      Case 4:
         Config Ta4 = Output
         Reset Ta4
      Case 5:
         Config Ta5 = Output
         Reset Ta5
      Case 6:
         Config Ta6 = Output
         Reset Ta6
      Case 7:
         Config Ta7 = Output
         Reset Ta7
      Case 8:
         Config Ta8 = Output
         Reset Ta8
   End Select
   Start Timer1
   Busy = 1
Return
'
Switch_off:
   Stop Timer1
   Timer1 = 0
   Kk = 0
   Config Ta1 = Input
   Config Ta2 = Input
   Config Ta3 = Input
   Config Ta4 = Input
   Config Ta5 = Input
   Config Ta6 = Input
   Config Ta7 = Input
   Config Ta8 = Input
   Switch = 0
   Busy = 0
Return
'
'
'----------------------------------------------------
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