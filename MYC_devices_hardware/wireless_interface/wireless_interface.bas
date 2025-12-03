'name : wireless interface
'Version V03.0, 20251201
'purpose : Program for a serial to wireless Interface
'Can be used with hardware wireless_interface V05.0 / V03.1 by DK1RI
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
' I2C
'-----------------------------------------------------
' Inputs / Outputs : see file __config.bas
' For announcements and rules see Data section in _announcements.bas
'
'------------------------------------------------------
' Missing/errors:
'
'------------------------------------------------------
' Detailed description
' There are differnt "modes":
' wireless_active = 0 (set by command &HFE, cannot be set in transparent mode)
'     all wireless functions off
' wireless_active = 1 (default, )
'     InterfaceFU = 0 (interface device)
'     wireless_active parameter is ignored (always wireless)
'        Mode_in bridged
'           Myc_mode = 1
'           serial only wireless off; config of wireless device is not modified
'           valid for RX and TX for wireless transmission connection
'        Mode_in open
'           Myc_mode = 0
'           transparent mode; no commands accepted
'     InterfaceFU = 1 (other devices; clients for interface device))
'        MYC commands are transmitted only
'        The behaviour for different myc_mode is handled by the commands always (not by wireless in commonxx)!!!
'        Myc_mode = 0:
'           command to modify wireless are not allowed
'        MYC commands are transmitted always
'        Myc_mode = 1:
'           command to modify wireless are allowed
'           These command will initiate a restart
'----------------------------------------------------
$regfile = "m1284pdef.dat"
'
'-----------------------------------------------------
$include "common_1.14\_Processor.bas"
$crystal = 20000000
'
'----------------------------------------------------
'
'=========================================
' Diese Werte koennen bei Bedarf geaendert werden!!!
' These values must be modified on demand!!!!
'
' 1 ... 127
Const I2c_address = 40
Const No_of_announcelines = 16
Const Tx_factor = 15
' For Test:15 (~ 10 seconds), real usage:2 (~ 1 second)
Const S_length = 50
'
'Radiotype 0: no radio; 1:RFM95 433MHz; 2:WLAN 3: RYFA689 4: nRF24, 5: Bluetooth
'default nRF24
Const Radiotype_default = 4
Const Radioname_default = "radix"
' 433.05 - 434,79MHz -> 433 - 434,7; 1kHz spacing
' 434MHZ:
Const Radio_frequency_default0 = 1000
Const Radio_frequency_start0 = 433000000
' WLAN: 2,4GHZ - 2.48GHz
'
' RYFA689 ???
'
'nrf24:  2,4 - 2.5 GHz; 1MHz spacing; 128 chanals
' Bluetooth:   2,4 - 2.5 GHz;
'
Const Radio_frequency_default4 = 40
'
Const Name_len = 5
'Interface: 0 other FU: 1:
Const InterfaceFU = 0
'----------------------------------------------------
$include "__use.bas"
$include "common_1.14\_Constants_and_variables.bas"
'
$include "common_1.14\wireless_constants.bas"
'----------------------------------------------------
$include "common_1.14\_Macros.bas"
'
'----------------------------------------------------
'
wait 10
Restart:
Print "start"
'
$include "common_1.14\_Config.bas"
'
If Pin_reset = 0 Then Gosub Reset_
'
If First_set <> 5 Then Gosub Reset_
'
$include "common_1.14\_Init.bas"
'
'----------------------------------------------------
$include "common_1.14\_Loop_start.bas"

If Interface_transparent_active = 1 Then
   ' transparent Interface
   ' receive
   Select Case Radio_type
     Case 1
        Gosub RFM95_receive0
     Case 4
        Gosub nRF24_receive4
   End Select
'
   ' send, if rquested
   If Command_pointer > 0 Then
      If Last_command_pointer <> Command_pointer Then
         B_temp5 = 10
         Last_command_pointer = Command_pointer
      Else
          ' wait 10 * 5ms after change of command_pointer
         ' because the end of incoming data is unknown
         Decr B_temp5
         If B_temp5 = 0 Then
            wireless_tx_length = Command_pointer
            Select Case Radio_type
               Case 1
                  Gosub RFM95_send0
               Case 4
                  Gosub nRF24_send4
            End Select
            Gosub Command_received
         Else
            waitms 5
         End If
      End If
   Else
      Last_command_pointer = 0
   End If
   Stop Watchdog
End If
'
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
$include "common_1.14\_Subs.bas"
'
'----------------------------------------------------
'
$include "common_1.14\RFM95.bas"
$include "common_1.14\Bluetooth.bas"
$include "common_1.14\nrf24.bas"
'$include  "common_1.14\A7129.bas"
'$include "common_1.14\_RRYFA689.bas"
'
'***************************************************************************
'
'----------------------------------------------------
$include "_Commands.bas"
$include "common_1.14\_Commands_required.bas"
'
$include "__Select_command.bas"
'
'-----------------------------------------------------
' End
'
$include "_announcements.bas"
'