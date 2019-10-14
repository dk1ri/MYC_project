'-----------------------------------------------------------------------
'name : infrarot_rx_bascom.bas
'Version V04.2, 20191014
'purpose : Programm for receiving infrared RC5 Signals
'This Programm workes as I2C slave, or serial
'Can be used with hardware i2c_rs232_interface Version V05.0 by DK1RI
'
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
' To run the compiler the directory comon_1,7 must be copied to the directory of this file!
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
'
'----------------------------------------------------
$include "common_1.7\_Introduction_master_copyright.bas"
' If the internal RC oscillator is used, Q1, C4, C5 can be omitted
'
'----------------------------------------------------
'
'Used Hardware:
' serial
' I2C
' Timer0
'-----------------------------------------------------
' Inputs / Outputs : see __config file
' For announcements and rules see Data section at the end
'
'------------------------------------------------------
'Missing/errors:
'
'------------------------------------------------------
'
' Detailed description
'
'----------------------------------------------------
$regfile = "m88pdef.dat"
'$regfile = "m88def.dat"
'$regfile = "m328pdef.dat"
$crystal = 20000000
'
'-----------------------------------------------------
$include "common_1.7\_Processor.bas"
'
'----------------------------------------------------
'
Const Processor = "8"
Const Command_is_2_byte    = 0
'1...127:
Const I2c_address = 12
Const No_of_announcelines = 11
'announcements start with 0 -> minus 1
Const Tx_factor = 10
' For Test:10 (~ 10 seconds), real usage:1 (~ 1 second)
'
'----------------------------------------------------
$include "common_1.7\_Constants_and_variables.bas"
'
'----------------------------------------------------
'
' Specific Constants Variables
Const Rc5_stringlength = Stringlength - 2
'
Dim Daten as Byte
Dim Valid_adress As Byte
Dim Valid_adress_eeram As Eram Byte
Dim Rc5buffer As String * Rc5_stringlength
Dim Rc5buffer_b(Rc5_stringlength) As Byte At Rc5buffer Overlay
Dim Rc5_overflow As Byte
Dim Rc5_writepointer As Byte
'Rc5_bit, Rc5_adress and Rc5_command are predefines variables
'
'----------------------------------------------------
$include "common_1.7\_Macros.bas"
'
'----------------------------------------------------
Config PinB.2 = Input
Reset__ Alias PinB.2
$include "common_1.7\_Config.bas"
'
'----------------------------------------------------
'
' procedures at start
'
'----------------------------------------------------
$include "common_1.7\_Main.bas"
'
'----------------------------------------------------
$include "common_1.7\_Loop_start.bas"
'
'----------------------------------------------------
'
If _rc5_bits.4 = 1 Then
   _rc5_bits.4 = 0
   'enable next data
   'the toggle bit toggles on each new received command
   'toggle bit is bit 7. Extended RC5 bit is in bit 6
   b_Temp1 = Rc5_address And &B00011111
   b_Temp3 = Rc5_command And &B00111111
   If No_myc = 1 Then
      'Rc5_adress
      b_Temp2 = b_Temp1 / 10
      b_Temp2 = b_Temp2 + 48
      Printbin b_Temp2
      b_Temp2 = b_Temp1 Mod 10
      b_Temp2 = b_Temp2 + 48
      Printbin b_Temp2
      'RC5 command
      b_Temp2 = b_Temp3 / 10
      b_Temp2 = b_Temp2 + 48
      Printbin b_Temp2
      b_Temp2 = b_Temp3 Mod 10
      b_Temp2 = b_Temp2 + 48
      Printbin b_Temp2
   End If
   If b_Temp1 = Valid_adress Then
      Rc5buffer_b(Rc5_writepointer) = b_Temp3
      Incr  Rc5_writepointer
      If Rc5_writepointer > Rc5_stringlength Then
         Rc5_writepointer = 1
         Rc5_overflow = 1
      End If
   End If
End If
'
'----------------------------------------------------
$include "common_1.7\_Serial.bas"
'
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
Reset_rc5buffer:
Rc5_writepointer = 1
Rc5_overflow = 0
Rc5buffer = String(Rc5_stringlength,255)
Return
'
'----------------------------------------------------
$include "common_1.7\_Commandparser.bas"
'
'-----------------------------------------------------
'
   Case 1
