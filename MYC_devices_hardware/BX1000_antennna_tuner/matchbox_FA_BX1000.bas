'name : matchbox_FA_BX1000.bas
'Version V01.1, 20200802
'purpose : programm for controlling a 1kW matchbox FA BX1000
'This Programm uses the serial interface for communication
'This firmware replaces the original firmware of the matchbox
'For exchanging Fwd and Rev Signal, see line 403
'
'++++++++++++++++++++++++++++++++++++++++++++++++++++
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
' i2c
'
'-----------------------------------------------------
' Inputs / Outputs : see file __config
' For announcements and rules see Data section at the end
'
'------------------------------------------------------
'Missing/errors:
'
'------------------------------------------------------
' Description
' The device is controlled via the serial interface RXD / TXD  only.
'
' Setting relais:
' Any change require:
'  determine, which relais changes the status (set_L-C_config_relais_drive)
' load 8bytes (drive) to relaisdriver and switch relais for 100ms
'
' The program has a main loop.
' Without other actions there are 887000 loop / s (abt)
' Every actions is done 28.8 time / s
'
' Frequency measurement:
' Frequency range is 1.8 - 29.7MHz
' AC161 divide by 8 : on Timer1 input (Qc):   225 - 3712,5 kHz
' Timer1 counting time (gate time) is given by Timer3:
' 147456 / 1024 / 500 = 28,8 Hz (34,72222 ms gatetime)
' -> Timer1_count = f / 8 * gatetime
'
'gatetime 0.034722222222222224
'F =  230.39999999999998  * Timer1count (Hz)
'
' Chanal_width inband = 15kHz
' Chanal_width_outband 50kHz
' For each chanal a L_value, C_value and the "set status" is stored.
' each chanal has 2 Byte for C and 2 byte for L
' MSB of L Word. 0: chanal not valid 1: chanal valid / set
' The Config_value is stored per band
'
'
Const L_default = &B0000010000000000
Const C_default = &B0000100000000000
Const L_max =     &B0000011111111111
Const C_max =     &B0000111111111111
Const Relais_value_default = 0
' There are 729 chanals representig a frequeny range.
Const Number_of_chanals = 729
'
Const Temp_fan = 203
'switch fan on if Temp is higher as 60 dgeC
'
Const Fwd_12 = 102
' Max 12W for switching the relays
'
'
' Freqency/MHz                     chanal:
'
Const Frequency_160_start = 1800
Const Frequency_160_end = 2000
Const Chanal160_start = 1
Const Number_of_chanals_160 = Int((Frequency_160_end - Frequency_160_start) / 15) + 1
'
Const Frequency_n160_start = Frequency_160_end + 1
Const Frequency_n160_end = 3499
Const Chanaln160_start = Chanal160_start + Number_of_chanals_160
Const Number_of_chanals_n160 = Int((Frequency_n160_end - Frequency_n160_start) / 50) + 1
'
Const Frequency_80_start = Frequency_n160_end + 1
Const Frequency_80_end = 3800
Const Chanal80_start = Chanaln160_start + Number_of_chanals_n160
Const Number_of_chanals_80 = Int((Frequency_80_end - Frequency_80_start) / 15) + 1
'
Const Frequency_n80_start = Frequency_80_end + 1
Const Frequency_n80_end = 6999
Const Chanaln80_start = Chanal80_start + Number_of_chanals_80
Const Number_of_chanals_n80 = Int((Frequency_n80_end - Frequency_n80_start) / 50) + 1
'
Const Frequency_40_start = Frequency_n80_end + 1
Const Frequency_40_end = 7200
Const Chanal40_start = Chanaln80_start + Number_of_chanals_n80
Const Number_of_chanals_40 = Int((Frequency_40_end - Frequency_40_start) / 15) + 1
'
Const Frequency_n40_start = Frequency_40_end + 1
Const Frequency_n40_end = 10099
Const Chanaln40_start = Chanal40_start + Number_of_chanals_40
Const Number_of_chanals_n40 = Int((Frequency_n40_end - Frequency_n40_start) / 50) + 1
'
Const Frequency_30_start = Frequency_n40_end + 1
Const Frequency_30_end = 10150
Const Chanal30_start = Chanaln40_start + Number_of_chanals_n40
Const Number_of_chanals_30 = Int((Frequency_30_end - Frequency_30_start) / 15) + 1
'
Const Frequency_n30_start = Frequency_30_end + 1
Const Frequency_n30_end = 13999
Const Chanaln30_start = Chanal30_start + Number_of_chanals_30
Const Number_of_chanals_n30 = Int((Frequency_n30_end - Frequency_n30_start) / 50) + 1
'
Const Frequency_20_start = Frequency_n30_end + 1
Const Frequency_20_end = 14350
Const Chanal20_start = Chanaln30_start + Number_of_chanals_n30
Const Number_of_chanals_20 = Int((Frequency_20_end - Frequency_20_start) / 15) + 1

