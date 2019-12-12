' IC7300 Command  120 - 13F
' 191129
'
120:
   Temps = Chr(&H14) + Chr(&H06)
   Civ_len = 2
   Gosub Civ_print
   Return
'
121:
   CiV_cmd1 = &H14
   Civ_cmd2 = &H07
   Gosub Civ_print_255_4_bcd
   Return
'
122:
   Temps = Chr(&H14) + Chr(&H07)
   Civ_len = 2
   Gosub Civ_print
'
123:
   CiV_cmd1 = &H14
   Civ_cmd2 = &H08
   Gosub Civ_print_255_4_bcd
   Return
'
124:
   Temps = Chr(&H14) + Chr(&H08)
   Civ_len = 2
   Gosub Civ_print
   Return
'
125:
   CiV_cmd1 = &H14
   Civ_cmd2 = &H09
   Gosub Civ_print_255_4_bcd
   Return
'
126:
   Temps = Chr(&H14) + Chr(&H09)
   Civ_len = 2
   Gosub Civ_print
   Return
'
127:
   CiV_cmd1 = &H14
   Civ_cmd2 = &H0A
   Gosub Civ_print_255_4_bcd
   Return
'
128:
   Temps = Chr(&H14) + Chr(&H0A)
   Civ_len = 2
   Gosub Civ_print
   Return
'
129:
   CiV_cmd1 = &H14
   Civ_cmd2 = &H0B
   Gosub Civ_print_255_4_bcd
   Return
'
12A:
   Temps = Chr(&H14) + Chr(&H0B)
   Civ_len = 2
   Gosub Civ_print
   Return
'
12B:
   CiV_cmd1 = &H14
   Civ_cmd2 = &H0C
   Gosub Civ_print_255_4_bcd
   Return
'
12C:
   Temps = Chr(&H14) + Chr(&H0C)
   Civ_len = 2
   Gosub Civ_print
   Return
'
12D:
   CiV_cmd1 = &H14
   Civ_cmd2 = &H0D
   Gosub Civ_print_255_4_bcd
   Return
'
12E:
   Temps = Chr(&H14) + Chr(&H0D)
   Civ_len = 2
   Gosub Civ_print
   Return
'
12F:
   CiV_cmd1 = &H14
   Civ_cmd2 = &H0E
   Gosub Civ_print_255_4_bcd
   Return
'
130:
   Temps = Chr(&H14) + Chr(&H0E)
   Civ_len = 2
   Gosub Civ_print
'
131:
   CiV_cmd1 = &H14
   Civ_cmd2 = &H0F
   Gosub Civ_print_255_4_bcd
   Return
'
132:
   Temps = Chr(&H14) + Chr(&H0F)
   Civ_len = 2
   Gosub Civ_print
   Return
'
133:
   CiV_cmd1 = &H14
   Civ_cmd2 = &H12
   Gosub Civ_print_255_4_bcd
'
134:
   Temps = Chr(&H14) + Chr(&H12)
   Civ_len = 2
   Gosub Civ_print
   Return
'
135:
   CiV_cmd1 = &H14
   Civ_cmd2 = &H15
   Gosub Civ_print_255_4_bcd
   Return
'
136:
   Temps = Chr(&H14) + Chr(&H15)
   Civ_len = 2
   Gosub Civ_print
   Return
'
137:
   CiV_cmd1 = &H14
   Civ_cmd2 = &H16
   Gosub Civ_print_255_4_bcd
   Return
'
138:
   Temps = Chr(&H14) + Chr(&H16)
   Civ_len = 2
   Gosub Civ_print
   Return
'
139:
   CiV_cmd1 = &H14
   Civ_cmd2 = &H17
   Gosub Civ_print_255_4_bcd
   Return
'
13A:
   Temps = Chr(&H14) + Chr(&H17)
   Civ_len = 2
   Gosub Civ_print
   Return
'
13B:
   CiV_cmd1 = &H14
   Civ_cmd2 = &H19
   Gosub Civ_print_255_4_bcd
   Return
'
13C:
   Temps = Chr(&H14) + Chr(&H19)
   Civ_len = 2
   Gosub Civ_print
   Return
'
13D:
   Temps = Chr(&H15) + Chr(&H01)
   Civ_len = 2
   Gosub Civ_print
   Return
'
13E:
   Temps = Chr(&H15) + Chr(&H02)
   Civ_len = 2
   Gosub Civ_print
   Return
'
13F:
   Temps = Chr(&H15) + Chr(&H05)
   Civ_len = 2
   Gosub Civ_print
Return
'