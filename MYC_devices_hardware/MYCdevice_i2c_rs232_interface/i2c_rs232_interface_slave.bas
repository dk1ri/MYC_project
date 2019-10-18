'-----------------------------------------------------------------------
'name : rs232_i2c_interface_slave.bas
'Version V06.0, 20191017
'purpose : I2C-RS232_interface Slave
'This Programm workes as I2C slave
'Can be used with hardware rs232_i2c_interface Version V05.0 by DK1RI
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
' Inputs: see below
' Outputs : see below
' For announcements and rules see Data section at the end
'
'------------------------------------------------------
'Missing/errors:
'
'------------------------------------------------------
$regfile = "m88pdef.dat"
'$regfile = "m168pdef.dat"
'$regfile = "m328pdef.dat"
'
'-----------------------------------------------------
$crystal = 20000000
$include "common_1.7\_Processor.bas"
'
'----------------------------------------------------
'
' 8: for 8/32pin, ATMEGAx8; 4 for 40/44pin, ATMEGAx4 packages
' used for reset now: different portnumber of SPI SS pin
Const Processor = "9"
Const Command_is_2_byte    = 0
' 1 ... 127:
Const I2c_address = 2
Const No_of_announcelines = 8
'announcements start with 0 -> minus 1
Const Tx_factor = 10
' For Test:10 (~ 10 seconds), real usage:1 (~ 1 second)
'
Const Rs232_length = 250
'
'----------------------------------------------------
$include "common_1.7\_Constants_and_variables.bas"
'
Dim Rs232_in As String * Rs232_length
'RS232 input
Dim Rs232_in_b(Rs232_length) As Byte At Rs232_in Overlay
Dim Rs232_pointer As Byte
'
'----------------------------------------------------
$include "common_1.7\_Macros.bas"
'
'----------------------------------------------------
$include "common_1.7\_Config.bas"
'
'----------------------------------------------------
' procedures at start
'
'----------------------------------------------------
$include "common_1.7\_Main.bas"
'
'----------------------------------------------------
$include "common_1.7\_Loop_start.bas"
'
'----------------------------------------------------
'RS232 got data for I2C ?
'Input on RS232 is stored in a buffer and transferred on read request to I2C buffer
'actual start is position 1 always
B_temp1 = Ischarwaiting()
If B_temp1 = 1 Then
   B_temp1 = Waitkey()
   If Rs232_pointer < Rs232_length Then
      Incr Rs232_pointer
      Printbin B_temp1
      Rs232_in_b(Rs232_pointer) = B_temp1
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
' ---> Specific subs
'
'----------------------------------------------------
   $include "common_1.7\_Commandparser.bas"
'
'-----------------------------------------------------
'
   Case 1
'Befehl &H01 <s>
'Sendet Daten von I2C nach RS232
'read data from I2C, write to RS232 (write to device)
'Data "1,oa;250"
      If Commandpointer > 1 Then
         If Command_b(2) = 0 Then
            Gosub Command_received
         Else
            If Command_b(2) > 252  Then
               Parameter_error
               Gosub Command_received
            Else
               B_temp1 = Command_b(2) + 2
               If Commandpointer >= B_temp1 Then
               'string finished
                  For B_temp2 = 3 To Commandpointer
                     B_temp3 = Command_b(B_temp2)
                     Printbin B_temp3
                  Next B_temp2
                  Gosub Command_received
               Else_Incr_Commandpointer
            End If
         End If
      Else_Incr_Commandpointer
'
   Case 2
'Befehl &H02
'liest Daten von RS232 nach I2C
'read data from RS232, write to I2C  (read from device)
'Data "2,aa,250"
      If Tx_busy = 0 Then
         Tx_b(1) = &H02
         Tx_b(2) = Rs232_pointer
         Tx_write_pointer = 3
         For B_temp2 = 1 To Rs232_pointer
            Tx_b(Tx_write_pointer) = Rs232_in_b(B_temp2)
            Incr Tx_write_pointer
         Next B_temp2
         Rs232_pointer = 0
         'all bytes transfered to I2c_tx
         Tx_busy = 2
      Else
        Not_valid_at_this_time
      End If
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
            Case 2
               If Commandpointer >= 3 Then
                  If Command_b(3) < 2 Then
                     I2C_active = Command_b(3)
                     I2C_active_eeram = I2C_active
                     Else_Parameter_error
                  Gosub Command_received
               Else_Incr_Commandpointer
            Case 3
               If Commandpointer >= 3 Then
                   b_Temp2 = Command_b(3)
                   If b_Temp2 < 128 Then
                      b_Temp2 = b_Temp2 * 2
                      Adress = b_Temp2
                      Adress_eeram = Adress
                      Gosub Reset_i2c
                   Else_Parameter_error
                   Gosub Command_received
               Else_Incr_Commandpointer
            Case Else
               Parameter_error
               Gosub Command_received
         End Select
      Else_Incr_Commandpointer
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
               Tx_b(3) = I2c_active
               Tx_write_pointer = 4
            Case 3
               b_Temp2 = Adress / 2
               Tx_b(3) = b_Temp2
               Tx_write_pointer = 4
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
'announce text
'
Announce0:
'Befehl &H00
'basic annoumement wird gelesen
'basic announcement is read to I2C
Data "0;m;DK1RI;Rs232_i2c_interface Slave;V06.0;1;200;1;8;1-1"
'
Announce1:
'Befehl &H01 <s>
'Sendet Daten von I2C nach RS232
'read data from I2C, write to RS232 (write to device)
Data "1,oa;250"
'
Announce2:
'Befehl &H02
'liest Daten von RS232 nach I2C
'read data from RS232, write to I2C  (read from device)
Data "2,aa,250"
'
Announce3:
'Befehl &HF0<n><m>
'announcement aller Befehle lesen
'read m announcement lines
Data "240;ln,ANNOUNCEMENTS;200;8"
'
Announce4:                                                  '
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
'
Announce5:                                                  '
'Befehl &HFD
'Geraet aktiv antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
Announce6:
'Befehl &HFE :
'eigene Individualisierung schreiben
'write individualization
Data "254;ka,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,8,{0 to 127}"
'
Announce7:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;la,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,8,{0 to 127}"
'