Const Frequency_n20_start = Frequency_20_end + 1
Const Frequency_n20_end = 18067
Const Chanaln20_start = Chanal20_start + Number_of_chanals_20
Const Number_of_chanals_n20 = Int((Frequency_n20_end - Frequency_n20_start) / 50) + 1
'
Const Frequency_17_start = Frequency_n20_end + 1
Const Frequency_17_end = 18168
Const Chanal17_start = Chanaln20_start + Number_of_chanals_n20
Const Number_of_chanals_17 = Int((Frequency_17_end - Frequency_17_start) / 15) + 1
'
Const Frequency_n17_start = Frequency_17_end + 1
Const Frequency_n17_end = 20999
Const Chanaln17_start = Chanal17_start + Number_of_chanals_17
Const Number_of_chanals_n17 = Int((Frequency_n17_end - Frequency_n17_start) / 50) + 1
'
Const Frequency_15_start = Frequency_n17_end + 1
Const Frequency_15_end = 21450
Const Chanal15_start = Chanaln17_start + Number_of_chanals_n17
Const Number_of_chanals_15 = Int((Frequency_15_end - Frequency_15_start) / 15) + 1
'
Const Frequency_n15_start = Frequency_15_end + 1
Const Frequency_n15_end = 24889
Const Chanaln15_start = Chanal15_start + Number_of_chanals_15
Const Number_of_chanals_n15 = Int((Frequency_n15_end - Frequency_n15_start) / 50) + 1
'
Const Frequency_12_start = Frequency_n15_end + 1
Const Frequency_12_end = 24990
Const Chanal12_start = Chanaln15_start + Number_of_chanals_n15
Const Number_of_chanals_12 = Int((Frequency_12_end - Frequency_12_start) / 15) + 1
'
Const Frequency_n12_start = Frequency_12_end
Const Frequency_n12_end = 27999
Const Chanaln12_start = Chanal12_start + Number_of_chanals_12
Const Number_of_chanals_n12 = Int((Frequency_n12_end - Frequency_n12_start) / 50) + 1
'
Const Frequency_10_start = Frequency_n12_end + 1
Const Frequency_10_end = 29700
Const Chanal10_start = Chanaln12_start + Number_of_chanals_n12
Const Number_of_chanals_10 = Int((Frequency_10_end - Frequency_10_start) / 15) + 1
Const Chanal10_end = Chanal10_start + Number_of_chanals_10
'
'----------------------------------------------------
$regfile = "m1284Pdef.dat"
'for ATMega1284
'
'-----------------------------------------------------
$crystal = 14745600
$include "common_1.11\_Processor.bas"
$baud = 115200
'
'----------------------------------------------------
'
' Adress of external EEPROM, no MYC communication via I2C (not used)
Const I2c_address =     &B10100000
Const No_of_announcelines = 34
Const Tx_factor = 15
' For Test:15 (~ 10 seconds), real usage:2 (~ 1 second)
Const S_length = 32
'
'----------------------------------------------------
$include "__use.bas"
$include "common_1.11\_Constants_and_variables.bas"
'
Dim Tempsingle As Single
Dim Temp_i As Integer
' output of the 8 relais driver:
Dim Drive(8) As Byte
Dim Aux As Byte
Dim Force_fan As Byte
Dim Fwd As Word
Dim Rev As Word
Dim Swr As Byte
Dim Temperature As Word
Dim L_value As Word
Dim L_value_old As Word
Dim L1 As Word
Dim L2 As Word
Dim L_value_save As Word
Dim C_value As Word
Dim C_value_old As Word
Dim C1 As Word
Dim C2 As Word
Dim L_pos(Number_of_chanals) As Eram Word
' Cpos.15 ... Cpos.14 contain Config_value.1 ... Config_value.0
Dim C_pos(Number_of_chanals) As Eram Word
Dim Config_pos(17) As Eram Byte
Dim Config_value As Byte
Dim Config_value_old As Byte
Dim Relais_value As Byte
Dim Relais_value_old As Byte
Dim Relais_value_eram As Eram Byte
Dim Drive_enable As Byte
Dim Start_send_data As Byte
Dim Chanal_number As Word
Dim Pos_start(17) As Word
Dim Pos_end(17) As Word
Dim Frequency_temp As Dword
Dim Frequency As Word
Dim T0_multi As Word
Dim T1_ov As Byte
Dim Up_down As Byte
Dim Up_down_step As Byte
Dim Counter_valid As Byte
Dim Count_of_frequency_measurements As Byte
Dim Counter_valid_count As Byte
Dim Found1 As Word
Dim Band As Byte
' 1 to 17 (inband and outband)
Dim Temp_measured As Byte
Dim Swr_measured As Byte
Dim Send_swr As Byte
Dim Up_down_done As Byte
'
'----------------------------------------------------
$include "common_1.11\_Macros.bas"
'
'----------------------------------------------------
$include "common_1.11\_Config.bas"
'
$initmicro
'----------------------------------------------------
' procedures at start
'
'----------------------------------------------------
$include "common_1.11\_Main.bas"
'
Start Timer3
Start Timer1
'----------------------------------------------------
$include "common_1.11\_Loop_start.bas"
'
'----------------------------------------------------
'
If Cnt_enable = 0 Then Counter_valid = 0
' Tcnt1 may overflow before measurement
If Tcnt1 > 64000 Then T1_ov = 1
'
If Timer3 >= 500 Then
   ' every 34,7ms
   Stop Timer1
   Stop Timer3
   Incr Count_of_frequency_measurements
   ' measurements
   If Count_of_frequency_measurements >= 10 Then
      ' 10 measuerements done
      ' frequency valid :
      If Counter_valid_count >= 6 Then
         Tempsingle = Frequency_temp
         Tempsingle = Tempsingle /  Counter_valid_count
         Frequency_temp = Tempsingle
         Tempsingle = Tempsingle * 0.23038
         Frequency = Tempsingle
         ' Frequncy_temp in kHz!
         Gosub Find_chanal_number_band
      End If
      Frequency_temp = 0
      Counter_valid_count = 0
      Count_of_frequency_measurements = 0
   Else
      If Counter_valid = 1 And TCNT1 > 0 Then
         ' Cnt_enable was ok for 16ms
         Frequency_temp = Frequency_temp + TCNT1
         If T1_ov = 1 Then
            If TCNT1 < 63900 Then
               ' There was an overflow
               Frequency_temp = Frequency_temp + &HFFFF
            ' Else
            ' no overflow, because max count is < 65535 + 63900 = 129435
            End If
         ' Else
         ' no overflow
         End If
         Incr Counter_valid_count
         T1_ov = 0
      End If
   End If
   Counter_valid = 1
   Temp_measured = 0
   Swr_measured = 0
   Up_down_done = 0
   Reset Clr_counter
   Set Clr_counter
   Timer3 = 0
   Tcnt1 = 0
   If Cnt_enable = 1 Then Start Timer1
   Start Timer3
