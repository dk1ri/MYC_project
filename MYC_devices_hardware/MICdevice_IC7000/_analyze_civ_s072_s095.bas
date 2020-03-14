' Analyze_civ Civ_sub_cmd: s072 - s095
' 20200221
'
s72:
   Tx_b(1) = 2:
   Tx_b(2) = &H02
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
'
s73:
   Tx_b(1) = 2:
   Tx_b(2) = &H04
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
'
s74:
   Tx_b(1) = 2:
   Tx_b(2) = &H06
   Tx_b(3) = Makedec(Civ_in_b(9))
   Tx_write_pointer = 4
'
s75:
   Tx_b(1) = 2:
   Tx_b(2) = &H08
   Tx_b(3) = Makedec(Civ_in_b(9))
   Tx_write_pointer = 4
'
s76:
   Tx_b(1) = 2:
   Tx_b(2) = &H0A
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
'
s77:
   Tx_b(1) = 2:
   Tx_b(2) = &H0C
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
'
s78:
   Tx_b(1) = 2:
   Tx_b(2) = &H0E
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
'
s79:
   Tx_b(1) = 2:
   Tx_b(2) = &H10
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
'
s80:
   Tx_b(1) = 2:
   Tx_b(2) = &H12
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
'
s81:
   Tx_b(1) = 2:
   Tx_b(2) = &H14
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
'
s82:
   Tx_b(1) = 2:
   Tx_b(2) = &H16
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
'
s83:
   Tx_b(1) = 2:
   Tx_b(2) = &H18
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
'
s84:
   Tx_b(1) = 2:
   Tx_b(2) = &H1A
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
'
s85:
   Tx_b(1) = 2:
   Tx_b(2) = &H1C
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
'
s86:
   Tx_b(1) = 2:
   Tx_b(2) = &H1E
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
'
s87:
   Tx_b(1) = 2:
   Tx_b(2) = &H20
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
'
s88:
   Tx_b(1) = 2:
   Tx_b(2) = &H22
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
'
s89:
   Tx_b(1) = 2:
   Tx_b(2) = &H24
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
'
s90:
   Tx_b(1) = 2:
   Tx_b(2) = &H26
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
'
s91:
   Tx_b(1) = 2:
   Tx_b(2) = &H28
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
'
s92:
   Tx_b(1) = 2:
   Tx_b(2) = &H2A
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
'
s93:
   Tx_b(1) = 2:
   Tx_b(2) = &H2C
   Tx_b(3) = Civ_in_b(9) * 256
   Tx_b(3) = Tx_b(3) + Makedec(Civ_in_b(10))
   Tx_write_pointer = 4
'
s94:
   Tx_b(1) = 2:
   Tx_b(2) = &H2E
   Tx_b(3) = Makedec(Civ_in_b(9))
   Tx_write_pointer = 4
'
s95:
   Tx_b(1) = 2:
   Tx_b(2) = &H30
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
'