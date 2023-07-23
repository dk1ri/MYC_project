'name : 70MHZ DDS Sender
'Version V03.1, 20230723
'purpose : Program for 70MHz DDS sender with AD9851
'This Programm workes as I2C slave or with serial protocol
'Can be used with hardware 70_Hz_dds_sender_eagle Version V02.1 by DK1RI
'Teile des Programms wurden aus "DDS AD9850 von 0 - 40 MHz mit ATtiny45" von Gerd Sinning uebernommen. Tnx
'
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
' To run the compiler the directory comon_1.13 with includefiles must be copied to the directory of this file!
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
' Timer0 for RC5
'-----------------------------------------------------
' Inputs /Outputs : see file __config
' For announcements and rules see Data section in announcements.bas
'
'------------------------------------------------------
' Missing/errors:
' IR mode:
' Power up after power down of AD9851 do not work; reason unknown
' So for power off frequency is set to 0. This reduce power by 40mA instead of 90mA
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
Const F19 = 29650000
Const Comm20 = 46
Const F20 = 50100000
'===================================
'
' 1 ... 127:
Const I2c_address = 37
Const No_of_announcelines = 29
Const Tx_factor = 15
' For Test:15 (~ 10 seconds), real usage:2 (~ 1 second)
Const S_length = 32
Const Correct_default = 20000
Const Clk0 = 180000000 - Correct_default
Const F_max = 70000000
Const DDS_command_off = &B00000101
Const DDS_command_on =  &B00000001
Const Tk_default = 0
'
'----------------------------------------------------
$include "__use.bas"
$include "common_1.13\_Constants_and_variables.bas"
'
Dim Si_temp1 As Single
Dim Dds_cmd As Byte
Dim Freq_in As Single
Dim Freq_in_old As Single
' serialout do not work with Double (_> Long)!!!
Dim Freq_data As Long
Dim Freq_accu As Double
Dim Clk_in As Double
Dim Correct As Word
Dim Correct_eeram As Eram Word
Dim Rcc As Byte
Dim Sensor As Byte
Dim Sensor_eeram As Eram Byte
' deg C
Dim Temperature As Word
Dim Temp_measure_eeram As Eram Word
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
Dim Rc5_adress_soll_eeram As Eram Byte
Dim Rc5_code(20) As Byte
Dim Rc5_code_eeram(20) As Eram Byte
Dim Rc_address As Byte
Dim Rc_command As Byte
Dim Rc_command_old As Byte
Dim IR_Myc_old As Byte
Dim Ir_mode As Byte
Dim F_out As Byte
' for predeined frequncies
Dim F_code As Byte
'
Waitms 100

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
B_temp1 = IR_Myc
If IR_Myc_old <> B_temp1 Then
   ' antibounce
   Waitms 100
   If IR_Myc_old <> B_temp1 Then
      If B_temp1 = 0 Then
         'ir mode
         Set Relais
         Ir_mode = 1
         IR_Myc_old = B_temp1
      Else
         ' MYC mode
         Reset Relais
         Ir_mode = 0
         Gosub Dds_output
      End If
      IR_Myc_old = B_temp1
   End If
End If
If Ir_mode = 1 Then
B_temp1 = Ir_myc
   Stop Watchdog
   ' Infrared mode
   GetRC5(Rc_address , Rc_command)
   If Rc_command <> &HFF Then
      If Rc_command <> Rc_command_old Then
         Tx_time = 1
         Tx_b(1) = &H14
         Tx_b(2) = Rc_address
         Tx_b(3) = Rc_command
         Tx_write_pointer = 4
         Gosub Print_tx
         Rc_command_old = Rc_command
         If Rc_address = Rc5_adress_soll Then
            Rcc = Rc_command And &B01111111
            Si_temp1 = Freq_in
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
               Si_temp1 = Freq_in
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
Stop Watchdog
D_temp1 = Clk0 + Correct
Clk_in = D_temp1
Si_temp1 = Freq_in
' Tk
If Sensor = 1 Then
   If Tk_measure = 0 Then
      Si_temp1 = Temperature - Tmin
      Si_temp1 = Si_temp1 * Tk
      Si_temp1 = 1 + Si_temp1
      Si_temp1 = Freq_in * Si_temp1
   End If
End If
Freq_accu = Si_temp1
Freq_accu = Freq_accu * &H100000000                        'calculate
Freq_accu = Freq_accu / Clk_in
Freq_data = Freq_accu
Shiftout Wdat , Wclk , Freq_data , 3 , 32 , 0            'DATA,WCLK LSB first
If F_out = 0 Then
   Dds_cmd = Dds_command_off
Else
   Dds_cmd = Dds_command_on
End If
Shiftout Wdat , Wclk , Dds_cmd , 3 , 8 , 0               'DATA,WCLK
Waitus 10
Set Fqud                                                 'FQUD
Waitus 10
Reset Fqud
Start Watchdog
Return
'
Predefined_f:
Select Case F_code:
   Case 0:
      Freq_in = F2
   Case 1:
      Freq_in = F3
   Case 2:
      Freq_in = F4
   Case 3:
      Freq_in = F5
   Case 4:
      Freq_in = F6
   Case 5:
      Freq_in = F7
   Case 6:
      Freq_in = F8
   Case 7:
      Freq_in = F9
   Case 8:
      Freq_in = F10
   Case 8:
      Freq_in = F11
   Case 10:
      Freq_in = F12
   Case 11:
      Freq_in = F13
   Case 12:
      Freq_in = F14
   Case 13:
      Freq_in = F15
   Case 14:
      Freq_in = F16
   Case 15:
      Freq_in = F17
   Case 16:
      Freq_in = F18
   Case 17:
      Freq_in = F19
   Case 18:
      Freq_in = F20
   End Select
   Gosub Dds_output
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
   ' thenth deg:
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