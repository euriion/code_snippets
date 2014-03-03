from multiprocessing import Process, Queue
import time

def f(q, inputFilename, no):
    idx = 0
    for i in range(10000):
      time.sleep(1)
      idx += 1
    q.put(idx)

def main():
    start = 0
    queue = Queue()
    procCount = 20
    subprocesses = []
    for pNo in range(procCount):
      filename = "filename.%d" % pNo
      p = Process(target=f, args=(queue, filename, pNo))
      p.start()
      subprocesses.append(p)
    # while subprocesses:
    #   subprocesses.pop().join()

if __name__ == '__main__':
    main()
