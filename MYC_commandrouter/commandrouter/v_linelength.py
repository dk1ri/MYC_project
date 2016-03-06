"""
lists for lrngth of commands, answers and infos
lists per CR commandtoken (of full announcelist)
All of the parameters are are set at at (re-)initialiization.
The corresponding temporary values are stored in des devices_buffer or input_buffer
All values without length of commandtoken

within these three lists:
   0 type: 	b: no properties
            e: error or nor applicable
            n: one numeric property;
            m: numeric parameter for sequential memory or fifo
            s: string;
            t: string for sequential memory access or fifo
            v: variable number of elements; t: for oa/aa command; u: for ob/ab command; c: for some metacommands,
for:
         b: no other elements
           1: 0
         e: error
           1: 0
         n: simple numeric
           1 length of parameter + commandtokenlength for commmand
         m: for on /an and of / af command: numeric
           1 length of number of elements + length of start
           2 length of number of elements
           4 length of start
           3 length of <ty>
         s: for  m / om / am command: length_of_string + string
           1 length of elementnumber + length of stringlength
           2 length of elementnumber
           3 length of stringlength
         t: for on /an and of / af command: length_of_string + string
           1 length of number of elements + length of start
           2 length of number of elements
           3 length of stringlength
           4 added real time: number of actual element
           5 added real time; length of string
          a: for arrays
           1 length_of_number_of_elements
           2 added real time: actual element in work
           3 added real time: position for next analize action

           4 ... x array for "n" or "s"
               0 "n" or "s"
               1 length of number or length of string
           c:	as s, but require a inline commandtoken backtranslation
           t:
           1 command: length of commandtoken + length of position parameter
           2 [] "s" or "n" as above, one array per type
           3 []  ...
          r: string for sequential access (on and of command)
           1: length of (commandtoken + 2 parameters)
           2 first parameter end
           3 length of parameter
           4 length of stringlength
           5 pos of next action (wait unit this)
           6 number of parameters left
           7 actual stringlength
"""

command = []                #command: list for length of command
answer = []				    #answer: list for length of answer, the length do not contain length of commandtoken
info = []					#info: list for length of info, the length do not contain length of commandtoken; is different from Answer only for memory commands
