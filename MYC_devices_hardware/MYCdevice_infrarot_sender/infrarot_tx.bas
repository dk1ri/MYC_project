'name : infrarot_tx.bas
'Version V05.0, 20190710
'purpose : Programm to send RC5 Codes
'This Programm workes as I2C slave or serial interface
'Can be used with hardware rs232_i2c_interface Version V04.0 by DK1RI
'
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
' To run the compiler the directory comon_1,7 must be copied to the directory of this file!
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
' Inputs: see below
' Outputs : see below
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
'$regfile = "m328pdef.dat"
$crystal = 20000000
'
'-----------------------------------------------------
$include "common_1.7\_Processor.bas"
'
'----------------------------------------------------
'
' 8: for 8/32pin, ATMEGAx8; 4 for 40/44pin, ATMEGAx4 packages
' used for reset now: different portnumber of SPI SS pin
Const Processor = "8"
Const Command_is_2_byte    = 0
'1...127:
Const I2c_address = 5
Const No_of_announcelines = 14
'announcements start with 0 -> minus 1
Const Tx_factor = 10
' For Test:10 (~ 10 seconds), real usage:1 (~ 1 second)
'
'----------------------------------------------------
$include "common_1.7\_Constants_and_variables.bas"
'
'----------------------------------------------------
'
' Specific  Constatns and Variables´
Dim Togglebit As Byte
Dim Rc5_adress As Byte
Dim Rc6_adress As Byte
Dim Rc5_byte As Byte
Dim Rc5_part As Byte
'
'----------------------------------------------------
$include "common_1.7\_Macros.bas"
'
'----------------------------------------------------
$include "common_1.7\_Config.bas"
'
'----------------------------------------------------
$include "common_1.7\_Main.bas"
'
'----------------------------------------------------
$include "common_1.7\_Loop_start.bas"
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
         If Serial_in < 58 And Serial_in > 47 Then
            If Rc5_part = 0 Then
               Rc5_byte = Serial_in - 48
               Rc5_byte = Rc5_byte * 10
               Rc5_part = 1
            Else
               B_temp1 = Serial_in - 48
               Rc5_byte = Rc5_byte + B_temp1
               If Rc5_byte < 64 Then Rc5send Togglebit, Rc5_adress, Rc5_byte
               Rc5_part = 0
            End If
         End If
      End If
   Else
      If Serial_active = 1 Or Command_b(1) = 254 Then
         Command_mode = 1
         If Tx_busy = 0 Then
            Command_b(Commandpointer) = Serial_in
            Command_mode = 1
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
$include "common_1.7\_Commandparser.bas"
'
'-----------------------------------------------------
'
   Case 1
'Befehl &H01   0-63
'als RC5 Signal senden 1 Zeichen
'send 1 IR signal
'Data "1;oa,send RC5;b,{&H00 to &H3F}"
      If Commandpointer >= 2 Then
         If Command_b(2) < 64 Then
            Rc5send Togglebit, Rc5_adress, Command_b(2)
            Set Ir_led
            'Switch of IR LED
         End If
         Gosub Command_received
      Else_incr_Commandpointer
'
   Case 2
'Befehl &H02   0-255
'als RC6 Signal senden, 8 bit
'send as RC6 signal, 8 bit
'Data "2;oa,send RC6;b"
      If Commandpointer >= 2 Then
         Rc6send Togglebit, Rc6_adress, Command_b(2)
         Set Ir_led
         'Switch of IR LED
         Gosub Command_received
      Else_incr_Commandpointer
'
   Case 3
'Befehl &H03   0-31
'RC5 Adresse schreiben
'write RC5 adress
'Data "3;oa,rc5adress;b,{0 to 31}"
      If Commandpointer >= 2 Then
         If Command_b(2) < 32 Then
            Rc5_adress = Command_b(2)
         Else
            Parameter_error
         End If
         Gosub Command_received
      Else_incr_Commandpointer
'
   Case 4
'Befehl &H04
'RC5 Adresse lesen
'read RC5 adress
'Data "4;aa,rc5adress,as3"
      Tx_b(1) = &H04
      Tx_b(2) = Rc5_adress
      Tx_write_pointer = 3
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
'
   Case 5
'Befehl &H05   0-255
'RC6 Adresse schreiben, 8 bit
'write RC6 adress, 8 bit
'Data "5;oa,rc6adress;b"
      If Commandpointer >= 2 Then
         Rc6_adress = Command_b(2)
         Gosub Command_received
      Else_incr_Commandpointer
'
   Case 6
'Befehl &H06
'RC6 Adresse lesen
'read RC6 adress
'Data "6;oa,rc5adress,as5"
      tx_b(1) = &H06
      tx_b(2) = Rc6_adress
      Tx_write_pointer = 3
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
'
   Case 238
'Befehl &HEE   0,1
'no_myc schreiben
'write no_myc
'Data "238;oa,write no_myc;a"
      If Commandpointer >= 2 Then
         If Command_b(2) < 2 Then
            no_myc = Command_b(2)
            no_myc_eeram = no_myc
         Else
            Parameter_error
         End If
         Gosub Command_received
      Else_incr_Commandpointer
'
   Case 239
'Befehl &HEF
'no_myc lesen
'read no_myc
'Data "239;aa,read no_myc;a"
      Tx_b(1) = &HEF
      Tx_b(2) = No_myc
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
' specific commands
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
Data "0;m;DK1RI;IR_sender;V05.0;1;145;1;14;1-1"
'
Announce1:
'Befehl &H01   0-63
'als RC5 Signal senden 1 Zeichen
'send 1 IR signal
Data "1;oa,send RC5;b,{&H00 to &H3F}"
'
Announce2:
'Befehl &H02   0-255
'als RC6 Signal senden, 8 bit
'send as RC6 signal, 8 bit
Data "2;oa,send RC6;b"
'
Announce3:
'Befehl &H03   0-31
'RC5 Adresse schreiben
'write RC5 adress
Data "3;oa,rc5adress;b,{0 to 31}"
'
Announce4:
'Befehl &H04
'RC5 Adresse lesen
'read RC5 adress
Data "4;aa,as3"
'
Announce5:
'Befehl &H05   0-255
'RC6 Adresse schreiben, 8 bit
'write RC6 adress, 8 bit
Data "5;oa,rc6adress;b"
'
Announce6:
'Befehl &H06
'RC6 Adresse lesen
'read RC6 adress
Data "6;oa,as5"
'
Announce7:
'Befehl &H238  0,1
'no_myc schreiben
'write no_myc
Data "238;oa,write no_myc;a"
'
Announce8:
'Befehl &HEF
'no_myc lesen
'read no_myc
Data "239;aa,as238"
'
Announce9:
'Befehl &HF0<n><m>
'announcement aller Befehle lesen
'read m announcement lines
Data "240;ln,ANNOUNCEMENTS;145;14"
'
Announce10:
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
'
Announce11:
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
Announce12:
'Befehl &HFE :
'eigene Individualisierung schreiben
'write individualization
Data "254;ka,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,5,{0 to 127};a,SERIAL,1"
'
Announce13:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;la,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,5,{0 to 127};a,SERIAL,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1"
'