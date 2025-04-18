'name : Feinstaubsensor_w.bas
'Version V01.0, 20241219

'purpose : Program for Sensitron SPS30 dust sensor
'This Programm workes as I2C slave or with serial protocol or use a wireless interface
'Can be used with hardware Feinstaubsensor_eagle Version V01.0 by DK1RI
'This Interface can be used with a wireless interface
'
'
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
' To run the compiler the directory comon_1.14 with includefiles must be copied to the directory of this file!
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
'
'----------------------------------------------------
$include "common_1.14\_Introduction_master_copyright.bas"
'
'----------------------------------------------------
'
'Used Hardware:
' serial
' I2C
' Timer1
'-----------------------------------------------------
' Inputs / Outputs : see file __config.bas
'
'------------------------------------------------------
'Missing/errors:
'
'------------------------------------------------------
' Detailed description
' F0 command deliveres 247 byte only (max). This may be less than requested
'
'----------------------------------------------------
$regfile = "m1284pdef.dat"
'for ATMega1284
'
'-----------------------------------------------------
$crystal = 20000000
$include "common_1.14\_Processor.bas"
$Baud1 = 115200
'
'----------------------------------------------------
'
'1...127:
Const I2c_address = 28
Const No_of_announcelines = 46
'announcements start with 0 -> minus 1
Const Tx_factor = 15
' For Test:15 (~ 10 seconds), real usage:2 (~ 1 second)
Const S_length = 50
'
Const Memory_size = 755
Const Rx_data_length = 100
' Length of Sensordata
'
'Radiotype 0: no radio Interface; 1: RFM95; (2:RYFA689)
Const Radiotype = 0
Const Name_len = 4
'----------------------------------------------------
$include "__use.bas"
$include "common_1.14\_Constants_and_variables.bas"
'
Dim Sum As Word
Dim MC10(Memory_size) As Word
Dim MC25(Memory_size) As Word
Dim MC40(Memory_size) As Word
Dim MC100(Memory_size) As Word
Dim NC05(Memory_size) As Word
Dim NC10(Memory_size) As Word
Dim NC25(Memory_size) As Word
Dim NC40(Memory_size) As Word
Dim NC100(Memory_size) As Word
Dim Ty(Memory_size) As Word
Dim MC10_last As Word
Dim MC25_last As Word
Dim MC40_last As Word
Dim MC100_last As Word
Dim NC05_last As Word
Dim NC10_last As Word
Dim NC25_last As Word
Dim NC40_last As Word
Dim NC100_last As Word
Dim Ty_last As Word
Dim Measure_time As Byte
Dim M_time As Dword
Dim Measure_time_eeram As Eram Byte
Dim M_time_eeram As Eram Dword
Dim M_timer As Dword
Dim Send_len As Byte
Dim Rx_started As Byte
Dim Rx_pointer As Byte
Dim Rx_data As String * Rx_data_length
Dim Rx_data_b(Rx_data_length) As Byte At Rx_data Overlay
Dim Memory_pointer As Word
Dim Bs As Byte
Dim Last_command As Byte
Dim Stuffing_pointer As Byte
Dim Check_overflow As Byte
Dim Cleaning_intervall As Dword
Dim Cleaning_intervall_b(4) As Byte At Cleaning_intervall Overlay
'
Dim Myc_mode As Byte
Dim wireless_active As Byte
Dim wireless_active_eram As Byte
Dim wirelesss_tx_in_progress As Byte
Dim Radio_type As Byte
Radio_type = Radiotype
Dim Radio_name As String * 4
Dim Radio_name_eram As Eram String * 4
Dim Radio_name_b(4) As Byte At Radio_name Overlay

'
#IF Radiotype > 0
   $include "common_1.14\wireless_setup.bas"
#ENDIF


'----------------------------------------------------
$include "common_1.14\_Macros.bas"
'
'----------------------------------------------------
$include "common_1.14\_Config.bas"
'
'----------------------------------------------------
Waitms 500
'
#IF Radiotype = 1
   $include "common_1.14\_LoRa_setup.bas"
   Gosub Lora_setup
#ENDIF
#IF Radiotype = 2
   $include "common_1.14\A7129_setup.bas"
   Gosub 7129_setup
#ENDIF

'----------------------------------------------------
$include "common_1.14\_Main.bas"
'
'----------------------------------------------------
$include "common_1.14\_Loop_start.bas"
'
If wirelesss_tx_in_progress = 0 Then
   ' read from wireless: client or server tarnasparent
   #IF Radiotype = 1
      Gosub Lora_rx
   #ENDIF
   #IF Radiotype = 2
      Gosub 7129_rx
   #ENDIF
