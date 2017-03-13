command = []                # command: list for length of command, the length contain length of tok (of full list);
answer = []				    # answer / info: list for length of answer, the length do contain length of commandtoken
                            # this will be the the length of the device_token

"""
The intention of these lists is simpliffy the parsing of commands, answers and info
The announcelines are translated to these list used for parsing
One entry per commandtoken of full announcelist
Index to these lists are identical to the commandtoken; this simplyfies lookup. exception: &HxxFx (CR own) commands;
these use a lookup table
The lists are set at (re-)initialiization.

Some parameters are modified in real time. these are handled in v_sk.xx and v_dev.xx, because
they must be reset at timeout.

Index 0: type: 	0: error or not applicable
                1:   switches, range commands and numeric om, am; no real time length calculation
                2:   om / am with string
                3:   on / an; of / af: transmission like on / an, expcept that there is no startpostion
                4:   oa / aa
                6:   ob / ab

for all:
in v_inputbuffer and v_devicebuffer added real time:
                    linelength_len                      # actual number of bytes to wait for next action
                    linelength_actual_call              # call number, start with 0
                    linelength_other                    # needed for some commands
                    linelength_othe1                    # dito

for:    0:
            -

        1:
            1 length for 1st loop: (length_of_commandtoken +) length of parameters
            2 number of following paramters (2 entries each) (will be > 1 for op commands onky)
            3 maxpos: maximum number for 1st parameter, 0: no check
            4 length of this
            5 maxpos: maximum number for 2nd parameter,..
            6 length of this
            ...

        2:
            1 length for 1st call: (length_of_commandtoken +) length of length of cellnumber (+ length of stringlength)
            2 number of following paramters (2 entries each) (fixed: 2)
            3 maxpos: maximum number for 1st parameter (memorycell)
            4 length of this
            5 maxpos: maximum number for 2nd parameter (stringlength)
            6 length of this

        3:
            1 length for 1st call: (length_of_commandtoken +) length of cellnumber + number of elements
            2 maxpos: number for memory cells
            3 length of this
            4 maxstring: maximum length of string, 0 for numeric <ty>
            5 length of this, length of <ty>
            6 0: numeric / 1: string
            7 0: on / an  1: of / af

        4:
            1 length for 1st call:  (length_of_commandtoken +) length of cellnumber
            2 maxpos: number for memory cells
            3 length of this (transmitted bytes)
            4 ... x 3 lines per array element
            4 maxstring: maximum length of string, 0 for numeric <ty>
            5 length of this, length of <ty>
            6 0: numeric / 1: string
            7 ...

        5:
            1 length for 1st call:  (length_of_commandtoken +) length of cellnumber
            2 maxpos: number for memory cells
            3 length of this
            4 ... x 3 lines per array element
            4 maxstring: maximum length of string, 0 for numeric <ty>
            5 length of this, length of <ty>
            6 0: numeric / 1: string
            7 ...
"""

