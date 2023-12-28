'name : lightsensor
'Version V01.0, 20231123
'purpose : Program for Adafruit AS7262 lightsensor (TM)
'This Programm workes as I2C slave or with serial protocol
'Can be used with hardware Klimasensor V02.1 or Airsensor V01.0 by DK1RI
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
' Inputs /Outputs : see file __config.bas
' For announcements and rules see Data section in announcements.bas
'
'------------------------------------------------------
' Missing/errors:
'
'------------------------------------------------------
' Detailed description
' Please read instructions for the sensor!
' Register read is possible with one register (byte) only (No multiple byte receive)!!!
' The sequence of the internal storage for single variables is reversed.
' So the first 8 bit according IEEE must be written to the 4th byte.
' Sequende within a byte is correct.
'
'----------------------------------------------------
$regfile = "m328pdef.dat"
'
'-----------------------------------------------------
$include "common_1.13\_Processor.bas"
$crystal = 10000000
'
'----------------------------------------------------
'
'=========================================
' Dies Werte koennen bei Bedarf geaendert werden!!!
' These values must be modified on demand!!!!
'
' not used
Const I2c_address = &H0
Const No_of_announcelines = 33
Const Tx_factor = 15
' For Test:15 (~ 10 seconds), real usage:2 (~ 1 second)
Const S_length = 32
' I2C adress of sensor
' 7Bit &H49
Const Tx_valid = &H02
const Rx_valid = &H01
Const I2c_adr = &H92
Const STATUS_REG = &H00
Const WRITE_REG = &H01
Const READ_REG = &H02
Const HW_VERSION = &H00
Const FW_VERSION = &H02
Const CONTROL = &H04
Const IT = &H05
Const TEMPERATURE = &H06
Const LED = &H07
Const VIOLET = &H08
Const BLUE = &H0A
Const GREEN = &H0C
Const YELLOW = &H0E
Const ORANGE = &H10
Const RED = &H12
Const VIOLET_COR = &H14
Const BLUE_COR = &H18
Const Green_COR = &H1C
Const YELLOW_COR = &H20
Const ORANGE_COR = &H24
Const RED_COR = &H28
Const Co_def = "V00000G00000Y00000B00000O00000R00000"
'----------------------------------------------------
$include "__use.bas"
$include "common_1.13\_Constants_and_variables.bas"
'
Dim Temp_single As Single
Dim Temp_single_b(4) As Byte at Temp_single Overlay
Dim Colorstring As String * 10
Dim Color_string_b(9) As Byte At Colorstring Overlay
Dim St_byte(10) As Byte
Dim Stri As String * 9 At St_byte Overlay
Dim Dat(13) As Byte
Dim Data_valid As Byte
Dim As_status As Byte
Dim Co As String * 37
Dim Co_b(37) As Byte At Co Overlay
Dim V_reg As Byte
Dim Violet_data As Word
Dim Green_data As Word
Dim Yellow_data As Word
Dim Blue_data As Word
Dim Orange_data As Word
Dim Red_data As Word
Dim As_mode As Byte
Dim To_send As Byte
Dim Gain As Byte
Dim Bank As Byte
Dim Data_rdy As Byte
Dim Integrate_time As Word
Dim Temp As Byte
Dim Led_current As Byte
Dim LED_on As Byte
Dim Led_ind_current As Byte
Dim Led_ind As Byte
Dim Start_co As Byte
Dim Cor_counter AS Byte
'
$lib "i2c_twi.lbx"
Wait 1
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
'----------------------------------------------------
'
Dat_to_String:
   ' used for HW FW Version
   ' String start at B_temp2
   Stri = Str(B_temp1)
   B_temp3 = Len(Stri)
   For B_temp1 = 1 to B_temp3
      Tx_b(B_temp2) = St_byte(B_temp1)
      Incr B_temp2
   Next B_temp1
   Tx_b(B_temp2) = &H20
   Incr B_temp2
Return
'
Read_color_data:
   ' Data_rdy? checked once only
   Gosub Read_control
   If Data_rdy = 1 Then
      Co = Co_def
      '
      V_reg = VIOLET
      Gosub Read_register
      W_temp1 = Dat(1) * 256
      Incr V_reg
      Gosub Read_register
      W_temp1 = W_temp1 + Dat(1)
      Start_co = 1
      Gosub Transfer_to_string
      '
      V_reg = BLUE
      Gosub Read_register
      W_temp1 = Dat(1) * 256
      Incr V_reg
      Gosub Read_register
      W_temp1 = W_temp1 + Dat(1)
      Start_co = 7
      Gosub Transfer_to_string
      '
      V_reg = GREEN
      Gosub Read_register
      W_temp1 = Dat(1) * 256
      Incr V_reg
      Gosub Read_register
      W_temp1 = W_temp1 + Dat(1)
      Start_co = 13
      Gosub Transfer_to_string
      '
      V_reg = YELLOW
      Gosub Read_register
      W_temp1 = Dat(1) * 256
      Incr V_reg
      Gosub Read_register
      W_temp1 = W_temp1 + Dat(1)
      Start_co = 19
      Gosub Transfer_to_string
      '
      V_reg = ORANGE
      Gosub Read_register
      W_temp1 = Dat(1) * 256
      Incr V_reg
      Gosub Read_register
      W_temp1 = W_temp1 + Dat(1)
      Start_co = 25
      Gosub Transfer_to_string
      '
      V_reg = RED
      Gosub Read_register
      W_temp1 = Dat(1) * 256
      Incr V_reg
      Gosub Read_register
      W_temp1 = W_temp1 + Dat(1)
      Start_co = 31
      Gosub Transfer_to_string
   End If
