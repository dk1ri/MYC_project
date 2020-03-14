' Analyze_civ Civ_sub_cmd: s048 - s071
' 20200301
'
s48:
   Tx_b(1) = 2:
   Tx_b(2) = &H31
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s49:
   Tx_b(1) = 2:
   Tx_b(2) = &H33
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s50:
   Tx_b(1) = 2:
   Tx_b(2) = &H35
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s51:
   Tx_b(1) = 2:
   Tx_b(2) = &H37
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s52:
   Tx_b(1) = 2:
   Tx_b(2) = &H39
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s53:
   Tx_b(1) = 2:
   Tx_b(2) = &H3B
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s54:
   Tx_b(1) = 2:
   Tx_b(2) = &H3D
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s55:
   Tx_b(1) = 2:
   Tx_b(2) = &H3F
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s56:
   Tx_b(1) = 2:
   Tx_b(2) = &H41
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s57:
   Tx_b(1) = 2:
   Tx_b(2) = &H43
   Tx_b(3) = 100 * Civ_in_b(9)
   Tx_b(3) = Tx_b(3) + Makedec(Civ_in_b(10))
   Tx_write_pointer = 4
Return
'
s58:
   Tx_b(1) = 2:
   Tx_b(2) = &H45
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s59:
   Tx_b(1) = 2:
   Tx_b(2) = &H47
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s60:
   Tx_b(1) = 2:
   Tx_b(2) = &H49
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s61:
   Tx_b(1) = 2:
   Tx_b(2) = &H4B
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s62:
   Tx_b(1) = 2:
   Tx_b(2) = &H4D
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s63:
   Tx_b(1) = 2:
   Tx_b(2) = &H4F
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s64:
   Tx_b(1) = 2:
   Tx_b(2) = &H51
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s65:
   Tx_b(1) = 2:
   Tx_b(2) = &H53
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s66:
   Tx_b(1) = 2:
   Tx_b(2) = &H55
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s67:
   Tx_b(1) = 2:
   Tx_b(2) = &H57
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s68:
   Tx_b(1) = 2:
   Tx_b(2) = &H59
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s69:
   Tx_b(1) = 2:
   Tx_b(2) = &H5B
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s70:
   Tx_b(1) = 2:
   Tx_b(2) = &H5D
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s71:
   Tx_b(1) = 2:
   Tx_b(2) = &H5F
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'