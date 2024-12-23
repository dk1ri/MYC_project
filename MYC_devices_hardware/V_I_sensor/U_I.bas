'name : U_I.bas
'Version V01.0, 20241223

'purpose : Program for U / I Sensor INA219
'This Programm workes with serial protocol or use a wireless interface
'Can be used with hardware U_I_eagle Version V01.0 by DK1RI
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
' SPI
'-----------------------------------------------------
' Inputs / Outputs : see file __config.bas
' For announcements and rules see Data section in _announcements.bas
'
'------------------------------------------------------
' Missing/errors:
' It may be necessary to change config PGA 1/8 to 1/1

'------------------------------------------------------
' Detailed description

'
'----------------------------------------------------
$regfile = "m328pdef.dat"
'
'-----------------------------------------------------
$include "common_1.14\_Processor.bas"
$crystal = 10000000
'
'----------------------------------------------------
'
'=========================================
' Dies Werte koennen bei Bedarf geaendert werden!!!
' These values must be modified on demand!!!!

'
Dim I2c_addr As Byte
I2c_addr = 63
Const No_of_announcelines = 17
Const Tx_factor = 15
' For Test:15 (~ 10 seconds), real usage:2 (~ 1 second)
Const S_length = 32
'Radiotype 0: no radio Interface; 1: RFM95; 2: RYFA689
Const Radiotype = 2
Const Name_len = 4
'----------------------------------------------------
$include "__use.bas"
$include "common_1.14\_Constants_and_variables.bas"
'
Const config_reg =0
Const Shunt_voltage_reg = 1
Const Bus_voltage_reg = 2
Const Current_reg = 3
Const Power_reg = 4
Const Calibration_reg = 5
'
Dim Ina_register As Byte
Dim Offset As Word
Dim Is_minus AS BYte
Dim I2c_rx_data As Word
Dim I2c_tx_data As String * 3
Dim I2c_tx_data_b(3) As Byte At I2c_tx_data Overlay
Dim Myc_mode As Byte
Dim wirelesss_tx_in_progress As Byte
Dim wireless_active  As Byte
Dim wireless_active_eram As Byte
Dim Enable_switch_over As Byte
Dim Enable_switch_over_eram  As Eram Byte
Dim Radio_type As Byte
Radio_type = Radiotype
Dim Radio_name As String * 4
Dim Radio_name_eram As Eram String * 4
Dim Radio_name_b(4) As Byte At Radio_name Overlay
'
#IF Radiotype > 0
   $include "common_1.14\wireless_setup.bas"
#ENDIF
#IF Radiotype = 1
   $include "common_1.14\_LoRa_setup.bas"
   Gosub Lora_setup
#ENDIF
#IF Radiotype = 2
   $include "common_1.14\A7129_setup.bas"
   Gosub 7129_setup
#ENDIF
'
Wait 1
'
'----------------------------------------------------
$include "common_1.14\_Macros.bas"
'
'----------------------------------------------------
$include "common_1.14\_Config.bas"
'
'----------------------------------------------------
$include "common_1.14\_Main.bas"
'
'----------------------------------------------------
$include "common_1.14\_Loop_start.bas"
'
#If Radiotype > 0
   If wirelesss_tx_in_progress = 0 Then
      ' read from wireless
      If Myc_mode = 0 Then
         ' server transparent read from wireless:
         #IF Radiotype = 1
            Gosub Lora_rx
         #ENDIF
         #IF Radiotype = 2
            Gosub 7129_rx
         #ENDIF
         '
         ' check serial in for data to transmit
         ' After send to do avoid rx and tx in the same loop
         Gosub Transparent_mode_rx_serial
      End If
      '
      If Send_wireless = 1 Then
         Gosub Tx_wireless_start
         Send_wireless = 0
      End If
      '
   Else
      #IF Radiotype = 1
          Gosub Lora_finish_tx
      #ENDIF
   End if
   '
  #IF Radiotype = 2
     If Wait_for_rx_ready = 1 Then
        ' return to receive mode)
        If Gio1 = 0 Then gosub Set_rx_mode
     End If
  #ENDIF
#ENDIF
:
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
#IF Radiotype = 1
   $include "common_1.14\wireless.bas"
   $include "common_1.14\_Lora.bas"
#ENDIF
#IF Radiotype = 2
   $include "common_1.14\wireless.bas"
   $include "common_1.14\A7129.bas"
#ENDIF
'
'
'----------------------------------------------------
'
Write_i2c_data:
   i2csend  I2c_addr, I2c_tx_data_b(1), 3
Return
'
Read_i2c_data:
   i2csend  I2c_addr, Ina_register
   i2creceive I2c_addr, I2c_rx_data, 2
Return
'
Transparent_mode_rx_serial:
#IF Radiotype > 0
   ' in transparent mode the end of serial transmission is not defined.
   ' so wait 5 times, with  commandpointer is not increased
   ' then send
   ' called by the main programm
      If Command_pointer > 0 Then
         ' something received
         If Commandpointer_old = Commandpointer Then
            Incr wireless_serial_rx_count
            If wireless_serial_rx_count > 5 Then
               ' Rx is ready

               '
               If Myc_mode = 0 Then
                  ' Not switched to Myc: data received: send to client (content of command)
                  Send_wireless = 1
               End If
               wireless_serial_rx_count = 0
               Send_wireless = 1
               Commandpointer_old = 0
            End If
         Else
            Commandpointer_old = Commandpointer
            wireless_serial_rx_count = 0
         End If
      End If
#ENDIF
Return
'
Complement:
If I2c_rx_data > &B0111111111111111 Then
   ' negative
   I2c_rx_data = I2c_rx_data Xor &HFFFF
   incr I2c_rx_data
   Is_minus = 1
End If
Return
'
Print_to_all:
#IF Radiotype > 0
   If Command_mode = 1 Then
      Gosub Print_tx
      If Myc_mode = 0 Then
         'client onky
         Gosub Tx_wireless_start
      End If
   End If
#ENDIF
Return
'
'***************************************************************************
'
'----------------------------------------------------
'$include "_Commands.bas"
$include "common_1.14\_Commands_required.bas"
'
$include "common_1.14\_Commandparser.bas"
'
'-----------------------------------------------------
' End
'
$include "_announcements.bas"