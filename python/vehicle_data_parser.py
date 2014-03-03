#!/usr/bin/python
# -*- coding: utf-8; mode: bash; tab-width: 2; indent-tabs-mode: nil; c-basic-offset: 2 -*-
import sys
import os
import re
import struct
import binascii
import datetime
import copy
from multiprocessing import Process, Queue, Pool

class VCRMParser(object):
  """ HKMC telematics parser class
  """
  fdList = {}
  chunkSeq = None
  patternFilename = re.compile("(LOCATION|USAGE|START|MPG|STOP|SPEED|TEMPERATURE)[.]txt")

  def convertHexstrToValue(self, format, HexString):
    """ Converting Hexadeciaml String to Packed data
    """
    unpacked = struct.unpack(format, binascii.unhexlify(HexString))
    if len(unpacked) == 0:
      return(None)
    else:
      return unpacked[0]

  def extractDatetimeFromHeader(self, data):
    """ Extracting datetime part from header
    """
    if len(data) < 14:
      return ""
    else:
      year   = ''.join(reversed(data[6:8]))
      month  = ''.join(reversed(data[2:4]))
      day    = ''.join(reversed(data[4:6]))
      hour   = ''.join(reversed(data[8:10]))
      minute = ''.join(reversed(data[10:12]))
      second = ''.join(reversed(data[12:14]))
      datetimeString = "20%s%s%s%s%s%s" % (year, month, day, hour, minute, second)
      return (datetimeString)
      # -- Standard way
      # splitMonthLow   = self.convertHexstrToValue('>H', chunkData[2])
      # splitMonthHigh  = self.convertHexstrToValue('>H', chunkData[3])
      # splitMonth      = splitMonthLow + (splitMonthHigh * 10)
      # splitDayLow     = self.convertHexstrToValue('>H', chunkData[4])
      # splitDayHigh    = self.convertHexstrToValue('>H', chunkData[5])
      # splitDay        = splitDayLow + (splitDayHigh * 10)
      # splitYearLow    = self.convertHexstrToValue('>H', chunkData[6])
      # splitYearHigh   = self.convertHexstrToValue('>H', chunkData[7])
      # splitYear       = splitYearLow + (splitYearHigh * 10) + 2000
      # splitHourLow    = self.convertHexstrToValue('>H', chunkData[8])
      # splitHourHigh   = self.convertHexstrToValue('>H', chunkData[9])
      # splitHour       = splitHourLow + (splitMonthHigh * 10)
      # splitMinuteLow  = self.convertHexstrToValue('>H', chunkData[10])
      # splitMinuteHigh = self.convertHexstrToValue('>H', chunkData[11])
      # splitMinute     = splitMinuteLow + (splitMonthHigh * 10)
      # splitSecondLow  = self.convertHexstrToValue('>H', chunkData[12])
      # splitSecondHigh = self.convertHexstrToValue('>H', chunkData[13])
      # splitSecond     = splitSecondLow + (splitMonthHigh * 10)
      # return ("20%02d%02d%02d%02d%02d%02d" % (splitYear, splitMonth, splitDay, splitHour, splitMinute, splitSecond))

  def parseDatafileStart(self, inputFilename, tripData):
    """ parsing START.txt
    """
    rawData = open(inputFilename).read()
    dataType = '00'
    blockSize = 13*2
    modResult = len(rawData) % 13*2
    if modResult != 0:
      return None
    else:
      if not tripData['group'].has_key('START'):  # initializing
        tripData['group']['START'] = []
      for i in range(0, len(rawData), blockSize):
        chunkData = rawData[i:i+blockSize]
        splitStart = chunkData[0:2]
        if splitStart != dataType:
          continue
        splitDatetimeStr = self.extractDatetimeFromHeader(chunkData)
        splitOdometer = int(self.convertHexstrToValue('>i', chunkData[14:22]))
        splitSeatbelt = chunkData[22:24]
        # seatbeltMap = {
        #   "03":"Driver and passenger locked",
        #   "00":"No Seat Belts",
        #   "02":"Driver",
        #   "01":"Passenger",
        #   "0F":"Not reported"
        # }
        splitTirePressure= chunkData[24:26]
        # tirePressureMap = {
        #   "00":"No warning",
        #   "10":"Warning",
        #   "F0":"Not Reported",
        #   "30":"FL",
        #   "40":"FR",
        #   "50":"RL",
        #   "60":"RR"
        # }
        recordData = [splitDatetimeStr,
                      splitOdometer,
                      splitSeatbelt,
                      splitTirePressure]
        tripData['group']['START'].append(recordData)

  def getChunkLengthList(self, data, typeCode, headerLength, subRecordCountFieldStart, subRecordCountFieldLength, subRecordLength):
    """ Getting physical chung lengths
    """
    chunkPositions = []
    dataLength = len(data)
    headerLength = headerLength * 2
    subRecordCountFieldStart = subRecordCountFieldStart * 2
    subRecordCountFieldLength = subRecordCountFieldLength * 2
    subRecordLength = subRecordLength * 2
    startPosition = 0
    idx = 0
    while True:
      idx += 1
      header = data[startPosition:startPosition+headerLength]
      if header[0:2] != typeCode:
        print("Invalid header. datatype is not matched with header of data! chung idx(%d). %s != %s" % (idx, header[0:2], typeCode))
        break
      subRecordCountRaw = header[subRecordCountFieldStart:subRecordCountFieldStart+subRecordCountFieldLength]
      subRecordCount = self.convertHexstrToValue(">H", subRecordCountRaw)
      newStartPosition = startPosition + headerLength + (subRecordCount * subRecordLength)
      chunkPositions.append((startPosition, newStartPosition))
      startPosition = newStartPosition
      if (startPosition+1) > dataLength:
        break
    if (startPosition) != dataLength:
      print("Critical!!! remaining data chunkg exist. %d:%d" % (startPosition, dataLength))
      return([])
    else:
      return(chunkPositions)

  def parseDatafileLocation(self, inputFilename, tripData):
    """ Parsing LOCATION.txt
    """
    rawData = open(inputFilename).read()
    dataType = '01'
    headerLength = 10
    subRecordCountPosition = 8
    subRecordCountLength = 2
    subRecordLength = 8
    chunkPositions = self.getChunkLengthList(rawData, dataType, 10, 8, 2, 8)
    if chunkPositions == []:
      print("no chunks")
    if not tripData['group'].has_key("LOCATION"):
      tripData['group']['LOCATION'] = {'tree':[], 'flat':[]}
    for chunkPosition in chunkPositions:
      chunkData = rawData[chunkPosition[0]:chunkPosition[1]]
      splitDatetimeStr = self.extractDatetimeFromHeader(chunkData)
      splitTimeInterval = self.convertHexstrToValue(">B", chunkData[14:16])
      splitLongLatChunk = chunkData[headerLength*2:]
      baseDatetime = None
      invalidBasedatetime = False
      try:
        baseDatetime = datetime.datetime.strptime(splitDatetimeStr, '%Y%m%d%H%M%S')
      except:
        invalidBasedatetime = True
        baseDatetime = datetime.datetime.strptime("20000101000000", '%Y%m%d%H%M%S')
      baseTimedelta = datetime.timedelta(seconds=splitTimeInterval)
      subRecords = []
      for i in range(0, len(splitLongLatChunk), subRecordLength*2):
        subRecordRawChunk = splitLongLatChunk[i:i+subRecordLength*2]
        latitudeRaw = subRecordRawChunk[0:subRecordLength*2/2]
        longitudeRaw = subRecordRawChunk[subRecordLength*2/2:subRecordLength*2]
        latitude = struct.unpack(">i", binascii.unhexlify(latitudeRaw))[0]  # MiliArc seconds
        longitude = struct.unpack(">i", binascii.unhexlify(longitudeRaw))[0]  # MiliArc seconds
        latitudeDegree = float(latitude) / float(3600000)
        longitudeDegree = float(longitude) / float(3600000)
        recordData = [baseDatetime.strftime("%Y%m%d%H%M%S"), latitude, longitude, latitudeDegree, longitudeDegree]
        subRecords.append(recordData)
        tripData['group']['LOCATION']['flat'].append(copy.copy(recordData))
        baseDatetime = baseDatetime + baseTimedelta
        # Example: The decimal value of 118519619 milliarc seconds would be sent as 0x07107743.  Longitude in milliarc seconds.
        # Example: The decimal value of -349254148 milliarc seconds would be sent as 0xEB2ECDFC.  Signed INT
      tripData['group']['LOCATION']['tree'].append({'datetime':splitDatetimeStr, 'timeinterval':splitTimeInterval, 'subrecords':subRecords})

  def parseDatafileSpeed(self, inputFilename, tripData):
    """ Parsing SPEED.txt
    """
    rawData = open(inputFilename).read()
    dataType = '02'
    headerLength = 10
    subRecordCountPosition = 8
    subRecordCountLength = 2
    subRecordLength = 2
    chunkPositions = self.getChunkLengthList(rawData, dataType, headerLength, subRecordCountPosition, subRecordCountLength, subRecordLength)
    if chunkPositions == []:
      print("no chunks")
    if not tripData['group'].has_key('SPEED'):
      tripData['group']['SPEED'] = {'tree':[], 'flat':[]}
    else:
      print "FATAL! SPEED data are already parsed!"
      sys.exit(1)
    for chunkPosition in chunkPositions:
      chunkData = rawData[chunkPosition[0]:chunkPosition[1]]
      splitDatetimeStr = self.extractDatetimeFromHeader(chunkData)
      splitTimeInterval = self.convertHexstrToValue(">B", chunkData[14:16])
      baseDatetime = None
      try:
        baseDatetime = datetime.datetime.strptime(splitDatetimeStr, '%Y%m%d%H%M%S')
      except:
        continue
      baseTimedelta = datetime.timedelta(seconds=splitTimeInterval)
      splitLongLatChunk = chunkData[headerLength*2:]
      subRecords = []
      for i in range(0, len(splitLongLatChunk), subRecordLength*2):
        subRecordRawChunk = splitLongLatChunk[i:i+subRecordLength*2]
        speed = float(self.convertHexstrToValue(">H", subRecordRawChunk)) / 10
        newRecord = [baseDatetime.strftime("%Y%m%d%H%M%S"), speed]
        subRecords.append(newRecord)
        tripData['group']['SPEED']['flat'].append(copy.copy(newRecord))
        baseDatetime = baseDatetime + baseTimedelta
      tripData['group']['SPEED']['tree'].append({'datetime':splitDatetimeStr, 'timeinterval':splitTimeInterval, 'subrecords':subRecords})

  def parseDatafileMpg(self, inputFilename, tripData):
    """ Parsing MPG.txt
    """
    rawData = open(inputFilename).read()
    dataType = '07'
    headerLength = 10
    subRecordCountPosition = 8
    subRecordCountLength = 2
    subRecordLength = 2
    chunkPositions = self.getChunkLengthList(rawData, dataType, headerLength, subRecordCountPosition, subRecordCountLength, subRecordLength)
    if chunkPositions == []:
      print("no chunks")
    if not tripData['group'].has_key('MPG'):
      tripData['group']['MPG'] = {'tree':[], 'flat':[]}
    for chunkPosition in chunkPositions:
      chunkData = rawData[chunkPosition[0]:chunkPosition[1]]
      splitDatetimeStr = self.extractDatetimeFromHeader(chunkData)
      splitTimeInterval = self.convertHexstrToValue(">B", chunkData[14:16])
      baseDatetime = None
      try:
        baseDatetime = datetime.datetime.strptime(splitDatetimeStr, '%Y%m%d%H%M%S')
      except:
        continue
      baseTimedelta = datetime.timedelta(seconds=splitTimeInterval)
      splitSubRecordChunk = chunkData[headerLength*2:]
      subRecords = []
      for i in range(0, len(splitSubRecordChunk), subRecordLength*2):
        subRecordRawChunk = splitSubRecordChunk[i:i+subRecordLength*2]
        mpg = float(self.convertHexstrToValue(">H", subRecordRawChunk)) / 10
        newRecord = [baseDatetime.strftime("%Y%m%d%H%M%S"), mpg]
        subRecords.append(newRecord)
        tripData['group']['MPG']['flat'].append(copy.copy(newRecord))
        baseDatetime = baseDatetime + baseTimedelta
      tripData['group']['MPG']['tree'].append({'datetime':splitDatetimeStr, 'timeinterval':splitTimeInterval, 'subrecords':subRecords})

  def parseDatafileTemperature(self, inputFilename, tripData):
    """ Parsing TEMPERATURE.txt
    """
    rawData = open(inputFilename).read()
    dataType = '08'
    blockSize = 11
    blockSizeReal = blockSize*2
    modResult = len(rawData) % blockSizeReal
    if modResult != 0:
      print "Broken data file\t%s" % inputFilename
      print "%d / %d" % (blockSize, len(rawData))
      return None
    else:
      if not tripData['group'].has_key('TEMPERATURE'):
        tripData['group']['TEMPERATURE'] = []
      for i in range(0, len(rawData), blockSizeReal):
        chunkData = rawData[i:i+blockSizeReal]
        splitDataType      = chunkData[0:2]
        if splitDataType != dataType:
          continue
        splitDatetimeStr = self.extractDatetimeFromHeader(chunkData)
        splitTimeInterval = self.convertHexstrToValue(">B", chunkData[14:16])
        baseDatetime = None
        try:
          baseDatetime = datetime.datetime.strptime(splitDatetimeStr, '%Y%m%d%H%M%S')
        except:
          continue
        baseTimedelta = datetime.timedelta(seconds=splitTimeInterval)
        splitInsideTemperature = r'\N'
        splitOutsideTemperature = r'\N'
        splitInsideTemperatureRaw = chunkData[14:18]
        splitOutsideTemperatureRaw = chunkData[18:22]
        if splitInsideTemperatureRaw != "FFFF":
          splitInsideTemperature = "%0.2f" % (float(self.convertHexstrToValue(">H", splitInsideTemperatureRaw)) / 10)
        if splitOutsideTemperatureRaw != "FFFF":
          splitOutsideTemperature = "%0.2f" % (float(self.convertHexstrToValue(">H", splitOutsideTemperatureRaw)) / 10)
        newRecord = [baseDatetime.strftime("%Y%m%d%H%M%S"), splitInsideTemperature, splitOutsideTemperature]
        tripData['group']['TEMPERATURE'].append(newRecord)
        baseDatetime = baseDatetime + baseTimedelta


  def parseDatafileUsage(self, inputFilename, tripData):
    """ Parsing USAGE.txt
    """
    rawData = open(inputFilename).read()
    dataTypes = ('09', '0A', '0B', '0E')
    blockSize = 9
    blockSizeReal = blockSize*2
    modResult = len(rawData) % blockSizeReal
    if modResult != 0:
      print "Broken data file\t%s" % inputFilename
      print "%d / %d" % (blockSize, len(rawData))
      return None
    else:
      if not tripData['group'].has_key('USAGE'):
        tripData['group']['USAGE'] = []
      for i in range(0, len(rawData), blockSizeReal):
        chunkData = rawData[i:i+blockSizeReal]
        splitDataType      = chunkData[0:2]
        if not splitDataType in dataTypes:
          continue
        splitDatetimeStr = self.extractDatetimeFromHeader(chunkData)
        splitTimeInterval = self.convertHexstrToValue(">B", chunkData[14:16])
        baseDatetime = None
        try:
          baseDatetime = datetime.datetime.strptime(splitDatetimeStr, '%Y%m%d%H%M%S')
        except:
          continue
        baseTimedelta = datetime.timedelta(seconds=splitTimeInterval)
        splitOnOff = self.convertHexstrToValue(">B", chunkData[14:16])
        splitFanSetting = self.convertHexstrToValue(">B", chunkData[16:18])
        newRecord = [baseDatetime, splitDataType, str(splitOnOff)]
        tripData['group']['USAGE'].append(newRecord)
        baseDatetime = baseDatetime + baseTimedelta


  def parseDatafileStop(self, inputFilename, tripData):
    """ Parsing STOP.txt
    """
    rawData = open(inputFilename).read()
    dataType = '03'
    blockSize = 17
    blockSizeReal = blockSize*2
    # modResult = len(rawData) % blockSizeReal
    # if modResult != 0:
    #   print "Broken data file\t%s" % inputFilename
    #   print "blockSize: %d, rawData size: %d" % (blockSize, len(rawData))
    #   return None
    # else:
    # print "Processing filename: %s" % inputFilename
    # print "Total embedded record count: %d" % (len(rawData) / blockSizeReal)
    if not tripData['group'].has_key('STOP'):
      tripData['group']['STOP'] = []
    idx = 1
    for i in range(0, len(rawData), blockSizeReal):
      idx += 1
      if len(rawData[i:]) < blockSizeReal:
        print "Critical! broken data STOP. len(rawData[i:]):%d / blockSizeRea:%d " % (len(rawData[i:]), blockSizeReal)
        # print rawData
        # sys.exit(1)
        break
      chunkData = rawData[i:i+blockSizeReal]
      splitDataType   = chunkData[0:2]
      if splitDataType != dataType:
        print "data type is mismathced %s != %s" % (splitDataType, dataType)
        continue
      splitDatetimeStr      = self.extractDatetimeFromHeader(chunkData)
      splitGasEmissions     = float(self.convertHexstrToValue(">i", '00'+chunkData[14:20])) / 10  # shoudl be 4 bytes for >i
      splitEcoScoreWhite    = int(self.convertHexstrToValue(">B", chunkData[20:22]))
      splitEcoScoreYellow   = int(self.convertHexstrToValue(">B", chunkData[22:24]))
      splitEcoScoreGreen    = int(self.convertHexstrToValue(">B", chunkData[24:26]))
      splitFuelConsumption  = int(self.convertHexstrToValue(">i", chunkData[26:34]))
      recordData = [splitDatetimeStr,
                    splitGasEmissions,
                    splitEcoScoreWhite,
                    splitEcoScoreYellow,
                    splitEcoScoreGreen,
                    splitFuelConsumption]
      tripData['group']['STOP'].append(recordData)

  def findTripId(self, tripDatetimeBounds, sourceDatetime):
    """ Finding TripId in list of start datetime and end datetime
    """
    for bound in tripDatetimeBounds:
      if sourceDatetime >= bound[0] and sourceDatetime <= bound[1]:
        return "%s-%s" % (bound[0], bound[1])
    return None

  def generateFeedFiles(self, tripData, outputBaseDir):
    tripIdList = []
    idx = 0
    fdOutput = self.fdList['master']
    for startItem in tripData['group']['START']:
      startDatetime = startItem[0]
      stopItem = tripData['group']['STOP'][idx]
      stopDatetime = stopItem[0]
      tripId = "%s-%s" % (startDatetime, stopDatetime)
      vin = tripData['vin']
      turnOn = startDatetime
      turnOff = stopDatetime
      accuMileages = startItem[1]
      drivingTime = None
      try:
        drivingTime = (datetime.datetime.strptime(stopDatetime, "%Y%m%d%H%M%S") - datetime.datetime.strptime(startDatetime, "%Y%m%d%H%M%S")).seconds
      except:
        drivingTime = r"\N"
      seltBelt        = startItem[2]
      tirePresure     = startItem[3]
      fuelConsumption = stopItem[2]
      co2Emission     = stopItem[1]
      ecoWhite        = stopItem[2]
      ecoYellow       = stopItem[3]
      ecoGreen        = stopItem[4]
      tripMasterRecord = "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%f\t%s\t%s\t%s\n" % (vin,
          tripId,
          turnOn,
          turnOff,
          accuMileages,
          drivingTime,
          seltBelt,
          tirePresure,
          fuelConsumption,
          co2Emission,
          ecoWhite,
          ecoYellow,
          ecoGreen)
      fdOutput.write("%s" % tripMasterRecord)
      idx += 1
    # Temperature
    fdOutput = self.fdList['temperature']
    idx = 0
    for recordItem in tripData['group']['TEMPERATURE']:
      tripId = self.findTripId(tripData['tripbounds'], recordItem[0])
      if tripId is None:
        continue
      else:
        idx += 1
        rawRecord = "%s\t%s\t%d\t%s\t%s\t%s\n" % (vin, tripId, idx, recordItem[0], str(recordItem[1]), str(recordItem[2]))
      fdOutput.write(rawRecord)
    # Usage
    fdOutput = self.fdList['usage']
    idx = 0
    for recordItem in tripData['group']['USAGE']:
      tripId = self.findTripId(tripData['tripbounds'], datetime.datetime.strftime(recordItem[0], "%Y%m%d%H%M%S"))
      if tripId is None:
        continue
      else:
        idx += 1
        rawRecord = "%s\t%s\t%s\t%s\t%s\t%s\n" % (vin, tripId, idx, datetime.datetime.strftime(recordItem[0], "%Y%m%d%H%M%S"), recordItem[1], recordItem[2])
      fdOutput.write(rawRecord)
    # Location (GPS)
    fdOutput = self.fdList['gps']
    idx = 0
    for recordItem in tripData['group']['LOCATION']['flat']:
      datetimeStr = recordItem[0]
      tripId = self.findTripId(tripData['tripbounds'], datetimeStr)
      if tripId is None:
        continue
      else:
        idx += 1
        # vin, tripId, idx, latitude, longitude, latitudeDegree, longitudeDegree
        latitude, longitude, latitudeDegree, longitudeDegree = recordItem[1:]
        rawRecord = "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n" % (vin, tripId, idx, datetimeStr, latitude, longitude, latitudeDegree, longitudeDegree)
      fdOutput.write(rawRecord)
    # MPG
    fdOutput = self.fdList['mpg']
    idx = 0
    for recordItem in tripData['group']['MPG']['flat']:
      tripId = self.findTripId(tripData['tripbounds'], recordItem[0])
      if tripId is None:
        continue
      else:
        idx += 1
        kpl = 0.425 * float(recordItem[1])
        rawRecord = "%s\t%s\t%d\t%s\t%f\n" % (vin, tripId, idx, recordItem[0], kpl)
      fdOutput.write(rawRecord)
    # SPEED
    fdOutput = self.fdList['speed']
    idx = 0
    previousSpeed = float(0)
    accumTravel = float(0)
    for recordItem in tripData['group']['SPEED']['flat']:
      tripId = self.findTripId(tripData['tripbounds'], recordItem[0])
      if tripId is None:
        continue
      else:
        datetimeStr = recordItem[0]
        acceleration = 0  # acceleration speed
        travel = 0
        averageTravel = 0
        currentSpeed = float(recordItem[1])
        if idx != 0:
          acceleration = currentSpeed - previousSpeed  # km/hsec (formula: v1 - v0 / t)
          travel = abs(float(acceleration) / 2)  # (formula: v0*t + (1/2(a*t^2)))
          accumTravel += travel
          averageTravel = float(accumTravel) / float(idx)
          previousSpeed = currentSpeed
        rawRecord = "%s\t%s\t%s\t%s\t%0.2f\t%0.2f\t%0.2f\t%0.2f\n" % (vin, tripId, idx, datetimeStr, currentSpeed, acceleration, travel, averageTravel)
        idx += 1
      fdOutput.write(rawRecord)

  @property
  def outputDir(self):
    return self.outputBaseDir

  @outputDir.setter
  def outputDir(self, value):
    if not os.path.exists(value):
      os.makedirs(value, '755')
    self.outputBaseDir = value

  def clearOutputDir(self):
    filenameList = (
      "vcrm_tm_master.%04d.tsv" % self.chunkSeq,
      "vcrm_tm_speed.%04d.tsv" % self.chunkSeq,
      "vcrm_tm_mpg.%04d.tsv" % self.chunkSeq,
      "vcrm_tm_gps.%04d.tsv" % self.chunkSeq,
      "vcrm_tm_temperature.%04d.tsv" % self.chunkSeq,
      "vcrm_tm_usage.%04d.tsv" % self.chunkSeq,
    )
    for filename in filenameList:
      filenameFullpath = "%s/%s" % (self.outputDir, filename)
      if os.path.exists(filenameFullpath):
        os.unlink(filenameFullpath)

  def openFileDescriptors(self):
    fd = open("%s/vcrm_tm_master.%04d.tsv" % (self.outputDir, self.chunkSeq), 'w')
    self.fdList['master'] = fd
    fd = open("%s/vcrm_tm_speed.%04d.tsv" % (self.outputDir, self.chunkSeq), 'w')
    self.fdList['speed'] = fd
    fd = open("%s/vcrm_tm_mpg.%04d.tsv" % (self.outputDir, self.chunkSeq), 'w')
    self.fdList['mpg'] = fd
    fd = open("%s/vcrm_tm_gps.%04d.tsv" % (self.outputDir, self.chunkSeq), 'w')
    self.fdList['gps'] = fd
    fd = open("%s/vcrm_tm_temperature.%04d.tsv" % (self.outputDir, self.chunkSeq), 'w')
    self.fdList['temperature'] = fd
    fd = open("%s/vcrm_tm_usage.%04d.tsv" % (self.outputDir, self.chunkSeq), 'w')
    self.fdList['usage'] = fd

  def cloeFileDescriptors(self):
    for key, fd in self.fdList.items():
      fd.close()

  def makeFeed(self, inputFilename, chunkSeq):
    aggrVin = {}
    aggrLogDate = {}
    aggrFeed = {"count": 0}
    feedDirList = open(inputFilename).read().split("\n")
    for inputLeafDir in feedDirList:
      # print "Directory name: %s" % (inputLeafDir)
      subDirParts = inputLeafDir.split('/')[-1].split('_')
      aggrFeed['count'] += 1
      header, vin, logDatetime = subDirParts[0:3]  # parse main column information
      fileAvailabilityCheckList = {
        "START": False,
        "STOP": False,
        "SPEED": False,
        "MPG": False,
        "LOCATION": False,
        "TEMPERATURE": False,
        "USAGE": False
      }
      tripData = {
        'vin': vin,
        'logdatetime': logDatetime,
        'header': header,
        'group': {}
      }
      skipDirectory = False
      for fileType in fileAvailabilityCheckList.keys():
        #filenameFullpath = "%s/%s/%s.txt" % (inputBaseDir, subDir, fileType)
        filenameFullpath = "%s/%s.txt" % (inputLeafDir, fileType)
        if os.path.exists(filenameFullpath) and os.path.isfile(filenameFullpath) and (os.path.getsize(filenameFullpath) > 0):
          fileAvailabilityCheckList[fileType] = True
        else:
          skipDirectory = True
          break
        if fileType == "START":
          self.parseDatafileStart(filenameFullpath, tripData)  # will make tripData['details']['START']
        elif fileType == "LOCATION":
          self.parseDatafileLocation(filenameFullpath, tripData)
        elif fileType == "USAGE":
          self.parseDatafileUsage(filenameFullpath, tripData)
        elif fileType == "MPG":
          self.parseDatafileMpg(filenameFullpath, tripData)
        elif fileType == "STOP":
          self.parseDatafileStop(filenameFullpath, tripData)
        elif fileType == "SPEED":
          self.parseDatafileSpeed(filenameFullpath, tripData)
        elif fileType == "TEMPERATURE":
          self.parseDatafileTemperature(filenameFullpath, tripData)
      if skipDirectory == True:
        continue
      print "START length: %d" % len(tripData['group']['START']),
      print "STOP length: %d" % len(tripData['group']['STOP']),
      print "LOCATION length: %d" % len(tripData['group']['LOCATION']),
      print "TEMPERATURE length: %d" % len(tripData['group']['TEMPERATURE']),
      print "SPEED length: %d" % len(tripData['group']['SPEED']['tree']),
      print "MPG length: %d" % len(tripData['group']['MPG']),
      print "USAGE length: %d" % len(tripData['group']['USAGE'])
      # -- post processing
      # ---- removing invalid stop
      # -- 20000000000000 problem
      speedDatetimeList = []
      for speedItem in tripData['group']['SPEED']['flat']:
        speedDatetimeList.append(copy.copy(speedItem[0]))
      startDatetimeList = []
      for startItem in tripData['group']['START']:
        startDatetimeList.append(copy.copy(startItem[0]))
      stopDatetimeList = []
      for stopItem in tripData['group']['STOP']:
        stopDatetimeList.append(copy.copy(stopItem[0]))
      def findDatetimeFromSpeed(speedDatetimeList, baseDatetimeBegin, baseDatetimeEnd, condition="first_start_stop"):
        foundList = []
        if condition == "first_start_stop":
          for speedDatetime in speedDatetimeList:
            if speedDatetime < baseDatetimeBegin:
              foundList.append(speedDatetime)
          if len(foundList) == 0:
            return (None, None)
          else:
            return(min(foundList), max(foundList))
        elif condition == "middle_start_stop":
          for speedDatetime in speedDatetimeList:
            if speedDatetime > baseDatetimeBegin and speedDatetime < baseDatetimeEnd:
              foundList.append(speedDatetime)
          if len(foundList) == 0:
            return (None, None)
          else:
            return(min(foundList), max(foundList))
        elif condition == "last_start_stop":
          for speedDatetime in speedDatetimeList:
            if speedDatetime > baseDatetimeEnd:
              foundList.append(speedDatetime)
          if len(foundList) == 0:
            return (None, None)
          else:
            return(min(foundList), max(foundList))
        elif condition == "one_start_stop":
          if len(speedDatetimeList) == 0:
            return (None, None)
          else:
            return (min(speedDatetimeList), max(speedDatetimeList))
        elif condition == "middle_start":
          for speedDatetime in speedDatetimeList:
            if speedDatetime > baseDatetimeBegin and speedDatetime < baseDatetimeEnd:
              foundList.append(speedDatetime)
          if len(foundList) == 0:
            return (None, None)
          else:
            return max(foundList)
        elif condition == "middle_stop":
          for speedDatetime in speedDatetimeList:
            if speedDatetime > baseDatetimeBegin and speedDatetime < baseDatetimeEnd:
              foundList.append(speedDatetime)
          if len(foundList) == 0:
            return (None, None)
          else:
            return max(foundList)
        elif condition == "last_stop":
          for speedDatetime in speedDatetimeList:
            if speedDatetime > baseDatetimeBegin:
              foundList.append(speedDatetime)
          if len(foundList) == 0:
            return None
          else:
            return max(foundList)
        elif condition == "first_start":
          for speedDatetime in speedDatetimeList:
            if speedDatetime < baseDatetimeEnd:
              foundList.append(speedDatetime)
          if len(foundList) == 0:
            return None
          else:
            return min(foundList)
        # if condition == "first_start":
        #   if speedDatetimeList[0] < baseDatetimeStop:
        #     return speedDatetimeList[0]
        #   else:
        #     return None
        # elif condition == "last_stop":
        #   if speedDatetimeList[-1] > baseDatetimeStart:
        #     return speedDatetimeList[-1]
        #   else:
        #     return None
        # elif condition == "middle_start"  # for 000000000000 start
        #   foundList = []
        #   for speedDatetime in speedDatetimeList:
        #     if speedDatetime < baseDatetimeStart and speedDatetime > baseDatetimeStop:
        #       foundList.append(speedDatetime)
        #   if foundList == []:
        #     return None
        #   else:
        #     return min(foundList)
        # elif condition == "middle_stop"  # for 000000000000 stop
        #   foundList = []
        #   for speedDatetime in speedDatetimeList:
        #     if speedDatetime < baseDatetimeStart and speedDatetime > baseDatetimeStop:
        #       foundList.append(speedDatetime)
        #   if foundList == []:
        #     return None
        #   else:
        #     return max(foundList)
        # else:
        #   print "Invalid condition to find datetime in SPEED"
        #   return None
      # if len(tripData['group']['START']) != len(tripData['group']['STOP']):
      #   print "START:STOP length mismatched = %d:%d" % (len(tripData['group']['START']), len(tripData['group']['STOP']))
      #   print "CRITICAL"
        # open("%s/start_stop_mistached.txt" % self.outputDir, 'a+').write("%s\t%d\t%d" % (self.outputDir, len(tripData['group']['START']), len(tripData['group']['STOP'])))
      startInvalidDateIndices = []
      stopInvalidDateIndices = []
      if len(speedDatetimeList) == 0:  # if SPEED data is not available then can't revise the TRIP periods
        print "FATAL SPEED data are not available"
      else:
        if len(startDatetimeList) == len(stopDatetimeList):
          tripDatetimeList = zip(startDatetimeList, stopDatetimeList)
          idx = 0
          for tripDatetimeItem in tripDatetimeList:
            if tripDatetimeItem[0] == '20000000000000' and tripDatetimeItem[1] == '20000000000000':
              if idx == 0 and len(tripDatetimeList) == 1:  # one
                result = findDatetimeFromSpeed(speedDatetimeList, None, None, 'one_start_stop')
              elif idx == 0:  # first
                nextStartDatetime = tripDatetimeList[idx+1][0]
                nextStopDatetime = tripDatetimeList[idx+1][1]
                result = findDatetimeFromSpeed(speedDatetimeList, nextStartDatetime, nextStopDatetime, 'first_start_stop')
                startDatetimeList[idx] = result[0]
                stopDatetimeList[idx] = result[1]
              elif idx == (len(tripDatetimeList) - 1):  # last
                prevStartDatetime = tripDatetimeList[idx-1][0]
                prevStopDatetime = tripDatetimeList[idx-1][1]
                result = findDatetimeFromSpeed(speedDatetimeList, prevStartDatetime, prevStopDatetime, 'last_start_stop')
                startDatetimeList[idx] = result[0]
                stopDatetimeList[idx] = result[1]
              else:  # middle
                prevStopDatetime = tripDatetimeList[idx-1][1]
                nextStartDatetime = tripDatetimeList[idx+1][0]
                result = findDatetimeFromSpeed(speedDatetimeList, prevStopDatetime, nextStartDatetime, 'middle_start_stop')
                startDatetimeList[idx] = result[0]
                stopDatetimeList[idx] = result[1]
            elif tripDatetimeItem[0] == '20000000000000' and tripDatetimeItem[1] != '20000000000000':  # getting START datetime
              if idx == 0 and len(tripDatetimeList) == 1:  # one
                result = findDatetimeFromSpeed(speedDatetimeList, None, None, 'one_start_stop')
                startDatetimeList[idx] = result[0]
              elif idx == 0:  # first
                currentStopDatetime = tripDatetimeList[idx][1]
                result = findDatetimeFromSpeed(speedDatetimeList, None, currentStopDatetime, 'first_start')
                startDatetimeList[idx] = result
              elif idx == (len(tripDatetimeList) - 1):  # last
                prevStopDatetime = tripDatetimeList[idx-1][1]
                currentStopDatetime = tripDatetimeList[idx][1]
                result = findDatetimeFromSpeed(speedDatetimeList, prevStopDatetime, currentStopDatetime, 'middle_start_stop')
                startDatetimeList[idx] = result[0]
              else:  # middle  same with 'last' condition
                prevStopDatetime = tripDatetimeList[idx-1][1]
                currentStopDatetime = tripDatetimeList[idx][1]
                result = findDatetimeFromSpeed(speedDatetimeList, prevStopDatetime, currentStopDatetime, 'middle_start_stop')
                startDatetimeList[idx] = result[0]
            elif tripDatetimeItem[0] != '20000000000000' and tripDatetimeItem[1] == '20000000000000':  # getting STOP datetime
              if idx == 0 and len(tripDatetimeList) == 1:  # one
                result = findDatetimeFromSpeed(speedDatetimeList, None, None, 'one_start_stop')
                stopDatetimeList[idx] = result[1]
              elif idx == 0:  # first
                currentStartDatetime = tripDatetimeList[idx][0]
                nextStartDatetime = tripDatetimeList[idx+1][0]
                result = findDatetimeFromSpeed(speedDatetimeList, currentStartDatetime, nextStartDatetime, 'middle_start_stop')
                stopDatetimeList[idx] = result[1]
              elif idx == (len(tripDatetimeList) - 1):  # last
                currentStartDatetime = tripDatetimeList[idx][0]
                result = findDatetimeFromSpeed(speedDatetimeList, currentStartDatetime, None, 'last_stop')
                stopDatetimeList[idx] = result
              else:  # middle  same with 'first' condition
                currentStartDatetime = tripDatetimeList[idx][0]
                nextStartDatetime  = tripDatetimeList[idx+1][0]
                result = findDatetimeFromSpeed(speedDatetimeList, currentStartDatetime, nextStartDatetime, 'middle_start_stop')
                stopDatetimeList[idx] = result[1]
            idx += 1
        else:
          print ("FATAL! TRIP - START and STOP lengthes are mismatched. %d != %d" % (len(startDatetimeList), len(stopDatetimeList)))
          continue
      deleteIndices = []
      idx = 0
      for startDatetime in startDatetimeList:
        if startDatetime is None:
          deleteIndices.append(idx)
        idx += 1
      idx = 0
      for stopDatetime in stopDatetimeList:
        if stopDatetime is None:
          deleteIndices.append(idx)
        idx += 1
      if len(deleteIndices) != 0:
        for idx in sorted(set(deleteIndices), reverse=True):
          del startDatetimeList[idx]
          del stopDatetimeList[idx]
          # real purging
          del tripData['group']['START'][idx]
          del tripData['group']['STOP'][idx]
      # making flat file for feeding to NDAP
      if len(startDatetimeList) != len(stopDatetimeList):
        continue
      tripData['tripbounds'] = zip(startDatetimeList, stopDatetimeList)
      self.generateFeedFiles(tripData, self.outputBaseDir)
      # for partition field
      logDate = logDatetime[0:8]
      logTime = logDatetime[8:14]
      # Aggregating stat
      if aggrVin.has_key(vin):
        aggrVin[vin] += 1
      else:
        aggrVin[vin] = 1
      if aggrLogDate.has_key(logDate):
        aggrLogDate[logDate] += 1
      else:
        aggrLogDate[logDate] = 1
      del tripData

