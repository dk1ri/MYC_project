'name : rs232_i2c_interface_master.bas
'Version V06.0, 20180709
'purpose : Programm for serial to i2c Interface for test of MYC devices
'This Programm workes as I2C master
'Can be used with hardware rs232_i2c_interface Version V05.1 by DK1RI
'
'++++++++++++++++++++++++++++++++++++++++++++++++++++
'
' ---> Description / name of program
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
$regfile = "m88pdef.dat"
'$regfile = "m328pdef.dat"
'
'-----------------------------------------------------
$crystal = 20000000
$include "common_1.7\_Processor.bas"
'
'$lib "i2cv2.lbx"
'
'----------------------------------------------------
'
' 8: for 8/32pin, ATMEGAx8; 4 for 40/44pin, ATMEGAx4 packages
' used for reset now: different portnumber of SPI SS pin
Const Processor = "8"
Const Command_is_2_byte    = 0
'1...127:
Const I2c_address = 1
Const No_of_announcelines = 19
'announcements start with 0 -> minus 1
Const Tx_factor = 10
' For Test:10 (~ 10 seconds), real usage:1 (~ 1 second)
'
'----------------------------------------------------
$include "common_1.7\_Constants_and_variables.bas"
'
Dim I2c_len As Byte
Dim I2c_start As Byte
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
'
If Tx_write_pointer > 1 Then Gosub Print_tx
'
'----------------------------------------------------
'RS232 got data?
Serial_in = Ischarwaiting()
If Serial_in = 1 Then
   Serial_in = Inkey()
   If Tx_busy = 0 Then
      Command_b(Commandpointer) = Serial_in
      Gosub Commandparser
   Else
      'do nothing
      Not_valid_at_this_time
   End If
End If
'
Stop Watchdog
Goto Loop_
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
'
Reset_i2c:
Watch_twi = 0
Return
'
'----------------------------------------------------
$include "common_1.7\_Commandparser.bas"
'
'-----------------------------------------------------
'
   Case 1
'Befehl &H01 <s>
'string an angeschlossenes device schicken, No_myc = 1
'write string to device
'Data "1;oa;250"
      If No_myc = 1 Then
         If Commandpointer >= 2 Then
            If Command_b(2) = 0 Then
               Gosub Command_received
            Else
               If Command_b(2) > Stringlength Then
                  Parameter_error
                  Gosub Command_received
               Else
                  I2c_len = Command_b(2)  + 2
                  If Commandpointer >= I2c_len Then
                     'string finished
                     I2c_start = 3
                     I2c_len = I2c_len - 2
                     I2c_s
                     Gosub Command_received
                  Else_incr_Commandpointer
               End If
            End If
         Else_incr_Commandpointer
      Else
         Command_not_found
         Gosub Command_received
      End If
'
   Case 2
'Befehl &H02
'string von angeschlossenem device lesen, No_myc = 1
'read string from device
'Data "2;aa,as1"
      If No_myc = 1 Then
         If Commandpointer >= 2 Then
            If Command_b(2) <> 0 Then
               If Command_b(2) > Stringlength Then
                  Parameter_error
               Else
                  ' get data
                  I2c_len = Command_b(2)
                  I2c_rec
               End If
            End If
            Gosub Command_received
         Else_incr_Commandpointer
      Else
         Command_not_found
      End If
'
   Case 16
'Befehl &H10
'übersetzes 0 des slave No_myc = 0
'translated 0 of slave
'Data "16;m;DK1RI;RS232_I2C_interface Slave;V04.0;1;90;1;8:1-1"
      If No_myc = 0 Then
         Tx_busy = 2
         Tx_time = 1
         A_line = 3
         Number_of_lines = 1
         Gosub Sub_restore
         Gosub Print_tx
      Else
         Command_not_found
      End If
      Gosub Command_received
'
   Case 17
'Befehl &H11 <s>
'übersetzes 1 des slave Myc_mode = 1 I2C nach RS232
'translated 1 of slave I2C to RS232
'Data "17,oa;250"
      If No_myc = 0 Then
         If Commandpointer >= 2 Then
            If Command_b(2) = 0 Then
               Gosub Command_received
            Else
               If Command_b(2) > Stringlength Then
                  Parameter_error
                  Gosub Command_received
               Else
                  B_Temp1 = Command_b(2) + 2
                  If Commandpointer >= B_Temp1 Then
                     'string finished
                     Command_b(1) = 1
                     I2c_len = Command_b(2) + 2
                     I2c_start = 1
                     I2c_s
                     Gosub Command_received
                  Else_incr_Commandpointer
               End If
            End If
         Else_incr_Commandpointer
      Else
         Command_not_found
         Gosub Command_received
      End If