End If

If Timer3 >= 100 Then
   ' check Up_down
   If Drive_enable = 1 Then
      If Up_down_done = 0 Then
         Incr T0_multi
         If T0_multi >= 4 Then
            ' switch every 4 * 16.6ms
            T0_multi = 0
            If Up_down > 0 Then
               Select Case Up_down
                  Case 1
                     L_value = L_value + Up_down_step
                     If L_value < L_max Then
                        Gosub Set_l_drive
                        Start_send_data = 1
                     Else
                        Up_down = 0
                        L_value = L_value - Up_down_step
                     End If
                  Case 2
                     If L_value  > Up_down_step Then
                        L_value = L_value - Up_down_step
                        Gosub Set_l_drive
                        Start_send_data = 1
                     Else
                        Up_down = 0
                     End If
                  Case 3
                     C_value = C_value + Up_down_step
                     If C_value < C_max Then
                        Gosub Set_c_drive
                        Start_send_data = 1
                     Else
                        C_value = C_value - Up_down_step
                        Up_down = 0
                     End If
                  Case 4
                     If C_value > Up_down_step Then
                        C_value = C_value - Up_down_step
                        Gosub Set_c_drive
                        Start_send_data = 1
                     Else
                        Up_down = 0
                     End If
               End Select
            End If
         End If
         Up_down_done = 1
      End If
   Else
      Up_down = 0
   End If