def retrievingInputdirList(inputBaseDirList):
  inputDirList = []
  for inputBaseDir in inputBaseDirList:
    for dirName in os.listdir(inputBaseDir):
      dirNameFull = "/".join((inputBaseDir, dirName))
      if not os.path.isdir(dirNameFull):
        continue
      if len(dirName.split("_")) != 3:
        continue
      inputDirList.append(dirNameFull)
  return inputDirList

def balancedSplitUp(listItems, splitCount):
  baseChunkLength, remainingItemCount = divmod(len(listItems), splitCount)
  chunkLengthList = [baseChunkLength + 1] * remainingItemCount + [baseChunkLength] * (splitCount-remainingItemCount)
  idx = 0
  for i, chunkgLength in enumerate(chunkLengthList):
    print i, chunkgLength
    chunkLengthList[i] = listItems[idx:idx+chunkgLength]
    idx += chunkgLength
  return chunkLengthList

def parse(args):
  inputFilename, outputDir, chunkSeq = args[0:3]
  fd = open("%s/%04d.run" % (outputDir, chunkSeq), 'w')
  fd.write("run\n")
  fd.close()
  vcrmParser = VCRMParser()
  vcrmParser.outputDir = outputDir
  vcrmParser.chunkSeq = chunkSeq
  vcrmParser.clearOutputDir()
  vcrmParser.openFileDescriptors()
  vcrmParser.makeFeed(inputFilename, chunkSeq)
  vcrmParser.cloeFileDescriptors()
  os.unlink("%s/%04d.run" % (outputDir, chunkSeq))
  del vcrmParser
  return chunkSeq


if __name__ == "__main__":
  outputBaseDir= "/data1/vcrm_feed_output"
  inputBaseDirList = ("/data1/vcrm_data/POC01-1/ecocoach", "/data1/vcrm_data/POC01-1/home/hma_sftp/PRODUCTION/COMPLETED")
  procCount = 20
  splitCount = 200
  inputDirList = retrievingInputdirList(inputBaseDirList)
  splitFilenameGroup = balancedSplitUp(inputDirList, splitCount)
  inputFilenameList = []
  args = []
  idx = 0
  for filenameItems in splitFilenameGroup:
    idx += 1
    listFilename = "%s/inputfile_list.%04d.txt" % (outputBaseDir, idx)
    open(listFilename, 'w').write("\n".join(filenameItems))
    inputFilenameList.append(listFilename)
    outputDir = "%s/split_%04d" % (outputBaseDir, idx)
    if not os.path.exists(outputDir):
      os.mkdir(outputDir, 0755)
    args.append((listFilename, outputDir, idx))
  pool = Pool(procCount)
  pool.map(parse, args)
  pool.close()

