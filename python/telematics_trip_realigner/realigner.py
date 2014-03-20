__author__ = 'Aiden'
import unittest

class Realigner(object):
  def findTripBounds(self, ReferenceDatetimeList, startDatetimeList, stopDatetimeList):
    pass

  def realignDatetimePairList(self, leftDatetimeList, rightDatetimeList):
    return leftDatetimeList, rightDatetimeList

class RealignerTestCase(unittest.TestCase):
  def setUp(self):
    self.realigner = Realigner()

  def tearDown(self):
    del self.realigner

  def test_realignDatetimePairList(self):
    leftDatetimeList = [
      "2013-06-01 01:01:01",
      "2013-06-01 02:01:01",
      "2013-06-01 03:01:01",
      "2013-06-01 04:01:01",
      "2013-06-01 05:01:01",
    ]
    rightDatetimeList = [
      "2013-06-01 01:11:01",
      "2013-06-01 02:11:01",
      "2013-06-01 03:11:01",
      "2013-06-01 04:11:01",
      "2013-06-01 05:11:01",
    ]

    result = self.realigner.realignDatetimePairList(leftDatetimeList, rightDatetimeList)
    self.assertEqual(result[0], leftDatetimeList)
    self.assertEqual(result[1], rightDatetimeList)

    leftDatetimeList = [
      "2013-06-01 01:01:01",
      "2013-06-01 02:01:01",
      "2013-06-01 03:01:01",
      "2013-06-01 04:01:01",
      "2013-06-01 05:01:01",
    ]
    rightDatetimeList = [
      "2013-06-01 02:11:01",
      "2013-06-01 03:11:01",
      "2013-06-01 04:11:01",
      "2013-06-01 05:11:01",
    ]

    result = self.realigner.realignDatetimePairList(leftDatetimeList, rightDatetimeList)
    self.assertEqual(result[0], leftDatetimeList)
    self.assertEqual(result[1], rightDatetimeList)


def main():
  realigner = Realigner()
  del realigner

def test():
  testSuite = unittest.TestLoader().LoadTestsFromTestCase(RealignerTestCase)
  unittest.TextTestRunner(verbosity=2).run(testSuite)

if __name__ == '__main__':
  # test()
  main()