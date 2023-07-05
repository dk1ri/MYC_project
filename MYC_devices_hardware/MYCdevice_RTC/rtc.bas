'-----------------------------------------------------------------------
'name : rtc_bascom.bas
'Version V04.1 20230705
'purpose : Programm as realtime clock using the ELV RTC-DCF module
'The interface communicates with the module via SPI
'This Programm can be controlled via I2C or serial
'Can be used with hardware MYC_rtc Version V03.1 by DK1RI
'
'
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
' To run the compiler the directory comon_1,12 with includefiles must be copied to the directory of this file!
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
' Inputs / Outputs : see file __config.bas
'
'------------------------------------------------------
'Missing/errors:
'
'------------------------------------------------------
'
' Detailed description
'
'----------------------------------------------------
$regfile = "m328pdef.dat"
'
'-----------------------------------------------------
$crystal = 20000000
$include "common_1.13\_Processor.bas"
'
'----------------------------------------------------
'
'1...127:
Const I2c_address = 19
Const No_of_announcelines = 14
Const Tx_factor = 15
' For Test:15 (~ 10 seconds), real usage:2 (~ 1 second)
Const S_length = 35
'
'----------------------------------------------------
$include "__use.bas"
$include "common_1.13\_Constants_and_variables.bas"
'
Const Length_spi = 11
Const Length_spi_1 = Length_spi - 1
Const Start_delay_end = 1000000
' 5 second about
'
Dim Second As Byte
Dim S_second As String * 5
Dim S_second_b(4) As Byte At S_second Overlay
Dim Minute As Byte
Dim S_minute As String * 5
Dim S_minute_b(4) As Byte At S_minute Overlay
Dim Hour As Byte
Dim S_hour As String * 5
Dim S_hour_b(4) As Byte At S_hour Overlay
Dim D_time As Dword
Dim D_time_b(4) As Byte At D_time Overlay
Dim B_temp3w As Dword
Dim Year As Dword
Dim Year_w As Word
Dim Day As Dword
Dim Day_b As Byte
Dim Month As Byte
Dim Unixtime As Dword
Dim Unixtime0 As Byte At Unixtime Overlay
Dim Unixtime1 As Byte At Unixtime + 1 Overlay
Dim Unixtime2 As Byte At Unixtime + 2 Overlay
Dim Unixtime3 As Byte At Unixtime + 3 Overlay
Dim Tage_seit_ja(12) As Word
Tage_seit_JA(1) = 31
'days since start of year at end of month without leap days
Tage_seit_JA(2) = 59
Tage_seit_JA(3) = 90
Tage_seit_JA(4) = 120
Tage_seit_JA(5) = 151
Tage_seit_JA(6) = 181
Tage_seit_JA(7) = 212
Tage_seit_JA(8) = 243
Tage_seit_JA(9) = 273
Tage_seit_JA(10) = 304
Tage_seit_JA(11) = 334
Dim Schaltjahre As Dword
Dim Value_ As Byte
Dim Spi_buffer(Length_spi) As Byte
Dim Spi_buffer1 As String * Length_spi_1 At Spi_buffer Overlay
Dim Start_delay As Dword
'
'----------------------------------------------------
$include "common_1.13\_Macros.bas"
'
'----------------------------------------------------
$include "common_1.13\_Config.bas"
'
'----------------------------------------------------
Spiinit
Start_delay = 1
'
'----------------------------------------------------
$include "common_1.13\_Main.bas"
'
'----------------------------------------------------
$include "common_1.13\_Loop_start.bas"
'
'----------------------------------------------------
If Start_delay > 0 Then
   ' wait for modul
   Incr Start_delay
   If Start_delay > Start_delay_end Then
      Start_delay = 0
      Gosub Start_dcf
   End If
End If
'
'----------------------------------------------------
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
'
'----------------------------------------------------
'
Read_time:
Waitus 70
Reset PortB.2
For B_temp1 = 1 To 7
   B_temp2 = B_temp1 + 191
   'read register 0 to 6
   Spiout B_temp2, 1
   Waitus 70
   Spiin Spi_buffer(B_temp1), 1
   Waitus 70
