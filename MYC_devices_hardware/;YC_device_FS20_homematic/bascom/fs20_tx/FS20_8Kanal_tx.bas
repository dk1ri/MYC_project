'-----------------------------------------------------------------------
'name : Fs20_8_kanal_tx.bas
'Version V06.2, 20200808
'purpose : Programm for sending FS20 Signals
'Can be used with hardware FS20_interface V03.3 by DK1RI
'
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
'1..127:
Const I2c_address = 12
Const No_of_announcelines = 30
Const Tx_factor = 15
' For Test:15 (~ 10 seconds), real usage:2 (~ 1 second)
Const S_length = 32
'
'20MHz / 1024 / 1953 = 10  Hz -> 100ms
'stop for Timer1
Const T_factor = 1953
Const T_Short = 1
'0,1 s
Const T_long = 6
'0.6 s
Const T_timer = 20
'2 s for timer
Const T_modus = 60
'6 s
'----------------------------------------------------
$include "__use.bas"
$include "common_1.11\_Constants_and_variables.bas"
'
Dim K as Word
Dim Kk As Byte
Dim Switch As Byte
Dim Switch1 As Byte
Dim Send_length As Byte
' Number of messages to transfer
Dim Send_code As Byte
Dim Code4 As String * 160
Dim Code4_b(160) As Byte At Code4 Overlay
Dim Code4_eeram As Eram String * 160
' 10set, 4 chanals, 4 adressbytes
Dim Code8 As String * 320
Dim Code8_eeram As Eram String * 320
Dim Code8_b(320) As Byte At Code8 Overlay
'
Dim Housecode As String * 8
Dim Housecode_b(8) As Byte At Housecode Overlay
Dim Housecode_eeram As Eram String * 8
' contain 8 2 bit values (Ascii 1 to 4) - 48 -> Switch number 1 to 4
Dim Kanal_mode As Byte
Dim Kanal_mode_eeram As Eram Byte
'0: 4 Kanal, 1: 8 Kanal
Dim Set4 As Byte
Dim Set4_eeram As Eram Byte
Dim Set8 As Byte
Dim Set8_eeram As Eram Byte
Dim Busy As Byte
Dim S_temp10 As String * 10
Dim S_temp10_b(10) As Byte At S_temp10  Overlay
Dim Send_string As String * 10
Dim Send_string_b(10) As Byte At Send_string Overlay
Dim Send_pointer As Byte
Dim Pause As Byte
' 0: off, idle 1: check for nfinish  2: first
Dim Funktion_pointer As Byte
Dim Change_set_active As Byte
Dim Dimming As Byte
Dim Dimm_chanal As Byte
Dim 8chanal_pre As Byte
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
'check timer
If Timer1 > T_factor Then
   Timer1 = 0
   Incr Kk
   If Kk > K Then Gosub Switch_off