End If
'
If TImer3 > 200 Then
   ' used for up / down only to separate set_x_drive and send_data
   If Start_send_data = 1 Then
      Gosub Send_data
      Start_send_data = 0
      L_value_old = L_value
      C_value_old = C_value
      Send_swr = 1
   End If
End If
'
If Timer3 > 100 Then
   ' measure temprature
   If Temp_measured = 0 Then
      Temperature = GetAdc(2)
      If Temperature > Temp_fan Then
         Force_fan = 1
         Set Cool
      Else
         If Aux = 0 Then Reset Cool
      End If
      Temp_measured = 1
   End If
End If
'
If Timer3 > 300 Then
'  measure swr
'
' 1kW -> 223,607V on 50Ohm
' 17,4V with 1kW before voltage deivider (as per circuit diagram)
' R divider 1k + 82k / 33k -> Vad = 17.4 * 33 /(33 + 83)V = 4.95V
' 223V relates to: 1024 * 4.95 / 5 = 1013,76 counts
'
' Vmeasure = Count * 223.607 / 1013.76 = Count * 0.220572
'
' 10W -> 22V on 50Ohm -> 1.74V before voltage divider -> after divider: 0.495V -> 101 counts
' 12W -> 24.49V       -> 1.75V                        ->                0.498V -> 102 counts
   If Swr_measured = 0 Then
' To exchange Fwd and Rev, exchange 0 and in the next 2 lines
      Fwd = Getadc(1)
      Rev = Getadc(0)
      If Fwd > Fwd_12 Then
         Drive_enable = 0
      Else
        Drive_enable = 1
      End If
      W_temp1 = Fwd + Rev
      W_temp2 = Fwd - Rev
      Swr = 0
      If W_temp1 > 0 Then
           If W_temp2 > 0 Then
            Tempsingle = W_temp1 / W_temp2
            If Tempsingle < 0 Then
               Tempsingle = Tempsingle * -1
               Tempsingle = Tempsingle + 100
            Else
               If Tempsingle > 25 Then Tempsingle = 25
            End If
            Swr = Tempsingle * 10
         Else
            Swr = 250
         End If
      End If
      If Send_swr = 1 Then
         Read_enable = 0
         Printbin 16
         'print Fwd
         'print rev
         Printbin Swr
         waitms 10
         Read_enable = 1
         Send_swr = 0
      End If
      Tempsingle = 0.220572 * Fwd
      Tempsingle = Tempsingle * Tempsingle
      Tempsingle = Tempsingle / 50
      Fwd = Tempsingle
      Tempsingle = 0.220572 * Rev
      Tempsingle = Tempsingle * Tempsingle
      Tempsingle = Tempsingle / 50
      Rev = Tempsingle
      Swr_measured = 1
   End If
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
'
_init_micro:
Reset Strb
Reset Sclk
Reset Oe0
Reset Oe1
Reset Oe2
Reset Oe3
Reset Oe4
Reset Oe5
Reset Oe6
Reset Oe7
Return
'
' Print_tx in common_1.11 cannot be used because of Write_enable
Print_tx:
Read_enable = 0
Decr  Tx_write_pointer
For B_temp2 = 1 To Tx_write_pointer
   B_temp3 = Tx_b(B_temp2)
   Printbin B_temp3
