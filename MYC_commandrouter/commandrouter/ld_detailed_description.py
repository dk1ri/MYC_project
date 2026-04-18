"""
name : ld_detailed_description.py
last edited: 20260414
Copyright : DK1RI
If no other rights are affected, this program can be used under GPL (Gnu public licence)

dataexchange is via variables only.
LD related moduls start with ld_

Basics:
There are two inputs: one for check and the original from sk
output is as the original (if not blocked)

At start the program read the rules
-read rules-list
-Rules for more than one commandtoken are splitted to one commandtoken per line
-create an array of status (actual data) for all commandtoken in right side of rules
-if answer commands are "asxxx" value storage of operating and answer is identical always
-some more lists to speed up th program

Operation:
reads data sent by SK via.
if commandtoken not in rules (left side):
    transfer unchanged answer via CR to SK and update status, if used on right side
    or
    transfer unchanged command via CR to FU
if commandtoken is in rules (left side):
    update status if in right side)
    send a command if required by rules and new status matches

if answer (from FU to CR):
    store only (LD do not get anwer)

missing:
float and double for conditions
calculation in conditions
"""