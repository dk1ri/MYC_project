'name QO100_control
'Version V01.0, 20231013
'purpose : Program for power controlboard for QO100
'This Programm workes with serial protocol
'Can be used with hardware power_schalter Version V02.3 by DK1RI
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
' 2 x  serial
'-----------------------------------------------------
' Inputs /Outputs : see file __config.bas
' For announcements and rules see Data section in announcements.bas
'
'------------------------------------------------------
' Missing/errors:
'PTT schaltet nicht ein
' automatisches umschalten auf WB, wenn WB /NV angeschloessen ist
'
'
'------------------------------------------------------
' Detailed description
' At start everything is switched off, except upconverter (switched on by port); started = 0
' after 2 seconds Upconverter switched on by serial; started = 1
' after 15min ptt on possible without NB / WB switch
'
' Only those connected equipment is switched, which is actually used (see manual)
'
'----------------------------------------------------
$regfile = "m1284pdef.dat"
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
' Dies Werte koennen bei Bedarf geaendert werden!!!
' These values must be modified on demand!!!!
'
' not used:
Const I2c_address = 1
Const No_of_announcelines = 18
Const Tx_factor = 15
' for Timer 1 : 20000000 / 1024 / 19500 = 1 -> 1sec
' Waittime at start: 15min ->  900 loops
Const Timer1_stop = 65535 - 19500
' 2 sec
Const Timer3_stop = 65535 - 39000
' 15 min:
Const Start_stop = 10  '900
' 2 sec:
Const Wait_2s = 2
Const Wait_4s = 4
Const Wait_7s = 7
'
Const S_length = 32
' 1 loop is 1000 cycles (min) abt -> 50us
' 150ms waitime after read -> 3000 loops
Const Wait_timeout_serial = 20000
' for Com2 RX timeout:
Dim NB_WB_pin_ As Byte
Dim NB_WB_pin_old_ As Byte
Dim Ptt_pin_ As Byte
Dim Ptt_pin_old_ As Byte
Dim Wait_time As Word
Dim Timer_store As Word
' 0: off, 1: NB, 2: WB
Dim NB_WB_ As Byte
Dim Ptt_ As Byte
' started: 0: at start; 1; after 2sec: 2 after 15 min
Dim Started As Byte
Dim Adc_value As Word
Dim Si_temp1 As Single
Dim Temperature As Word
Dim Fan_ As Byte
Dim Minitiouner_ As Byte
Dim BiasT_ As Byte
Dim Ptt_out_ As Byte
Dim Pluto_WB_ As Byte
Dim 1wPA1_ As Byte
Dim 1wPA2_ As Byte
Dim Relais_ As Byte
Dim 13cmPA_Ptt_ As Byte
Dim 12v_datv_ As Byte
Dim Upconverter_ As Byte
Dim Ser_command As Byte
Dim Up_pointer As Byte
Dim Up_string As String * 4
Dim Up_string_b(4)As Byte At Up_string Overlay
Dim Up_temp As Byte
Dim Up_f As Byte
Dim Up_r As Byte
Dim Up_locked As Byte
Dim Ser2_valid As Byte
Dim Blocked As Byte
Dim Block_request As Byte
Dim Wait_led As Byte
'----------------------------------------------------
$include "__use.bas"
$include "common_1.13\_Constants_and_variables.bas"

'
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
'
If Started > 0 Then
   Gosub Check_block_wait
   Gosub Check_external_switchces
'
   If Upconverter_ = 1 Then
      Gosub Send_read_command
      Gosub Get_serial_2
      Gosub Check_ser_valid
   End If
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
'switch off all
'
'PA2.2 for tests
PA2_2 Alias PinA.6
Config PA2_2 = Output
'
' 12V_DATV
12V_datv Alias PortB.0
Config 12V_datv = Output

