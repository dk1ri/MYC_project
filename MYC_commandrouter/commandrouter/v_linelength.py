"""
name : v_linelength.py
last edited: 20260224
list of required command /answer length used for parsing
Copyright : DK1RI
If no other rights are affected, this programm can be used under GPL (Gnu public licence)
"""

command = {}                # command: list for length of command, the length contain length of tok (of full list);
answer = {}				    # answer / info: list for length of answer, the length contain length of device commandtoken

"""
The intention of these lists is simplify the parsing of commands, answers / info
The announcelines are translated to these lists at (re-)initialiization.
These  2 lists contain n lists each, where n is the tok of answer / operating commands of the full announcelist

Principle of data handling when the CR is analyzing incoming data:

Data is handled during calls of the programm. A call is started, when a defined number of bytes is received. Then data is analyzed
and the command / answer is either finished or the CR is awaiting additional bytes for entering the next call.

During a loop checks may be done as well. The content of a parameter is checked, if applicable, but not using <des>
In case of failure the command / answer is teminated and data are not forwarded.

For the first call the commandtoken is available. If the command has no parameters, the command is finished.
Otherwise number of bytes for this commandtoken is got and the CR wait for these bytes.
For each commandtoken a specific type (1 to 5) is used. The handling of the following data depend on this type.

Some parameters are stored in v_sk.len[input_device], v_dev_xxx[device], which will be used during the next call

Each string requires 2 calls: one for length, one for the string itself.



Detailed description of v_linelength.command , v_line_length.answer for each tok:
  
            index
 type 0:            no parameters, just forward command, some switches with one stack
            0       type
            1       length of commandtoken
            
                    v_sk.len / v_dev.len: not used
 
 type 1:            operate commands and answers for switches, range, m (numeric + string) ; all answer commands
                    ob command with one element (numeric)
            0:      1
            1:      1ength: to be copied to v_sk.len[0]
           
            2:      first parameter max values
            3:      length of this
            4:      0
            
            5:      same for second parameter
            ...
            
            used v_sk.len / v_dev.len:
            0: actual wait
            
type 2:             operate commands and answers for n
            0       2
            1       length: to be copied to v_sk.len[0]
            
            2       max of start
            3       length of start
            4       string : 0
            
            5       max of elements
            6       length of elements
            7       string: 0
            
            8       max of parameter or stringlength
            9       length of this
            10      string (0 or 1)
            
            used v_sk.len / v_dev.len:
            0: actual wait
            1: number of calls (0 based)
            2: numer of elements not yet transmitted
            4: 0 next: stringlenth - 1 next: string
            5: actual stringlength
                            
type 3:             operate oa / answer aa with position + one or more string or numeric
                    
            0:      3
            1       1ength: to be copied to v_sk.len[0]
            2:      max of position (for more than one paramter)
            3:      length of position (for more than one paramter)
            4:      0 (for more than one paramter)
            5:      max of 1st parameter (max stringlength for strings)
            6:      length of 1st parameter
            7:      string: 0 or 1
            8:      ..
            
            used v_sk.len / v_dev.len:
            0: len of line to wait
            1: number of calls (0 based)
            2: 1st parameter
            3: pos in line to start actual.
    
type 4:             operate of / answer of af   
            0:      4
            1       1ength: to be copied to v_sk.len[0]
            2:      max of number of transmitted elements
            3:      length of this
            4:      max of valu of element or length of string
            5:      string: 0 or 1

            used v_sk.len / v_dev.len:
            0: actual wait
            1: next call
            1: numer of elements not yet transmitted
            2: 0 next stringlenth - 1 next string
            3: actual stringlenth        

type 5:             ob / ab any number of mixed string / numeric
            0       5
            1       1ength: to be copied to v_sk.len[0]
            
            2       max of start
            3       length of start
            4       string : 0
            
            5       max of elements
            6       length of elements
            7       string: 0
            
            8:      max of 1st parameter
            9:      length of 1st parameter
            10:     string: 0 or 1
            11:      ..
            
            used v_sk.len / v_dev.len:
            0: actual wait
            1: call
            2: numer of elements not yet transmitted
            3: 0 normal, 1: additional call
            4: next pos in linelength

type 6:             ob one element (string)
                    om with string
            0       6
            1       1ength: to be copied to v_sk.len[0]
            
            2       max of stringlength
            3       length of this
            4       string : 1
            
            used v_sk.len / v_dev.len:
            0: actual wait
            1: call
            2: stringlength
"""