Next B_temp2
Tx_pointer = 1
Tx_write_pointer = 1
Tx_time = 0
Waitms 10
Read_enable = 1
Return
'
Eeram_default:
For W_temp1 = 1 To Number_of_chanals
   L_pos(W_temp1) = L_default
   C_pos(W_temp1) = C_default
Next W_temp1
Return
'
Find_chanal_number_band:
Select Case Frequency
    Case 0 To Frequency_160_start
       Chanal_number = 1
       Band = 1
    Case Frequency_160_start To Frequency_160_end
       Tempsingle = Frequency - Frequency_160_start
       Tempsingle = Tempsingle / 15
       W_temp2 = Tempsingle
       Chanal_number = Chanal160_start + W_temp2
       Band = 1
    Case Frequency_n160_start To Frequency_n160_end
       Tempsingle = Frequency - Frequency_n160_start
       Tempsingle = Tempsingle / 50
       W_temp2 = Tempsingle
       Chanal_number = Chanaln160_start + W_temp2
       Band = 2
    Case Frequency_80_start To Frequency_80_end
       Tempsingle = Frequency - Frequency_80_start
       Tempsingle = Tempsingle / 15
       W_temp2 = Tempsingle
       Chanal_number = Chanal80_start + W_temp2
       Band = 3
    Case Frequency_n80_start To Frequency_n80_end
       Tempsingle = Frequency - Frequency_n80_start
       Tempsingle = Tempsingle / 50
       W_temp2 = Tempsingle
       Chanal_number = Chanaln80_start + W_temp2
       Band = 4
    Case Frequency_40_start To Frequency_40_end
       Tempsingle = Frequency - Frequency_40_start
       Tempsingle = Tempsingle / 15
       W_temp2 = Tempsingle
       Chanal_number = Chanal40_start + W_temp2
       Band = 5
    Case Frequency_n40_start To Frequency_n40_end
       Tempsingle = Frequency - Frequency_n40_start
       Tempsingle = Tempsingle / 50
       W_temp2 = Tempsingle
       Chanal_number = Chanaln40_start + W_temp2
       Band = 6
    Case Frequency_30_start To Frequency_30_end
       Tempsingle = Frequency - Frequency_30_start
       Tempsingle = Tempsingle / 15
       W_temp2 = Tempsingle
       Chanal_number = Chanal30_start + W_temp2
       Band = 7
    Case Frequency_n30_start To Frequency_n30_end
       Tempsingle = Frequency - Frequency_n30_start
       Tempsingle = Tempsingle / 50
       W_temp2 = Tempsingle
       Chanal_number = Chanaln30_start + W_temp2
       Band = 8
    Case Frequency_20_start To Frequency_20_end
       Tempsingle = Frequency - Frequency_20_start
       Tempsingle = Tempsingle / 15
       W_temp2 = Tempsingle
       Chanal_number = Chanal20_start + W_temp2
       Band = 9
    Case Frequency_n20_start To Frequency_n20_end
       Tempsingle = Frequency - Frequency_n20_start
       Tempsingle = Tempsingle / 50
       W_temp2 = Tempsingle
       Chanal_number = Chanaln20_start + W_temp2
       Band = 10
    Case Frequency_17_start To Frequency_17_end
       Tempsingle = Frequency - Frequency_17_start
       Tempsingle = Tempsingle / 15
       W_temp2 = Tempsingle
       Chanal_number = Chanal17_start + W_temp2
       Band = 11
    Case Frequency_n17_start To Frequency_n17_end
       Tempsingle = Frequency - Frequency_n17_start
       Tempsingle = Tempsingle / 50
       W_temp2 = Tempsingle
       Chanal_number = Chanaln17_start + W_temp2
       Band = 12
    Case Frequency_15_start To Frequency_15_end
       Tempsingle = Frequency - Frequency_15_start
       Tempsingle = Tempsingle / 15
       W_temp2 = Tempsingle
       Chanal_number = Chanal15_start + W_temp2
       Band = 13
    Case Frequency_n15_start To Frequency_n15_end
       Tempsingle = Frequency - Frequency_n15_start
       Tempsingle = Tempsingle / 50
       W_temp2 = Tempsingle
       Chanal_number = Chanaln15_start + W_temp2
       Band = 14
    Case Frequency_12_start To Frequency_12_end
       Tempsingle = Frequency - Frequency_12_start
       Tempsingle = Tempsingle / 15
       W_temp2 = Tempsingle
       Chanal_number = Chanal12_start + W_temp2
       Band = 15
    Case Frequency_n12_start To Frequency_n12_end
       Tempsingle = Frequency - Frequency_n12_start
       Tempsingle = Tempsingle / 50
       W_temp2 = Tempsingle
       Chanal_number = Chanaln12_start + W_temp2
       Band = 16
    Case Frequency_10_start To Frequency_10_start
       Tempsingle = Frequency - Frequency_10_start
       Tempsingle = Tempsingle / 15
       W_temp2 = Tempsingle
       Chanal_number = Chanal10_start + W_temp2
       Band = 17
    Case Else
      Chanal_number = Chanal10_end
      Band = 17
