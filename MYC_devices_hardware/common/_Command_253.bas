' Command253
'1.7.0, 190512
'
   Case 253
      Tx_busy = 2
      Tx_time = 1
      Tx_b(1) = &HFD
      Tx_b(2) = 4
      'no info
      Tx_write_pointer = 3
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received