'Befehl  &H01
'kopiert RC5 Daten in den Ausgang
'copies RC5 data to output
'Data "1;aa,RC5 buffer;252,{&H00 to &H3F}"
     Tx_b(1) = &H01
       If Rc5_overflow = 0 Then
         Tx_b(2) = Rc5_writepointer - 1
         'length
         If Rc5_writepointer > 1 Then
            For b_Temp1 = 1 To Rc5_writepointer - 1
               b_Temp2 = b_Temp1 + 2
               'Rc5buffer start with 1
               Tx_b(b_Temp2) = Rc5buffer_b(b_Temp1)
            Next b_Temp1
         End If
         Tx_write_pointer = Rc5_writepointer + 2
      Else
         Tx_b(2) = Rc5_writepointer
         'all bytes  of Rc5_buffer are transmitted
         b_Temp2 = Rc5_writepointer
         For b_Temp1 = 1 to Rc5_stringlength
            b_Temp3 = b_Temp1 + 2
            Tx_b(b_Temp3) = Rc5buffer_b(b_Temp2)
            Incr b_Temp2
            If b_Temp2 > Rc5_stringlength Then b_Temp2 = 1
         Next b_Temp1
         Tx_write_pointer = Rc5_stringlength + 2
      End if
      Gosub Reset_rc5buffer
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
'

   Case 2
'Befehl &H02   0-31
'RC5 Adresse schreiben
'write RC5 adress
'Data "2;oa,rc5adress;b,{0 to 31}"
      If Commandpointer >= 2 Then
         b_Temp1 = Command_b(2)
         If b_Temp1 < 32 Then
            Valid_adress = b_Temp1
            Valid_adress_eeram = b_Temp1
         Else_parameter_error
         Gosub Command_received
      Else_Incr_Commandpointer
'
   Case 3
'Befehl &H03
'RC5 Adresse lesen
'read RC5 adress
'Data "3;aa,as2"
      Tx_b(1) = &H03
      Tx_b(2) = Valid_adress
      Tx_write_pointer = 3
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
'
   Case 238
'Befehl  &HEE
'schaltet MYC / no_MYC mode
'switches MYC / no_MYC mode
'Data "238;oa,no_myc;a"
      If Commandpointer >= 2 Then
         If Command_b(2) < 2 Then
            no_myc = Command_b(2)
            no_myc_eeram = no_myc
         Else_parameter_error
         Gosub Command_received
      Else_Incr_Commandpointer
'
   Case 239
'Befehl  &HEF
'liest MYC / no_MYC mode
'read MYC / no_MYC mode
'Data "239;aa,as2238"
      Tx_b(1) = &HEF
      Tx_b(2) = no_myc
      Tx_write_pointer = 3
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
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
'announce text
'
Announce0:
'Befehl &H00
'eigenes basic announcement lesen
'basic announcement is read to I2C or output
Data "0;m;DK1RI;Infrared (RC5) receiver;V04.2;1;145;1;11;1-1"
'
Announce1:
'Befehl  &H01
'kopiert RC5 Daten in den Ausgang
'copies RC5 data to output
Data "1;aa,RC5 buffer;252,{&H00 to &H3F}"
'
Announce2:
'Befehl &H02   0-31
'RC5 Adresse schreiben
'write RC5 adress
Data "2;oa,rc5adress;b,{0 to 31}"
'
Announce3:
'Befehl &H03
'RC5 Adresse lesen
'read RC5 adress
Data "3;aa,as2"
'
Announce4:
'Befehl  &HEE
'schaltet MYC / no_MYC mode
'switches MYC / no_MYC mode
Data "2238;oa,no_myc;a"
'
Announce5:
'Befehl  &HEF
'liest MYC / no_MYC mode
'read MYC / no_MYC mode
Data "239;aa,as238"
'
Announce6:
'Befehl &HF0<n><m>
'announcement aller Befehle lesen
'read m announcement lines
Data "240;ln,ANNOUNCEMENTS;145;11"
'
Announce7:
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
'
Announce8:
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
Announce9:
'Befehl &HFE :
'eigene Individualisierung schreiben
'write individualization
Data "254;ka,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,6,{0 to 127};a,SERIAL,1"
'
Announce10:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;la,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,6,{0 to 127};a,SERIAL,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1"
'