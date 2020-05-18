' additional commands
' 20200516
'
01:
   If Commandpointer >= 5 Then
      Vfo_a_b = 10
      Gosub Frequency
   Else
      Incr Commandpointer
   End If
Return
'
02:
   If Commandpointer >= 5 Then
      Vfo_a_b = 11
      Gosub Frequency
   End If
Return
'
03:
   Dtmfchar = 10
   Gosub Dtmf
   '*
   Gosub Dtmf
   Gosub Command_received
Return
'
04:
   Dtmfchar = 11
   Gosub Dtmf
   '#
   Gosub Dtmf
   Gosub Command_received
Return
'
'Menu 1 RX
'
05:
   If Commandpointer >= 2 Then
      If Command_b(2) < 4 Then
         New_commandmode = 1
         Gosub Setcommandmode
         Select Case Command_b(2)
            Case 0
               Dtmfchar = 1
               Gosub Dtmf
            Case 1
               Dtmfchar = 4
               Gosub Dtmf
            Case 2
               Dtmfchar = 8
               Gosub Dtmf
            Case 3
               Dtmfchar = 0
               Gosub Dtmf
         End Select
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
06:
   If Commandpointer = 2 Then
      If Command_b(2) < 5 Then
         New_commandmode = 1
         Gosub Setcommandmode
         Select Case Command_b(2)
            Case 0
               Dtmfchar = 2
               Gosub Dtmf
            Case 1
               Dtmfchar = 3
               Gosub Dtmf
            Case 2
               Dtmfchar = 5
               Gosub Dtmf
            Case 3
               Dtmfchar = 6
               Gosub Dtmf
            Case 4
               Dtmfchar = 0
               Gosub Dtmf
         End Select
      Else
        Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
07:
   If Commandpointer >= 5 Then
      Memory_set_recall = 7
      Gosub Memory
   End If
Return
'
08:
   If Commandpointer >= 5 Then
      Memory_set_recall = 9
      Gosub Memory
   End If
Return
'
'=================================================0
'Menu 2  Antenna
'
09:
   New_commandmode = 2
   b_Temp1 = 1
   Gosub Single_dtmf_char
Return
'
0A:
   New_commandmode = 2
   b_Temp1 = 2
   Gosub Single_dtmf_char
Return
'
0B:
   New_commandmode = 2
   b_Temp1 = 3
   Gosub Single_dtmf_char
Return
'
0C:
   New_commandmode = 2
   b_Temp1 = 6
   Gosub Single_dtmf_char
Return
'
0D:
   New_commandmode = 2
   b_Temp1 = 7
   Gosub Single_dtmf_char
Return
'
0E:
   New_commandmode = 2
   b_Temp1 = 8
   Gosub Single_dtmf_char
Return
'
0F:
   New_commandmode = 2
   b_Temp1 = 9
   Gosub Single_dtmf_char
Return
'
10:
   If Commandpointer >= 3 Then
      New_commandmode = 2
      Antenna = 4
      Tb = 361
      Tc = Antenna
      Td = 100
      Te = 3
      Tf = 255
      Gosub Send_dtmf
   End If
Return
'
11:
   If Commandpointer >= 3 Then
      New_commandmode = 2
      Antenna = 5
      Tb = 361
      Tc = Antenna
      Td = 100
      Te = 3
      Tf = 255
      Gosub Send_dtmf
   End If
Return
'
12:
   New_commandmode = 2
   b_Temp1 = 0
   Gosub Single_dtmf_char
Return
'
'=================================================0
'Menu 3  Filter
'
13:
   If Commandpointer >= 2 Then
      New_commandmode = 3
      Func = 1
      Gosub Command3_1_5
   End If
Return
'
14:
   If Commandpointer >= 2 Then
      New_commandmode = 3
      Func = 2
      Gosub Command3_1_5
   End If
Return
'
15:
   If Commandpointer >= 2 Then
      New_commandmode = 3
      Func = 3
      Gosub Command3_1_5
   End If
Return
'
16:
   If Commandpointer >= 2 Then
      New_commandmode = 3
      Func = 4
      Gosub Command3_1_5
   End If
Return
'
17:
   If Commandpointer >= 2 Then
      New_commandmode = 3
      Func = 5
      Gosub Command3_1_5
   End If
Return
'
18:
   If Commandpointer >= 2 Then
      New_commandmode = 3
      Gosub Setcommandmode
      Select Case Command_b(2)
         Case 0
            Dtmfchar = 7
            Gosub Dtmf
         Case 1
            Dtmfchar = 8
            Gosub Dtmf
         Case 2
            Dtmfchar = 9
            Gosub Dtmf
         Case Else
            Error_no = 4
            Error_cmd_no = Command_no
      End Select
      Gosub Command_received
   End If
Return
'
19:
   New_commandmode = 3
   Gosub Setcommandmode
   Dtmfchar = 0
   Gosub Dtmf
   Gosub Dtmf
   Gosub Command_received