Else
   #IF Radiotype = 1
      Gosub Lora_finish_tx
   #ENDIF
End If
#IF Radiotype = 2
   If Wait_for_rx_ready = 1 Then
   '   return to receive mode)
      If Gio1 = 0 Then gosub Set_rx_mode
   End If
#ENDIF
'----------------------------------------------------
' commands are send to sensor; returned data are analyzed:
Gosub Ananlyze_in
'
$include "common_1.14\_Main_end.bas"
'
'----------------------------------------------------
'
' End Main start subs
'
'----------------------------------------------------
$include "common_1.14\_Reset.bas"
'
'----------------------------------------------------
$include "common_1.14\_Init.bas"
'
'----------------------------------------------------
$include "common_1.14\_Subs.bas"
'
#IF Radiotype = 1
   $include "common_1.14\wireless.bas"
   $include "common_1.14\_Lora.bas"
#ENDIF
#IF Radiotype = 2
   $include "common_1.14\wireless.bas"
   $include "common_1.14\A7129.bas"
#ENDIF
'----------------------------------------------------
'
Timer_interrupt:
' for read data every 3,36s
   If M_timer >= M_time Then
      If Rx_started = 1 Then
         ' read measured values
         Temps_b(1) = &H7E
         Temps_b(2) = &H00
         Temps_b(3) = &H03
         Temps_b(4) = &H00
         Temps_b(5) = &HFC
         Temps_b(6) = &H7E
         Send_len = 6
         Gosub Send_data
      End If
      M_timer = 0
   Else
      Incr M_timer
   End If
   Timer0 = 0
