<?php
#    detailed description
#    20231208
#    To understand the program, you should be familiar with the announcements and commands of the MYC system (at least)
#    please read https://dk1ri.de/myc/commands.pdf or https://dk1ri.de/myc/commands.txt
#
#    To understand the program flow see action.php
#
#    This version should work basically, but there are some errors
#
#    found errors:
#    ct_of_as correctly used? -> ct_of_as_ ?
#    command a with 1 parameter: "0" not omitted
#
#     not implemented / missing:
#    automatically update of values: no working solution found. see action.php
#     ext
#     range commands: sequence like log, date.. (lin only)
#    CONVERT
#
# at start read_new_device is called and with this split_to_display_object.
# This generates $_SESSION data to simplify and speed up later operation.
# So this will take some more time with the first call.
# read_new_device
# - create $_SESSION data for additional device (old ones not deleted)
# - split anouncelist to display objects and get chapter_names
# - define device dependent data
# - basic_tok is the token given in the original annoucelist
# For description of $_SESSION data see below

# detailed_description.php
# DK1RI 20240124
# The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.

# Then action.php is called always, which is basically one form element
# action.php is the basic page and call all other functions
# to store data between the page calls, the SESSION mechanism is used.
# action.php is the basic page and call all other functions
# to store data the SESSION mechanism is used, which stores data for the next call of the page.
# data are stored in $_SESSION["dataname"][$device] independent for each device
# To reduce computing power most of these data are generated with the first call of the page for a device. So this will
# take some more time with the first call.
# Most of these data are stored in files "session"dataname" in the devices/"devicename" folder. This may help debugging.
# testmode must be set to 1 in _config
# The initialisation and description of these data can be found in read_new_device.php
# all other data (independent of a device) are initialized and described in read_config.php (called with myc.php)


# For testmode testmode must be set to 1 in _config
# Most of the $_SESSION data are stored in files "session"dataname" in the devices/"devicename" folder. This may help debugging.


# Description of $_SESSION data (all per device)

# for including necessary code for commandtypes only
# $_SESSION["includes"]

# -
# $_SESSION["chapter_index"]

# -
# $_SESSION["chapter_token"]

# _POST is not corrected / modified for use by $_SESSION["actual_data]
# &B and &H values are not modified / converted
# others may be retranslated (real data -> MYC data) -> contain transmitted data (not the displayed ones)
# $not_SESSION["corrected_POST"]

# _POST is corrected / modified for transmit
# $B and &H is converted
# for multiple data speces are removed
# stringlength added
# $_SESSION["corrected_POST_for transmit"]

# original_announce: spltted original announcefile token; array data: array: line split by ";"
# $_SESSION["original_announce"]

# announce_all: commandtype only for all displayed elements by token
# but: "as" commands have no entry (but a display element). They are handled with the corresponding operate command
# and get the basic_tok of the operating command
# token : basic_tok."identifier"
# identifiers:
# m selectors for stack, memoryposition
# n selector for ADD
# o selector for number of data to send for an / on and am / on commands
# d data
# a answer element
# $_SESSION["announce_all"]

# token of "as" command -> corresponding token
# $_SESSION["a_to_o"]
#
# reverse
# $_SESSION["o_to_a"]

# list of _POST indices, which are not tokens
# $_SESSION["special_token"]

# length of property (for send data) for each property
# for memorypositions the property may have more than one display elements _ stored in the first element only
# $_SESSION["property_len"]

# half of above
# $_SESSION["property_len_byte"]

# for commands with range (without MUL and ADD)
# range of numbers (not for memoryposition and stacks)
# $_SESSION{"des_range"]

# all token (of displayed elements) for a basic_tok
# $_SESSION["cor_token"]

# actual data for each display element
# number type: numbers separated by space (if applicable)
# string: printable chars or &Hxx (including space); separated by space (if applicable)
# ready for display (after space _> to &nbsp; for transmit: &H / $B must be converted to char
# manual entries of selectors and op command values are corrected to the nearest valid value,
# invalid manual entries for numbers of memory commands (data) are ignored (display not changed)
# string restrictions are not supported -> no correction)
# type a: elementnumber stored with (corresponding) tok."m0"; send data stored with tok."dx" and sent if different to tok."d0|1|2"
#   send with no change anyway
#   received data stored with (corresponding) tok."d0|1|2.."
#type b: start position stored with tok."m0", number of elements stored with tok,"o0"
#   transmitted data use tok."dx" (not displayed) tok."d"-1|2|... are displayed elements for input
#   received data stored witj tok."d"1|2|...
# type m: position stored with differnet selectors: tok."mx"
#   data stored in tok."d0"
# type n: start position stored with tok."m0", number of elements stored with tok,"o0"
#   data are stored in tok."d0"  (space separated)
# type f: number of elements stored with (corresponding) tok."m0", send data: not stored; received data stored
#   with (corresponding) tok."d0"
#   send with no change anyway
# $_SESSION["actual_data"]

# not used ?
# $_SESSION["chapter_array"]

# actual tokens, depend on selected chapters
# $_SESSION["tok_list"]

# commandtype of "os" commands used but may be error -> to check
# $_SESSION["ct_of_as"]

# token for as commands: as-token array data master-token (num)
# $_SESSION["as_token"]

# token for as commands: master-token array data as-token (num)
# data are stored in $_SESSION["dataname"][$device] independent for each device
# token for as commands: master-token array data as-token (num)
# $_SESSION["as_token_as_to_basic"]

# type for memoried per display tok
# $_SESSION["type_for_memories"]

# token of oo commands
# $_SESSION["oo_tok"]

# per displaytoken:
# for memory data :
#       string: "alpha" (restriction not supported)
#       small numeric: max,0,0,1,1,2,4....
#       big numeric: max,<des-range>    (token is in "to_correct")
# others (all numeric)
#       small numeric: max,0,0,1,1,2,4....
#       big numeric: max,<des-range>     (token is in "to_correct")
# $_SESSION["des"]

# names for display elements
# $_SESSION["des_name"]

# contain "1" used if values are "big", read and write commands
# $_SESSION["to_correct"]

# to calculate stacks / memoryposition max values are required
# $_SESSION["max_for_send"]

# for ADD token ("n"):
# product of MULS
# $_SESSION["max_for_ADD"]

# commands with one string (m, n, f possible)
# $_SESSION["string_commands"]

# for p / o commands: unit
# $_SESSION["unit"]

# announcemnts with OPTION METER
# $_SESSION["meter"][$device]

# line for METER
# $_SESSION["meter_announce_line"]

# min time of all METER lines
# $_SESSION["meter_min_time"]

# chapter_names: array
# $_SESSION["chapter_names"][$device] = [];

#
# $_SESSION["actual_data] has new values
# generated in "tanslate".php
# $_SESSION["update"]

# default 1; set to "0", if error is detected and data not transmitted and actual data not updated
# $_SESSION["send_ok"]

# basictok for command to send
# $_SESSION["tok_to_send"]

#sendstring to send
# $_SESSION["send_string_ny_tok"]
?>