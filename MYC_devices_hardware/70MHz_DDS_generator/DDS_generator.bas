'name : 70MHZ DDS Sender
'Version V01.1, 20210908
'purpose : Program for 70MHz DDS sender with AD9851
'This Programm workes as I2C slave or with serial protocol
'Can be used with hardware 70_Hz_dds_sender_eagle Version V02.1 by DK1RI
'Teile des Programms wurden aus "DDS AD9850 von 0 - 40 MHz mit ATtiny45" von Gerd Sinning uebernommen. Tnx
'
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
' To run the compiler the directory comon_1.11 with includefiles must be copied to the directory of this file!
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
' Timer1
'-----------------------------------------------------
' Inputs /Outputs : see file __config
' For announcements and rules see Data section in announcements.bas
'
'------------------------------------------------------
' Missing/errors:
' Power up after power down of AD9851 do not work; reason unknown
' So for power off frequency is set to 0. This reduce power by 40mA instead of 90mA
'
' MYC mode: nicht getestet
' RC5 Adresse korrekt?
'
'------------------------------------------------------
' Detailed description
'
'----------------------------------------------------
$regfile = "m328pdef.dat"
'
'-----------------------------------------------------
$crystal = 20000000
$include "common_1.11\_Processor.bas"
'
$initmicro
'
'----------------------------------------------------
'
'=========================================
' Dies Werte koenne bei Bedarf geaendert werden!!!
' These values must be modified on demand!!!!
' Number of loops for temperaturmeasurement
Const T_measure_time = 20000
' default RC5 adress
Const Rc5_address_def = 0
' Commxx are default RC5 codes
' Fxx are associated frequencies in Hz
Const Comm1 = 1
Const F1 = 0
Const Comm2 = 2
Const F2 = 151000
Const Comm3 = 3
Const F3 = 3510000
Const Comm4 = 4
Const F4 = 3650000
Const Comm5 = 5
Const F5 = 3790000
Const Comm6 = 6
Const F6 = 7100000
Const Comm7 = 7
Const F7 = 10065000
Const Comm8 = 8
Const F8 = 14050000
Const Comm9 = 9
Const F9 = 14175000
Const Comm10 = 56
Const F10 = 14345000
Const Comm11 = 0
Const F11 = 18065000
Const Comm12 = 34
Const F12 = 21050000
Const Comm13 = 87
const F13 = 21200000
Const Comm14 = 33
Const F14 = 21445000
Const Comm15 = 32
Const F15 = 24050000
Const Comm16 = 13
Const F16 = 28050000
Const Comm17 = 17
Const F17 = 28700000
Const Comm18 = 16
Const F18 = 29200000
Const Comm19 = 41
Const F19 = 296500000
Const Comm20 = 46
Const F20 = 50100000
'===================================
'
' 1 ... 127
Const I2c_address = 37
Const No_of_announcelines = 26
Const Tx_factor = 15
' For Test:15 (~ 10 seconds), real usage:2 (~ 1 second)
Const S_length = 32
Const Correct_default = &H7FFFFF
Const Clk0 = 180000000 - Correct_default
Const F_max = 70000000
Const DDS_command_on = &B00000001
Const Tk_default = &H7FFF
'
'----------------------------------------------------
$include "__use.bas"
$include "common_1.11\_Constants_and_variables.bas"
'
Dim S_temp1 As Single
Dim S_temp2 As Single
Dim S_temp3 As Single
Dim Do_temp1 As Double
Dim Dds_cmd As Byte
Dim Freq_in As Single
Dim Freq_in_old As Single
' serialout do not work with Double (_> Long)!!!
Dim Freq_data As Long
Dim Freq_accu As Double
Dim Clk_in As Double
Dim Correct As Dword
Dim Correct_eeram As Eram Dword
Dim Rcc As Byte
Dim Sensor As Byte
Dim Sensor_eeram As Eram Byte
' deg C
Dim Temperature As Word
Dim Temp_measure_eeram As Eram Word
Dim Tk As Word
Dim Tk_eeram As Eram Word
Dim Tk_measure As Byte
Dim T_measure As Word
Dim Rc5_adress_soll As Byte
Dim Rc5_adress_soll_eeram As Eram Byte
Dim Rc5_code(20) As Byte
Dim Rc5_code_eeram(20) As Eram Byte
Dim Rc_address As Byte
Dim Rc_command As Byte
Dim Rc_command_old As Byte
Dim IR_Myc_old As Byte
'
Waitms 100

'----------------------------------------------------
$include "common_1.11\_Macros.bas"
'
'----------------------------------------------------
$include "common_1.11\_Config.bas"
'
'----------------------------------------------------
$include "common_1.11\_Main.bas"
'
'----------------------------------------------------
$include "common_1.11\_Loop_start.bas"
B_temp1 = IR_Myc
If IR_Myc_old <> B_temp1 Then
   Waitms 100
   ' Stabilize switch
   B_temp1 = IR_Myc
   If IR_Myc_old <> B_temp1 Then
      IR_Myc_old = B_temp1
      If B_temp1 = 1 Then
         ' IR_mode: set Relais
         Set Relais
      Else
         ' MYC mode: defaulf off
         Reset Relais
      End If
      Freq_in = 0
      Gosub Dds_output
   End If
