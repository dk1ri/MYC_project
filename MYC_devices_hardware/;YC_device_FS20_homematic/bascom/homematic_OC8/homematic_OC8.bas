'name : homematic_OC8.bas
'Version V06.2, 20200820
'purpose : Programm for receiving Homematic signal with HM-MOD-RE8
'Can be used with hardware FS20_interface V03.3 by DK1RI (not with earlier versions)
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
$crystal = 10000000
$include "common_1.11\_Processor.bas"
'
'----------------------------------------------------
'
'1..127:
Const I2c_address = 35
Const No_of_announcelines = 11
Const Tx_factor = 15
' For Test:15 (~ 10 seconds), real usage:2 (~ 1 second)
Const S_length = 32
'
Const T_factor = 1953
Const T_Short = 1
'0,1 s
Const T_long = 6
'0.6 s
'
'
'----------------------------------------------------
$include "__use.bas"
$include "common_1.11\_Constants_and_variables.bas"
'
Dim Switch_status As Byte
Dim Switch As Byte
Dim K as Word
Dim Kk As Byte
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
$initmicro
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
$include "common_1.11\_Main_end.bas"
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
_init_micro:
Config Sp_ = Input
Config Tp_ = Input
Config Up_ = Input
Config Vp_ = Input
Config Wp_ = Input
Config Xp_ = Input
Config Yp_ = Input
Config Zp_ = Input
Return
'
Check_input_status:
'This will not interrupt the F0 command
If Number_of_lines > 0 Then Return
B_temp2 = Not Out1
If Switch_status_old1 <> B_temp2 Then
   Tx_b(2) = 1
   Switch_status_old1 = B_temp2
   Gosub status_changed
Else
   B_temp2 = Not Out2
   If Switch_status_old2 <> B_temp2 Then
      Tx_b(2) = 2
      Switch_status_old2 = B_temp2
      Gosub Status_changed
   Else
      B_temp2 = Not Out3
      If Switch_status_old3 <> B_temp2 Then
         Tx_b(2) = 3
         Switch_status_old3 = B_temp2
         Gosub Status_changed
      Else
         B_temp2 = Not Out4
         If Switch_status_old4 <> B_temp2 Then
            Tx_b(2) = 4
            Switch_status_old4 = B_temp2
            Gosub Status_changed
         Else
            B_temp2 = Not Out5
            If Switch_status_old5 <> B_temp2 Then
               Tx_b(2) = 5
               Switch_status_old5 = B_temp2
               Gosub Status_changed
            Else
               B_temp2 = Not Out6
               If Switch_status_old6 <> B_temp2 Then
                  Tx_b(2) = 6
                  Switch_status_old6 = B_temp2
                  Gosub status_changed
               Else
                  B_temp2 = Not Out7
                  If Switch_status_old7 <> B_temp2 Then
                     Tx_b(2) = 7
                     Switch_status_old7 = B_temp2
                     Gosub Status_changed
                  Else
                     B_temp2 = Not Out8
                     If Switch_status_old8 <> B_temp2 Then
                        Tx_b(2) = 8
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