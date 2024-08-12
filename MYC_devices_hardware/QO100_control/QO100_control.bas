'name QO100_control
'Version V01.4, 20240811
'purpose : Program for power controlboard for QO100
'This Programm workes with serial protocol
'Can be used with hardware power_schalter Version V02.4 by DK1RI
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
'
'------------------------------------------------------
' Detailed description
' At start everything is switched off
'
' Only those connected equipment is switched on, which is actually used (see manual)
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
Const No_of_announcelines = 32
Const Tx_factor = 15
' for Timer (LED) 1 : 20000000 / 1024 / 19500 = 1 -> 1sec
Const Timer1_stop = 65535 - 19500
Const Wait_1s = 1
' 2 sec:
Const Wait_2s = 2
Const Wait_4s = 4
Const Wait_7s = 7
'55 degC:
Const  Switch_off_temp_default = 55
'
Const S_length = 32
' Timer3 tick : 20MHz / 1024 = 19,5kHz  -> T = 51,2us
' ser timeout 1ms (9600kBaud) for 1 byte -> 20 ticks necessary
' but there is a delay at atsrt: -> 20000 -> 2s
Const Serial_timeout = 64935 - 10000
'
'Dim NB_WB_pin_ As Byte
Dim NB_WB_pin_last As Byte
Dim Ptt_pin_last As Byte
Dim Timer_store As Word
' 0: off, 1: NB, 2: WB
Dim NB_WB_ As Byte
Dim Ptt_ As Byte
Dim Adc_value As Word
Dim Si_temp1 As Single
Dim Temperature As Byte
Dim Up_pointer As Byte
Dim Up_string As String * 8
Dim Up_string_b(7)As Byte At Up_string Overlay
Dim Up_f As Byte
Dim Up_r As Byte
Dim Ser2_valid As Byte
Dim Wait_led As Byte
Dim Timeout_flag As Byte
Dim Switch_off_temp As Byte
Dim Switch_off_temp_eram As ERAM Byte
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
Waitms 100
Gosub Switch_off
'----------------------------------------------------
$include "common_1.13\_Loop_start.bas"
'
Gosub Check_external_switches
Gosub  Read_temperature
If Temperature > Switch_off_temp Then
   Gosub 13cmPA_ptt_off
   Gosub PTT_out_off
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
' 12V_DATV
12V_DATV Alias PortB.0
Config 12V_DATV = Output
Reset 12V_DATV

'1WPA2
1WPA2 Alias PortB.2
Config 1WPA2 = Output
Set 1WPA2
'
Biast Alias PortB.3
Config Biast = Output
Reset Biast
'
' Pluto WB
PlutoWB Alias PortC.0
Config PlutoWB = Output
Set PlutoWB
'
'LED
Led_ Alias Portc.1
Config LED_ = Output
Set Led_
'
'1WPA1
1WPA1 Alias PortC.2
Config 1WPA1 = Output
Set 1WPA1
'
'relais
Relais Alias PortC.3
Config Relais = Output
Reset Relais
'
'13cmPA_Ptt
13cmPA_Ptt Alias Portc.4
Config 13cmPA_Ptt = Output
Reset 13cmPA_Ptt
'
'Pttout_
Pttout_ Alias PortC.5
Config Pttout_ = Output
Reset Pttout_
'
'Minitiouner
Minitiouner Alias PortD.5
Config Minitiouner = Output
Reset Minitiouner
'
' Upcon
Upcon Alias PortD.6
Config Upcon = Output
Reset Upcon
'
' FAN
Fan Alias PortD.7
Config FAN = Output
Reset Fan
Return
'
12v_datv_off:
'12V DATV
Reset 12V_datv
Return
'
12v_datv_on:
'12V DATV
Set 12V_datv
Return
'
1WPA2_off:
'1WPA2
Set 1WPA2
Return
'
1WPA2_on:
'1WPA2
Reset 1WPA2
Return
'
Biast_12:
'Biast
Reset Biast
Return
'
Biast_17:
'Biast
Set Biast
Return
'
Pluto_wb_off:
'Pluto_wb
Set Plutowb
Return
'
Pluto_wb_on:
'Pluto_wb
Reset Plutowb
Return
'
1WPA1_off:
'1WPA1
Set 1WPA1
Return
'
1WPA1_on:
'1WPA1
Reset 1WPA1
Return
'
Relais_off:
' relais
Reset Relais
Return
'
Relais_on:
' relais
Set Relais
Return
'
13cmPA_ptt_off:
'13cmPA_Ptt
Reset 13cmPA_Ptt
Ptt_ = 0
Return
'
13cmPA_ptt_on:
'13cmPA_Ptt
Set 13cmPA_Ptt
Ptt_ = 1
Return
'
Ptt_out_off:
'Ptt_out
Reset Pttout_
printbin #2,&H50; &H30; &H0D;
Ptt_ = 0
Return
'
Ptt_out_on:
'Ptt_out
Set Pttout_
printbin #2,&H50; &H31; &H0D;
Ptt_ = 1
Return
'
Minitiouner_off:
'Minitiouner                                               q
Reset Minitiouner
Return
'
Minitiouner_on:
'Minitiouner
Set Minitiouner
Return
'
Upconverter_off:
' Upconverter power off
Reset Upcon
' no need for serial switch off
Return
'
Upconverter_on:
' Upconverter power on
Set Upcon
' wait for Upcon to accept serial data
Stop Watchdog
Wait 2
printbin #2,&H4F; &H31; &H0D;
Start Watchdog
Return
'
Fan_off:
'Fan
Reset FAN
Return
'
Fan_on:
'Fan
Set FAN
Return
'
Check_external_switches:
   ' switch:0: WB 1 (open): NB
   B_temp1 = NB_WB_in
   If B_temp1 <> NB_WB_pin_last Then
      Waitms 50
      B_temp1 = NB_WB_in
      If B_temp1 <> NB_WB_pin_last Then
         NB_WB_pin_last = B_temp1
          ' change
         If B_temp1 <>  NB_WB_pin_last Then
            Gosub Switch_off
            NB_WB_pin_last = B_temp1
            If B_temp1 = 0 Then
               Gosub Start_WB
               NB_WB_= 2
            Else
               Gosub Start_NB
               NB_WB_ = 1
            End If
         End If
      End If
   End If
   ' external PTT is 0 active !
   ' only in NB or WB mode
   B_temp1 = Ptt_in
   If B_temp1 <> Ptt_pin_last Then
      Waitms 50
      If B_temp1 <> Ptt_pin_last Then
         If NB_WB_ = 1 or NB_WB_ = 2 Then
            Ptt_pin_last = B_temp1
               If B_temp1 = 1 Then
                  Gosub End_transmit
               Else
                  Gosub Start_transmit
              End If
          Else
            Not_valid_at_this_time
         End If
      End If
   End If
