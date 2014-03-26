__author__ = 'aiden.hong'

import os
import urllib
import re
import gzip
from optparse import OptionParser

class WikipediaPVImpoter:
  website_path_prefix = "http://dumps.wikimedia.org/other/pagecounts-raw"
  base_archiving_directory = "/data/aiden.hong/feeding/wikipedia_pagecount"
  origin_filelist = []
  delimiter = "\t"
  file_format = """
  log_date,  -- dummy
  log_hour,  -- dummy
  project_name,
  title,
  request_count,
  content_size
  """
  pattern_numbers = re.compile(r'[0-9]{1,}')

  def __init__(self):
    self.pattern_extracing_filename = re.compile("<li><a href=\"(pagecounts-[0-9]{8,8}-[0-9]{6,6}[.]gz)\">")

  def get_filelist_form_webpage(self, year, month, day):
    param = {
      'local_archive_directory': self.base_archiving_directory,
      'year': year,
      'month': month,
      'day': day
    }

    page_url = "http://dumps.wikimedia.org/other/pagecounts-raw/%(year)s/%(year)s-%(month)s/" % param
    page_content = urllib.urlopen(page_url).read()
    found_result = self.pattern_extracing_filename.findall(page_content)
    for filename in found_result:
      self.origin_filelist.append(filename)

  def get_exact_filename_from_filelist(self, year, month, day, hour):
    param = {
      'year': year,
      'month': month,
      'day': day,
      'hour': hour
    }

    pattern_hour_filename = re.compile(r"pagecounts-%(year)s%(month)s%(day)s-%(hour)s[0-9]{4,4}[.]gz" % param)
    origin_filename = None
    for filename in self.origin_filelist:
      if pattern_hour_filename.match(filename):
        origin_filename = filename
        break
    return origin_filename

  def download_file(self, year, month, day, hour, remote_filename, overwrite=False):
    param = {
      'year': year,
      'month': month,
      'day': day,
      'hour': hour,
      'local_archiving_directory': self.base_archiving_directory,
      'filename_prefix': 'wikipedia-pagecounts-',
      'remote_filename': remote_filename
    }

    if not os.path.exists(param['local_archiving_directory']):
      os.makedirs(param['local_archiving_directory'])

    local_filename = "%(local_archiving_directory)s/%(filename_prefix)s%(year)s%(month)s%(day)s-%(hour)s.gz" % param
    remote_filename_url = "http://dumps.wikimedia.org/other/pagecounts-raw/%(year)s/%(year)s-%(month)s/%(remote_filename)s" % param

    if not os.path.exists(local_filename):
      print("Downloading file '%s' -> '%s'" % (remote_filename_url, local_filename))
      urllib.urlretrieve(remote_filename_url, local_filename)
    else:
      print("The file was already downloaded.")
    return local_filename

def converting(config_filename, basedate):
  wikipediapv_importer = WikipediaPVImpoter()
  year = basedate['year']
  month = basedate['month']
  day = basedate['day']
  hour = basedate['hour']

  param = {
    'year': year,
    'month': month,
    'day': day,
    'hour': hour
  }
  wikipediapv_importer.get_filelist_form_webpage(year, month, day)
  remote_filename = wikipediapv_importer.get_exact_filename_from_filelist(year, month, day, hour)
  download_filename = wikipediapv_importer.download_file(year, month, day, hour, remote_filename, overwrite=False)

  print("Uncompressing and transforming the file...")
  gz_fd = gzip.open(download_filename, 'rb')
  new_fd = open(download_filename + ".transformed", 'w')
  idx = 0

  pattern_delimiter = re.compile(''.join(('[', wikipediapv_importer.delimiter, ']')))
  pattern_newline = re.compile('[\n\r]')
  skip_count = 0

  for raw_line in gz_fd.readlines():
    line = raw_line.strip()
    fields = line.split(' ')
    if len(fields) != 4:
      skip_count += 1
      continue
    else:
      title = urllib.unquote_plus(fields[1])
      title = pattern_delimiter.sub(' ', title)
      title = pattern_newline.sub(' ', title)

      new_fields = (
        "%(year)s%(month)s%(day)s" % param,
        "%(hour)s" % param,
        fields[0],
        title,
        fields[2],
        fields[3]
      )
      new_record = wikipediapv_importer.delimiter.join(new_fields)
      new_fd.write(new_record + '\n')
    idx += 1
  new_fd.close()
  gz_fd.close()
  print("Completed")
  print("Total %d records are invalid" % skip_count)

if __name__ == '__main__':
  usage = "Usage: \n%prog -c config_filename -d datetime\n\nExam: \n%prog -c import.wikipedia_pagecount.conf.yaml -d 2012100907"
  parser = OptionParser(usage=usage)
  parser.add_option("-c", "--conf",
                    dest="config_filename",
                    help="filename of configuration")

  parser.add_option("-d", "--datetime",
                    dest="basedate",
                    help="The date which is processed data. format should be 'YYYYMMDDHH'")

  (options, args) = parser.parse_args()

  if not options.config_filename:
    parser.error("config_filename has to be provided")
  elif not os.path.exists(options.config_filename):
    parser.error("the config file '%s' does not exist" % options.config_filename)

  pattern_basedate = re.compile(r'(?P<year>[12]{1}[09]{1}[0-9]{1}[0-9]{1})(?P<month>[01]{1}[0-9]{1})(?P<day>[0-3]{1}[0-9]{1})(?P<hour>[0-2]{1}[0-9]{1})')

  if not options.basedate:
    parser.error("BASEDATE has to be provided. in most case it should be a date of yesterday as having format 'YYYYMMDD'")

  if not pattern_basedate.match(options.basedate):
    parser.error("The format of basedate '%s' is not valid" % options.basedate)

  m = pattern_basedate.search(options.basedate)
  basedate = {
    'year': m.group('year'),
    'month': m.group('month'),
    'day': m.group('day'),
    'hour': m.group('hour')
  }
  converting(options.config_filename, basedate)