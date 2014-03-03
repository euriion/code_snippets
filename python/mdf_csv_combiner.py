#!/usr/bin/python
import sys
import os

class InputCombiner:
  _inputDir = "/home/ndap/mdf/output"
  _outputDir = "/home/ndap/mdf/combined_output"
  _fileNameList = ('1_1.csv', '2_1.csv', '3_1.csv', '4_1.csv', '5_1.csv', '6_1.csv')
  _fileNameListMap = {}
  _combinedFileNamePostfix = ".combined"
  _combinedFieldNamePostfix = ".combined_fieldnames"

  def __init__(self):
    pass

  def combineFiles(self, contentFileName, fieldFilename, fileNameList):
    contentBuffer = {}
    fieldNameList =[]
    for filenameFullpath in fileNameList:
      idx = 0
      for rawLine in open(filenameFullpath):
        if idx == 0:
          contentBuffer[filenameFullpath] = {}
          fieldNames = rawLine.strip().split("\t")
          contentBuffer[filenameFullpath]['header'] = fieldNames
          fieldNameList = fieldNameList + fieldNames
          break

    fieldNameUniqueList = list(set(fieldNameList))
    fdOutput = open(fieldFilename, "w")
    fdOutput.write("\t".join(fieldNameUniqueList) + "\n")
    fdOutput.close()

    fdOutput = open(contentFileName, "w")
    lineCount = 0
    for filenameFullpath in fileNameList:
      fields = []
      fieldNames = contentBuffer[filenameFullpath]['header']
      idx = 0
      print "input csv file :%s" % filenameFullpath
      for rawLine in open(filenameFullpath):
        idx += 1
        if idx == 1:
          continue
        fields = rawLine.strip().split("\t")
        newFields = []
        for uniqueFieldName in fieldNameUniqueList:
          if uniqueFieldName in fieldNames:
            newFields.append(fields[fieldNames.index(uniqueFieldName)])
          else:
            newFields.append(r'\N')
        newLine = "\t".join(newFields)
        lineCount+=1
        if idx > 1:
          fdOutput.write(newLine + "\n")

    fdOutput.close()
    print "line count of %s: %d" % (contentFileName, lineCount)

  def getFileList(self):
    fileNameList = {}
    for dirName in os.listdir(self._inputDir):
      if not os.path.isdir(self._inputDir + "/" + dirName):
        continue
      subDir = self._inputDir + "/" + dirName
      for contentFilename in os.listdir(subDir):
        if contentFilename in self._fileNameList:
          filenameFullpath = subDir + "/" + contentFilename
          if fileNameList.has_key(contentFilename):
            fileNameList[contentFilename].append(filenameFullpath)
          else:
            fileNameList[contentFilename] = [filenameFullpath]
    return fileNameList

  def combine(self):
    fileNameListMap = self.getFileList()
    for fileNameKey in fileNameListMap.keys():
      combinedFilename = self._outputDir + "/" + fileNameKey + self._combinedFileNamePostfix
      combinedFieldname = self._outputDir + "/" + fileNameKey + self._combinedFieldNamePostfix
      print "combining files into %s" % combinedFilename
      self.combineFiles(combinedFilename, combinedFieldname, fileNameListMap[fileNameKey])

if __name__ == "__main__":
  inputCombiner = InputCombiner()
  inputCombiner.combine()

