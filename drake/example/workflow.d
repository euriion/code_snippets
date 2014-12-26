
out.csv <- in.csv [shell]
  grep i $INPUT > $OUTPUT
; produce an extraordinarily fancy report
count.txt <- out.csv
  wc $INPUT > $OUTPUT
