"""
name : ld_detailed_description.py
Copyright : DK1RI 20250305
If no other rights are affected, this programm can be used under GPL (Gnu public licence)

dataexchange is via variables only.
LD related moduls start  with ld_

Basics:
#################################################################################
All input data  must be in HEX, each parameter end with a space.
strings are given by character, each ending with a space
#################################################################################
input is an array of s|d tok parameters
output is a string (because the direct commands are not not splitted (too much effort to split )
The data packets is not checked and the packet is sent in a rush.

At start the program read the announcements (initially from a (test)file)
-read announcelist
-Rules for more than one commandtoken are splitted to one commandtoken per line
-create an array of status (actual data) for all commandtoken with all locations used by rules
-if answer commands are "asxxx" value storage of operating and answer is identical always
-some more lists to speed up th program

Operation:
program reads data sent by CR.
if commandtoken not in rules (left side):
    transfer unchanged answer via CR to SK and update status, if used on right side
    or
    transfer unchanged command via CR to FU
if commandtoken is in rules (left side):
    if answer (from FU via CR):
        update status
        send a command if required by rules and new status matches
        transfer unchanged answer via CR to SK
    if command:
        update status
        send a command if required by rules and new status matches
        block if required
        if not blocked:
            transfer command via CR to FU

missing:
oo ou command without parameter
float and double for conditions
calculation in conditions
rulechcheck not finished
"""