'1WPA2
1WPA2 Alias PortB.2
Config 1WPA2 = Output
'
Biast Alias PortB.3
Config Biast = Output
'
' Pluto WB
Pluto_wb Alias PortC.0
Config Pluto_wb = Output
'
'LED
Config Led = output
Set Led
'
'1WPA1
1WPA1 Alias PortC.2
Config 1WPA1 = Output
'
'relais
Relais Alias PortC.3
Config Relais = Output
Relais = 0
'
'13cmPA_Ptt
13cmPA_Ptt Alias Portc.4
Config 13cmPA_Ptt = Output
'
'Pttout
PTT_out Alias PortC.5
Config Ptt_out = Output
'
'Minitiouner
Minitiouner Alias PortD.5
Config Minitiouner = Output
'
' Upconverter
Upconverter Alias Portd.6
Config Upconverter = Output
'
' FAN
FAN Alias PortD.7
Config FAN = Output
'
Gosub Switch_off
Return
'
12v_datv_off:
'12V DATV
Reset 12V_datv
12V_datv_ = 0
Return
'
12v_datv_on:
'12V DATV
Set 12V_datv
12V_datv_ = 1
Return
'
1WPA2_off:
'1WPA2
Set 1WPA2
1WPA2_ = 0
Return
'
1WPA2_on:
'1WPA2
Reset 1WPA2
1WPA2_ = 1
Return
'
Biast_12:
'Biast
Reset Biast
Biast_ = 0
Return
'
Biast_17:
'Biast
Set Biast
Biast_ = 1
Return
'
' Pluto_nb is on always (not switchable
'
Pluto_wb_off:
'Pluto_wb
Set Pluto_wb
Pluto_wb_ = 0
Return
'
Pluto_wb_on:
'Pluto_wb
Reset Pluto_wb
Pluto_wb_ = 1
Return
'
1WPA1_off:
'1WPA1
Set 1WPA1
1WPA1_ = 0
Return
'
1WPA1_on:
'1WPA1
Reset 1WPA1
1WPA1_ = 1
Return
'
Relais_off:
' relais
Reset Relais
Relais_ = 0
Return
'
Relais_on:
' relais
Set Relais
Relais_ = 1
Return
'
13cmPA_ptt_off:
'13cmPA_Ptt
Reset 13cmPA_Ptt
13cmPA_Ptt_ = 0
Ptt_ = 0
Return
'
13cmPA_ptt_on:
'13cmPA_Ptt
Set 13cmPA_Ptt
13cmPA_Ptt_ = 1
Ptt_ = 1
Return
'
Ptt_out_off:
'Ptt_out
Reset Ptt_out
Stop Watchdog
Waitms 100
printbin #2,&H4F; &H30; &H0D;
Start Watchdog
Ptt_out_ = 0
Ptt_ = 0
Return
'
Ptt_out_on:
'Ptt_out
Set Ptt_out
Stop Watchdog
Waitms 100
printbin #2,&H4F; &H31; &H0D;
Start Watchdog
Ptt_out_ = 1
Ptt_ = 1
Return
'
PA2_2_off:
'for tests
Reset PA2_2
Return
'
PA2_2_on:
'for tests
Set PA2_2
Return
'
Minitiouner_off:
'Minitiouner
Reset Minitiouner
Minitiouner_ = 0
Return
'
Minitiouner_on:
'Minitiouner
Set Minitiouner
Minitiouner_ = 1
Return
'
Upconverter_off:
' Upconverter power off
Reset Upconverter
' no need for srial switch off
Upconverter_ = 0
Return
'
Upconverter_on:
' Upconverter power on, not switched on !!!
Set Upconverter
Return
'
Fan_off:
'Fan
Reset FAN
FAN_ = 0
Return
'
Fan_on:
'Fan
Set FAN
FAN_ = 1
Return
'
Check_external_switchces:
   ' external PTT is 0 active !
   ' At start NB_WB = 0
   If NB_WB_ > 0 Then
      B_temp1 = Ptt_pin
      If B_temp1 <> Ptt_pin_old_ Then
         If B_temp1 = 1 Then
            Block_request = 3
         Else
            Block_request = 2
         End If
         Ptt_pin_old_ = B_temp1
         Started = 2
      End If
      '
      ' switch:0: WB 1 (open): NB
      B_temp1 = NB_WB_pin
      If B_temp1 <> NB_WB_pin_old_ Then
         If B_temp1 = 0 Then
         ' WB
            Block_request = 5
         Else
            'NB
            Block_request = 4
         End If
         NB_WB_pin_old_ = B_temp1
         Started = 2
      End If
   End If
Return
'
Send_read_command:
   ' stop new read command, if operate command is waiting
   If Block_request = 0 Then
      ' read in progress?
      If Blocked = 0 Then
         Select Case Ser_command
            Case 0:
               'Upconverter Temperature
               printbin #2,&H74;&H0D;
            Case 1:
               'Upconverter forward
               printbin #2,&H74;&H0D;
              ' printbin #2,&H66 ; &H0D;
            Case 2:
               'Upconverter reverse
               printbin #2,&H74;&H0D;
              ' printbin #2,&H72; &H0D;
             Case 3:
               'Upconverter locked
               printbin #2,&H74;&H0D;
              ' printbin #2,&H6C; &H0D;
         End Select
         Blocked = 1
         Wait_time = 0
      End If
   End If
Return
'
Reset_serial:
   Ser2_valid = 0
   Wait_time = 0
   Blocked = 0
   Up_pointer = 1
   Up_string = String (0, 4)
