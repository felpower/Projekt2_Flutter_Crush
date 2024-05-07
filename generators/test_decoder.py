import time

PUSH_CHARS = "-0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz"

def decode(id):
    id = id[:8]
    timestamp = 0
    for i in range(len(id)):
        c = id[i]
        timestamp = timestamp * 64 + PUSH_CHARS.index(c)
    return timestamp

key = "-NwAbfmUb4RfL43ACrlx"

if key:
    timestamp = decode(key)
    print(f"{timestamp}\n{time.ctime(timestamp/1000)}")