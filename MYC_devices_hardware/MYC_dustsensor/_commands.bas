' Commands
' 20230309
'
00:
   Tx_time = 1
   A_line = 0
   Number_of_lines = 1
   Send_line_gaps = 2
   Gosub Sub_restore
   If Command_mode = 1 Then Gosub Print_tx
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
0A:
   Gosub Send_memory_content
Return
'
0B:
   If Commandpointer >= 2 Then
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
         Gosub Clear_memory
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
0C:
   Tx_b(1) = &H0C
   Tx_b(2) = Measure_time
   Tx_write_pointer = 3
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
0D:
   If Commandpointer >= 2 Then
      If Command_b(3) < 2 Then
         Temps_b(1) = &H7E
         Temps_b(2) = &H00
         If Command_b(2) = 1 Then
            Temps_b(3) = &H00
            Temps_b(4) = &H02
            Temps_b(5) = &H01
            Temps_b(6) = &H05
            Temps_b(7) = &HF7
            Temps_b(8) = &H7E
            Send_len = 8
            M_timer = 0
            Rx_started = 1
         Else
            Temps_b(3) = &H01
            Temps_b(4) = &H00
            Temps_b(5) = &HFE
            Temps_b(6) = &H7E
            Send_len = 6
            Rx_started = 0
            Gosub Clear_memory
         End If
         Gosub Send_data
      Else
         Parameter_error
         Gosub Command_received
      End If
   End If
Return
'
0E:
   If Commandpointer >= 4 Then
      Cleaning_intervall_b(4) = 0
      Cleaning_intervall_b(3) = Command_b(2)
      Cleaning_intervall_b(2) = Command_b(3)
      Cleaning_intervall_b(1) = Command_b(4)
      If Cleaning_intervall < 700001 Then
         Temps_b(1) = &H7E
         Temps_b(2) = &H00
         Temps_b(3) = &H80
         Temps_b(4) = &H05
         Temps_b(5) = &H00
         Temps_b(6) = &H00
         Stuffing_pointer = 7
         Temps_b(Stuffing_pointer) = Command_b(2)
         Gosub Byte_stuffing_send
         Temps_b(Stuffing_pointer) = Command_b(3)
         Gosub Byte_stuffing_send
         Temps_b(Stuffing_pointer) = Command_b(4)
         Gosub Byte_stuffing_send
         Sum = 133 + Command_b(2)
         Sum = Sum + Command_b(3)
         Sum = Sum + Command_b(4)
         Sum = Sum + Command_b(5)
         B_temp1 = Low(Sum)
         Temps_b(Stuffing_pointer) = &HFF - B_temp1
         Incr Stuffing_pointer
         Temps_b(Stuffing_pointer) = &H7E
         Send_len = Stuffing_pointer
         Gosub Send_data
      Else
         Parameter_error
      End If
   End If
Return
'
0F:
   Temps_b(1) = &H7E
   Temps_b(2) = &H00
   Temps_b(3) = &H80
   Temps_b(4) = &H01
   Temps_b(5) = &H00
   Temps_b(6) = &H7D
   Temps_b(7) = &H5E
   Temps_b(8) = &H7E
   Send_len = 8
   Gosub Send_data
   Last_command = 4
Return
'
10:
   Temps_b(1) = &H7E
   Temps_b(2) = &H00
   Temps_b(3) = &H56
   Temps_b(4) = &H00
   Temps_b(5) = &HA9
   Temps_b(6) = &H7E
   Send_len = 6
   Gosub Send_data
Return
'
11:
   Temps_b(1) = &H7E
   Temps_b(2) = &H00
   Temps_b(3) = &HD0
   Temps_b(4) = &H01
   Temps_b(5) = &H01
   Temps_b(6) = &H2D
   Temps_b(7) = &H7E
   Send_len = 7
   Gosub Send_data
Return
'
12:
   Temps_b(1) = &H7E
   Temps_b(2) = &H00
   Temps_b(3) = &HD1
   Temps_b(4) = &H00
   Temps_b(5) = &H2E
   Temps_b(6) = &H7E
   Send_len = 6
   Gosub Send_data
Return
'
13:
   Temps_b(1) = &H7E
   Temps_b(2) = &H00
   Temps_b(3) = &HD0
   Temps_b(4) = &H01
   Temps_b(5) = &H03
   Temps_b(6) = &H2B
   Temps_b(7) = &H7E
   Send_len = 7
   Gosub Send_data
Return
'
14:
   Temps_b(1) = &H7E
   Temps_b(2) = &H00
   Temps_b(3) = &HD3
   Temps_b(4) = &H00
   Temps_b(5) = &H2C
   Temps_b(6) = &H7E
   Send_len = 6
   Gosub Send_data
Gosub Clear_memory
Return
'
15:
   Temps_b(1) = &H7E
   Temps_b(2) = &H00
   Temps_b(3) = &HD2
   Temps_b(4) = &H01
   Temps_b(5) = &H00
   Temps_b(6) = &H2C
   Temps_b(7) = &H7E
   Send_len = 7
   Gosub Send_data
Return
'