Return
'
Check_ser_valid:
   If Ser2_valid = 1 Then
      Select Case Ser_command
         Case 0:
            Up_temp = Up_string_b(1) - &H30
            If Up_string_b(2) <> 0 Then
               Up_temp = Up_temp * 10
               B_temp1 = Up_string_b(2) - &H30
               Up_temp = Up_temp + B_temp1
            End If
         Case 1:
            Up_f = Up_string_b(1) - &H30
            Up_f = Up_f * 100
            B_temp1 = Up_string_b(2) - &H30
            B_temp1 = B_temp1 * 10
            Up_f = Up_f + B_temp1
            B_temp1 = Up_string_b(3) - &H30
            Up_f = Up_f + B_temp1
         Case 2:
            Up_r = Up_string_b(1) - 30
            Up_r = Up_r * 100
            B_temp1 = Up_string_b(2) - &H30
            B_temp1 = B_temp1 * 10
            Up_r = Up_r + B_temp1
            B_temp1 = Up_string_b(3) - &H30
            Up_r = Up_r + B_temp1
         Case 3:
            B_temp1 = Up_string_b(1) - &H30
            Up_temp = B_temp1 * 10
            B_temp1 = Up_string_b(2) - &H30
            Up_temp = Up_temp + B_temp1
      End Select
      Gosub Reset_serial
      Incr Ser_command
      If Ser_command > 3 Then Ser_command = 0
   Else
      'timeout?
      If Wait_time > Wait_timeout_serial Then
         Gosub Reset_serial
         Incr Ser_command
         If Ser_command > 3 Then Ser_command = 0
      End If
   End If
   Incr Wait_time
Return

Check_block_wait:
   If Blocked = 0 Then
      If Block_request > 0 Then
         ' Block_request = 0 -> no request
         Select Case Block_request
            Case 2
               Gosub Start_transmit
            Case 3
               Gosub End_transmit
         End Select
         Block_request =  0
      End If
   End If
Return
'
Start_transmit:
   If NB_WB_ > 0 Then
      Ptt_ = 1
      If NB_WB_ = 1 Then
         Gosub Ptt_out_on
      Else
         Gosub 13cmPA_Ptt_on
      End If
   End If
Return
'
End_transmit:
   Ptt_ = 0
   If NB_WB_ = 1 Then Gosub Ptt_out_off
   If NB_WB_ = 2 Then Gosub 13cmPA_Ptt_off
Return
'
Switch_off:
    'switch off all
    ' transmitting devices first
    Gosub 1WPA1_off
    Gosub 1WPA2_off
    Gosub 13cmPA_ptt_off
    Gosub Upconverter_off
    Gosub 12v_datv_off
    Gosub Biast_12
    Gosub Pluto_wb_off
    Gosub Relais_off
    Gosub Ptt_out_off
    Gosub Minitiouner_off
    Gosub Fan_off
    NB_WB_ = 0
    Wait_led = Wait_2s
    ' delete data from upconverter
    UDR1 = 0
Return
'
Start_NB:
   Gosub Biast_12
   Gosub Upconverter_on
   Gosub Relais_off
   Wait_led = Wait_4s
   Gosub Reset_serial
Return
'
Start_WB:
    Gosub Relais_on
    Gosub 1WPA1_on
    Gosub 1WPA2_on
    Gosub Biast_17
    Gosub Pluto_wb_on
    Gosub 12V_datv_on
    Gosub Fan_on
    Gosub Minitiouner_on
    NB_WB_ = 2
    Wait_led = Wait_7s
Return
'
Get_serial_2:
   B_temp1 = Ischarwaiting(#2)
   ' The upconverter delivers one byte (+ CR?)
   If B_temp1 = 1 Then
      B_temp1 = Waitkey(#2)
      If B_temp1 <> 0 Then
         If B_temp1 <> &H0D Then
            Up_string_b(Up_pointer) = B_temp1
            If Up_pointer < 4 Then Incr Up_pointer
         Else
            Ser2_valid = 1
         End If
      End If
   End If
Return
'
Sub Timer1_int():
   Incr Timer_store
   Select Case Started
   Case 2:
         If Timer_store > Wait_led Then
            If Led = 1 Then
               Reset Led
            Else
               Set Led
            End If
            Timer_store = 0
         End If
      Case 1:
         ' 15 min after switch on:
         If Timer_store > start_stop Then
            Started = 2
            Timer_store = 0
         End If
      Case 0:
         If Timer_store > Wait_2s Then
            ' 2sec after power on upconverter cab be on directly
            Started = 1
            Gosub Start_nb
            Reset Led
            Timer_store = 0
         End If
   End Select
   Tcnt1 = Timer1_stop
End Sub
'
Sub Switch_upconverter_on_serial():
' upconverter was off -> no read request before
printbin #2, &H4F; &H31; &H0D;
Upconverter_ = 1
NB_WB_ = 1
Stop Timer3
End Sub
'***************************************************************************

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