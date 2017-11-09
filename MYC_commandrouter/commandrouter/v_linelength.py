command = []                # command: list for length of command, the length contain length of tok (of full list);
answer = []				    # answer / info: list for length of answer, the length do contain length of commandtoken
                            # this will be the the length of the device_token

"""
The intention of these lists is simplify the parsing of commands, answers and info
The announcelines are translated to these list used for parsing
One entry per commandtoken of full announcelist
Index to these lists are identical to the commandtoken; this simplyfies lookup. exception: &Hxxfx (CR own) commands;
(these use a lookup table)

For "length of first loop" one parameter is used only, so that wrong data can be discarded immediately!!!

The lists are set at (re-)initialiization.

The maximum number of parameters is of a (0 based) positional parameter in most cases. This therefore is number of parameters  - 1

Some parameters are modified in real time. these are handled in v_sk.xx and v_dev.xx, because
they must be reset at timeout.
Principle of data handling:
Data is handled during loops.
When there are "enaugh" data available, a loop is entered. 
For the first loop (loop0) the commandtoken and the first parameter (if any) must be available.
During a loop 0 or one checks will be done. This checks the content of a parameter, if applicable.
For switches and range commands all parameters are checked.
For memory the memory position and number of parameters are checked, but not <ty>, If <ty> is a string the stringlength is checked.
A string requires 2 loops: one for length, one for the string itself.
Within a loop after the check the loopcounter is increased and the length of the new element added to the actual length.
The result is the length of the data, which must be available to enter the next loop.
if this length is available at that time next loop is entered immediately, otherwise the loop is exited and the next task done.
If there are enough data to enter a loop, it is checked, whether all lops are finished. If so the command is finished 
and some data are reset.
If the loop is exited because there are not enaugh data, the status is remembered in the following variables:
v_sk_xxx, v_ld_xxx and v_dev_xxx
                    linelength_loop                     # actual loopnumber starting with 0
                    linelength_len                      # actual number of bytes to wait for next action
                    linelength_other                    # needed for some commands
                    linelength_other1                   # dito

Description of v_linelength_xxx:
Index 0: type: 	0:      error or not applicable
                1:      switches, range commands and numeric om, am; command of all answer commands
                2:      om / am with string
                3:      on / an numeric
                4:      on / an string
                5:      of / af numeric
                6:      of / af string
                7:      oa / aa
                8:      ob / ab
                
            Index
for all     1   length for 1st loop: SK and LD: length_of_commandtoken + length of 1st parameter
                                     dev: length of 1st parameter
            2   number of loops (3 entries each, starting with 4)
            3   not used
            the following values are used if needed:
            4   maxpos: maximum number for 1st parameter (loop0)
            5   length of this
            6   0: skip, 1: no check, 2: check
            7   ...

Individual:
for:    0:
            1 0
            others omitted

"""

