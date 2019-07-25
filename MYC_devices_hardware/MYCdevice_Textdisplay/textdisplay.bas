'name : textdisplay.bas
'Version V03.2 20190725
'purpose : Textdisplay
'Can be used with hardware textdisplay Version V03.0 by DK1RI
'
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
' To run the compiler the directory common_1,7 must be copied to the directory of this file!
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
'-----------------------------------------------------------------------
' Inputs: see below
' Outputs : see below
' For announcements and rules see Data section at the end
'
'-----------------------------------------------------------------------
'Missing/errors:
'
'-----------------------------------------------------------------------
'$regfile = "m168pdef.dat"
$regfile = "m328pdef.dat"
'
'----------------------------------------------------
$crystal = 20000000
$include "common_1.7\_Processor.bas"
'
'----------------------------------------------------
'
' 8: for 8/32pin, ATMEGAx8; 4 for 40/44pin, ATMEGAx4 packages
' used for reset now: different portnumber of SPI SS pin
Const Processor = "8"
Const Command_is_2_byte = 1
'1...127:
Const I2c_address = 8
Const No_of_announcelines = 17
'announcements start with 0 -> minus 1
Const Tx_factor = 10
' For Test:10 (~ 10 seconds), real usage:1 (~ 1 second)
'
'----------------------------------------------------
$include "common_1.7\_Constants_and_variables.bas"
'
'----------------------------------------------------
'
Dim B_cmp1 as Byte
Dim B_cmp1_eeram As Eram Byte
Dim B_cmp2 as Byte
Dim B_cmp2_eeram As Eram Byte
Dim B_row As Byte
Dim B_col As Byte
Dim B_chars As Byte
Dim B_chars2 As Byte
' b_Chars / 2
Dim B_chars_eeram As Eram Byte
'32: 2* 16, 40: 2*20 Display
'
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
$include "common_1.7\_Serial.bas"
'
'----------------------------------------------------
$include "common_1.7\_I2c.bas"
'
'----------------------------------------------------
'
' End of Main start subs
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
LCD_write:
   If Commandpointer = 2 Then
      Select Case Command_b(2)
         Case 0
            'string empty
            Gosub Command_received
         Case Is > b_Chars
            Parameter_error
            Gosub Command_received
         Case Else
            Incr Commandpointer
      End Select
   Else
      b_Temp3 = Command_b(2) + 2
      If Commandpointer >= b_Temp3 Then
         For b_Temp2= 3 To Commandpointer
            LCD Chr(Command_b(b_Temp2))
            Incr b_Col
            If b_Col > b_Chars2 Then
               If b_Row = 2 Then
                  b_Row = 1
                  Home Upper
               Else
                  b_Row = 2
                  Home Lower
               End If
               b_Col = 1
            End If
         Next b_Temp2
         Gosub Command_received
      Else_Incr_Commandpointer
   End If
Return
'
LCD_locate_write:
If Commandpointer = 2 Then
   If Command_b(2) > b_Chars Then
      Parameter_error
      Gosub Command_received
   End If
Else
   If Command_b(3) = 0 Then
      Gosub Command_received
   Else
      If Command_b(3) > b_Chars Then
         Parameter_error
         Gosub Command_received
      Else
         b_Temp2 = Command_b(3) + 3
         If Commandpointer >= b_Temp2 Then
            If Command_b(2) >= b_Chars2 Then
               b_Row = 2
            Else
               b_Row = 1
            End If
            b_Temp3 = b_Row - 1
            b_Temp3 = b_Temp3 * b_Chars2
            b_Col = Command_b(2) - b_Temp3
            Incr b_Col
            'Command_b(2) is 0 based, Col 1 based
            Locate b_Row , b_Col
            For b_Temp2 = 4 To Commandpointer
               LCD Chr(Command_b(b_Temp2))
               Incr b_Col
               If b_Col > b_Chars2 Then
                  If b_Row = 2 Then
                     b_Row = 1
                     Home Upper
                  Else
                     b_Row = 2
                     Home Lower
                  End If
                  b_Col = 1
               End If
            Next b_Temp2
            Gosub Command_received
         Else_Incr_Commandpointer
      End If
   End If
End If
Return
'
LCD_locate:
   If Command_b(2) < b_Chars Then
   'Command_b(2): 0 ... Chars - 1
      If Command_b(2) >= b_Chars2 Then
         b_Row = 2
      Else
         b_Row = 1
      End If
      b_Temp3 = b_Row - 1
      b_Temp3 = b_Temp3 * b_Chars2
      b_Col = Command_b(2) - b_Temp3
      Incr b_Col
      Locate b_Row , b_Col
   Else_Parameter_error
   Gosub Command_received
Return
'
Config_lcd:
If b_Chars = 32 Then
   Config LCD = 16*2
Else
   Config LCD = 20*2
End If
B_chars2 = B_chars / 2
Initlcd
Home upper
Cls
Cursor on blink
B_row = 1
B_col = 1
Return
'
'----------------------------------------------------
$include "common_1.7\_Commandparser.bas"
'
'-----------------------------------------------------
   Case 1
