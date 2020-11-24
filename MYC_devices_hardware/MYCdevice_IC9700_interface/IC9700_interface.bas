'name : IC9700_interface_bascom.bas
'Version V01.3, 20201123
'purpose : Programm to control a ICOM IC9700 Radio
'Can be used with hardware ICOM Interface Version V03.2 by DK1RI          >
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
' I2C
'-----------------------------------------------------
' Inputs /Outputs : see file __config
' For announcements and rules see Data section at the end
'
'------------------------------------------------------
'Missing/errors:
' see separate document
'
'------------------------------------------------------
'
'all commandtoken are 2 byte (except 0)
'One transceiver only can be connected to the Interface (So there are no collisions on the ICOM Bus)
'The transceiver must be configured "transceive off" So it will not send data without request.
'The transceiver must have "link to remote"on
'Reason is, that RX line is inactive during transmit, so full duplex is not possible.
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
$include "common_1.11\_Processor.bas"
'
'----------------------------------------------------
'
'1...127:
Const I2c_address = 33
Const No_of_announcelines = 969
'announcements start with 0 -> minus 1
Const Tx_factor = 10
' For Test:10 (~ 10 seconds), real usage:1 (~ 1 second)
Const S_length = 120
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
$include "common_1.11\_Constants_and_variables.bas"
'
Dim Temp_dw As Dword
Dim Temp_dw1 As Dword
Dim S_temp1 As Single
Dim Answer_pointer As Word
Dim Civ_watchdog As Byte
Dim Civ_watchdog_time As Byte
Dim Civ_adress As Byte
Dim Civ_adress_eeram As Eram Byte
Dim Civ_cmd As Word
Dim Civ_cmd1 As Byte
Dim Civ_cmd2 As Byte
Dim Civ_cmd3 As Byte
Dim Civ_cmd4 As Byte
Dim Civ_len As Byte
Dim Data_filter As Byte
Dim Frequenz As Dword
Dim Frequenz_b(4) As Byte At Frequenz Overlay
Dim F_offset As Word
Dim Multiplier As Dword
Dim No_token As Byte
Dim Replayheader As String * 10
Dim Replayheader_b(10) As Byte At Replayheader Overlay
Dim Header As String * 10
Dim Header_b(10) As Byte At Header Overlay
Dim Ok_msg As String * 10
Dim Ok_msg_b(10) As Byte at Ok_msg Overlay
Dim Nok_msg As String * 10
Dim Nok_msg_b(10) As Byte at Nok_msg Overlay
Dim Msgsg As String * 10
Dim Civ_in As String * 250
Dim Civ_in_b(250) As Byte At Civ_in Overlay
Dim Civ_pointer As Byte
Dim Command_status As Byte
Dim Read_started As Byte
' 101 Memories ith 25 Byte each (no memory number)
Dim Memorycontent As String * 12000
Dim Memorycontent_b(12000) As Byte At Memorycontent Overlay
Dim Read_memory_counter As Byte
Dim Block_read_mem_command As Byte
Dim Civ_sub_cmd As Word
' For selection within morycontent:
Dim Mem_function As Byte
Dim Memory_default As String * 113
Dim Memory_default_b(113) As Byte At Memory_default Overlay
Dim Vfo_mem As Byte
Dim Number_avail_tx_band As Byte
Dim Copy_band_stack As Byte
' Cv value
Dim Operating_mode As Byte
Dim Frequenz_adder As Dword
Dim Satellite_mode As Byte
Dim Last_command As Word
Dim Last_command_h As Byte At Last_command + 1 Overlay
Dim Last_command_l As Byte At Last_command Overlay
'
'----------------------------------------------------
$include "common_1.11\_Macros.bas"
'
'----------------------------------------------------
$include "common_1.11\_Config.bas"
'
'----------------------------------------------------
' procedures at start
'
'----------------------------------------------------
$include "common_1.11\_Main.bas"
'
'----------------------------------------------------
$include "common_1.11\_Loop_start.bas"
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
Read_memory_counter = 110
'This is not working!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! :
' No Input at startup (reading memory)
If Read_memory_counter < 110 Then
   Select case Read_memory_counter
      Case 109
         ' set VFO mode
         Gosub 105
         Read_memory_counter = 104
         Block_read_mem_command = 1
      Case 108
         ' read operating mode
         If Block_read_mem_command = 0 Then
            Gosub 103
            Block_read_mem_command = 1
         End If
      Case 107
         'read number of available TX frequency band
         If Block_read_mem_command = 0 Then
            Gosub 2D4
            Block_read_mem_command = 1
         End If
      Case Is < 107
         If Block_read_mem_command = 0 Then
            Command_b(3) = Read_memory_counter
            B_temp1 = 0
            Gosub Mem_to_civ
            Block_read_mem_command = 1
         End If
   End Select
   Stop Watchdog
   Goto Loop_
End If
'
'----------------------------------------------------
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
$include "common_1.11\_init.bas"
'
'----------------------------------------------------
$include "common_1.11\_Subs.bas"
'
'----------------------------------------------------
'
Civ_reset:
Civ_pointer = 1
Command_status = 0
Civ_watchdog = 0
Read_started = 0
Data_filter = 3
No_token = 0
Civ_cmd = 0
Answer_pointer = 1
Set Pin_rx_enable
Return
'
$include "_tx_subs.bas"
'
$include "_rx_subs.bas"
'
$include "_Analyze_civ.bas"
'
$include "_command_010.bas"
$include "_command_012.bas"
$include "_command_014.bas"
$include "_command_016.bas"
$include "_command_018.bas"
$include "_command_01A.bas"
$include "_command_01C.bas"
$include "_command_01E.bas"
$include "_command_020.bas"
$include "_command_022.bas"
$include "_command_024.bas"
$include "_command_026.bas"
$include "_command_028.bas"
$include "_command_02A.bas"
$include "_command_02C.bas"
$include "_command_02E.bas"
$include "_command_030.bas"
$include "_command_032.bas"
$include "_command_034.bas"
$include "_command_036.bas"
$include "_command_038.bas"
$include "_command_03A.bas"
$include "_command_03C.bas"
$include "_command_03E.bas"
$include "_command_040.bas"
$include "_command_042.bas"
$include "_command_044.bas"
$include "_command_046.bas"
$include "_command_048.bas"
$include "_command_04A.bas"
$include "_command_04C.bas"
$include _analyze_civ_s000_s026.bas
$include _analyze_civ_s027_s047.bas
$include _analyze_civ_s048_s071.bas
$include _analyze_civ_s072_s095.bas
$include _analyze_civ_s096_s119.bas
$include _analyze_civ_s120_s143.bas
$include _analyze_civ_s144_s167.bas
$include _analyze_civ_s168_s193.bas
$include _analyze_civ_s194_s220.bas
$include _analyze_civ_s221_s254.bas
$include _analyze_civ_s255_s290.bas
$include _analyze_civ_s291_s339.bas
'
'----------------------------------------------------
$include "common_1.11\_Commands_required.bas"
#IF Command_is_2_byte = 0
   $include "common_1.11\_Commandparser.bas"
#ELSE
$include "common_1.11\_Command0.bas"
'
Commandparser:
$include __select_command.bas
Return
'
End
#ENDIF
'
'-----------------------------------------------------
' End
'
$include "_announcements.bas"
'
$include "_Tones.bas"