Return
'
Transfer_to_string:
   Colorstring = Str(W_temp1)
   B_temp2 = Len(Colorstring)

   B_temp2 = 6 - B_temp2
   B_temp1 = 1
   Start_co = Start_co + B_temp2
   While B_temp2 < 6
      Co_b(Start_co) = Color_string_b(B_temp1)
      Incr B_temp1
      Incr B_temp2
      Incr Start_co
   Wend
Return
'
Read_one_color_cor:
   ' V_reg is 1st corrected color register
   For Cor_counter = 4 to 1 Step -1
      Gosub Read_register
      Temp_single_b(Cor_counter) = Dat(1)
      Incr V_reg
   Next Cor_counter
Return
'
Read_status:
   Stop Watchdog
   Dat(1) = STATUS_REG
   I2creceive I2c_adr, Dat(1), 1, 1
   If Err = 1 Then
      I2c_error
   End If
   As_status = Dat(1)
   Start Watchdog
Return
'
Read_control:
   V_reg = CONTROL
   Gosub Read_register
   If Data_valid = 1 Then
       As_mode = Dat(1)
       Gain.1 = As_mode.5
       Gain.0 = As_mode.4
       Bank.1 = As_mode.3
       Bank.0 = As_mode.2
       Data_rdy = As_mode.1
   End If
Return
'
Write_control:
     To_send = &H00
     To_send.5 = Gain.1
     To_send.4 = Gain.0
     To_send.3 = Bank.1
     To_send.2 = Bank.0
     V_reg = CONTROL
     Gosub Write_register
Return
'
Read_led:
   V_reg = LED
   Gosub Read_register
   If Data_valid = 1 Then
       B_temp1 = Dat(1)
       Led_current = B_temp1.5 * 2
       Led_current = Led_current + B_temp1.4
       Led_on = B_temp1.3
       Led_ind_current = B_temp1.2 * 2
       Led_ind_current = Led_ind_current + B_temp1.1
       Led_ind = B_temp1.0
   End If
Return
'
Write_led:
   To_send = &H00
   To_send.5 = Led_current.1
   To_send.4 = Led_current.0
   To_send.3 = Led_on.0
   To_send.2 = Led_ind_current.1
   To_send.1 = Led_ind_current.0
   To_send.0 = Led_ind.0
   V_reg = LED
   Gosub Write_register
Return
'
Read_register:
   Data_valid = 0
   Gosub Read_status
   B_temp1 = As_status.1 And Tx_valid
   If B_temp1 = 0 Then
      'v_reg can be sent
      Dat(1) = WRITE_REG
      Dat(2) = V_reg
      Gosub S
      'read status for read_ok, this may nees some time
      B_temp4 = 0
      Stop Watchdog
      While B_temp4 < 200 And Data_valid = 0
         Gosub Read_status
         '
         B_temp1 = As_status.0 And Rx_valid
         If B_temp1 = 1 Then
            ' rx register ready
            Dat(1) = READ_REG
            I2creceive I2c_adr, Dat(1), 1, 1
            If Err = 1 Then
               I2c_error
            End If
            Data_valid = 1
         End If
         Incr B_temp4
      Wend
      Start Watchdog
   Else
      Not_valid_at_this_time
   End If
Return
'
Write_register:
   Gosub Read_status
   '
   Stop Watchdog
   B_temp1 = As_status.1 And Tx_valid
   If B_temp1 = 0 Then
      Dat(1) = WRITE_REG
      ' set V_reg for write
      Dat(2) = V_reg Or &B10000000
      I2csend I2c_adr, Dat(1), 2
      If Err = 1 Then
         I2c_error
      Else
         'read status for write_ok
         Gosub Read_status
         B_temp1 = As_status.1 And Tx_valid
         If B_temp1 = 0 Then
            Dat(1) = WRITE_REG
            Dat(2) = To_send
            Gosub S
      Else
         Not_valid_at_this_time
      End If
      End If
   Else
      Not_valid_at_this_time
   End If
   Start Watchdog
Return
'
S:
   I2csend I2c_adr, Dat(1), 2
   If Err = 1 Then
      I2c_error
   End If
Return
'
'***************************************************************************
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