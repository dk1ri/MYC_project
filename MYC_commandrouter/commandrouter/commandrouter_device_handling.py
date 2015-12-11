# devicehandling subprograms
#
import v_device_buffer
#
def reset_device_buffer(device):
# reset device_buffer[x]
    v_device_buffer.actual_token[device]=0                                                                              #actual commandtoken in work, 0, nothing actual
    v_device_buffer.wait_for_answer[device]=0                                                                           #actual need to wait for answer?
    v_device_buffer.input[device]=""                                                                                    #answer buffer
    return
#