'name : IC471_interface_bascom.bas
'Version V01.3, 20241015
'purpose : Programm to control a ICOM IC471 Radio
'Can be used with hardware ICOM Interface Version V03.2 by DK1RI          >
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
'-----------------------------------------------------
' Inputs / Outputs : see file __config.bas
'
'------------------------------------------------------
' Missing/errors:
' see sepatate document
'
'------------------------------------------------------
'
'all commandtoken are 1 byte
'One transceiver only can be connected to the Interface (So there are no collisions on the ICOM Bus)
'A command must wait, until an earlier answer command is finished.
'
'Commands are executed in the same loop, when a valid command is detected.
'Other commands are ignored during that time.
'After CiV_timeout, CiV is resetted
'The CIV Interface use the second hardware UART
'
'----------------------------------------------------
$regfile = "m1284pdef.dat"
'
'-----------------------------------------------------
$crystal = 20000000
$include "common_1.13\_Processor.bas"
'
'----------------------------------------------------
'
'1...127:
Const I2c_address = 30
Const No_of_announcelines = 20
'announcements start with 0 -> minus 1
Const Tx_factor = 15
' For Test:15 (~ 10 seconds), real usage:2 (~ 1 second)
Const S_length = 32
'
Const Header_ = "{254}{254}{000}{224}"
Const Replay_header_ = "{254}{254}{224}{000}"
Const Ok_msg_ = "{254}{254}{224}{000}{251}"
' End of packet (253) is not copied to Civ_in string !
Const Nok_msg_ = "{254}{254}{224}{000}{250}"
Const Civ_data_length = 250
'
'----------------------------------------------------
$include "__use.bas"
$include "common_1.13\_Constants_and_variables.bas"
'
Dim Answer_pointer As Word
Dim Civ_watchdog As Byte
Dim Civ_adress As Byte
Dim Civ_adress_eeram As Eram Byte
Dim Civ_cmd As Word
Dim Civ_len As Byte
Dim Frequenz As Dword
Dim Frequenz_b(4) As Byte At Frequenz   Overlay
Dim Replayheader As String * 10
Dim Replayheader_b(10) As Byte At Replayheader Overlay
Dim Header As String * 10
Dim Header_b(10) As Byte At Header Overlay
Dim Ok_msg As String * 10
Dim Ok_msg_b(10) As Byte at Ok_msg Overlay
Dim Nok_msg As String * 10
Dim Nok_msg_b(10) As Byte at Nok_msg Overlay
Dim Civ_in As String * 250
Dim Civ_in_b(250) As Byte At Civ_in Overlay
Dim Civ_pointer As Byte
Dim Command_status As Byte
'
'----------------------------------------------------
$include "common_1.13\_Macros.bas"
'
'----------------------------------------------------
$include "common_1.13\_Config.bas"
'
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
'CIV got data?
B_temp1 = Ischarwaiting(#2)
If b_Temp1 = 1 Then
   b_Temp1 = Waitkey(#2)
   If Civ_watchdog = 0 Then Civ_watchdog = 1
   'start watchdog
   If Civ_pointer < Civ_data_length Then
      If b_Temp1 <> 253 Then
         ' Wait until End Character received
         Civ_in_b(Civ_pointer) = b_Temp1
         Incr Civ_pointer
      Else
         'End of packet
         If Civ_pointer < 6 Then
            ' too short
            Other_civ_error
            print "OE"
         Else
            ' change global civ address
            Civ_in_b(3) = &HE0
            If Civ_pointer = 6 Then
               B_temp1 = Instr(1, Civ_in, Ok_msg)
               If B_temp1 = 0 Then
                  B_temp1 = Instr(1, Civ_in, Nok_msg)
                  If B_temp1 = 1 Then
                     Nok_message
                  Else
                     ' should not happen
                     Other_civ_error
                  End If
               End If
            Else
               b_Temp2 = Instr (Civ_in, Replayheader)
               If b_Temp2 = 1 Then
                  'Valid header , 4 Byte
                  ' During test phase one; delete later:
                  For b_Temp1 = 1 To Civ_pointer
                     b_Temp4 = Civ_in_b(b_Temp1)
                    Printbin b_Temp4
                  Next b_Temp1
                 ' end test
                  Gosub Analyze_civ
                  Gosub Print_tx
               Else
                  No_valid_header
               End If
            End If
         End If
         Gosub Civ_reset
      End If
   Else
      Civ_overflow
      Gosub Civ_reset
   End If
End If
'
'----------------------------------------------------
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
$include "common_1.13\_init.bas"
'
'----------------------------------------------------
$include "common_1.13\_Subs.bas"
'
'----------------------------------------------------
'
Civ_reset:
Civ_pointer = 1
Command_status = 0
Civ_watchdog = 0
Civ_cmd = 0
Answer_pointer = 1
Set Pin_rx_enable
Return
'
Civ_print:
Reset Pin_rx_enable
UCSR1b.4 = 0
'Switch off Com2 Rx
Printbin #2, 254; 254; Civ_adress; 224
For B_temp1 = 1 To Civ_len
   B_temp2 = Temps_b(B_temp1)
   Printbin #2, B_temp2
Next B_temp1
Printbin #2, 253
Set Pin_rx_enable
Gosub Command_received
'The programm continues immediately after initiating the transmit
' so wait for 1 character before enable receive
Waitms 1
UCSR1b.4 = 1
Return
'
$include _analyze_civ.bas
'
$include "_Commands.bas"
$include "common_1.13\_Commands_required.bas"
'
#IF Command_is_2_byte = 0
   $include "common_1.13\_Commandparser.bas"
#ELSE
$include "common_1.13\_Command0.bas"
'
Commandparser:
$include __select_command.bas
Return
'
End
#ENDIF
'-----------------------------------------------------
' End
'
$include "_announcements.bas"
'