Return
'
Start_transmit:
   If NB_WB_ = 1 Then Gosub Ptt_out_on
   If NB_WB_ = 2 Then Gosub 13cmPA_Ptt_on
Return
'
End_transmit:
   Ptt_ = 0
   Gosub Ptt_out_off
   Gosub 13cmPA_Ptt_off
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
    Wait_led = Wait_2s
    Ptt_ = 0
Return
'
Start_NB:
   Gosub Biast_12
   Gosub Upconverter_on
   Wait_led = Wait_4s
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
    Wait_led = Wait_7s
Return
'
Start_DATV_RX:
   Gosub Minitiouner_on
   Gosub Biast_17
   Gosub Relais_on
   Wait_led = Wait_1s
Return
'
Get_serial_2:
   Stop Watchdog
   Ser2_valid = 0
   Up_pointer = 1
   Up_string = String (6, 0)
   TCNT3 = Serial_timeout
   Timeout_flag = 0
   printbin #2,B_temp1;&H0D;
   Start Timer3
   While Timeout_flag = 0
      B_temp1 = Ischarwaiting(#2)
      ' The upconverter delivers CR
      If B_temp1 = 1 Then
         B_temp1 = Waitkey(#2)
         Up_string_b(Up_pointer) = B_temp1
         Incr Up_pointer
         If Up_pointer < 5 Then
            If B_temp1 = &H0D Then
               Ser2_valid = 1
               Timeout_flag = 1
            End If
            TCNT3 = Serial_timeout
         Else
            Timeout_flag = 1
            Up_string_b(Up_pointer) = 78
         End If
      End If
   Wend
   Stop Timer3
   Start Watchdog
Return
'
Check_number:
   If B_temp1 > &H2F And B_temp1 < &H3A Then
      B_temp1 = B_temp1 - &H30
   Else
      B_temp1 = 0
   End If
Return
'
Read_temperature:
'external Temperatur sensor
' LM135 0 -> -263 degc; 10mV / degc  2980mV -> 25 degc
' adc resolution 5V / 1024  -> 5mV abt  -> 0.5 degc resolution
'
 ' Temp: external Temp sensor of 23cm PA
   W_temp1 = Getadc(0)
   If W_temp1 > 1000 Then Return
   If W_temp1 < 559 Then
      Temperature = 0
      Return
   End If
   'T / degC = W_temp1 / 1024 * 5 - 2.731
   Si_temp1 = W_temp1 * 5
   ' mV:
   Si_temp1 = Si_temp1 / 1024
   Si_temp1 = Si_temp1 - 2.731
   Si_temp1 = Si_temp1 * 100
   Temperature = Si_temp1
 Return
 '
Sub Timer1_int():
   ' for LED
   Incr Timer_store
   If Timer_store > Wait_led Then
      If Led_ = 1 Then
         Reset Led_
      Else
         Set Led_
      End If
      Timer_store = 0
   End If
   Tcnt1 = Timer1_stop
End Sub
'
Sub Check_serial_timeout():
   Timeout_flag = 1
   Serial_timout
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