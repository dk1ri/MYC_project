'name : matchbox_FA_BX1000.bas
'Version V02.1, 20240611
'purpose : programm for controlling a 1kW matchbox FA BX1000
'This Programm uses the serial interface for communication
'This firmware replaces the original firmware of the matchbox
'For exchanging Fwd and Rev Signal, see line 527 (Measure_swr)
'
'++++++++++++++++++++++++++++++++++++++++++++++++++++
'
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
' To run the compiler the directory common_1.13 with includefiles must be copied to the directory of this file!
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
'
'----------------------------------------------------
$include "common_1.13\_Introduction_master_copyright.bas"
'
'----------------------------------------------------
'
'Used Hardware:
' serial
'
'-----------------------------------------------------
' Inputs / Outputs : see file __config
' For announcements and rules _announcements.bas
'
'------------------------------------------------------
'Missing/errors:
' Read_enaable must be reset for additional test - prints!!!   with some Waittime!!!
'
'------------------------------------------------------
' Description
' The device is controlled via the serial interface RXD / TXD  only.
'
' Setting relais:
' Any change require:
' determine, which relais changes the status (set_(L/C/config/relais)_drive)
' serial load to relaisdriver and switch relais for 100ms
'
' The program has a main loop.(70ms)
'
' Frequency measurement:
' Frequency range is 1.8 - 29.7MHz
' AC161 divide by 8 : on Timer1 input (Qc):   225 - 3712,5 kHz
' Timer1 counting time (gate time) is given by Timer0 interrupt
' 147456 / 1024 / 247 = 58,2996 Hz (17,15 ms gatetime)
' -> Timer1_count = f / 8 * gatetime
' 1.8MHz -> 3858 counts 29.7MHz ->  636693 counts
'
'f =  0.44112116  * timer1count (kHz)
'
' For each chanal a L_value, C_value and the "set (valid) status" is stored.
' each chanal has 2 Byte for C and 2 byte for L
' MSB of L Word. 0: chanal not valid 1: chanal valid / set
' The Config_value is stored as 2 bit MSB of C_value
'
'
'Lmax = (11 values on) 8,77 uH
Const L_default = &B0000000000000000
'Cmax = (12 values on) 3006pF
Const C_default = &B0000000000000000
Const L_max =     &B0000011111111111
Const C_max =     &B0000111111111111
Const Relais_value_default = 0
Const Config_default = 0
' There are 737 chanals representing a frequeny range.
Const Number_of_chanals = 737
'
Const Temp_fan = 375
'switch fan on if Temp is higher as 60 dgeC
'
Const Fwd_12 = 103
' Max 12W for switching the relays
'
'
' There are 17 bands from 160m to 10m
' first chanalnumber of a band is stored in Pos_start(x); last in Pos_end(x) x = 1 to 17
' Chanal_width in amateur radio band = 15kHz
' Chanal_width_outside 50kHz
' band   Pos_start   Pos_end  no_fo_chanals  f_start  f_end   kHz /chanal
' 1      1           14       14             1800     2009    15
' 2      15          43       29             2010     3459    50
' 3      44          66       23             3460     3804    15
' 4      67          129      63             3805     6954    50
' 5      130         146      17             6955     7209    15
' 6      147         203      57             7210     10059   50
' 7      203         208      6              10060    10149   15
' 8      209         285      77             10150    13999   50
' 9      286         309      24             14000    14359   15
' 10     310         382      73             14360    18009   50
' 11     383         393      11             18010    18174   15
' 12     394         451      58             18075    20974   50
' 13     452         483      32             20975    21454   15
' 14     484         551      68             21455    24854   50
' 15     552         561      10             24855    25004   14
' 16     562         620      59             25005    27954   50
'17      621         737      117            27955    29709   15
'
Const Frequency_160_start = 1800
Const Frequency_160_end = 2009
Const Chanal160_start = 1
Const Chanal160_end = 14
Const Number_of_chanals_160 = 14' 15kHz
Const Mid_chanal_160 = 7
'
Const Frequency_n160_start = 2010
Const Frequency_n160_end = 3459
Const Chanaln160_start = 15 ' 50kHz
Const Chanaln160_end = 43
Const Number_of_chanals_n160 = 29
Const Mid_chanal_n160 = 29
'
Const Frequency_80_start = 3460
Const Frequency_80_end = 3804
Const Chanal80_start = 44
Const Chanal80_end = 66
Const Number_of_chanals_80 = 23
Const Mid_chanal_80 = 55
'
Const Frequency_n80_start = 3805
Const Frequency_n80_end = 6954
Const Chanaln80_start =  67
Const Number_of_chanals_n80 = 63
Const Chanaln80_end = 129
Const Number_of_chanals_n80 = 63
Const Mid_chanal_n80 = 98
'
Const Frequency_40_start = 6955
Const Frequency_40_end = 7209
Const Chanal40_start = 130
Const Chanal40_end = 146
Const Number_of_chanals_40 = 17
Const Mid_chanal_40 = 138
'
Const Frequency_n40_start = 7210
Const Frequency_n40_end = 10059
Const Chanaln40_start = 147
Const Chanaln40_end = 203
Const Number_of_chanals_n40 = 57
Const Mid_chanal_n40 =175
'
Const Frequency_30_start = 10060
Const Frequency_30_end = 10149
Const Chanal30_start = 203
Const Chanal30_end = 208
Const Number_of_chanals_30 = 6
Const Mid_chanal_30 = 205
'
Const Frequency_n30_start = 10150
Const Frequency_n30_end = 13999
Const Chanaln30_start = 209
Const Chanaln30_end = 285
Const Number_of_chanals_n30 = 285
Const Mid_chanal_n30 = 247
'
Const Frequency_20_start = 14000
Const Frequency_20_end = 14359
Const Chanal20_start = 286
Const Chanal20_end = 309
Const Number_of_chanals_20 = 24
Const Mid_chanal_20 =297