Return
'
Seri2:
   B_temp1 = Waitkey(#2)
'  Printbin B_temp1
   Rx_data_b(Rx_pointer) = B_temp1
   Incr Rx_pointer
Return
'
Clear_memory:
For Memory_pointer = 1 To Memory_size
   Mc10(Memory_pointer) = 0
   Mc25(Memory_pointer) = 0
   Mc40(Memory_pointer) = 0
   Mc100(Memory_pointer) = 0
   Nc05(Memory_pointer) = 0
   Nc10(Memory_pointer) = 0
   Nc25(Memory_pointer) = 0
   Nc40(Memory_pointer) = 0
   Nc100(Memory_pointer) = 0
   Ty(Memory_pointer) = 0
Next Memory_pointer
Mc10(Memory_pointer) = 0
   Mc25_last = 0
   Mc40_last = 0
   Mc100_last = 0
   Nc05_last = 0
   Nc10_last = 0
   Nc25_last = 0
   Nc40_last = 0
   Nc100_last = 0
   Ty_last = 0
Memory_pointer = 1
Rx_pointer = 1
Return
'
Ananlyze_in:
   If Rx_pointer > 1 Then
      If Rx_pointer >= Rx_data_length Or Rx_data_b(1) <> &H7E Then
         ' Some Error
         Rx_pointer = 1
      Else
         If Rx_pointer > 5 Then
            B_temp1 = Rx_pointer - 1
            If Rx_data_b(B_temp1) = &H7E Then
               ' got all data
               If Rx_pointer > 5 Then
                  Select Case Rx_data_b(4)
                     Case 0
                        ' correct
                        If Rx_data_b(5) <> 0 Then
                           ' not empty
                           Select Case Rx_data_b(3)
                             ' CMD
                              Case 3
                                 Gosub Analyze_data
                              Case &H80
                                 Gosub Read_cleaning_intervall
                              Case &HD0
                                 Gosub Get_info
                              Case &HD1
                                 ' version
                                 Gosub Get_info_numeric
                              Case &HD2
                                 ' status register
                                 Gosub Get_info_numeric
                           End Select
                        Else
                           No_data_available
                        End If
                     Case 1
                        Wrong_data_length
                     Case 2
                        Unknown_command
                     Case 4
                        Illegal_command_parameter
                     Case &H28
                        Internal_function_argument_out_of_range
                     Case &H43
                        Command_not_allowed_in_current_state
                  End Select
               Else
                  Wrong_data_length
               End If
               Rx_pointer = 1
            End If
         End If
      End If
   End If
Return
'
Analyze_data:
If Rx_pointer = 7 Then
   Mc10(Memory_pointer) = 0
   Mc25(Memory_pointer) = 0
   Mc40(Memory_pointer) = 0
   Mc100(Memory_pointer) = 0
   Nc05(Memory_pointer) = 0
   Nc10(Memory_pointer) = 0
   Nc25(Memory_pointer) = 0
   Nc40(Memory_pointer) = 0
   Nc100(Memory_pointer) = 0
   Ty(Memory_pointer) = 0
Else
   If Rx_pointer > 20 Then
       Gosub Byte_stuffing
       W_temp1_h = Rx_data_b(6)
       W_temp1_l = Rx_data_b(7)
       Mc10(Memory_pointer)= W_temp1
       Mc10_last= W_temp1
       W_temp1_h = Rx_data_b(8)
       W_temp1_l = Rx_data_b(9)
       Mc25(Memory_pointer) = W_temp1
       Mc25_last= W_temp1
       W_temp1_h = Rx_data_b(10)
       W_temp1_l = Rx_data_b(11)
       Mc40(Memory_pointer) = W_temp1
       Mc40_last= W_temp1
       W_temp1_h = Rx_data_b(12)
       W_temp1_l = Rx_data_b(13)
       Mc100(Memory_pointer) = W_temp1
       Mc100_last= W_temp1
       W_temp1_h = Rx_data_b(14)
       W_temp1_l = Rx_data_b(15)
       Nc05(Memory_pointer) = W_temp1
       Nc05_last = W_temp1
       W_temp1_h = Rx_data_b(16)
       W_temp1_l = Rx_data_b(17)
       Nc10(Memory_pointer) = W_temp1
       Nc10_last = W_temp1
       W_temp1_h = Rx_data_b(18)
       W_temp1_l = Rx_data_b(19)
       Nc25(Memory_pointer) = W_temp1
       Nc25_last = W_temp1
       W_temp1_h = Rx_data_b(20)
       W_temp1_l = Rx_data_b(21)
       Nc40(Memory_pointer) = W_temp1
       Nc40_last = W_temp1
       W_temp1_h = Rx_data_b(22)
       W_temp1_l = Rx_data_b(23)
       Nc100(Memory_pointer) = W_temp1
       Nc100_last = W_temp1
       W_temp1_h = Rx_data_b(24)
       W_temp1_l = Rx_data_b(25)
       Ty(Memory_pointer) = W_temp1
       Ty_last = W_temp1
   End If
End If
   Incr Memory_pointer
   If Memory_pointer > Memory_size  Then Memory_pointer = 1
Return
'
Read_cleaning_intervall:
   Gosub Byte_stuffing
   Tx_b(1) = &H1A
   Tx_b(2) = Rx_data_b(7)
   Tx_b(3) = Rx_data_b(8)
   Tx_b(4) = Rx_data_b(9)
   Tx_write_pointer = 5
   Gosub Print_to_all
Return
'
Get_info_numeric:
' numeric 0x00 .. 0x9 -> to ASC
Gosub Byte_stuffing
Tx_b(1) = Command_b(1)
Tx_b(2) = Rx_data_b(5)
B_temp2 = 3
B_temp3 = 6
For B_temp1 = 1 To Rx_data_b(5)
   B_temp4 = Rx_data_b(B_temp3) + 48
   Tx_b(B_temp2) = B_temp4
   Incr B_temp2
   Incr B_temp3
Next B_temp1
Tx_write_pointer = B_temp2
Gosub Print_to_all
Return
'
Get_info:
Gosub Byte_stuffing
Tx_b(1) = Command_b(1)
Tx_b(2) = Rx_data_b(5)
B_temp2 = 3
B_temp3 = 6
For B_temp1 = 1 To Rx_data_b(5)
   Tx_b(B_temp2) = Rx_data_b(B_temp3)
   Incr B_temp2
   Incr B_temp3
Next B_temp1
Tx_write_pointer = B_temp2
Gosub Print_to_all
Return
'
Byte_stuffing:
   Decr Rx_pointer
   B_temp2 = 1
   Bs = 0
   For B_temp1 = 1 To Rx_pointer
      If Rx_data_b(B_temp1) = &H7D Then
         Bs = 1
      Else
         If Bs = 1 Then
            ' stuffed
            Select case Rx_data_b(B_temp1)
               Case &H5E
                  Rx_data_b(B_temp2) = &H7F
               Case &H5D
                  Rx_data_b(B_temp2) = &H7D
               Case &H31
                  Rx_data_b(B_temp2) = &H11
               Case &H33
                  Rx_data_b(B_temp2) = &H13
            End Select
            Bs = 0
         Else
            ' no change
            Rx_data_b(B_temp2) = Rx_data_b(B_temp1)
         End If
         Incr B_temp2
      End If
   Next B_temp1
   Rx_pointer = B_temp2 - 1
Return
'
Byte_stuffing_send:
Select Case Temps_b(Stuffing_pointer)
   Case &H7E
      Temps_b(Stuffing_pointer) = &H7D
      Incr Stuffing_pointer
      Temps_b(Stuffing_pointer) = &H5E
   Case &H7D
      Temps_b(Stuffing_pointer) = &H7D
      Incr Stuffing_pointer
      Temps_b(Stuffing_pointer) = &H5D
   Case &H11
      Temps_b(Stuffing_pointer) = &H7D
      Incr Stuffing_pointer
      Temps_b(Stuffing_pointer) = &H31
   Case &H13
      Temps_b(Stuffing_pointer) = &H7D
      Incr Stuffing_pointer
      Temps_b(Stuffing_pointer) = &H33
End Select
Incr Stuffing_pointer
Return
'
Send_data:
   For B_temp1 = 1 To Send_len
      B_temp2 = Temps_b(B_temp1)
      Printbin #2, B_temp2
   Next B_temp1
   Gosub Command_received
Return
'
Send_memory_content:
   If Commandpointer >= 4 Then
      ' position
      W_temp1 = Command_b(2) * 256
      W_temp1 = W_temp1.+ Command_b(3)
      ' number
      B_temp1 = Command_b(4)
      If W_temp1 < Memory_size And B_temp1 < 29 Then
         ' will deliver the content indedependent of memorypointer
         Tx_time = 1
         Tx_b(1) = Command_b(1)
         Tx_b(2) = Command_b(2)
         Tx_b(3) = Command_b(3)
         Tx_b(4) = Command_b(4)
         Tx_write_pointer = 5
         For B_temp2 = 1 To B_temp1
            Select Case Command_b(1)
               Case &H02
                  W_temp3 = Mc10(W_Temp1)
               Case &H04
                  W_temp3 = Mc25(W_Temp1)
               Case &H06
                  W_temp3 = Mc40(W_Temp1)
               Case &H08
                  W_temp3 = Mc100(W_Temp1)
               Case &H0A
                  W_temp3 = Nc05(W_Temp1)
               Case &H0C
                  W_temp3 = Nc10(W_Temp1)
               Case &H0E
                  W_temp3 = Nc25(W_Temp1)
               Case &H10
                  W_temp3 = Nc40(W_Temp1)
               Case &H12
                  W_temp3 = Nc100(W_Temp1)
               Case &H14
                  W_temp3 = Ty(W_Temp1)
            End Select
            Tx_b(Tx_write_pointer) = High (W_temp3)
            Incr Tx_write_pointer
            Tx_b(Tx_write_pointer) = Low (W_temp3)
            Incr Tx_write_pointer
            Incr W_temp1
            If W_temp1 >= Memory_size Then
               W_temp1 = 0
            End If
         Next B_temp2
         If Tx_write_pointer > 1 Then Gosub Print_to_all
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
Send_meter:
   Tx_b(1) = Command_b(1)
   Select Case Command_b(1)
      Case &H01
         W_temp3 = Mc10_last
      Case &H03
         W_temp3 = Mc25_last
      Case &H05
         W_temp3 = Mc40_last
      Case &H07
         W_temp3 = Mc100_last
      Case &H09
         W_temp3 = Nc05_last
      Case &H0B
         W_temp3 = Nc10_last
      Case &H0D
         W_temp3 = Nc25_last
      Case &H0F
         W_temp3 = Nc40_last
      Case &H11
         W_temp3 = Nc100_last
      Case &H13
         W_temp3 = Ty_last
   End Select
   Tx_b(2) =  High(W_temp3)
   Tx_b(3) =  Low(W_temp3)
   Tx_write_pointer = 4
   If Tx_write_pointer > 1 Then Gosub Print_to_all
   Gosub Command_received
Return
'
Print_to_all:
If Command_mode = 1 Then
   Gosub Print_tx
   #IF Radiotype > 0
   If wireless_active = 1 Then
      'client onky
      Gosub Tx_wireless_start
   #ENDIF
End If
Return
'

'----------------------------------------------------
$include "_Commands.bas"
$include "common_1.14\_Commands_required.bas"
'
$include "common_1.14\_Commandparser.bas"
'
'-----------------------------------------------------
' End
'
$include "_announcements.bas"
'