Return
'
1A:
   If Commandpointer >= 2 Then
      If Command_b(2) < 5 Then
         New_commandmode = 3
         Gosub Setcommandmode
         Dtmfchar = 6
         Gosub Dtmf
         Select Case Command_b(2)
            Case 0
               Dtmfchar = 1
               Gosub Dtmf
            Case 1
               Dtmfchar = 2
               Gosub Dtmf
            Case 2
               Dtmfchar = 3
               Gosub Dtmf
            Case 3
               Dtmfchar = 4
               Gosub Dtmf
            Case 4
               Dtmfchar = 5
               Gosub Dtmf
         End Select
      Else
         Error_no = 4
         Error_cmd_no = Command_no
      End If
      Gosub Command_received
   End If
Return
'
'=================================================0
'Menu 4 TX
'
1B:
   If Commandpointer >= 2 Then
      New_commandmode = 4
      Func = 2
      Gosub Command3_1_5
   End If
Return
'
1C:
   If Commandpointer >= 2 Then
      New_commandmode = 4
      Func = 3
      Gosub Command3_1_5
   End If
'
1D:
   If Commandpointer >= 2 Then
      New_commandmode = 4
      Func = 4
      Gosub Command3_1_5
   End If
Return
'
1E:
   If Commandpointer >= 2 Then
      New_commandmode = 4
      Func = 5
      Gosub Command3_1_5
   End If
Return
'
1F:
   If Commandpointer >= 2 Then
      New_commandmode = 4
      Func = 6
      Gosub Command3_1_5
   End If
Return

20:
   New_commandmode = 4
   Gosub Setcommandmode
   Dtmfchar = 0
   Gosub Dtmf
   Gosub Dtmf
   Gosub Command_received
Return
'
21:
   If Commandpointer >= 3 Then
      New_commandmode = 4
      Tb = 10000
      Tc = 7
      Td = 1000
      Te = 4
      Tf = 255
      Gosub Send_dtmf
   End If
Return
'
22:
   If Commandpointer >= 2 Then
      Func = 8
      Gosub Tx_function
   End If
Return
'
23:
   If Commandpointer >= 2 Then
      Func = 9
      Gosub Tx_function
   End If
Return
'
'=================================================0
'Menu 6 Aux
'
24:
   If Commandpointer >= 2 Then
      Func = 2
      Gosub Command6_
   End If
Return
'
25:
   If Commandpointer >= 2 Then
      Func = 3
      Gosub Command6_
   End If
Return
'
26:
   If Commandpointer >= 2 Then
      Func = 4
      Gosub Command6_
   End If
Return
'
27:
   If Commandpointer >= 2 Then
      Func = 5
      Gosub Command6_
   End If
Return
'
28:
   If Commandpointer >= 2 Then
      Func = 6
      Gosub Command6_
   End If
Return
'
29:
   If Commandpointer >= 2 Then
      Func = 7
      Gosub Command6_
   End If
Return
'
2A:
   If Commandpointer >= 2 Then
      Func = 8
      Gosub Command6_
   End If
Return
'
2B:
   If Commandpointer >= 2 Then
      Func = 9
      Gosub Command6_
   End If
Return
'
'=================================================0
'menu 5: Settings
'
2C:
   New_commandmode = 5
   Gosub Setcommandmode
   Dtmfchar = 5
   Gosub Dtmf
   Gosub Command_received
Return
'
2D:
   New_commandmode = 5
   Gosub Setcommandmode
   Dtmfchar = 8
   Gosub Dtmf
   Gosub Command_received
Return
'
2E:
   New_commandmode = 5
   Gosub Setcommandmode
   Dtmfchar = 0
   Gosub Dtmf
   Gosub Command_received
Return
'
2F:
   If Commandpointer >= 2 Then
      New_commandmode = 5
      Tb = 10
      Tc = 7
      Td = 1
      Te = 1
      Tf = 255
      Gosub Send_dtmf
   End If
Return
'
30:
   If Commandpointer >= 3 Then
      New_commandmode = 5
      Tb = 10000
      Tc = 4
      Td = 1000
      Te = 4
      Tf = 255
      Gosub Send_dtmf
   End If
Return
'
'=================================================0
'Menu 4 Transmit
'
31:
   New_commandmode = 4
   Gosub  Setcommandmode
   DTMFchar = 1
   Gosub Dtmf
   Gosub Command_received
Return
'
32:
   New_commandmode = 4
   Gosub  Setcommandmode
   DTMFchar = 3
   Gosub Dtmf
   Gosub Command_received
Return
'
'=================================================0
'Start
'
33:
   DTMFchar = 10
   Gosub Dtmf
   Gosub Init
   Gosub Command_received
Return
'
34:
   If Commandpointer = 2 Then
      Dtmf_duration = Command_b(2)
      Dtmf_duration_eeram = Dtmf_duration
      Gosub Command_received
   End If
Return
'
35:
   Tx_time = 1
   Tx_b(1) = &H35
   Tx_b(2) = Dtmf_duration
   Tx_write_pointer = 3
   If Command_mode = 1 Then Gosub Print_Tx
   Gosub Command_received
Return
'
36:
   If Commandpointer >= 2 Then
      Dtmf_pause = Command_b(2)
      Dtmf_pause_eeram = Dtmf_pause
      Gosub Command_received
   End If
Return
'
37:
   Tx_time = 1
   Tx_b(1) = &H37
   Tx_b(2) = Dtmf_pause
   Tx_write_pointer = 3
   If Command_mode = 1 Then Gosub Print_Tx
   Gosub Command_received
Return
'