End Select
Return
'
Set_l_drive:
' Description in the circuit diagramm for Lx on / Lx off is mixed up !!
' Drive is set only when status changes: then either on coil or off coil is set
' All Drive(x) are 0  now
B_temp1 = High(L_Value)
B_temp2 = High(L_value_old)
' L11
If B_temp1.2 <> B_temp2.2 Then
   If B_temp1.2 = 0 Then
      Drive(4).3 = 1
   Else
      Drive(7).6 = 1
   End If
End If
' L10
If B_temp1.1 <> B_temp2.1 Then
   If B_temp1.1 = 0 Then
      Drive(4).2 = 1
   Else
      Drive(7).7 = 1
   End If
End If
'
' L9
If B_temp1.0 <> B_temp2.0 Then
   If B_temp1.0 = 0 Then
      Drive(4).1 = 1
   Else
      Drive(6).0 = 1
   End If
End If
'
B_temp1 = Low(L_Value)
B_temp2 = Low(L_value_old)
' L8
If B_temp1.7 <> B_temp2.7 Then
   If B_temp1.7 = 0 Then
      Drive(4).0 = 1
   Else
      Drive(6).1 = 1
   End If
End If
' L7
If B_temp1.6 <> B_temp2.6 Then
   If B_temp1.6 = 0 Then
      Drive(5).7 = 1
   Else
      Drive(6).2 = 1
   End If
End If
' L6
If B_temp1.5 <> B_temp2.5 Then
   If B_temp1.5 = 0 Then
      Drive(5).6 = 1
   Else
      Drive(6).3 = 1
   End If
End If
' L5
If B_temp1.4 <> B_temp2.4 Then
   If B_temp1.4 = 0 Then
      Drive(5).5 = 1
   Else
      Drive(6).4 = 1
   End If
End If
' L4
If B_temp1.3 <> B_temp2.3 Then
   If B_temp1.3 = 0 Then
      Drive(5).4 = 1
   Else
      Drive(6).5 = 1
   End If
End If
' L3
If B_temp1.2 <> B_temp2.2 Then
   If B_temp1.2 = 0 Then
      Drive(5).3 = 1
   Else
      Drive(6).6 = 1
   End If
End If
' L2
If B_temp1.1 <> B_temp2.1 Then
   If B_temp1.1 = 0 Then
      Drive(5).2 = 1
   Else
      Drive(6).7 = 1
   End If
End If
' L1
If B_temp1.0 <> B_temp2.0 Then
   If B_temp1.0 = 0 Then
      Drive(5).1 = 1
   Else
      Drive(5).0 = 1
   End If
End If
Return
'
Set_c_drive:
' Description in the circuit diagramm for Cx on / Cx off is mixed up !!
' Drive is set only when status changes: then either on coil or off coil is set
' All Drive(x) are 0
B_temp1 = High(C_Value)
B_temp2 = High(C_value_old)
' C12
If B_temp1.3 <> B_temp2.3 Then
   If B_temp1.3 = 0 Then
      Drive(7).4 = 1
   Else
      Drive(7).5 = 1
   End If
End If
' C11
If B_temp1.2 <> B_temp2.2 Then
   If B_temp1.2 = 0 Then
      Drive(4).5 = 1
   Else
      Drive(4).4 = 1
   End If