End If
B_temp1 = IR_Myc
If IR_Myc = 1 Then
   Stop Watchdog
   ' Infrared mode
   GetRC5(Rc_address , Rc_command)
   If Rc_command <> &HFF Then
      If Rc_command <> Rc_command_old Then
         Tx_time = 1
         Tx_b(1) = &H0F
         Tx_b(2) = Rc_address
         Tx_b(3) = Rc_command
         Tx_write_pointer = 4
         Gosub Print_tx
         Rc_command_old = Rc_command
         If Rc_address = Rc5_adress_soll Then
            Rcc = Rc_command And &B01111111
            print "A"
            S_temp1 = Freq_in
            Freq_in = 99999999
            If Rcc = Rc5_code(1) Then
               Freq_in = F1
            End If
            If Rcc = Rc5_code(2) Then
               Freq_in = F2
            End If
            If Rcc = Rc5_code(3) Then
               Freq_in = F3
            End If
            If Rcc = Rc5_code(4) Then
               Freq_in = F4
            End If
            If Rcc = Rc5_code(5) Then
               Freq_in = F5
            End If
            If Rcc = Rc5_code(6) Then
               Freq_in = F6
            End If
            If Rcc = Rc5_code(7) Then
               Freq_in = F7
            End If
            If Rcc = Rc5_code(8) Then
               Freq_in = F8
            End If
            If Rcc = Rc5_code(9) Then
               Freq_in = F9
            End If
            If Rcc = Rc5_code(10) Then
               Freq_in = F10
            End If
            If Rcc = Rc5_code(11) Then
               Freq_in = F11
            End If
            If Rcc = Rc5_code(12) Then
               Freq_in = F12
            End If
            If Rcc = Rc5_code(13) Then
               Freq_in = F13
            End If
            If Rcc = Rc5_code(14) Then
               Freq_in = F14
            End If
            If Rcc = Rc5_code(15) Then
               Freq_in = F15
            End If
            If Rcc = Rc5_code(16) Then
               Freq_in = F16
            End If
            If Rcc = Rc5_code(17) Then
               Freq_in = F17
            End If
            If Rcc = Rc5_code(18) Then
               Freq_in = F18
            End If
            If Rcc = Rc5_code(19) Then
               Freq_in = F19
            End If
            If Rcc = Rc5_code(20) Then
              Freq_in = F20
            End If
            If Freq_in = 99999999 Then
               ' other code, do nothing
               S_temp1 = Freq_in
            Else
               If Freq_in = F1 Then
                  Reset Relais
               Else
                  Set Relais
               End If
               Gosub Dds_output
            End If
         End If
      End If
   End If
   Start Watchdog
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
Return
'
'***************************************************************************
' Init_dds
'***************************************************************************
Init_dds:
Reset Wdat                                               'DATA                                '
Reset Wclk                                               'WCLK
Waitus 10
Set Wclk                                                 'WCLK
Waitus 10
Reset Wclk                                               'WCLK
Waitus 10
Set Fqud                                                 'FQUD
Waitus 10
Reset Fqud                                               'FQUD
Waitus 10
Return
'
Dds_output:
Clk_in = Clk0
Do_temp1 = Correct
Clk_in = Clk_in + Do_temp1
' Tk
S_temp1 = Freq_in
If Sensor = 1 Then
   If Tk <> Tk_default Then
      If Tk_measure = 0 Then
         ' S_temp1 is + or -'
         ' ppb / K:
         S_temp2 = Tk - Tk_default
         S_temp3 = Temperature
         W_temp1 = Temp_measure_eeram
         S_temp3 = S_temp3 - W_temp1
         ' 1/ deg -> deg:
         S_temp3 = S_temp3 / 10
         ' total ppb
         S_temp2 = S_temp2 * S_temp3
         ' total delta f:
         S_temp1 = Freq_in * S_temp2
         S_temp1 = S_temp1 / 1000000000
         ' new f:
         S_temp1 = Freq_in + S_temp1
      End If
   End If
End If
Do_temp1 = S_temp1
Freq_accu = Do_temp1 * &H100000000                        'calculate
Freq_accu = Freq_accu / Clk_in
Freq_data = Freq_accu
Shiftout Wdat , Wclk , Freq_data , 3 , 32 , 0            'DATA,WCLK LSB first
Shiftout Wdat , Wclk , Dds_cmd , 3 , 8 , 0               'DATA,WCLK
Waitus 10
Set Fqud                                                 'FQUD
Waitus 10
Reset Fqud
Return
'
Calc_temperature:
If Sensor = 1 Then
   W_temp1 = Getadc(0)
   'T / degC = W_temp1 * (5V / 1024)/(10mV /degK)  - 273
   S_temp1 = W_temp1 * 500
   ' mV:
   S_temp1 = S_temp1 / 1024
   S_temp1 = S_temp1 - 273.15
   ' thenth deg:
   Temperature = S_temp1 * 10
   If Tk <> Tk_default Then
      Gosub Dds_output
   End If
End If
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