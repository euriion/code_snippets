def splitList(listItems, splitCount):
  baseChunkLength, remainingItemCount = divmod(len(listItems), splitCount)
  chunkLengthList = [baseChunkLength + 1] * remainingItemCount + [baseChunkLength] * (splitCount - remainingItemCount)
  idx = 0
  for chunkIndex, chunkLength in enumerate(chunkLengthList):
    chunkLengthList[chunkIndex] = listItems[idx:idx+chunkLength]
    idx += chunkLength
  return chunkLengthList

sample_items = [0, 1, 2, 3, 4, 5, 6, 7, 8 ,9, 10] 
print splitList(sample_items, 4)