Const Frequency_n20_start = 14360
Const Frequency_n20_end = 18009
Const Chanaln20_start = 310
Const Chanaln20_end = 382
Const Number_of_chanals_n20 =734
Const Mid_chanal_n20 = 346
'
Const Frequency_17_start = 18010
Const Frequency_17_end = 18174
Const Chanal17_start = 382
Const Chanal17_end = 393
Const Number_of_chanals_17 = 11
Const Mid_chanal_17 = 387
'
Const Frequency_n17_start = 18175
Const Frequency_n17_end = 20974
Const Chanaln17_start = 394
Const Chanaln17_end = 451
Const Number_of_chanals_n17 = 58
Const Mid_chanal_n17 = 422
'
Const Frequency_15_start = 20975
Const Frequency_15_end = 21454
Const Chanal15_start = 452
Const Chanal15_end = 483
Const Number_of_chanals_15 = 22
Const Mid_chanal_15 = 467
'
Const Frequency_n15_start = 21455
Const Frequency_n15_end = 24854
Const Chanaln15_start = 484
Const Chanaln15_end = 551
Const Number_of_chanals_n15 = 68
Const Mid_chanal_n15 = 517
'
Const Frequency_12_start = 24855
Const Frequency_12_end = 25004
Const Chanal12_start = 552
Const Chanal12_end = 561
Const Number_of_chanals_12 = 10
Const Mid_chanal_12 = 557
'
Const Frequency_n12_start = 25005
Const Frequency_n12_end = 27954
Const Chanaln12_start = 562
Const Chanaln12_end = 620
Const Number_of_chanals_n12 = 59
Const Mid_chanal_n12 = 591
'
Const Frequency_10_start = 27955
Const Frequency_10_end = 29709
Const Chanal10_start = 621
Const Chanal10_end = 737
Const Number_of_chanals_10 = 117
Const Mid_chanal_10 = 679
'
'----------------------------------------------------
$regfile = "m1284Pdef.dat"
'for ATMega1284
'
'-----------------------------------------------------
$crystal = 14745600
$include "common_1.13\_Processor.bas"
$baud = 19200
'
'----------------------------------------------------
'
' Adress of external EEPROM, no MYC communication via I2C (not used)
Const I2c_address = &B10100000
Const No_of_announcelines = 44
Const Tx_factor = 15
' For Test:15 (~ 10 seconds), real usage:2 (~ 1 second)
Const S_length = 32
'
'----------------------------------------------------
$include "__use.bas"
$include "common_1.13\_Constants_and_variables.bas"
'
Dim Temp_i1 As Integer
Dim Temp_i2 As Integer
Dim Tempsingle As Single
Dim Tempsingle1 As Single
Dim Tempsingle2 As Single
Dim Tempsingle3 As Single
Dim Tempsingle4 As Single
' output of the 8 relais driver:
Dim Drive(8) As Byte
'Dim Aux As Byte
Dim Force_fan As Byte
Dim Fwd As Word
Dim Rev As Word
Dim Swr As Byte
Dim Last_power As Word
Dim Last_count As Word
Dim Diff_count1 As Word
Dim Diff_count2 As Word
Dim Diff_power As Word
Dim Ntc_value As Word
Dim L_value As Word
'to store during 50Ohm through
Dim L_value_old As Word
Dim L_value_last As Word
Dim C_value As Word
Dim C_value_old As Word
Dim L_pos(Number_of_chanals) As Eram Word
' Cpos.15 ... Cpos.14 contain Config_value.1 ... Config_value.0
Dim C_pos(Number_of_chanals) As Eram Word
Dim Config_value As Byte
Dim Config_value_old As Byte
Dim Last_config As Byte
Dim Relais_value As Byte
Dim Relais_value_old As Byte
Dim Relais_value_eram As Eram Byte
Dim Drive_enable As Byte
Dim Chanal_number As Word
Dim Pos_start(17) As Word
Dim Pos_mid(17) As Word
Dim Pos_end(17) As Word
Dim Frequency_temp As Dword
' real f (not MYC) in kHz
Dim Frequency As Word
Dim Up_down As Byte
Dim Up_down_step As Byte
Dim Band As Byte
Dim Action_counter As Byte
Dim Frequencies(10) As Word
Dim Cou(10) As Word
Dim Frequency_pointer As Byte
Dim Analyze_frequency As Byte
Dim Up_down_loop As Byte
Dim Found As Byte
Dim Valid_counts As Byte
'
'----------------------------------------------------
$include "common_1.13\_Macros.bas"
'
'----------------------------------------------------
$include "common_1.13\_Config.bas"
'
$initmicro
'----------------------------------------------------
' procedures at start
'
'----------------------------------------------------
$include "common_1.13\_Main.bas"
'
'----------------------------------------------------
$include "common_1.13\_Loop_start.bas"
'
'----------------------------------------------------
'
If Timer3 > 1000 Then
   ' every 70ms
   Select Case Action_counter
      Case 0
         Gosub Read_frequency
      Case 1
         Gosub Check_up_down
      Case 2
         Gosub Measure_temp
      Case 3
         Gosub Measure_swr
   End Select
  Incr Action_counter
  If Action_counter > 3 Then Action_counter = 0
  Timer3 = 0
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
'
_init_micro:
' Copy data to Output:
Strb Alias Portd.6
Config Strb = Output
Reset Strb
'
' Clock for Shifting
Sclk Alias Portd.5
Config Sclk = Output
Reset Sclk
'
' OE of driver IC (OE0 to OE7)( aktive low)
Oe0 Alias PortB.3
Config Oe0 = Output
Set Oe0
Oe1 Alias PortC.2
Config Oe1 = Output
Set Oe1
Oe2 Alias PortC.3
Config Oe2 = Output
Set Oe2
Oe3 Alias PortC.4
Config Oe3 = Output
Set Oe3
Oe4 Alias PortC.5
Config Oe4 = Output
Set Oe4
Oe5 Alias PortC.6
Config Oe5 = Output
Set Oe5
Oe6 Alias PortC.7
Config Oe6 = Output
Set Oe6
Oe7 Alias PortB.2
Config Oe7 = Output
Set Oe7
Return
'
Read_frequency:
If Analyze_frequency = 1 Then
   '10 measurements  done
   'frequency is divided by 8
   'gatetime is 17.151ms
   'Frequncy in kHz
   ' -> f = counts * 8 / 0.017151s / 1000 = counts * 0.466445
   ' 18MHz -> 3858 counts
  ' Reset Read_enable
   'print "f1"
    'Waitms 100
     ' set Read_enable
   B_temp3 = 0
   'Used tor teststs onla
   For B_temp1 = 1 To 10
      Cou(B_temp1) = Frequencies(B_temp1)
   Next B_temp1
   For B_temp1 = 1 To 10
      W_temp1 = Frequencies(B_temp1)
      ' valid if > 1,8MHz
      If W_temp1 > 3800 Then
         Tempsingle1 = Tempsingle1 + W_temp1
         Incr B_temp3
      End If
   Next B_temp1
   If B_temp3 > 5 Then
      ' > 5 must be valid
   '   print B_temp3
      'mean value
      Tempsingle1 = Tempsingle1 / B_temp3
      ' deviation < 10%  ?
      Valid_counts = 0
      Tempsingle2 = Tempsingle * 0.1
      Tempsingle = 0
      For B_temp1 = 1 To 10
         Tempsingle4 = Frequencies(B_temp1)
         ' valid if > 1,8MHz
         If W_temp1 > 3800 Then
            Tempsingle3 = W_temp1 + Tempsingle2
            If Tempsingle4 < Tempsingle3 Then
               Tempsingle3 = W_temp1 - Tempsingle2
               If Tempsingle4 > Tempsingle3 Then
                  Tempsingle = Tempsingle + W_temp1
                  Incr Valid_counts
               End If
            End If
         End If
      Next B_temp1
      If Valid_counts > 3 Then
         ' mean counts
         Tempsingle = Tempsingle / B_temp3
         Tempsingle = Tempsingle * 0.466445
         Frequency = Tempsingle
         Gosub Find_chanal_number_band
      End If
   End If
   Analyze_frequency = 0
   Reset Clr_counter
   Set Clr_counter
   TCnT0 = 9
   TCNT1 = 0
   Frequency_pointer = 1