End If
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
_init_micro:
' no Sofort-Senden-Mode
Config PortC.7 = Output '1 Modul Output_1
PortC.7 = 0
Config PortC.6 = Output '2 Modul Output_2
PortC.6 = 0
Config PortC.5 = Output '3 Modul Output_3
PortC.5 = 1
Config PortC.4 = Output '4 Modul Output_4
PortC.4 = 1
Config PortC.3 = Output '5 Modul Output_5
Portc.3 = 1
Config Portc.2 = Output '6 Modul Output_6
Portc.2 = 1
Config portd.7 = Output '7 Modul Output_7
Portd.7 = 1
Config Portd.6 = Output '8 Modul Output 8
Portd.6 = 1
Wait 1
Return
'
Change_set:
   If Kanal_mode = 0 Then
      ' 4 chanals
      B_temp1 = Set4 * 16
      B_temp2 = Funktion_pointer - 1
      B_temp2 = B_temp2 * 4
      B_temp1 = B_temp1 + B_temp2
      Incr B_temp1
      ' from here 4 Byte of Adress
      For B_temp2 = 1 To 4
         Send_string_b(B_temp2) = Code4_b(B_temp1) - 48
         B_temp3 = Code4_b(B_temp1)
         Incr B_temp1
      Next B_temp2
      Send_length = 4
      Send_pointer = 1
      Pause = 2
      Switch = Funktion_pointer * 2
      ' 2,4,6,8
      Switch1 = Switch - 1
      ' 1,3,5,7,7
      K = T_modus
      Gosub Switch_on
      Incr Funktion_pointer
      If Funktion_pointer = 5 Then
         ' this is the last
         Change_set_active = 0
      End If
   Else
      ' 8 chanals
      If 8chanal_pre = 1 Then
         ' set the channal for 100ms
         Switch = Funktion_pointer
         Switch1 = 0
         ' will not switch off, pause only
         8chanal_pre = 2
         K = T_short
         Pause = 2
         print "q"
         Send_length = 0
         Send_pointer = 1
         Gosub Switch_on
      Else
         If 8chanal_pre = 3 Then
            ' set the button beneeth as well
            B_temp1 = Set8 * 32
            B_temp2 = Funktion_pointer - 1
            B_temp2 = B_temp2 * 4
            B_temp1 = B_temp1 + B_temp2
            Incr B_temp1
            ' from here 4 Byte of Adress
            For B_temp2 = 1 To 4
               Send_string_b(B_temp2) = Code8_b(B_temp1) - 48
               B_temp3 = Code8_b(B_temp1)
               Incr B_temp1
            Next B_temp2
            Send_length = 4
            Send_pointer = 1
            Pause = 2
            Select Case Funktion_pointer
               Case 1 To 2
                  Switch = 1
                  Switch1 = 2
               Case 3 To 4
                  Switch = 3
                  Switch1 = 4
               Case 5 To 6
                  Switch = 5
                  Switch1 = 6
               Case 7 To 8
                  Switch = 7
                  Switch1 = 8
            End Select
            K = T_modus
            Gosub Switch_on
            Incr Funktion_pointer
            8chanal_pre = 1
            If Funktion_pointer = 9 Then
               ' this is the last
               Change_set_active = 0
               8chanal_pre = 0
            End If
         End If
      End If
   End If
Return
'
Switch_on:
If Switch1 <> 0 Then printbin Switch1
   Select Case Switch
      Case 1
         Reset Ta1
      Case 2
         Reset Ta2
      Case 3
         Reset Ta3
      Case 4
         Reset Ta4
      Case 5
         Reset Ta5
      Case 6
         Reset Ta6
      Case 7
         Reset Ta7
      Case 8
         Reset Ta8
   End Select
   Select Case Switch1
      Case 1
         Reset Ta1
      Case 2
         Reset Ta2
      Case 3
         Reset Ta3
      Case 4
         Reset Ta4
      Case 5
         Reset Ta5
      Case 6
         Reset Ta6
      Case 7
         Reset Ta7
      Case 8
         Reset Ta8
   End Select
   Busy = 1
   If Dimming = 0 Then Start Timer1
Return
'
Switch_off:
   Stop Timer1
   Timer1 = 0
   Kk = 0
   If Pause = 2 Then
      If 8chanal_pre <> 2 Then
      ' switch off, initiate pause
         Gosub Switch_off1
      Else
         ' pause only
         8chanal_pre = 3
      End If
'      print "P"
      K = T_short
      Pause = 1
      Start Timer1
   Else
      If Pause = 1 Then
         ' pause finished
         If Send_pointer > Send_length Then
            If Change_set_active = 1 Then
               Gosub Change_set
            Else
               ' all done
               Busy = 0
               Pause = 0
            End If
         Else
            ' mext message, initiate pause
            Switch = Send_string_b(Send_pointer)
            Switch1 = 0
            Incr Send_pointer
            K = T_short
            Pause = 2
            Gosub Switch_on
         End If
      Else
         ' Pause = 0
         Gosub Switch_off1
         Busy = 0
      End If
   End If
Return
'
Switch_off1:
      Set Ta1
      Set Ta2
      Set Ta3
      Set Ta4
      Set Ta5
      Set Ta6
      Set Ta7
      Set Ta8
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