#commandrouter parameter
name=[]                         #0: name
                                #1: index in announceline
length_of_name_length=0
number=[]                       #0: number
                                #1: index in announceline
length_of_last_error_length=0
length_of_announcement_length=0
#
interface=[]                    #[] per interface, index as per input_buffer
                                #   0: full parameter (name)
                                #   1:  value (name)
                                #   2: index in announcelis
                                #   3: full parameter first parameter: port, adress, baudrate
                                #   4: value
                                #   5: index in announcelist
                                #   6: name of 2nd parameter: 8n1...
                                #   7: value
                                #...