End If
Return
'
Check_up_down:
   ' check Up_down
   If Drive_enable = 1 Then
      If Up_down_step > 1 Then
         Incr Up_down_loop
         B_temp4 = Up_down_step
         If Up_down_loop >= 4 Then
            If Up_down_step = 4 Then
               B_temp4 = 50
            End If
            If Up_down_step = 5 Then
               B_temp4 = 100
            End If
            Select Case Up_down
               Case 0
                  L_value = L_value + B_temp4
                  If L_value > L_max Then
                     L_value = 0
                  End If
                  Gosub Set_L_drive
               Case 1
                  If L_value  > Up_down_step Then
                     L_value = L_value - B_temp4
                  Else
                     L_value = L_max
                  End If
                  Gosub Set_L_drive
               Case 2
                  C_value = C_value + B_temp4
                  If C_value > C_max Then
                     C_value = 0
                  End If
                    Gosub Set_C_drive
               Case 3
                  If C_value > Up_down_step Then
                     C_value = C_value - B_temp4
                  Else
                     C_value = C_max
                  End If
                  Gosub Set_C_drive
            End Select
            Gosub Send_data
            L_value_old = L_value
            C_value_old = C_value
            Up_down_loop = 0
         End If
      Else
         Up_down_step = 0
      End If
   Else
      Up_down_step = 0
   End If
