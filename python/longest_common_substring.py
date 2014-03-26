def LongestCommonSubstring(S1, S2):
  M = [[0]*(1+len(S2)) for i in xrange(1+len(S1))]
  longest, x_longest = 0, 0
  for x in xrange(1,1+len(S1)):
    for y in xrange(1,1+len(S2)):
      if S1[x-1] == S2[y-1]:
        M[x][y] = M[x-1][y-1] + 1
        if M[x][y]>longest:
          longest = M[x][y]
          x_longest  = x
      else:
        M[x][y] = 0
  return S1[x_longest-longest: x_longest]

filenames = [
  'filename_20121203.log',
  'filename_20121204.log',
  'filename_20121212.log',
  'filename_20121212.log',
]

result = LongestCommonSubstring(filenames[0], filenames[1])
print result
result2 = LongestCommonSubstring(result, filenames[2])
print result2