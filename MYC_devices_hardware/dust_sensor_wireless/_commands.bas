' Commands
' 20251209
'
00:
   Gosub Print_basic
   Gosub Print_tx
   Gosub Command_received
Return

'
01:
   Gosub Send_memory_content
Return
'
02:
   Gosub Send_memory_content
Return
'
03:
   Gosub Send_memory_content
Return
'
04:
   Gosub Send_memory_content
Return
'
05:
   Gosub Send_memory_content
Return
'
06:
   Gosub Send_memory_content
Return
'
07:
   Gosub Send_memory_content
Return
'
08:
   Gosub Send_memory_content
Return
'
09:
   Gosub Send_memory_content
Return
'
10:

   Gosub Send_memory_content
Return
'
11:
   Old_commandpointer = Commandpointer
   Tx_b(1) = &H0B
   Tx_b(2) = High(Memory_pointer)
   Tx_b(3) = Low(Memory_pointer)
   Tx_write_pointer = 4
   Gosub Print_tx
Return
'

12:
   'start stop
   If Commandpointer >= 2 Then
      Old_commandpointer = Commandpointer
      If Command_b(3) < 2 Then
         If Command_b(2) = 1 Then
            Gosub Start_sensor
         Else
            Gosub Stop_sensor
         End If
      Else
         Parameter_error
	Gosub Command_received
      End If
   End If
Return
'
13:
   If Commandpointer >= 2 Then
      Old_commandpointer = Commandpointer
      If Command_b(2) < 7 Then
         Measure_time = Command_b(2)
         Select Case Measure_time
            Case 0
               ' 3s
               M_time = 1
            Case 1
               ' 10 s
               M_time = 3
            Case 2
               ' 30 s
               M_time = 9
            Case 3
               ' 1 min
               M_time = 18
            Case 4
               ' 10 min
               M_time = 180
            Case 5
               ' 30 min
               M_time = 540
            Case 6
               ' 60 min
               M_time = 1080
         End select
         Measure_time_eeram = Measure_time
         M_time_eeram = M_time
         Gosub Clear_memory
      Else
         Parameter_error
      End If
	Gosub Command_received
   End If
Return
'
14:
   Old_commandpointer = Commandpointer
   Tx_b(1) = &H0E
   Tx_b(2) = Measure_time
   Tx_write_pointer = 3
   Gosub Print_tx
Return
'
15:
   If Commandpointer >= 4 Then
      Old_commandpointer = Commandpointer
      D_temp1_b(4) = 0
      D_temp1_b(3) = Command_b(2)
      D_temp1_b(2) = Command_b(3)
      D_temp1_b(1) = Command_b(4)
      If D_temp1 < 700001 Then
         Cleaning_intervall = D_temp1
         Gosub Send_Cleaning_intervall
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
16:
   Old_commandpointer = Commandpointer
   Tx_b(1) = &H10
   Tx_b(2) = Cleaning_intervall_b(3)
   Tx_b(3) = Cleaning_intervall_b(2)
   Tx_b(4) = Cleaning_intervall_b(1)
   Tx_write_pointer = 5
   Gosub Print_tx
Return
'
17:
   'start cleaning
   Old_commandpointer = Commandpointer   :
   Temps1_b(1) = &H7E
   Temps1_b(2) = &H00
   Temps1_b(3) = &H56
   Temps1_b(4) = &H00
   Temps1_b(5) = &HA9
   Temps1_b(6) = &H7E
   Send_len = 6
   Gosub Send_data
   Gosub Command_received
Return
'
18:
   'type
   Old_commandpointer = Commandpointer
   Temps1_b(1) = &H7E
   Temps1_b(2) = &H00
   Temps1_b(3) = &HD0
   Temps1_b(4) = &H01
   Temps1_b(5) = &H00
   Temps1_b(6) = &H2E
   Temps1_b(7) = &H7E
   Send_len = 7
   Gosub Send_data
   Gosub Command_received