Return
'
Measure_temp:
   ' measure temprature
   Ntc_value = GetAdc(2)
   If NTC_value > Temp_fan Then
      'low temperature
      If Force_fan = 1 Then
         'switch on always
         Set Cool
      Else
         Reset Cool
      End If
   Else
      'switch on fan
     Set Cool
   End If
Return
'
Measure_swr:
'  measure swr
' To exchange Fwd and Rev, exchange 0 and 1 in the next 2 lines
   Fwd = Getadc(1)
   Rev = Getadc(0)
   If Fwd > Fwd_12 Then
      Drive_enable = 0
   Else
      Drive_enable = 1
   End If
Return
'
Print_tx:
' Print_tx in common_1.13 cannot be used because of Read_enable
Reset Read_enable
Decr  Tx_write_pointer
For B_temp2 = 1 To Tx_write_pointer
   B_temp3 = Tx_b(B_temp2)
   Printbin B_temp3
Next B_temp2
Tx_pointer = 1
Tx_write_pointer = 1
Tx_time = 0
Waitms 100
Set Read_enable
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
Set_L_drive:
' Description in the circuit diagramm for Lx on / Lx off is the relais state
' So if output xon is used the L is shortened (switched off)
' Drivenumber (drive(x)) correspond Dx in circuit diagram.
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
Set_C_drive:
' Description in the circuit diagramm for Cx on / Cx off is mixed up !!
' Drivenumber (drive(x)) correspond Dx in circuit diagram.
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
' in circuit dagram: on and of mixed up
' Drive is set only when status changes: then either on coil or off coil is set
' drive(2).6 and 7 are not used
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
      Drive(2).7 = 0
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
      Drive(2).7 = 0
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
      Drive(2).7 = 0
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
      Drive(2).7 = 0
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
'with drive = 0 nothing switched
'with later changes there are new "set"
Drive(1) = 0
Drive(2) = 0
Drive(3) = 0
Drive(4) = 0
Drive(5) = 0
Drive(6) = 0
Drive(7) = 0
Drive(8) = 0
Return
'
Interpolate:
' look for chanal with "set bit" downwards or upwards
' Value at start of band, if nothing found:
If chanal_number > Pos_mid(band) Then
   B_temp1 = 0
   W_temp1 = Pos_end(Band)
Else
   W_temp1 = Pos_start(Band)
End If
W_temp2 = Chanal_number
Found = 0
While  W_temp2 < W_temp1 And Found = 0
   W_temp3 = L_pos(W_temp2)
   B_temp4 = W_temp3.15
   If B_temp4 = 1 Then
      Found = 1
   End If
   If chanal_number > Pos_mid(band) Then
      Incr W_temp2
   Else
      Decr W_temp2
   End If
