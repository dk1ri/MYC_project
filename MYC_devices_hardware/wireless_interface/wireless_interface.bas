'name : wireless interface
'Version V03.0, 20251208
'purpose : Program for a serial to wireless Interface
'Can be used with hardware wireless_interface V05.0 by DK1RI
'
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
' To run the compiler the directory comon_1.14 (202512) with includefiles must be copied to the directory of this file!
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
' see common_1.14/__Version_202512.bas
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
Const No_of_announcelines = 14
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
'
Const DIO_length = 5000
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
   If Commandpointer > 0 Then
      If Old_commandpointer <> Commandpointer Then
         B_temp5 = 10
         Old_commandpointer = Commandpointer
      Else
          ' wait 10 * 5ms after change of command_pointer
         ' because the end of incoming data is unknown
         Decr B_temp5
         If B_temp5 = 0 Then
            wireless_tx_length = Commandpointer
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
   End If
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