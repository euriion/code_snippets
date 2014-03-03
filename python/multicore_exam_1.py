from multiprocessing import Process, Queue, Pool
import time

def f(arg):
  print arg
  inputFilename = arg[0]
  no = arg[2]
  idx = 0
  for i in range(10000):
    time.sleep(1)
    idx += 1
  print no
  return no
  # q.put(idx)

def main():
    queue = Queue()
    poolCount = 20
    pool = Pool(processes=poolCount)
    result = pool.apply_async(f, [(1,1),(2,2),(3,3)])
    pool.map(f, [(1,1),(2,2),(3,3)])
    pool.close()
    pool.join()

    subprocesses = []
    for pNo in range(procCount):
      filename = "filename.%d" % pNo
      p = Process(target=f, args=(queue, filename, pNo))
      p.start()
      subprocesses.append(p)
    while subprocesses:
       subprocesses.pop().join()
