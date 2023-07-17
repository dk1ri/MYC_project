'-----------------------------------------------------------------------
'name : 'name : dtmf_trx.bas
'Version V07.0, 20230715
'purpose : Programm for receiving DTMF Signals
'This Programm workes as I2C slave, or serial
'Can be used with hardware dtmf_trx Version V04.0 by DK1RI
'
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
' To run the compiler the directory comon_1,13 with includefiles must be copied to the directory of this file!
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
' Inputs /Outputs : see file __config
' For announcements and rules see Data section at the end
'
'------------------------------------------------------
'Missing/errors:
'
'------------------------------------------------------
'
' Detailed description
'----------------------------------------------------
$regfile = "m328pdef.dat"
'
'-----------------------------------------------------
$crystal = 20000000
$include "common_1.13\_Processor.bas"
'
'----------------------------------------------------
'
'1...127:
Const I2c_address = 34
Const No_of_announcelines = 10
'announcements start with 0 -> minus 1
Const Tx_factor = 10
' For Test:10 (~ 10 seconds), real usage:1 (~ 1 second)
'
Const S_length = 32
'----------------------------------------------------
$include "__use.bas"
$include "common_1.13\_Constants_and_variables.bas"
'
Const ControlA_default  = &B00001101
'lower nibble: RegB, IRQ on, DTMF, Tone on
Const ControlB_default  = 0
'-, dual tone, no test mode, burst mode
Const Dtmf_length = 251
'Dim Received_byte As  Byte
Const Dtmf_time_out = 1000
' 1000 loops to finish
'
Dim Received_byte As  Byte
Dim Transmit_byte As Byte
Dim Dtmf_buffer As String * Dtmf_length
'input Buffer
Dim Dtmf_buffer_b(Dtmf_length) As Byte At Dtmf_buffer Overlay
Dim Dtmf_buffer_out As String * Dtmf_length
Dim Dtmf_buffer_out_b(Dtmf_length) As Byte At Dtmf_buffer_out Overlay
Dim Dtmf_buffer_out_writepointer As Byte
Dim Dtmf_buffer_out_readpointer As Byte
Dim Dtmf_byte As Byte
Dim Dtmf_out_ready As Byte
Dim Dtmf_in_writepointer As Byte
Dim Dtmf_in_readpointer As Byte
Dim Dtmf_time As Word
Dim Dtmf_send_started As Byte
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

'----------------------------------------------------
'
'check DTMF chip
If Irq = 0 Then
'Buffer empty (output) or new DTMF signal received (input)
   Rs0 = 1
   'status is cleared automatically after reading
   Gosub Read_dtmf
   Rs0 = 0
   If Received_byte.2 = 1 Then
      'Buffer empty flag set(output)
      Dtmf_out_ready = 1
      Dtmf_time = 0
      Printbin 56
   End If
'
   If Received_byte.2 = 1 Then
   'DTMF received (input)
      'read data
      Gosub Read_dtmf
      Select Case Received_byte
         Case 1 to 9
         '1 to 9
            Received_byte = Received_byte + 48
         case 10
         '0
            Received_byte = 48
         Case 11
         '*
            Received_byte = 42
         Case 12
         '#
            Received_byte = 35
         Case 13 to 15
         'A to C
            Received_byte = Received_byte + 52
         Case 0
         'D
            Received_byte = 68
      End Select
      If no_myc = 1 Then
         'non MYC Mode
         Printbin Received_byte
      Else
         'store to ringbuffer Dtmf_buffer
         Dtmf_buffer_b(Dtmf_in_writepointer) = Received_byte
         Incr  Dtmf_in_writepointer
         If Dtmf_in_writepointer >= Dtmf_length  Then Dtmf_in_writepointer  = 1
         'Old data are overwritten
         If Dtmf_in_writepointer = Dtmf_in_readpointer Then Incr Dtmf_in_readpointer
         If Dtmf_in_readpointer >= Dtmf_length Then Dtmf_in_readpointer = 1
      End If
   End If
End If
'
'some Dtmf to send?
If Dtmf_send_started = 1 And Dtmf_out_ready = 1 Then
   'MT8088 ready to send, send one byte
   If Dtmf_buffer_out_readpointer < Dtmf_buffer_out_writepointer Then
      'Dtmf_out_buffer not empty
      Transmit_byte = Dtmf_buffer_out_b(Dtmf_buffer_out_readpointer)
      Select Case Transmit_byte
         Case 49 to 57
         '1 to 9
            Dtmf_byte =  Transmit_byte - 48
         Case 48
         '0
            Dtmf_byte = 10
         Case 42
         '*
            Dtmf_byte = 11
         Case 35
         '#
            Dtmf_byte = 12
         Case 65 to 67
         'A to C
            Dtmf_byte = Transmit_byte - 52
            '65 -> 13
         Case 97 to 99
         'a to c
            Dtmf_byte = Transmit_byte - 84
            '97 -> 13
         Case 68
         'D
            Dtmf_byte = 0
         Case 100
         'd
            Dtmf_byte = 0
         Case Else
            Dtmf_byte  = 255
      End Select
      If Dtmf_byte <> 255 Then
         Gosub Write_dtmf
         'Wait for next IRQ
         Dtmf_out_ready = 0
      End If
      Incr Dtmf_buffer_out_readpointer
   Else
      ' all Data sent
      Dtmf_send_started = 0
   End If
End If
'
'---------------------------------------------------
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
Init_dtmf:
Dtmf_buffer_out_writepointer = 1
Dtmf_buffer_out_readpointer = 1
Dtmf_in_writepointer = 1
Dtmf_in_readpointer = 1
Dtmf_send_started = 0
Dtmf_out_ready = 1
Dtmf_time = 0
Dtmf_buffer_out = String (Dtmf_length, 0)
Dtmf_byte  = 255
'
'Config MT8880:
Rs0 = 1
Dtmf_byte = ControlA_default
Gosub Write_dtmf
Dtmf_byte = ControlB_default
Gosub Write_dtmf
Return
Rs0 = 0
'
Write_dtmf:
'Uses lower nibble of B_temp2
'Config_output
printbin Dtmf_byte
printbin 255
Config Q1out = Output
Config Q2out = Output
Config Q3out = Output
Config Q4out = Output
'
Q1out = Dtmf_byte.0
Q2out = Dtmf_byte.1
Q3out = Dtmf_byte.2
Q4out = Dtmf_byte.3
Rw = 0
Phy2 = 1
NOP
NOP
NOP
Phy2 = 0
Return
'
Read_dtmf:
printbin 254
Config Q1in = Input
Config Q2in = Input
Config Q3in = Input
Config Q4in = Input
Q1out = 1
Q2out = 1
Q3out = 1
Q4out = 1
Rw =  1
Phy2 = 1
NOP
NOP
Received_byte = 0
Received_byte.0 = Q1in
Received_byte.1 = Q2in
Received_byte.2 = Q3in
Received_byte.3 = Q4in
Phy2 = 0
Return
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