"""
name : v_linelength.py
last edited: 201803
list of required command /answer length used for parsing
"""

command = []                # command: list for length of command, the length contain length of tok (of full list);
answer = []				    # answer / info: list for length of answer, the length do contain length of commandtoken
                            # this will be the the length of the device_token

"""
The intention of these lists is simplify the parsing of commands, answers / info
The announcelines are translated to these lists at (re-)initialiization.
These lists contain n lists each, where n is the number of answer / operating commands of the full announcelist
Index to these lists are identical to the commandtoken; this simplyfies lookup. exception: &Hxxfx (CR own) commands;
(these use a lookup table)

Principle of data handling when the CR is analyzing incoming data:

Data is handled during loops. A loop is started, when a defined number of bytes is received. Then data is analyzed
and the command / answer is either finished or the CR is awaiting additional bytes for entering the next loop.

During a loop checks may be done as well. The content of a parameter is checked, if applicable.
In case of failure the command / answer is teminated and data are not forwarded.

For the first loop (loop0) the commandtoken is available. If the command has no parameters, the command is finisched.
Otherwise number of bytes for this parameter is got and the CR wait for these bytes. After this it enters loop1 ....
For each commandtoken a specific type (1 of 9) is found. The handling of the following data depend on this type.

If a loop do not finish a command some paramters are stored in v_sk_xxx, v_ld_xxx and v_dev_xxx, which will be used
during the next loop

Each string requires 2 loops: one for length, one for the string itself.

If a command is not finished within a loop after the check the loopcounter is increased and the length of the next
element added to the actual length.
The result is the length of the data, which must be available to enter the next loop.

If a loop is is finished and an additional loop is necesary, the status is remembered in the following variables:
v_sk.len, v_ld.len and v_dev.len
                    0                     # actual loopnumber starting with 0
                    1                     # complete number of bytes to wait for entering next loop
                    2                     # needed for some commands
                    3                     # dito
                    4                     # dito

Description of v_linelength.command , v_line_length.answer:
These lists contain n lists each, where n is the number of answer / operating commands of the full announcelist

For each command there are the following entries:
                
for type    Index
            0       type
0           1       length of commandtoken
            others  omitted
                        
not 0       0       type
            1       length for loop0 / loop1: length_of_commandtoken (+ length of 1st parameter -> loop1 as well)
            2       number of loops (5 additional entries each, starting with index 4)
            3       subfunction
            
            the following values are used if number of loops > 0: x = 4 + n * loops
            x+0     maxpos: maximum number for 1st parameter (loop1)
            x+1     length of 1st parameter
            x+2     bytes to wait for for 2nd loop (0 if no other loop)
            x+3     0: skip, 1: no check, 2: check maxpos
            x+4     0: add x+1 to previous loop+2, 1: add actual parameter to x+2 (used for strings)
            x+0     maxpos: maximum number for 2nd parameter (loop2)
            x+1 ...

                                                                        parameters
 type: 	    0:      no parameters, just forward command, some switches
            1:      switches, range commands, m and numeric om, am      all numeric and not changed at runtime
            2:      om / am with string:                                fixed  numeric with one string
            3:      on / an numeric;                                    variable number of numerics
            4:      on / an string:                                     variable number of strings
            5:      of / af numeric                                     variable number of numeric
            6:      of / af string                                      variable number of strings
            7:      oa / aa                                             either one string or numeric
            8:      ob / ab                                             any number of mixed string / numeric
            9:      do nothing, not applicable (as for answers of operating commands)
"""

