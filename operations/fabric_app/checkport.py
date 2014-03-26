import socket, struct

def check_port(host, port, timeout=1):
    ret = False
    #try:
    # create socket.
    #sock = socket.socket()
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    # create timeval structure.
    timeval = struct.pack("2I", timeout, 0)
    # set socket timeout options.
    # sock.setsockopt(socket.SOL_SOCKET, socket.SO_RCVTIMEO, timeval)
    # sock.setsockopt(socket.SOL_SOCKET, socket.SO_SNDTIMEO, timeval)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_RCVTIMEO, 1)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_SNDTIMEO, )
    # connect to host.
    sock.connect_ex((host, port))
    # abort communications.
    sock.shutdown(SHUT_RDWR)
    # we have connectivity after all.
    ret = True
    #except:
    #    print("except")
    #    pass

    # try to close socket in any case.
    try:
        sock.close()
    except:
        pass

    return ret 

def check_port2(host, port, timeout=1):
    result = False
    try:
        sock = socket.create_connection((host, port), timeout)
    except:
        pass
    
    try:
        sock.close()
        result = True
    except:
        pass
    return(result)

#check_port("127.0.0.1", 22)
if check_port2("nexr00", 23):
    print("available")
else:
    print("not avaliable")

