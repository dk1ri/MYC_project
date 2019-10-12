'-----------------------------------------------------------------------
'name : rtc_bascom.bas
'Version V03.0, 20191012
'purpose : Programm as realtime clock using the ELV RTC-DCF module
'The interface communicates with the module via SPI
'This Programm can be controlled via I2C or serial
'Can be used with hardware MYC_rtc Version V03.0 by DK1RI
'
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
$regfile = "m328pdef.dat"
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
Const I2c_address = 38
Const No_of_announcelines = 19
'announcements start with 0 -> minus 1
Const Tx_factor = 10
' For Test:10 (~ 10 seconds), real usage:1 (~ 1 second)
'
'----------------------------------------------------
$include "common_1.7\_Constants_and_variables.bas"
'
Const Length_spi = 11
Const Length_spi_1 = Length_spi - 1
Const Start_delay_end = 1000000
' 5 second about
'
Dim B_temp3w As Dword
Dim Year As Dword
Dim Day As Dword
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
Dim Spi_bytes as Byte
Dim Start_delay As Dword
'
'----------------------------------------------------
$include "common_1.7\_Macros.bas"
'
'----------------------------------------------------
$include "common_1.7\_Config.bas"
'
'----------------------------------------------------
Spiinit
Start_delay = 1
'
'----------------------------------------------------
$include "common_1.7\_Main.bas"
'
'----------------------------------------------------
$include "common_1.7\_Loop_start.bas"
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
$include "common_1.7\_Serial.bas"
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
Calculate_unix_time:
   Value_ = Spi_buffer(1)
   B_temp1 = Value_ AND &B01110000
   'seconds
   Shift B_temp1 ,Right , 4
   B_temp1 = B_temp1 * 10
   B_temp2 = Value_ And &B00001111
   B_temp2 = B_temp1 + B_temp2
   Unixtime = B_temp2
'
   Value_ = Spi_buffer(2)
   'minutes
   B_temp1 = Value_ And &B01110000
   Shift B_temp1 ,Right , 4
   B_temp1 = B_temp1 * 10
   B_temp2 = Value_ AND &B00001111
   B_temp2 = B_temp2 + B_temp1
   B_temp3w = B_temp2
   B_temp3w   = B_temp3w * 60
   Unixtime = Unixtime + B_temp3w
'
   Value_ = Spi_buffer(3)
   'hours
   B_temp1 = Value_ And &B00110000
   Shift B_temp1 ,Right , 4
   B_temp1 = B_temp1 * 10
   B_temp2 = Value_ And &B00001111
   B_temp2 = B_temp2 + B_temp1
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
   Decr B_temp2
   Day = B_temp2
   'without actual day
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
   'Year sinse 2000
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
'
   Tx_b(2) = 0
   Tx_b(3) = 0
   Tx_b(4) = 0
   Tx_b(5) = 0
   Tx_b(6) = Unixtime3
   'first 4 byte are 0  little endian -> big endian
   Tx_b(7) = Unixtime2
   Tx_b(8) = Unixtime1
   Tx_b(9) = Unixtime0
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
   $include "common_1.7\_Commandparser.bas"
'
'-----------------------------------------------------
'
   Case 1
'Befehl  &H01
'liest Uhrzeit
'read time
'Data "1;aa,read time;t"
      Tx_busy = 2
      Tx_time = 1
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
      Tx_b(1) = &H01
      Tx_write_pointer = 10
      If Command_mode = 1 Then  Gosub Print_tx
      Gosub Command_received
'
   Case 2
'Befehl  &H02 <0..14><m>
'schreibt register
'write register
'Data "2;om,write register;b;15"
      If Commandpointer >= 3 Then
         If Command_b(2) < 15 Then
            Spi_buffer1 = String(Length_spi, 0)
            Spi_buffer(1) = Command_b(2) + 128
            Spi_buffer(2) =  Command_b(3)
            Reset PortB.2
            Spiout Spi_buffer(1), 1
            Waitus 70
            Spiout Spi_buffer(2), 1
            Waitus 70
            Set PortB.2
         Else
            Parameter_error
         End If
         Gosub Command_received
      Else_Incr_Commandpointer
'
   Case 3
'Befehl  &H03 <0..14>
'liest register
'read register
'Data "3;am,as2"
      If Commandpointer >= 2 Then
         If Command_b(2) < 15 Then
            Tx_busy = 2
            Tx_time = 1
            Spi_buffer(1) = Command_b(2) + 192
            Reset PortB.2
            Waitus 70
            Spiout Spi_buffer(1), 1
            Waitus 70
            Spi_buffer1 = String(Length_spi, 0)
            Spiin Spi_buffer(1), 1
            Waitus 70
            Set PortB.2
            Tx_b(1) = &H03
            Tx_b(2) = Command_b(2)
            Tx_b(3) = Spi_buffer(1)
            TX_write_pointer = 4
            If Command_mode = 1 Then Gosub Print_tx
         Else
            Parameter_error
         End If
         Gosub Command_received
      Else_Incr_Commandpointer
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
'eigenes basic announcement lesen
'basic announcement is read to I2C or output
Data "0;m;DK1RI;RTC;V03.0;1;145;1;9;1-1"
'
Announce1:
'Befehl  &H01
'liest Uhrzeit
'read time
Data "1;aa,read time;t"
'
Announce2:
'Befehl  &H02 <0..14><m>
'schreibt register
'write register
Data "2;om,write register;b;15"
'
Announce3:
'Befehl  &H03 <0..14>
'liest register
'read register
Data "3;am,,as2"
'
Announce4:
'Befehl &HF0<n><m>
'liest announcements
'read n announcement lines
Data "240;ln,ANNOUNCEMENTS;145;9"
'
Announce5:                                                  '
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
'
Announce6:                                                  '
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
Announce7:
'Befehl &HFE :
'eigene Individualisierung schreiben
'write individualization
Data "254;ka,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,19,{0 to 127};a,SERIAL,1"
'
Announce8:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;la,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,19,{0 to 127};a,SERIAL,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1"
'