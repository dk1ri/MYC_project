<?php
#    detailed description
#    20240212
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
# DK1RI 20240324
# The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.
#
#T he program do not use globals, because i do not know, weather different users use the dame globals in a multithread environment
# when sending a commnand at the same time. SESSION are simmilat to globals
# The programm uses the SESSION mechanism. So data are stored from one call of a page to the next individually for each user.
# This works with different users; each getting an individual data set.
# 3 types of SESSION data:
# - device specific data are generated once only and store in files. $_SESSION[...][$device] stored in the device directory
# - exception: actual_data: these are variable data. These are not stored in files, because each user can update the data
# - user specific data stored in user_data per user. default user "user" cannot store data.
# - other data, which are used in the next call of the page.
# this is done by read_user_data() in action.php:
# Some (user-specific) SESSION variables are copied to (global) variables at start of the page and restored to SESSION
# at the end. This will reduce code length and (hopefully) reduce compute load.
# if $SESSION variables are empty, and a username is set, data are loaded file(if existing)
# for username = user default data are loaded to the global variables at start (and stored to SESSION at the end)
#
# Myc.php is called once at start; then action.php is called always, which is basically one form element.
# action.php is the basic page and call all other functions.
# user dependent variable are stored as global and updated from _SESSION["user_data"][user_name] at start of action.php
# Other data, which must be stored between sessions are stored in $_SESSION.... '
# Data are stored in $_SESSION["dataname"][$device] independent for each device
# To reduce computing power most of these data are generated with the first call of the page for a device. So this will
# take some more time with the first call.
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

# original_announce: splitted original announcefile token; array data: array: line split by ";"
# $_SESSION["original_announce"]

# announce_all: commandtype only for all displayed elements by token
# token : basic_tok."identifier"."number": example: 256d0
# identifiers:
# mx selectors for stack, memoryposition as defined by <des_memory>; one for each MUL
# n0 additional selector for ADD
# o0 selector for number of data to send for an / on, ab / ob and ap /op  (with more than one dimension) commands (<des> has max only)
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

# length of property (for send data) for each property (token)
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
# actual_data contain "MYC" values -> displayed values are corrected before display as per <des>
# invalid data from POST can occur for manual entries only and are not stored in actual_data.
# (and not transmitted). Some errors can be corrected
# number type: multiple numbers separated by space (if applicable for b,n and f commands)
# string: printable chars or &Hxx; separated by 2 space  (if applicable for b,n and f commands)
# actual data is ready for display (after space -> to &nbsp; for transmit: &H / $B must be converted to char
# string restrictions are used, not valid characters are omitted
# command a: elementnumber stored with (corresponding) tok."m0"; send data stored with tok."dx" and sent if different to tok."d0|1|2"
#   send with no change anyway
#   data are maual entried always
#   received data stored with (corresponding) tok."d0|1|2.."
# command b: start position stored with tok."m0", number of elements stored with tok,"o0"
#   transmitted data use tok."dx" (not displayed) tok."d"-1|2|... are displayed elements for input
#   received data stored witj tok."d"1|2|...
#   data are manual entries always
# command m: position stored with different selectors: tok."mx"
#   data stored in tok."d0"
#   data are manual entries always
# command n: start position stored with tok."m0", number of elements stored with tok,"o0"
#   data are stored in tok."d0"  (space separated)
#   data are maual entried always
# command f: number of elements stored with (corresponding) tok."m0", send data: not stored; received data stored
#   with (corresponding) tok."d0"
#   send with no change anyway
#   data are maual entried always
# all switches:
#   stacks (mx) and data (d0): no manual entries: MYC data stored and used for display
# command op/oo:
#   stacks (mx): MYC data (positions) are stored and display may be different (stringas well)
#   data (dx) per dimension: MYC positions are stored.
#   _POST is checked, if "big values" are used (manual entries)
#   for big values: displayed (real) values are translated from actual_data; otherwise actual_data are used directly
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

# for stacks:

#
# for memory data (d0,d1,..):
# string: ",length of string,allowed_characters
# number: "max_count,allowed_numbers"   -> copy of <des_range>
#
# op / oo:
# small numbers: "max,selectordata"
#big number: ",max_count_for transmit,allowed_numbers"   -> copy of <des_range>  there is a translation!!
#
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

# basictok for commands to ready to send
# $_SESSION["tok_to_send"]

#sendstring to send
# $_SESSION["send_string_ny_tok"]
?>