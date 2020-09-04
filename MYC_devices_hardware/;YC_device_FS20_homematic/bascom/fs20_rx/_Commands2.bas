' additional init
' 200204
'
ED:
'Befehl &HED
'busy, 1: keine Befehle akzeptiert
'busy, 1: no commands accepted
'Data "237;la,busy;a"

   Tx_time = 1
   Tx_b(1) = &HEA
   Tx_write_pointer = 3
   B_temp1 = 0
   If Codelength > 0 Then B_temp1 = 1
   Tx_b(2) = B_temp1
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
EE:
'Befehl  &HEE
'schaltet ein /aus
'switch on / off
'Data "238;ku, switch for Test;1;0;1;2;3;4;5;6;7"
      If Commandpointer >= 2 Then
      If Command_b(2) < 8 Then
         If Codelength = 0 Then
            Send_code(1) = Command_b(2) + 1
            Send_code(2) = 0
            Send_code(3) = T_short
            Codepointer = 1
            Codelength = 1
         Else
            Parameter_error
         End If
      Else
         Parameter_error
      End If
   End If
Return
'
EF:
'Befehl  &HEF
'schaltet ein /aus  Anlernen
'switch on / off learning
'Data "239;ku, learning mode for Test and Initialization;1;0;1;2;3;4;5;6;7"
   If Switchoff_time = 0 Then
      If Commandpointer >= 2 Then
         If Command_b(2) < 8 And Command_b(3) > 0  Then
            If Codelength = 0 Then
               Send_code(1) = Command_b(2) + 1
               Send_code(2) = 0
               Send_code(3) = T_modus
               Codepointer = 1
               Codelength = 1
            Else
               Not_valid_at_this_time
            End If
         Else
            Parameter_error
         End If
         Gosub Command_received
      End If
   Else
      Error_no = 0
      Error_cmd_no = Command_no
      Gosub Command_received
   End If
Return
'