'
   Case 18
'Befehl &H12
'übersetzes 2 des slave Myc_mode = 1 , RS232 nach I2C
'translated 2 of slave, RS232 to I2C
'Data "18,aa,as17"
      If No_myc = 0 Then
         Tx_busy = 2
         Tx_time = 1
         ' copy RS232 to I2C
         I2c_len = 1
         I2c_start = 1
         Command_b(1) = 2
         I2c_s
         If I2c_len = 1 Then
            'find length
            I2c_r
            If I2c_len > 0 Then
               Printbin &H12
               printbin I2c_len
               ' get data
               I2c_rec
            End If
         End If
      Else
         Command_not_found
      End If
      Gosub Command_received
'
   Case 19
'Befehl &H13
'übersetzes 252 des slave No_myc = 0
'translated 252 of slave,
'Data "19;aa,LAST ERROR;20,last_error"
      If No_myc = 0 Then
         I2c_len = 1
         I2c_start = 1
         Command_b(1) = &HFC
         I2c_s
         If I2c_len = 1 Then
            'find length
            I2c_r
            If I2c_len > 0 Then
               Printbin &H12
               printbin I2c_len
               ' get data
               I2c_rec
            End If
         End If
      Else
         Command_not_found
      End If
      Gosub Command_received
'
   Case 20
'Befehl &H14
'übersetzes 253 des slave No_myc = 0
'translated 253 of slave,
'Data "20;aa,MYC INFO;b,ACTIVE"
      If No_myc = 0 Then
         I2c_len = 1
         I2c_start = 1
         Command_b(1) = &HFD
         I2c_s
         If I2c_len = 1 Then
            Printbin &H14
            I2c_rec
         End If
      Else
         Command_not_found
      End If
      Gosub Command_received
'
   Case 236
'Befehl &HEC <0..127>
'Adresse zum Senden speichern
'write send adress
'Data "236;oa,I2C adress;b,{0 to 127}"                                               '
      If Commandpointer >= 2 Then
         If Command_b(2) < 128 And Command_b(2) > 0 Then
            Adress = Command_b(2) * 2
            Adress_eeram = Adress
            Gosub Reset_i2c
         Else
            Parameter_error
         End If
         Gosub Command_received
      Else_incr_Commandpointer
'
   Case 237
'Befehl &HED
'Adresse zum Senden lesen
'read send adress
'Data "237;aa,as236"
      printbin &HED
      B_temp1 = Adress / 2
      Printbin B_temp1
      Gosub Command_received                                '
'
   Case 238
'Befehl &HEE 0|1
'no_myc speichern
'write no_myc
'Data "238;oa,no_myc;a"                                               '
      If Commandpointer >= 2 Then
         Select Case Command_b(2)
            Case 0
               no_myc = 0
               no_myc_eeram = 0
            Case 1
               no_myc = 1
               no_myc_eeram = 1
            Case Else
               Parameter_error
         End Select
         Gosub Command_received
      Else_incr_Commandpointer
'
   Case 239
'Befehl &HEF
'MYC_mode lesen
'read myc_mod
'Data "239;aa,as238"
      Printbin &HEF
      Printbin no_myc
      Gosub Command_received                                '
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
   Case 254
      If Commandpointer >= 2 Then
         Select Case Command_b(2)
            Case 0
               If Commandpointer >= 3 Then
                  If Command_b(3) = 0 Then
                     Gosub Command_received
                  Else
                     b_Temp1 = Command_b(3) + 3
                     If Commandpointer >= b_Temp1 Then
                        Dev_name = String(20 , 0)
                        If b_Temp1 > 23 Then b_Temp1 = 23
                        For b_Temp2 = 4 To b_Temp1
                           Dev_name_b(b_Temp2 - 3) = Command_b(b_Temp2)
                        Next b_Temp2
                        Dev_name_eeram = Dev_name
                     Else_Incr_Commandpointer
                  End If
               Else_Incr_Commandpointer
            Case 1
               If Commandpointer >= 3 Then
                  Dev_number = Command_b(3)
                  Dev_number_eeram = Dev_number
                  Gosub Command_received
               Else_Incr_Commandpointer
            Case 3
               If Commandpointer >= 3 Then
                  b_Temp2 = Command_b(3)
                  If b_Temp2 < 2 Then
                     Serial_active = b_Temp2
                     Serial_active_eeram = Serial_active
                  Else_Parameter_error
                  Gosub Command_received
               Else_Incr_Commandpointer
