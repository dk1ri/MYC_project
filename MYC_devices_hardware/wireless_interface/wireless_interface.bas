'name : wireless interface
'Version V01.0, 20241217
'purpose : Program for a serial to wireless Interface; serverside
'Can be used with hardware wireless_interface V01.0 by DK1RI
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
'
'------------------------------------------------------
' Detailed description
' The Modul Type is fixed and not programmable.
'
' Transparent mode
' Data are directly sent from serial / USB (like a command) to radio, if Commandpointer do not change within 5 loops
' length is added as first byte for RYFA689 modul
' received data (Spi_in) are sent to serial (print), For RYFA689 first byte is the lenght of the packet (removed)
'
' Myc mode
' input from wireless interface  not used, works as all MYC devices output to wireless interface for configuration.
'
' Client (func)side should work as this:
' wireless interface is enabbled by individualization, Input from wireless interface is a command input as via serial / USB input
' (length byte removed)
' Answers are send to all interfaces; for wireless interface length byte added.
' The server may send commands for wireless interface configuration,(if allowd)
' Server must be in transparent mode !!!
'
' Please refer to the relevant manual:
'RFM95:
' frequency: 868MHz (High) -> RFM
' spreading factor: 128 (7)
' Coding Rate :? RegTxCfg1 not found, see page 25
' Bandwidth ?
' Preamble length : 12 (8)
' explicite mode (with header) RxPayloadCrcOn
'
' RYFA689 (A2179):
' Frequeny: 433MHz
' initial Set paramters taken from C file by manufacturer
' Master /Slave mode not used: (no ACKK !) just send and receive
' if Func send info and CR send data at that time info is lost and command as well
'
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
Const No_of_announcelines = 15
Const Tx_factor = 15
' For Test:15 (~ 10 seconds), real usage:2 (~ 1 second)
Const S_length = 32
'Radiotype 0: no radio Interface; 1: RFM95; 2: RYFA689
Const Radiotype = 1
Const Name_len = 4
'----------------------------------------------------
$include "__use.bas"
$include "common_1.14\_Constants_and_variables.bas"
'
Dim I2c_address As Byte 'not used
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
               If Enable_switch_over = 1 Then Gosub Analyze_switch_to_myc
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
Analyze_switch_to_myc:
#IF Radiotype > 0
   ' switch to MYC?
   If Len(Command) = 34 Then
      If Command = Myc_string Then
         Myc_mode = 1
      End If
   End If
#ENDIF
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
$include "_Commands.bas"
$include "common_1.14\_Commands_required.bas"
'
$include "common_1.14\_Commandparser.bas"
'
'-----------------------------------------------------
' End
'
$include "_announcements.bas"
'