End If
' C10
If B_temp1.1 <> B_temp2.1 Then
   If B_temp1.1 = 0 Then
      Drive(4).7 = 1
   Else
      Drive(4).6 = 1
   End If
End If
'
' C9
If B_temp1.0 <> B_temp2.0 Then
   If B_temp1.0 = 0 Then
      Drive(3).1 = 1
   Else
      Drive(3).0 = 1
   End If
End If
'
B_temp1 = Low(C_Value)
B_temp2 = Low(C_value_old)
' C8
If B_temp1.7 <> B_temp2.7 Then
   If B_temp1.7 = 0 Then
      Drive(7).0 = 1
   Else
      Drive(7).1 = 1
   End If
End If
' C7
If B_temp1.6 <> B_temp2.6 Then
   If B_temp1.6 = 0 Then
      Drive(7).2 = 1
   Else
      Drive(7).3 = 1
   End If
End If
' C6
If B_temp1.5 <> B_temp2.5 Then
   If B_temp1.5 = 0 Then
      Drive(3).3 = 1
   Else
      Drive(3).2 = 1
   End If
End If
' C5
If B_temp1.4 <> B_temp2.4 Then
   If B_temp1.4 = 0 Then
      Drive(8).6 = 1
   Else
      Drive(8).7 = 1
   End If
End If
' C4
If B_temp1.3 <> B_temp2.3 Then
   If B_temp1.3 = 5 Then
      Drive(8).4 = 1
   Else
      Drive(8).5 = 1
   End If
End If
' C3
If B_temp1.2 <> B_temp2.2 Then
   If B_temp1.2 = 0 Then
      Drive(3).5 = 1
   Else
      Drive(3).4 = 1
   End If
End If
' C2
If B_temp1.1 <> B_temp2.1 Then
   If B_temp1.1 = 0 Then
      Drive(8).2 = 1
   Else
      Drive(8).3 = 1
   End If
End If
' C1
If B_temp1.0 <> B_temp2.0 Then
   If B_temp1.0 = 0 Then
      Drive(3).7 = 1
   Else
      Drive(3).6 = 1
   End If
End If
Return
'
Set_config_drive:
' Description in the circuit diagramm for x on / x off is mixed up !!
' Drive is set only when status changes: then either on coil or off coil is set
Select Case Config_value
   Case 0
      'C-L
      'Ch off, Cant off, Ctrx on
      Drive(2).0 = 0
      Drive(2).1 = 1
      Drive(2).2 = 0
      Drive(2).3 = 1
      Drive(2).4 = 1
      Drive(2).5 = 0
      Drive(2).6 = 0
      Drive(2).7 = 1
   Case 1
      'L-C
      'Ch off, Cant on, Ctrx off
      Drive(2).0 = 0
      Drive(2).1 = 1
      Drive(2).2 = 1
      Drive(2).3 = 0
      Drive(2).4 = 0
      Drive(2).5 = 1
      Drive(2).6 = 0
      Drive(2).7 = 1
   Case 2
      'Ch-C-L
      'Ch on, Cant on, Ctrx off
      Drive(2).0 = 1
      Drive(2).1 = 0
      Drive(2).2 = 1
      Drive(2).3 = 0
      Drive(2).4 = 0
      Drive(2).5 = 1
      Drive(2).6 = 0
      Drive(2).7 = 1
   Case 3
      'through
      'Ch off, Cant off, Ctrx off
      Drive(2).0 = 0
      Drive(2).1 = 1
      Drive(2).2 = 0
      Drive(2).3 = 1
      Drive(2).4 = 0
      Drive(2).5 = 1
      Drive(2).6 = 0
      Drive(2).7 = 1
   Case 4
      ' for init only
      Drive(2) = &B01010101
   Case 5
      ' for init only
      Drive(2) = &B10101010
End Select
Return
'
Set_relais_drive:
If Relais_value.3 <> Relais_value_old.3 Then
   If Relais_value.3 = 1 Then
      Drive(1).7 = 1
   Else
      Drive(1).6 = 1
   End If
End If
If Relais_value.2 <> Relais_value_old.2 Then
   If Relais_value.2 = 1 Then
      Drive(1).5 = 1
   Else
      Drive(1).4 = 1
   End If
