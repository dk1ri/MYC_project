'-----------------------------------------------------------------------
'name : 'name : dtmf_trx.bas
'Version V04.0, 20191014
'purpose : Programm for receiving DTMF Signals
'This Programm workes as I2C slave, or serial
'Can be used with hardware dtmf_trx Version V01.2 by DK1RI
'
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
' To run the compiler the directory comon_1,7 with includefiles must be copied to the directory of this file!
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
'
'----------------------------------------------------
$include "common_1.7\_Introduction_master_copyright.bas"
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
'----------------------------------------------------
$regfile = "m328pdef.dat"
'
'-----------------------------------------------------
$crystal = 20000000
$include "common_1.7\_Processor.bas"
'
'----------------------------------------------------
'
' 8: for 8/32pin, ATMEGAx8; 4 for 40/44pin, ATMEGAx4 packages
' used for reset now: different portnumber of SPI SS pin
Const Processor = "8"
Const Command_is_2_byte = 0
'1...127:
Const I2c_address = 34
Const No_of_announcelines = 10
'announcements start with 0 -> minus 1
Const Tx_factor = 10
' For Test:10 (~ 10 seconds), real usage:1 (~ 1 second)
'
'----------------------------------------------------
$include "common_1.7\_Constants_and_variables.bas"
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
$include "common_1.7\_Macros.bas"
'
'----------------------------------------------------
Wait 10
Config PinD.7 = Input
Reset__ Alias PinD.7
$include "common_1.7\_Config.bas"
'
'----------------------------------------------------
$include "common_1.7\_Main.bas"
'
'----------------------------------------------------
$include "common_1.7\_Loop_start.bas"
'
'----------------------------------------------------
'
'check DTMF chip
If Irq = 0 Then
print "I"
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
'----------------------------------------------------
'RS232 got data?
Serial_in = Ischarwaiting()
If Serial_in = 1 Then
   Serial_in = Inkey()
   If no_myc = 1 Then
      If Serial_in = 32 Then
      'switch to myc mode again
         no_myc=0
         no_myc_eeram = no_myc
      Else
         Dtmf_buffer_out_b(1) = Serial_in
         Dtmf_buffer_out_readpointer = 1
         Dtmf_buffer_out_writepointer = 2
         Dtmf_send_started = 1
      End If
   Else
      If Serial_active = 1 Or Command_b(1) = 254 Then
         Command_mode = 1
         If Tx_busy = 0 Then
            Command_b(Commandpointer) = Serial_in
            Gosub Commandparser
         Else
            'do nothing
            Not_valid_at_this_time
         End If
      Else
         'do nothing
         Not_valid_at_this_time
      End If
   End If
End If
'
'----------------------------------------------------
$include "common_1.7\_I2c.bas"
'
'----------------------------------------------------
'
' End Main start subs
'
'----------------------------------------------------
$include "common_1.7\_Reset.bas"
'
'----------------------------------------------------
$include "common_1.7\_Init.bas"
'
'----------------------------------------------------
$include "common_1.7\_Subs.bas"
$include "common_1.7\_Sub_reset_i2c.bas"
'
'----------------------------------------------------
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
   $include "common_1.7\_Commandparser.bas"
'
'-----------------------------------------------------
'
   Case 1
'Befehl  &H01 1 Byte + <s> / -
'liest den DTMF-Lesespeicher
'read the read DTMF buffer
'Data "1;aa,DTMF buffer;251,{0 to 9,*,#,A to D}"
      Tx_busy = 2
      Tx_time = 1
      Tx_b(1) = &H01
      'read ringbuffer Dtmf_buffer from Dtmf_in_readpointer to Dtmf_in_writepointer - 1
      Tx_write_pointer = 3
      While Dtmf_in_readpointer <> Dtmf_in_writepointer
         Tx_b(Tx_write_pointer) = Dtmf_buffer_b(Dtmf_in_readpointer)
         Incr Dtmf_in_readpointer
         If Dtmf_in_readpointer >= Dtmf_length Then Dtmf_in_readpointer = 1
         Incr Tx_write_pointer
      Wend
      Tx_b(2) = Tx_write_pointer - 3
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
'
   Case 2