'
                $include "__command254.bas"
'
            Case Else
               Parameter_error
               Gosub Command_received
         End Select
      Else_Incr_Commandpointer
'
   Case 255
      If Commandpointer >= 2 Then
         Tx_busy = 2
         Tx_time = 1
         Tx_b(1) = &HFF
         Tx_b(2) = Command_b(2)
         Select Case Command_b(2)
            Tx_write_pointer = 0
            Case 0
               'Will send &HFF0000 for empty string
               b_Temp3 = Len(Dev_name)
               Tx_b(3) = b_Temp3
               Tx_write_pointer = 4
               b_Temp2 = 1
               While b_Temp2 <= b_Temp3
                  Tx_b(Tx_write_pointer) = Dev_name_b(b_Temp2)
                  Incr Tx_write_pointer
                  Incr b_Temp2
               Wend
            Case 1
               Tx_b(3) = Dev_number
               Tx_write_pointer = 4
            Case 2
               Tx_b(3) = Serial_active
               Tx_write_pointer = 4
            Case 3
               Tx_b(3) = 0
               Tx_write_pointer = 4
            Case 4
               Tx_b(3) = 3
               Tx_b(4) = "8"
               Tx_b(5) = "N"
               Tx_b(6) = "1"
               Tx_write_pointer = 7
'
            $include "__command255.bas"
'
            Case Else
               Parameter_error
               Gosub Reset_tx
         End Select
         If Tx_write_pointer > 0 Then
            If Command_mode = 1 Then Gosub Print_tx
         End If
         Gosub Command_received
      Else_Incr_Commandpointer
'-----------------------------------------------------
$include "common_1.7\_End.bas"
'
Announce0:
'Befehl &H00
'basic annoumement wird gelesen
'basic announcement is read
Data "0;m;DK1RI;RS232_I2C_interface Master;V06.0;1;120;1;20;1-1"
'
Announce1:
'Befehl &H01 <s>
'string an angeschlossenes device schicken, Myc_mode = 0
'write string to device
Data "1;oa;250"
'
Announce2:
'Befehl &H02
'string von angeschlossenem device lesen, Myc_mode = 0
'read string from device
Data "2;aa,as1"
'
Announce3:
'Befehl &H10
'übersetzes 0 des slave Myc_mode = 1
'translated 0 of slave
Data "16;m;DK1RI;RS232_I2C_interface Slave;V06.0;1;90;1;8;1-1"
'
Announce4:
'Befehl &H11 <s>
'übersetzes 1 des slave Myc_mode = 1 I2C nach RS232
'translated 1 of slave I2C to RS232
Data "17,oa;250"
'
Announce5:
'Befehl &H12
'übersetzes 2 des slave Myc_mode = 1 , RS232 nach I2C
'translated 2 of slave, RS232 to I2C
Data "18,aa,as17"
'
Announce6:
'Befehl &H13
'übersetzes 252 des slave Myc_mode = 1
'translated 252 of slave,
Data "19;aa,LAST ERROR;20,last_error"
'
Announce7:
'Befehl &H14
'übersetzes 253 des slave Myc_mode = 1
'translated 253 of slave,
Data "20;aa,MYC INFO;b,ACTIVE"
'
Announce8:
'Befehl &HEC <0..127>
'Adresse zum Senden speichern
'write send adress
Data "236;oa,I2C adress;b,{0 to 127}"                                               '
'
Announce9:
'Befehl &HED
'Adresse zum Senden lesen
'read send adress
Data "237;aa,as236"
'
Announce10:
'Befehl &HEE 0|1
'no_myc speichern
'write no_myc
Data "238;oa,no_myc;a"                                               '
'
Announce11:
'Befehl &HEF
'MYC_mode lesen
'read myc_mode
Data "239;aa,as238"
'
Announce12:
'Befehl &HF0<n><m>
'liest announcements
'read n announcement lines
Data "240;ln,ANNOUNCEMENTS;120;20"
'
Announce13:                                                 '
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
 '
Announce14:                                                 '
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
Announce15:
'Befehl &HFE <n><data>
'eigene Individualisierung schreiben
'write individualization
Data "254;ka,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,SERIAL,1"
'
Announce16:
'Befehl &HFF <n> :
'eigene Individualisierung lesen
'read individualization
Data "255;la,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,SERIAL,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1"
'
Announce17:
Data "R !($1 $2) IF $239=1"
'
Announce18:
Data "R !($16 $17 $18 $19 $20) IF $239=0"