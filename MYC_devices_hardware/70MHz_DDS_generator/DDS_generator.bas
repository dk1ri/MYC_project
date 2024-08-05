'name : 70MHZ DDS Sender
'Version V03.4, 20240802
'purpose : Program for 70MHz DDS sender with AD9851
'This Programm workes as I2C slave or with serial protocol
'Can be used with hardware 70_Hz_dds_sender_eagle Version V02.1 by DK1RI
'Teile des Programms wurden aus "DDS AD9850 von 0 - 40 MHz mit ATtiny45" von Gerd Sinning uebernommen. Tnx
'
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
' To run the compiler the directory comon_1.13 with includefiles must be copied to the directory of this file!
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
'
' for any reason IR reception is not working, so IR mode is disabled
'
'----------------------------------------------------
$include "common_1.13\_Introduction_master_copyright.bas"
'
'----------------------------------------------------
'
'Used Hardware:
' serial
' I2C
' Timer0 for RC5
'-----------------------------------------------------
' Inputs /Outputs : see file __config
' For announcements and rules see Data section in announcements.bas
'
'------------------------------------------------------
' Missing/errors:
'
'
'------------------------------------------------------
' Detailed description
'
'----------------------------------------------------
$regfile = "m328pdef.dat"
'
'-----------------------------------------------------
$crystal = 20000000
$include "common_1.13\_Processor.bas"
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
' som e default
Const F1 = 10000000
Const Comm2 = 2
Const F2 = 1510000
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
Const F19 = 29650000
Const Comm20 = 46
Const F20 = 50100000
'===================================
'
' 1 ... 127:
Const I2c_address = 37
Const No_of_announcelines = 43
Const Tx_factor = 15
' For Test:15 (~ 10 seconds), real usage:2 (~ 1 second)
Const S_length = 32
Const Correct_default = 1
' 4294967296 / 180000000 =  23,85926275555556             2exp2 / sysclk
Const Factor_accu =23.85926275555556
Const F_max = 70000000
Const DDS_command_on =  &B00000001
Const Tk_default = 1
'
' with IR working should be set to 1:
Const Ir_mode_default = 0
'
'----------------------------------------------------
$include "__use.bas"
$include "common_1.13\_Constants_and_variables.bas"
'
Dim Si_temp1 As Single
Dim Str_temp1 As String * 3
Dim Dds_cmd As Byte
Dim Freq_in As Single
Dim Freq (20) As Single
Dim Freqe(20) As Eram Single
' serialout do not work with Double (_> Long)!!!
Dim Freq_data As Dword
Dim Correct As Single
Dim Correct_eeram As Eram Single
Dim Rcc As Byte
Dim Sensor As Byte
Dim Sensor_eeram As Eram Byte
' deg C
Dim Temperature As Word
Dim Temp_measure As Word
Dim Temp_measure_eram As Eram Word
Dim Tmin As Word
Dim Tmax As Word
Dim F_at_tmin As Single
Dim F_at_tmax As Single
' deviation is max + - 32767Hz at 70 MHz -> 0.0004681/K
' relative deviation 1/K
Dim Tk As Single
Dim Tk_eeram As Eram Single
Dim Tk_measure As Byte
Dim T_measure As Word
Dim Rc5_adress_soll As Byte
Dim Rc5_adress_soll_eram As Eram Byte
Dim Rc5_address As Byte
Dim Rc5_last As String * 7
Dim Rc5_last_b(7) As Byte At Rc5_last Overlay
Dim Rc5_command As Byte
Dim Rc5_command_old As Byte
Dim Rc5_code(20) As Byte
Dim Rc5_code_eeram(20) As Eram Byte
Dim Ir_mode As Byte
Dim Ir_mode_e As Eram Byte
'Relais state
Dim Rel As Byte
Dim Rel_amp_pin As Byte
Dim With_amp as Byte
Dim With_amp_eram As Eram Byte
'
Dds_cmd = Dds_command_on
'----------------------------------------------------
$include "common_1.13\_Macros.bas"
'
'----------------------------------------------------
$include "common_1.13\_Config.bas"
'
'----------------------------------------------------
$include "common_1.13\_Main.bas"
'
'----------------------------------------------------
$include "common_1.13\_Loop_start.bas"
If Ir_mode = 0 Then
   ' MYC mode
      B_temp2 = Rel_amp
      If Rel_amp_pin <> B_temp2 Then
         ' antibounce
         Waitms 100
         If Rel_amp_pin <> B_temp2 Then
            If B_temp2 = 1 Then
               B_temp1 = 1
            Else
               B_temp1 = 0
            End If
            Gosub Switch_relais
            Rel_amp_pin = B_temp2
         End If
      End If
