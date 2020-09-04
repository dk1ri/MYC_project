'name : FS20_8Kanal_rx_bascom.bas
'Version V06.2, 20200801
'purpose : Programm for receiving FS20 Signals
'Can be used with hardware FS20_interface V03.3 by DK1RI
'
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
' To run the compiler the directory common_1.11 with includefiles must be copied to the directory of this file!
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
'
'----------------------------------------------------
$include "common_1.11\_Introduction_master_copyright.bas"
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
$include "common_1.11\_Processor.bas"
'
'----------------------------------------------------
'
'1...127:
Const I2c_address = 13
Const No_of_announcelines = 10
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
$include "common_1.11\_Constants_and_variables.bas"
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

Dim Busy As Byte
'
'----------------------------------------------------
$include "common_1.11\_Macros.bas"
'
'----------------------------------------------------
$include "common_1.11\_Config.bas"
'
'----------------------------------------------------
' procedures at start
'
'----------------------------------------------------
$include "common_1.11\_Main.bas"
'
'----------------------------------------------------
$include "common_1.11\_Loop_start.bas"
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
$include "common_1.11\_Main_end.bas"
'
'
'----------------------------------------------------
'
' End Main start subs
'
'----------------------------------------------------
$include "common_1.11\_Reset.bas"
'
'----------------------------------------------------
$include "common_1.11\_Init.bas"
'
'----------------------------------------------------
$include "common_1.11\_Subs.bas"
'
'----------------------------------------------------
'
Check_input_status:
'This will not interrupt the F0 command
If Number_of_lines > 0 Then Return
B_temp2 = Not Sch1
If Switch_status_old1 <> B_temp2 Then
   Tx_b(2) = 0
   Switch_status_old1 = B_temp2
   Gosub status_changed
Else
   B_temp2 = Not Sch2
   If Switch_status_old2 <> B_temp2 Then
      Tx_b(2) = 1
      Switch_status_old2 = B_temp2
      Gosub Status_changed
   Else
      B_temp2 = Not Sch3
      If Switch_status_old3 <> B_temp2 Then
         Tx_b(2) = 2
         Switch_status_old3 = B_temp2
         Gosub Status_changed
      Else
         B_temp2 = Not Sch4
         If Switch_status_old4 <> B_temp2 Then
            Tx_b(2) = 3
            Switch_status_old4 = B_temp2
            Gosub Status_changed
         Else
            B_temp2 = Not Sch5
            If Switch_status_old5 <> B_temp2 Then
               Tx_b(2) = 4
               Switch_status_old5 = B_temp2
               Gosub Status_changed
            Else
               B_temp2 = Not Sch6
               If Switch_status_old6 <> B_temp2 Then
                  Tx_b(2) = 5
                  Switch_status_old6 = B_temp2
                  Gosub status_changed
               Else
                  B_temp2 = Not Sch7
                  If Switch_status_old7 <> B_temp2 Then
                     Tx_b(2) = 6
                     Switch_status_old7 = B_temp2
                     Gosub Status_changed
                  Else
                     B_temp2 = Not Sch8
                     If Switch_status_old8 <> B_temp2 Then
                        Tx_b(2) = 7
                        Switch_status_old8 = B_temp2
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
Tx_b(1) = &H01
Tx_b(3) = B_temp2
Tx_write_pointer = 4
If Command_mode = 1 Then Gosub Print_tx
Return
'
Switch_on:
   Select Case Switch
      Case 0
         Reset Ta1
      Case 1
         Reset Ta2
      Case 2
         Reset Ta3
      Case 3
         Reset Ta4
      Case 4
         Reset Ta5
      Case 5
         Reset Ta6
      Case 6
         Reset Ta7
      Case 7
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
   Porta = &HFF
   Switch = 0
   Busy = 0
Return
'
'
'----------------------------------------------------
$include "_Commands.bas"
$include "common_1.11\_Commands_required.bas"
'
$include "common_1.11\_Commandparser.bas"
'
'-----------------------------------------------------
' End
'
$include "_announcements.bas"
'