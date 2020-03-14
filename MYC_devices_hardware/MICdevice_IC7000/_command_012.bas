' Command  120 - 13F
' 200217
'
120:
   CiV_cmd1 = &H14
   Civ_cmd2 = &H07
   Gosub Civ_print_255_4_bcd
   Return
'
121:
   Temps = Chr(&H14) + Chr(&H07)
   Civ_len = 2
   Gosub Civ_print
'
122:
   CiV_cmd1 = &H14
   Civ_cmd2 = &H08
   Gosub Civ_print_255_4_bcd
   Return
'
123:
   Temps = Chr(&H14) + Chr(&H08)
   Civ_len = 2
   Gosub Civ_print
   Return
'
124:
   CiV_cmd1 = &H14
   Civ_cmd2 = &H09
   Gosub Civ_print_255_4_bcd
   Return
'
125:
   Temps = Chr(&H14) + Chr(&H09)
   Civ_len = 2
   Gosub Civ_print
   Return
'
126:
   CiV_cmd1 = &H14
   Civ_cmd2 = &H0A
   Gosub Civ_print_255_4_bcd
   Return
'
127:
   Temps = Chr(&H14) + Chr(&H0A)
   Civ_len = 2
   Gosub Civ_print
   Return
'
128:
   CiV_cmd1 = &H14
   Civ_cmd2 = &H0B
   Gosub Civ_print_255_4_bcd
   Return
'
129:
   Temps = Chr(&H14) + Chr(&H0B)
   Civ_len = 2
   Gosub Civ_print
   Return
'
12A:
   CiV_cmd1 = &H14
   Civ_cmd2 = &H0C
   Gosub Civ_print_255_4_bcd
   Return
'
12B:
   Temps = Chr(&H14) + Chr(&H0C)
   Civ_len = 2
   Gosub Civ_print
   Return
'
12C:
   CiV_cmd1 = &H14
   Civ_cmd2 = &H0D
   Gosub Civ_print_255_4_bcd
   Return
'
12D:
   Temps = Chr(&H14) + Chr(&H0D)
   Civ_len = 2
   Gosub Civ_print
   Return
'
12E:
   CiV_cmd1 = &H14
   Civ_cmd2 = &H0E
   Gosub Civ_print_255_4_bcd
   Return
'
12F:
   Temps = Chr(&H14) + Chr(&H0E)
   Civ_len = 2
   Gosub Civ_print
'
130:
   CiV_cmd1 = &H14
   Civ_cmd2 = &H0F
   Gosub Civ_print_255_4_bcd
   Return
'
131:
   Temps = Chr(&H14) + Chr(&H0F)
   Civ_len = 2
   Gosub Civ_print
   Return
'
132:
   CiV_cmd1 = &H14
   Civ_cmd2 = &H12
   Gosub Civ_print_255_4_bcd
'
133:
   Temps = Chr(&H14) + Chr(&H12)
   Civ_len = 2
   Gosub Civ_print
   Return
'
134:
   CiV_cmd1 = &H14
   Civ_cmd2 = &H15
   Gosub Civ_print_255_4_bcd
   Return
'
135:
   Temps = Chr(&H14) + Chr(&H15)
   Civ_len = 2
   Gosub Civ_print
   Return
'
136:
   CiV_cmd1 = &H14
   Civ_cmd2 = &H16
   Gosub Civ_print_255_4_bcd
   Return
'
137::
   Temps = Chr(&H14) + Chr(&H16)
   Civ_len = 2
   Gosub Civ_print
   Return
'
138:
   CiV_cmd1 = &H14
   Civ_cmd2 = &H17
   Gosub Civ_print_255_4_bcd
   Return
'
139:
   Temps = Chr(&H14) + Chr(&H17)
   Civ_len = 2
   Gosub Civ_print
   Return
'
13A:
   CiV_cmd1 = &H14
   Civ_cmd2 = &H18
   Gosub Civ_print_255_4_bcd
   Return
'
13B:
   Temps = Chr(&H14) + Chr(&H18)
   Civ_len = 2
   Gosub Civ_print
   Return
'
13C:
   CiV_cmd1 = &H14
   Civ_cmd2 = &H19
   Gosub Civ_print_255_4_bcd
   Return
'
13D:
   Temps = Chr(&H14) + Chr(&H19)
   Civ_len = 2
   Gosub Civ_print
   Return
'
13E:
   CiV_cmd1 = &H14
   Civ_cmd2 = &H1A
   Gosub Civ_print_255_4_bcd
   Return
'
13F:
   Temps = Chr(&H14) + Chr(&H1A)
   Civ_len = 2
   Gosub Civ_print
   Return
'