'Befehl  &H02 1 Byte / 1 Byte + <s>
'gibt DTMF Signal aus
'send DTMF tones
'Data "2;oa,send dtmf;252,{0 to 9,*,#,A to D"
      If Commandpointer > 1 Then
         B_temp1 = Command_b(2)
         If B_temp1 = 0 Or B_temp1 > Dtmf_length Then
            Parameter_error
            Gosub command_received
         Else
            B_temp1 = Command_b(2) + 2
            If Commandpointer >= B_temp1 Then
               'string finished
               If Dtmf_send_started = 0 Then
                  'adds to ringbuffer Dtmf_buffer_out,
                  'overwrite old data, if buffer is full
                  Dtmf_buffer_out_writepointer = 1
                  For B_temp2 = 3 To B_temp1
                     Dtmf_buffer_out_b(Dtmf_buffer_out_writepointer) = Command_b(B_temp2)
                     Incr Dtmf_buffer_out_writepointer
                  Next B_temp2
                  Dtmf_time = 1
                  Dtmf_send_started = 1
                  Dtmf_buffer_out_readpointer = 1
                  Gosub Command_received
               Else
                  Parameter_error
               End If
            Else_Incr_Commandpointer
         End If
      Else_Incr_Commandpointer
'
   Case 238
'Befehl  &HEE 0|1 2 Byte / -
'schaltet MYC / no_MYC mode
'switches MYC / no_MYC mode
'Data "238;ka,no_myc;a"
      If Commandpointer = 2 Then
         If Command_b(2) < 2 Then
            no_myc = Command_b(2)
            no_myc_eeram = no_myc
            Dtmf_buffer_out_writepointer = 1
            Dtmf_buffer_out_readpointer = 1
            Gosub Reset_Tx
         Else
            Parameter_error
         End If
         Gosub Command_received
      Else_Incr_Commandpointer
'
   Case 239
'Befehl  &HEF 1 Byte / 2 Byte
'liest MYC / no_MYC mode
'read MYC / no_MYC mode
'Data "239;la,as238"
      Tx_busy = 2
      Tx_time = 1
      Tx_b(1) = &HEB
      Tx_b(2) = no_myc
      Tx_write_pointer = 3
      If Command_mode = 1 Then Gosub Print_Tx
      Gosub Command_received
'
'
'-----------------------------------------------------
$include "common_1.7\_Command_240.bas"
'
'-----------------------------------------------------
$include "common_1.7\_Command_252.bas"
'
'-----------------------------------------------------
$include "common_1.7\_Command_253.bas"
'
'-----------------------------------------------------
$include "common_1.7\_Command_254.bas"
'
'-----------------------------------------------------
$include "common_1.7\_Command_255.bas"
'
'-----------------------------------------------------
$include "common_1.7\_End.bas"
'
' ---> Rules announcements
Announce0:
'Befehl &H00 1 Byte / -
'eigenes basic announcement lesen
'basic announcement is read to I2C or output
Data "0;m;DK1RI;DTMF_transceiver;V04.0;1;110;1;10;1-1"
'
Announce1:
'Befehl  &H01 1 Byte + <s> / -
'liest den DTMF-Lesespeicher
'read the read DTMF buffer
Data "1;aa,DTMF buffer;251,{0 to 9,*,#,A to D}"
'
Announce2:
'Befehl  &H02 1 Byte / 1 Byte + <s>
'gibt DTMF Signal aus
'send DTMF tones
Data "2;oa,send dtmf;252,{0 to 9,*,#,A to D"
'
Announce3:
'Befehl  &HEE 0|1 2 Byte / -
'schaltet MYC / no_MYC mode
'switches MYC / no_MYC mode
Data "238;ka,no_myc;a"
'
Announce4:
'Befehl  &HEF 1 Byte / 2 Byte
'liest MYC / no_MYC mode
'read MYC / no_MYC mode
Data "239;la,as238"
':
Announce5:
'Befehl &HF0<n><m>3 Byte / 3 Byte + n * <s>
'liest announcements
'read m announcement lines
Data "240;ln,ANNOUNCEMENTS;110;10"
'
Announce6:
'Befehl &HFC 1 Byte / 1 Byte +<s>
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
'
Announce7:
'Befehl &HFD 1 Byte / 2 Byte
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
Announce8:
'Befehl &HFE :
'eigene Individualisierung schreiben
'write individualization
Data "254;ka,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,17,{0 to 127};a,SERIAL,1"
'
Announce9:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;la,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,17,{0 to 127};a,SERIAL,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1"
'