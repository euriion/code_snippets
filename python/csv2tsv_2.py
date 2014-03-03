import sys
import csv

if len(sys.argv) != 3:
  print "Insufficient arguments"
  sys.exit(1)

fd = open(sys.argv[2], 'w')
with open(sys.argv[1], 'rb') as csvfile:
  csvReader = csv.reader(csvfile, delimiter=',', quotechar='"')
  for row in csvReader:
    fd.write('\t'.join(row) + "\n")
fd.close()
