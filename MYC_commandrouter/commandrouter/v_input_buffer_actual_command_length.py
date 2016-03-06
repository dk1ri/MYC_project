command = []                # command: per input: actual list for length of command
answer = []					# answer: per input: actual  list for length of answer
info = []					# info: per input: actual  list for length of info
"""
 within these three lists:
   0 type: 	x:no properties for command, no parameter for info; n: one numeric property; e: answer command
                                                                                   or info not applicable,  error
                s: string; v: variable number of elements; t: for oa/aa command; u: for ob/ab command; c:
                                                                                        for some metacommands,
                r: string for sequential access of on command
         b: no other elements
           1: 0
         e: error
           1: 0
         n: numeric
           1 length of all parameter(s) / for sequential: without parameters
           2 first parameter end (for sequential access commands only; on and of command)
           3 length of parameter (for sequential access commands only; onand of command)
         s: numeric + string, element 0 and 1 must be set always
           1 length of (commandtoken + number of bytes before stringlength + length of stringlength)
           2 length of stringlength
                  0: not set or not valid; do include commandtoken
           3 length of string only (not including stringlength, added at real time) 0: not yet set
           4 length of number
          v:
           1 length of (commandtoken + length_of_number_of_elements
           2 "n" or "s"
           3 length of number or length of string
           4 n: length of complete data to wait for (commandtoken + length_of_number_of_elements +
                                                                       number_of_elements * length of number
             s: number of element left
           5 s :start pos of next string
           6 s: end pos of next string
             (added real time)
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