Wend
If Found = 1 Then
   L_value_old = L_value
   L_value = L_pos(W_temp2) And &B000111111111
   Gosub Set_L_drive
   C_value_old = C_value
   C_value = C_pos(W_temp2) And &B0011111111111111
   Gosub Set_C_drive
   Config_value_old = Config_value
   Config_value =  = C_pos(W_temp2) And &H1100000000000000
   Gosub Set_config_drive
   Gosub Send_data
' else do nothing no change
End If
Return
'
Find_fwd_rev:
' W_temp1 is actual count
Last_power = 0
Last_count = 0
Restore Fwd_rev_values
B_temp1 = 1
Found = 0
While B_temp1 < 15 And Found = 0
   'Power
   Read Temp_i1
   'count
   Read Temp_i2
   If W_temp1 < Temp_i2 Then
      'found
      Diff_count1 = W_temp1 - Last_count
      Diff_count2 = Temp_i2 - Last_count
      Tempsingle = Diff_count1 / Diff_count2
      Diff_power = Temp_i1 - Last_power
      Tempsingle = Diff_power * Tempsingle
      W_temp1 = Tempsingle
      W_temp1 = W_temp1 + Last_power
      Found = 1
   Else
      Last_power = Temp_i1
      Last_count = Temp_i2
   End If
   Incr B_temp1
Wend
Return
'
Frequency_isr:
' gatetine is  17.151ms
   If Analyze_frequency = 0 Then Frequencies(Frequency_pointer) = tcnt1
   Incr Frequency_pointer
   If Frequency_pointer >= 11 Then Analyze_frequency = 1
   Tcnt1 = 0
   tcnt0 = 9
   Reset Clr_counter
   Set Clr_counter
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
Ntc:
' 25degC -> 5*10/14.7V = 3.4V  -> count: 696
' use 1011 charactesistics from datasheet (may be 8500 is correct, but not changed: difference is < 1 deg)
'                                      1011                                8501 count
'                                                              per deg
' 0 degC: 5*30 / 34,7 = 4,32V       -> count 885               6
' 5 degC: 5*23.8 / 28.5 = 4.175     -> count 855  30           7
'10 degC  5*18.95 / 23.65 = 4.006   -> count 820  35           7 / 8
'15 degC  5*15.2 / 19.9 = 3.81      -> count 782  38           8 /9
'20degC   5*12.2 / 16.9 = 3.609     -> count 739  43           9 / 8
'25degC   5*10 / 14.7V = 3.4V       -> count:696  43           8 / 8       696
'30dedC   5*8.17 / 12.87 = 3.174    -> count 650  46           9 / 10      648
'40degC   5*5.57 / 10,27 = 2.71V    -> count 555      95       9           558
'50degC   5*3.87 / 8.57 = 2.25      -> count 462      93       9           467
'60degC   5*2.72 / 7.42 = 1.83V     -> count 375      87       8 / 7       382
'80degC   5*1.43 / 6.13 = 1.16      -> count 238      136      5 / 4       248
'100degC  5*0.81 / 5.51 = 0.735     -> count 150      135                  157
' one value from 0 to 100degC interpolated
'Interger must end with  %
' 0 - 9
Data 885%,879%,873%,867%,861%,855%,848%,841%,834%,827%,
'10 - 19
Data 820%,813%,806%,798%,790%,782%,774%,766%,757%,748%,
'20 - 29
Data 739%,730%,721%,712%,704%,696%,685%,676%,667%,658%,
'30 - 39
Data 651%,642%,633%,624%,615%,605%,595%,585%,575%,565%,
'40 - 49
Data 555%,546%,537%,528%,519%,510%,501%,492%,483%,474%,
'50-59
Data 462%,456%,447%,438%,429%,420%,411%,402%,393%,384%,
'60-69
Data 375%,360%,362%,355%,348%,341%,334%,327%,320%,314%,
'70-79
Data 308%,301%,294%,287%,280%,273%,266%,259%,252%,245%
'80-89
Data 238%,233%,228%,223%,218%,213%,208%,203%,198%,194%,
'90-100
Data 190%,186%,182%,178%,174%,170%,166%,162%,158%,154%,150%
'
Fwd_rev_values:
' measured:
'W    counts
'10   94
'20   137
'40   196
'60   243
'80   285
' others are estimated
'100  323
'200  390
'300  500
'400  600
'500  690
'600  770
'700  840
'800  900
'900  950
'1000 1023
'
Data 10%, 94%,20%, 137%, 40%, 196%, 60%, 243%, 80%, 285%, 100%, 323%
Data 200%, 390%, 300%, 500%, 400%, 600%, 500%, 690%, 600%, 770%, 700%, 840%,800%, 900%, 900%, 950%, 1000%, 1023%
'
'