'Befehl &H01
'LCD schreiben
'write LCD
'Data "1;oa,write text;32"
      If b_Chars = 32 Then
         If Commandpointer > 1 Then
            Gosub LCD_write
         Else_Incr_Commandpointer
      Else
         Command_not_found
         Gosub Command_received
      End If
'
   Case 2
'Befehl &H02
'an position schreiben
'goto position and write
'Data "2;om,STRING,write to position;32;32"
      If b_Chars = 32 Then
         If Commandpointer > 1 Then
            Gosub LCD_locate_write
         Else_Incr_Commandpointer
      Else
         Command_not_found
      End If
'
   Case 3
'Befehl  &H03
'gehe zu Cursorposition
' go to Cursorposition
'Data "3;op,Cursorposition;1;32;lin;-"
      If b_Chars = 32 Then
         If Commandpointer > 1 Then
            Gosub LCD_locate
         Else_Incr_Commandpointer
      Else
         Command_not_found
         Gosub Command_received
      End If
'
   Case 4
'Befehl &H04
'LCD schreiben
'write LCD
'Data "4;oa,write text;40"
      If b_Chars = 40 Then
         If Commandpointer > 1 Then
            Gosub LCD_write
         Else_Incr_Commandpointer
      Else
         Command_not_found
         Gosub Command_received
      End If
'
   Case 5
'Befehl &H05
'an position schreiben
'goto position and write
'Data "5;om,STRING,write to position;40;40"
      If b_Chars = 40 Then
         If Commandpointer > 1 Then
            Gosub LCD_locate_write
         Else_Incr_Commandpointer
      Else
         Command_not_found
         Gosub Command_received
      End If
'
   Case 6
'Befehl  &H06
'gehe zu Cursorposition
' go to Cursorposition
'Data "6;op,Cursorposition;40;lin;-"
      If b_Chars = 40 Then
         If Commandpointer > 1 Then
            Gosub LCD_locate
         Else_Incr_Commandpointer
      Else
         Command_not_found
         Gosub Command_received
      End If
'
   Case 7
'Befehl &H07
'Anzeige löschen
'clear screen
'Data "7;ou,CLS;0,CLS"
      Gosub Config_lcd
      Gosub Command_received
'
   Case 8
'Befehl &H08
'Kontrast schreiben
'write Contrast
'Data "8;oa,contrast;b"
      If Commandpointer = 2 Then
         B_cmp1 = Command_b(2)
         B_cmp1_eeram = B_cmp1
         Pwm1a = b_Cmp1
         Gosub Command_received
      Else_Incr_Commandpointer
'
   Case 9
'Befehl &H09
'Kontrast lesen
'read Contrast
'Data "9;oa,contrast;b"
      Tx_b(1) = &H09
      Tx_b(2) = B_cmp1
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
'
Announce0:
'Befehl &H00
'eigenes basic announcement lesen
'basic announcement is read to I2C buffer or output
Data "0;m;DK1RI;Textdisplay;V03.2;1;230;1;17;1-1"
'
Announce1:
'Befehl &H01
'LCD schreiben
'write LCD
Data "1;oa,write text;32"
'
Announce2:
'Befehl &H02
'an position schreiben
'goto position and write
Data "2;om,STRING,write to position;32;32"
'
Announce3:
'Befehl  &H03
'gehe zu Cursorposition
' go to Cursorposition
Data "3;op,Cursorposition;32;lin;-"
'
Announce4:
'Befehl &H04
'LCD schreiben
'write LCD
Data "4;oa,write text;40"
'
Announce5:
'Befehl &H05
'an position schreiben
'goto position and write
Data "5;om,STRING,write to position;40;40"
'
Announce6:
'Befehl  &H06
'gehe zu Cursorposition
'go to Cursorposition
Data "6;op,Cursorposition;40;lin;-"
'
Announce7:
'Befehl &H07
'Anzeige löschen
'clear screen
Data "7;ou,CLS;0,CLS"
'
Announce8:
'Befehl &H08
'Kontrast schreiben
'write Contrast
Data "8;oa,contrast;b"
'
Announce9:
'Befehl &H09
'Kontrast lesen
'read Contrast
Data "9;oa,contrast;b"
'
Announce10:
'Befehl &HF0<n><m>
'liest announcements
'read n announcement lines
Data "240;ln,ANNOUNCEMENTS;230;17"
'
Announce11:                                                  '
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
'
Announce12:                                                  '
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
Announce13:
'Befehl &HFE :
'eigene Individualisierung schreiben
'write individualization
Data "254;ka,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,8,{0 to 127};a,SERIAL,1;a,DISPLAYSIZE,0,{16x2,20x2}"
'
Announce14:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;la,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,8,{0 to 127};a,SERIAL,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;a,DISPLAYSIZE,0,{16x2,20x2}"
'
Announce15:
Data "R !($1 $2 $3) IF $255&5 = 1"
'
Announce16:
Data "R !($4 $5 $6) IF $255&5 = 0"