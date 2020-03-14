' Analyze_civ Civ_sub_cmd: s072 - s095
' 20200302
'
s72:
   Tx_b(1) = 2:
   Tx_b(2) = &H61
   Tx_b(3) = 100 * Civ_in_b(9)
   Tx_b(3) = Tx_b(3) + Makedec(Civ_in_b(10))
   Tx_write_pointer = 4
Return
'
s73:
   Tx_b(1) = 2:
   Tx_b(2) = &H63
   Tx_b(3) = 100 * Civ_in_b(9)
   Tx_b(3) = Tx_b(3) + Makedec(Civ_in_b(10))
   Tx_write_pointer = 4
Return
'
s74:
   Tx_b(1) = 2:
   Tx_b(2) = &H65
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s75:
   Tx_b(1) = 2:
   Tx_b(2) = &H67
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s76:
   Tx_b(1) = 2:
   Tx_b(2) = &H69
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s77:
   Tx_b(1) = 2:
   Tx_b(2) = &H6B
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s78:
   Tx_b(1) = 2:
   Tx_b(2) = &H6D
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s79:
   Tx_b(1) = 2:
   Tx_b(2) = &H6F
   Tx_b(3) = Makedec(Civ_in_b(9))
   Tx_write_pointer = 4
Return
'
s80:
   Tx_b(1) = 2:
   Tx_b(2) = &H71
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s81:
   Tx_b(1) = 2:
   Tx_b(2) = &H73
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s82:
   Tx_b(1) = 2:
   Tx_b(2) = &H75
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s83:
   Tx_b(1) = 2:
   Tx_b(2) = &H77
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s84:
   Tx_b(1) = 2:
   Tx_b(2) = &H79
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s85:
   Tx_b(1) = 2:
   Tx_b(2) = &H7B
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s86:
   Tx_b(1) = 2:
   Tx_b(2) = &H7D
   Tx_b(3) = 100 * Civ_in_b(9)
   Tx_b(3) = Tx_b(3) + Makedec(Civ_in_b(10))
   Tx_write_pointer = 4
Return
'
s87:
   Tx_b(1) = 2:
   Tx_b(2) = &H7F
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s88:
   Tx_b(1) = 2:
   Tx_b(2) = &H81
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s89:
   Tx_b(1) = 2:
   Tx_b(2) = &H83
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s90:
   Tx_b(1) = 2:
   Tx_b(2) = &H85
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s91:
   Tx_b(1) = 2:
   Tx_b(2) = &H87
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s92:
   Tx_b(1) = 2:
   Tx_b(2) = &H89
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s93:
   Tx_b(1) = 2:
   Tx_b(2) = &H8B
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s94:
   Tx_b(1) = 2:
   Tx_b(2) = &H8D
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s95:
   Tx_b(1) = 2:
   Tx_b(2) = &H8F
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'