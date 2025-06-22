'name : 50hz_sensor.bas
'Version V01.0, 20250612

'purpose : Program for 50HHz frequency sensor
'This Programm workes as I2C slave or with serial protocol or use a wireless interface
'Can be used with hardware Wireless_interface Version V02.1 by DK1RI
'This Interface can be used with a wireless interface
'
'
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
' To run the compiler the directory comon_1.14 with includefiles must be copied to the directory of this file!
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
'
'----------------------------------------------------
$include "common_1.14\_Introduction_master_copyright.bas"
'
'----------------------------------------------------
'
'Used Hardware:
' serial
' I2C
' Timer1
'-----------------------------------------------------
' Inputs / Outputs : see file __config.bas
' For announcements and rules see Data section in _announcements.bas

'
'------------------------------------------------------
'Missing/errors:
'
'------------------------------------------------------
' Detailed description
'
'----------------------------------------------------
$regfile = "m644def.dat"
'
'-----------------------------------------------------
$include "common_1.14\_Processor.bas"
$crystal = 20000000
'
'----------------------------------------------------
'
'
'=========================================
' Diese Werte koennen bei Bedarf geaendert werden!!!
' These values must be modified on demand!!!!
'
'1...127:
Const I2c_address = 28
Const No_of_announcelines = 23
'announcements start with 0
Const Tx_factor = 15
' For Test:15 (~ 10 seconds), real usage:2 (~ 1 second)
Const S_length = 50
'
'Radiotype 0: RFM95 900MHz; 1: RFM95 450MHz, 2: RFM95 150MHz, 3: nRF24 4: WLAN 5: RYFA689
'default RFM95 900MHz:
Const Radiotype = 3
Const Radioname = "radi"
Const Name_len = 5
'Interface: 0 other FU: 1:
Const InterfaceFU = 1
'----------------------------------------------------
$include "__use.bas"
$include "common_1.14\_Constants_and_variables.bas"
$include "common_1.14\wireless_constants.bas"
'
Dim Frequ As Word
Dim Frequency As Word
Dim Frequency_s As Single
Dim Frequency_B(2) As Byte at Frequency Overlay
Dim Minf As Word
Dim Minf_b(2) As Byte at Minf Overlay
Dim Maxf As Word
Dim Maxf_b(2) As Byte at Maxf Overlay
Dim Started As Byte
Dim Mean_f As Dword
Dim Mean_frequency As Word
Dim Mean_frequency_b(2) As Byte At Mean_frequency Overlay
'
waitms 100
print "start"
'----------------------------------------------------
$include "common_1.14\_Macros.bas"
'
'----------------------------------------------------
$include "common_1.14\_Config.bas"
'
'----------------------------------------------------
Restart:
'
'----------------------------------------------------
$include "common_1.14\_Main.bas"
'
'----------------------------------------------------
$include "common_1.14\_Loop_start.bas"
Gosub Calc_f
If wireless_active = 1 Then
   Select Case Radio_type
      Case 0
         Gosub Receive_wireless0
   End Select
End If	
'----------------------------------------------------
$include "common_1.14\_Main_end.bas"
'
'----------------------------------------------------
'
' End Main start subs
'
'----------------------------------------------------
$include "common_1.14\_Reset.bas"
'
'----------------------------------------------------
$include "common_1.14\_Init.bas"
'
'----------------------------------------------------
$include "common_1.14\_Subs.bas"
'
'----------------------------------------------------
'
Sub Read_time:
   Frequ = timer1
   Timer1 = 0
   Start Timer1
End Sub
'
Calc_f:
' May be, that not all frequ measurements are used
D_temp1 = Frequ
If Started = 0 Then
   If D_temp1 > 46999 And D_temp1 < 53001 Then
      Frequency = D_temp1 - 47000
      If Frequency < Minf Then
         Minf = Frequency
      End If
      If Frequency > Maxf Then
         Maxf = Frequency
      End If
   '   print "s"
    '  print frequency
     ' print mean_f
      Mean_f = Mean_f * 1000
      Mean_f = Mean_f + Frequency
   '   print mean_f
      Mean_f = Mean_f / 1001
      Mean_frequency = Mean_f
    '  print mean_f
   End If
Else
   ' skip some value
   Decr Started
End If
Return
'
'***************************************************************************
$include "common_1.14\_RFM95.bas"
$include "common_1.14\nrf24.bas"
   '$include "common_1.14\A7129_setup.bas"
   '$include  "common_1.14\A7129.bas"
   '$include "common_1.14\_RRYFA689.bas"
'
$include "_Commands.bas"
$include "common_1.14\_Commands_required.bas"
'
$include "common_1.14\_Commandparser.bas"
'
'-----------------------------------------------------
' End
'
$include "_announcements.bas"
'