Next B_temp1
Set PortB.2
Gosub Calculate_unix_time
Return
'
Calculate_unix_time:
   ' each byte contain 2 BCD coded numbers
   Value_ = Spi_buffer(1)
   B_temp1 = Value_ AND &B01110000
   'seconds
   Shift B_temp1 ,Right , 4
   B_temp1 = B_temp1 * 10
   B_temp2 = Value_ And &B00001111
   B_temp2 = B_temp1 + B_temp2
   Unixtime = B_temp2
   Second = B_temp2
   S_second = str(Second)
   S_second = format(S_Second, "00")
   Value_ = Spi_buffer(2)
   'minutes
   B_temp1 = Value_ And &B01110000
   Shift B_temp1 ,Right , 4
   B_temp1 = B_temp1 * 10
   B_temp2 = Value_ AND &B00001111
   B_temp2 = B_temp2 + B_temp1
   B_temp3w = B_temp2
   Minute = B_temp2
   S_minute = str(Minute)
   S_minute = format(S_Minute, "00")
   B_temp3w   = B_temp3w * 60
   Unixtime = Unixtime + B_temp3w
'
   Value_ = Spi_buffer(3)
   'hours
   B_temp1 = Value_ And &B01110000
   Shift B_temp1 ,Right , 4
   B_temp1 = B_temp1 * 10
   B_temp2 = Value_ And &B00001111
   B_temp2 = B_temp2 + B_temp1
   Hour = B_temp2
   S_hour = str(Hour)
   S_hour = format(S_Hour, "00")
   B_temp3w = B_temp2
   B_temp3w = B_temp3w * 3600
   Unixtime = Unixtime + B_temp3w
   'seconds of actual day
'
 'day of week, not used
'
   Value_ = Spi_buffer(5)
   'day
   B_temp1 = Value_ And &B00110000
   Shift B_temp1 , Right , 4
   B_temp1 = B_temp1 * 10
   B_temp2 = Value_ And &B00001111
   B_temp2 = B_temp2 + B_temp1
   Day_b = B_temp2
   'without actual day
   Decr B_temp2
   Day = B_temp2
'
   Value_ = Spi_buffer(6)
   'month
   B_temp1 = Value_ And &B00010000
   Shift B_temp1 , Right , 4
   B_temp1 = B_temp1 * 10
   B_temp2 = Value_ And &B00001111
   Month = B_temp2 + B_temp1
   Decr Month
   'without actual month
   If Month = 0 Then
      B_temp3w = Day
   Else
      B_temp3w = Tage_seit_ja(Month)
      B_temp3w = B_temp3w + Day
      'all days since start of year without actual day
   End If
   B_temp3w = B_temp3w * 86400
   '60*60*24  seconds
   Unixtime = Unixtime + B_temp3w
   'all seconds since start of year   (no Leapday)
'
   Value_ = Spi_buffer(7)
   B_temp1 = Value_ And &B11110000
   Shift B_temp1 , Right , 4
   B_temp2 = Value_ And &B00001111
   B_temp1 = B_temp1 * 10
   B_temp2 = B_temp2 + B_temp1
   Year = B_temp2
   Year_w = Year + 2000
   'Year since 2000
   B_temp3w = Year + 30
   'complete years since 1. 1. 1970 (without actual year) (31 - 1)
'
   Schaltjahre = B_temp2 / 4
   'since 2001: Schaltjahre (leapyear)
   Schaltjahre = Schaltjahre + 8
   '8 leapyears from 1970  - 2000 inclusive
'
   B_temp3w = B_temp3w * 365
   B_temp3w = B_temp3w + Schaltjahre
   'one day per leapyear
'
   B_temp3w = B_temp3w * 86400
   '60*60*24   second of the past years
'
   Unixtime = Unixtime + B_temp3w
'
   B_temp2 = Year Mod 4
   'actual year is leapear? This work ok unitil 28.2.2100 :)
   B_temp1 = B_temp2 Mod 4
   If B_temp1 = 0 Then
      If Month > 2 Then
         Unixtime = Unixtime + 86400
      End If
   End If
   D_time = Hour * 60
   D_time = D_time + Minute
   D_time = D_time * 60
   D_time = D_time + Second
   Incr Month

Return
'
Start_dcf:
   Reset PortB.2
   B_temp1 = 141
   Spiout B_temp1, 1
   'Single write register D
   B_temp1 = 7
   Waitus 70
   Spiout B_temp1, 1
   'DCF on, Interrupt with DCF, LED on
   Waitus 70
   Set PortB.2
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