End If
Stop Watchdog
GetRC5(Rc5_address , Rc5_command)
Rc5_address = 2
Rc5_command = 34
If Rc5_command <> &HFF Then
   Rc5_last =  Str(Rc5_address)
   Rc5_last = Rc5_last + " "
   Str_temp1 =  Str(Rc5_command)
   Rc5_last = Rc5_last + Str_temp1
   If Ir_mode = 1 Then
       ' Infrared mode
      If Rc5_command <> Rc5_command_old Then
         Rc5_command_old = Rc5_command
         If Rc5_address = Rc5_adress_soll Then
            Rcc = Rc5_command And &B01111111
            If Rcc = Rc5_code(1) Then
               Freq_in = Freq(1)
            End If
            If Rcc = Rc5_code(2) Then
               Freq_in = Freq(2)
            End If
            If Rcc = Rc5_code(3) Then
               Freq_in = Freq(3)
            End If
            If Rcc = Rc5_code(4) Then
               Freq_in = Freq(4)
            End If
            If Rcc = Rc5_code(5) Then
               Freq_in = Freq(5)
            End If
            If Rcc = Rc5_code(6) Then
               Freq_in = Freq(6)
            End If
            If Rcc = Rc5_code(7) Then
               Freq_in = Freq(7)
            End If
            If Rcc = Rc5_code(8) Then
               Freq_in = Freq(8)
            End If
            If Rcc = Rc5_code(9) Then
               Freq_in = Freq(9)
            End If
            If Rcc = Rc5_code(10) Then
               Freq_in = Freq(10)
            End If
            If Rcc = Rc5_code(11) Then
               Freq_in = Freq(11)
            End If
            If Rcc = Rc5_code(12) Then
               Freq_in = Freq(12)
            End If
            If Rcc = Rc5_code(13) Then
               Freq_in = Freq(13)
            End If
            If Rcc = Rc5_code(14) Then
               Freq_in = Freq(14)
            End If
            If Rcc = Rc5_code(15) Then
               Freq_in = Freq(15)
            End If
            If Rcc = Rc5_code(16) Then
               Freq_in = Freq(16)
            End If
            If Rcc = Rc5_code(17) Then
               Freq_in = Freq(17 )
            End If
            If Rcc = Rc5_code(18) Then
               Freq_in = Freq(18)
            End If
            If Rcc = Rc5_code(19) Then
               Freq_in = Freq(19)
            End If
            If Rcc = Rc5_code(20) Then
              Freq_in = Freq(20)
            End If
            Gosub Dds_output
         End If
      End If
   End If
   Start Watchdog
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
'
'----------------------------------------------------
_init_micro:
Return
'
'***************************************************************************
' Init_dds
'***************************************************************************
Init_dds:
' initiate serial mode: first:set all to 0
Reset Fqud
Reset Wdat                                               'DATA                                '
Reset Wclk                                               'WCLK
'
Set Wclk                                                 'WCLK
Waitus 1
Reset Wclk                                               'WCLK
Waitus 1
Set Fqud                                                 'FQUD
Waitus 1
Set Wclk
Reset Fqud                                               'FQUD
Waitus 1
Gosub Calculate_freq_data
Gosub Shiftout_data
Return
'
Dds_output:
Stop Watchdog
Gosub Calculate_freq_data
Gosub Shiftout_data
Waitus 10
Gosub Shiftout_data
Start Watchdog
Return
'
Calculate_freq_data:
Si_temp1 = Freq_in
Si_temp1 = Si_temp1 * Correct
' Tk
If Sensor = 1 Then
   If Tk_measure = 0 Then
      Si_temp1 = Temperature - Temp_measure
      Si_temp1 = Si_temp1 * Tk
      Si_temp1 = 1 + Si_temp1
      Si_temp1 = Freq_in * Si_temp1
   End If
End If
Si_temp1 = Si_temp1 * Factor_accu
Freq_data = Si_temp1
Return
'
Shiftout_data:
Shiftout Wdat , Wclk , Freq_data , 2, 32 , 0            'DATA,WCLK LSB first
Shiftout Wdat , Wclk , Dds_cmd , 2 , 8 , 0               'DATA,WCLK
Set Wclk
Waitus 1
Set Fqud                                                 'FQUD
Waitus 1
Reset Fqud
Return
'
Calc_temperature:
If Sensor = 1 Then
   W_temp1 = Getadc(0)
   'T / degC = W_temp1 * (5V / 1024)/(1mV /degK) - 2731
   ' 2731: due to resolution of 1/10 deg
   Si_temp1 = W_temp1 * 5000
   ' mV:
   Si_temp1 = Si_temp1 / 1024
   Si_temp1 = Si_temp1 - 2731.5
   ' tenth deg:
   Temperature = Si_temp1
   If Tk <> Tk_default Then
      Gosub Dds_output
   End If
End If
Return
'
Calc_tc:
W_temp1 = Tmax - Tmin
' > 5 K difference required
If W_temp1 > 50 Then
   D_temp1 = F_at_tmax - F_at_tmin
   If F_at_tmax <> F_at_tmin Then
      Si_temp1 = D_temp1 / W_temp1
      ' Hz / K/10
      Si_temp1 = Si_temp1 / F_at_tmin
      If Si_temp1 < 0.000468 Then
         If Si_temp1 > -0.000468 Then
            ' < +- 0.0004 / K
            Tk = Si_temp1
            Tk_eeram = Tk
         End If
      End If
   End If
End If
Return
'
Switch_relais:
   If B_temp1 = 1 Then
      Set Relais
      Rel = 1
   Else
      Reset Relais
      Rel = 0
   End If
Return
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