End If
If Relais_value.1 <> Relais_value_old.1 Then
   If Relais_value.1 = 1 Then
      Drive(1).3 = 1
   Else
      Drive(1).2 = 1
   End If
End If
If Relais_value.0 <> Relais_value_old.0 Then
   If Relais_value.0 = 1 Then
      Drive(1).1 = 1
   Else
      Drive(1).0 = 1
   End If
End If
Return
'
Send_data:
' to drivers
' all 64 bits must be send each time
'
For B_temp1 = 1 To 8
'8 drivers
   For B_temp2 = 7 To 0 Step - 1
      '8 outputs Out8 first
      Data_ = Drive(B_temp1).B_temp2
      ' setup > 75ns
      NOP
      Set Sclk
      ' > 300ns
      NOP
      B_temp4 = Drive(B_temp1).B_temp2
      NOP
      Reset Sclk
   Next B_temp2
Next B_temp1
'
' than strobe to all drivers
Set Strb
' > 100ns
NOP
NOP
Reset Strb
'
' Then switch relais
' only those relais with modified state are driven
Reset Oe0
Reset Oe1
Reset Oe2
Reset Oe3
Reset Oe4
Reset Oe5
Reset Oe6
Reset Oe7
Waitms 10
Set Oe0
Set Oe1
Set Oe2
Set Oe3
Set Oe4
Set Oe5
Set Oe6
Set Oe7
'
Drive(1) = 0
Drive(2) = 0
Drive(3) = 0
Drive(4) = 0
Drive(5) = 0
Drive(6) = 0
Drive(7) = 0
Drive(8) = 0
Read_enable  = 1
Return
'
Interpolate:
' look for chanal with "set bit" downwards
' Value at start of band, if nothing found:
W_temp1 = Pos_start(Band)
L1 = L_pos(W_temp1)
B_temp1 = High(L1)
B_temp1.7 = 0
B_temp2 = Low(L1)
L1 = B_temp1 * 256
L1 = L1 + B_temp2
C1 = C_pos(W_temp1)
W_temp1 = Chanal_number
Found1 = 0
While W_temp1 >= Pos_start(Band) And Found1 = 0
   Decr W_temp1
   W_temp2 = L_pos(W_temp1)
   B_temp1 = High(W_temp2)
   If B_temp1.7 = 1 Then
      ' found
      Found1 = 1
      L1 = L_pos(W_temp1)
      C1 = C_pos(W_temp1)
   End If
Wend
'
' same for upwards
' Value, if nothing found
W_temp1 = Pos_end(Band)
L2 = L_pos(W_temp1)
B_temp1 = High(L2)
B_temp1.7 = 0
B_temp2 = Low(L2)
L2 = B_temp1 * 256
L2 = L2 + B_temp2
C2 = C_pos(W_temp1)
W_temp1 = Chanal_number
Found1 = 0
While W_temp1 <= Pos_end(Band) And Found1 = 0
   Incr W_temp1
   W_temp2 = L_pos(W_temp1)
   B_temp1 = High(W_temp2)
   If B_temp1.7 = 1 Then
      ' found
      Found1 = 1
      L2 = L_pos(W_temp1)
      C2 = C_pos(W_temp1)
   End If
Wend
'
L_value = L1 + L2
L_value = L_value / 2
C_value = C1 + C2
C_value = C_value / 2
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
Ntc:
Data 784%,774%,764%,755%,744%,734%,724%,713%,703%,692%,681%,670%,659%,648%,636%,625%,
Data 614%,602%,591%,580%,568%,557%,545%,534%,523%,511%,500%,489%,478%,467%,457%,446%,
Data 435%,426%,415%,404%,394%,385%,375%,365%,356%,347%,338%,329%,320%,311%,303%,295%,
Data 287%,279%,270%,263%,256%,249%,242%,235%,228%,222%,215%,209%,203%,198%,192%,186%,
Data 181%,176%,171%,166%,161%,157%,152%,148%,144%,139%,135%,132%,128%,124%,121%,117%
Data 114%,111%,107%,104%,101%, 98%, 96%, 93%, 90%, 88%, 85%, 83%, 81%, 78%, 76%, 74%,
Data  72%, 70%, 68%, 66%, 66%