Return
'
19:
   'serial
   Old_commandpointer = Commandpointer
   Temps1_b(1) = &H7E
   Temps1_b(2) = &H00
   Temps1_b(3) = &HD0
   Temps1_b(4) = &H01
   Temps1_b(5) = &H03
   Temps1_b(6) = &H2B
   Temps1_b(7) = &H7E
   Send_len = 7
   Gosub Send_data
   Gosub Command_received
Return
'
20:
   'version
   Old_commandpointer = Commandpointer
   Temps1_b(1) = &H7E
   Temps1_b(2) = &H00
   Temps1_b(3) = &HD1
   Temps1_b(4) = &H00
   Temps1_b(5) = &H2E
   Temps1_b(6) = &H7E
   Send_len = 6
   Gosub Send_data
   Gosub Command_received
Return
'
21:
   'reset
   Old_commandpointer = Commandpointer
   Temps1_b(1) = &H7E
   Temps1_b(2) = &H00
   Temps1_b(3) = &HD3
   Temps1_b(4) = &H00
   Temps1_b(5) = &H2C
   Temps1_b(6) = &H7E
   Send_len = 6
   Gosub Send_data
   Gosub Clear_memory
   Gosub Command_received
Return
'
22:
   'register
   Old_commandpointer = Commandpointer
   Temps1_b(1) = &H7E
   Temps1_b(2) = &H00
   Temps1_b(3) = &HD2
   Temps1_b(4) = &H01
   Temps1_b(5) = &H00
   Temps1_b(6) = &H2C
   Temps1_b(7) = &H7E
   Send_len = 7
   Gosub Send_data
   Gosub Command_received
Return
'
23:
   If Commandpointer >= 3 Then
      Old_commandpointer = Commandpointer
      'never as wireless command
      If Command_origin <> 4 Then
         ' config Jumper required
         If Mode_in = 0 Then
            W_temp1 = Command_b(2) * 256
            W_temp1 = W_temp1 + Command_b(3)
            If W_temp1 < 1700 Then
               Radio_frequency0 = W_temp1
               Radio_frequency0_eeram = Radio_frequency0
               D_temp1 = Radio_frequency0 * 1000
               Gosub Set_frequency_0
            Else
               Not_valid_at_this_time
            End If
            Gosub Command_received
         Else
            Not_valid_at_this_time
         End If
      Else
         Not_valid_at_this_time
      End If
      Gosub Command_received
   End If
Return
'
24:
   Old_commandpointer = Commandpointer
   if Radio_type = 0 Then Gosub Read_frequency_0
   Tx_b(1) = &H18
   print Radio_frequency0
   w_temp1 = Radio_frequency0
   Tx_b(2) = w_temp1_h
   Tx_b(3) = w_temp1_l
   Tx_write_pointer = 4
   Gosub Print_tx
Return
'
25:
   If Commandpointer >= 2 Then
      Old_commandpointer = Commandpointer
      'never as wireless command
      If Command_origin <> 4 Then
         ' config Jumper required
         If Mode_in = 0 Then
            If Command_b(2) < 129 Then
               Radio_frequency4 = B_temp1
               Radio_frequency4_eeram = Radio_frequency4
               Gosub Set_frequency_nrf244
            Else
               Not_valid_at_this_time
            End If
         Else
            Not_valid_at_this_time
         End If
      Else
         Not_valid_at_this_time
      End If
      Gosub Command_received
   End If
Return
'
26:
   Old_commandpointer = Commandpointer
   If Radio_type = 4 Then Gosub Read_frequency_nrf244
   Tx_b(1) = &H1A
   Tx_b(2) = Radio_frequency4
   Tx_write_pointer = 3
   Gosub Print_tx
Return
'
27:
   Old_commandpointer = Commandpointer
   Tx_b(1) = &H1B
   If Mode_in = 0 Then
      Tx_b(2) = 1
   Else
      Tx_b(2) = 0
   End If
   Tx_write_pointer = 3
   Gosub Print_tx
Return