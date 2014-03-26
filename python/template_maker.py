__author__ = 'aiden.hong'
import re
import templatemaker

t = templatemaker.Template()

filenames = [
  'filename_20111213.log',
  'filename_20121203.log',
  'filename_20121204.log',
  'filename_20121212.log',
  'filename_20121212.log',
  'filename_20130103.log',
  'filename_20130112.log'
]

for filename in filenames:
  t.learn(filename)

pattern = re.escape(t.as_text("\001")).replace("\\\001", '(.*)')
print "pattern: %s" % pattern

compiled_pattern = re.compile(pattern)
for filename in filenames:
  sub_groups = compiled_pattern.findall(filename)
  print sub_groups

del t
t = templatemaker.Template()

log_lines = [
  '66.249.73.139 - - 26/Dec/2012:00:06:45 +0900  GET /nexrcorp_en/products_and_services/intro.php HTTP/1.1 404 319 - Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)"',
  '14.219.181.54 - - 26/Dec/2012:00:08:02 +0900  GET /nexrcorp_en/products_and_services/rhive.php&amp;sa=U&amp;ei=P8HZUI2_OOWdiAe1sIHAAg&amp;ved=0CDQQFjAJ&amp;usg=AFQjCNGWuec5RqwdFOXmHa5_adjiSZ6qeA HTTP/1.1 404 436 - Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.11 (KHTML, like Gecko) Chrome/23.0.1271.64 Safari/537.11"',
  '14.219.181.54 - - 26/Dec/2012:00:08:02 +0900  GET / HTTP/1.1  200 103 - Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.11 (KHTML, like Gecko) Chrome/23.0.1271.64 Safari/537.11"',
  '14.219.181.54 - - 26/Dec/2012:00:10:25 +0900  GET /&amp;sa=U&amp;ei=ucHZUP-6DcSQiAef14GwBw&amp;ved=0CDoQFjAMOCg&amp;usg=AFQjCNHSZJhpnZq-1zXlQgVqiuqo_PR_Iw HTTP/1.1 404 396 - Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.11 (KHTML, like Gecko) Chrome/23.0.1271.64 Safari/537.11"',
  '202.46.53.89  - - 26/Dec/2012:00:11:08 +0900  GET / HTTP/1.1  200 103 - Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.0)"',
  '119.63.193.132  - - 26/Dec/2012:00:12:20 +0900  GET / HTTP/1.1  200 103 - Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.0)"',
  '110.45.214.150  - - 26/Dec/2012:00:13:26 +0900  GET /robots.txt HTTP/1.1  404 283 http://search.daum.net/ Mozilla/5.0 (compatible; MSIE or Firefox mutant; not on Windows server; + http://tab.search.daum.net/aboutWebSearch.html) Daumoa/3.0"',
  '90.221.183.105  - - 26/Dec/2012:00:15:05 +0900  GET / HTTP/1.1  200 103 http://www.google.co.uk/search?q=nexr&hl=en&oq=nexr&gs_l=mobile-heirloom-hp.12..0i10j0l3j0i10.3288.8531.0.9893.17.10.0.0.0.2.918.3779.0j2j3j3j6-2.10.0.les%3B..0.0...1ac.1.fryVoDbcdSE  Mozilla/5.0 (compatible; MSIE 9.0; Windows Phone OS 7.5; Trident/5.0; IEMobile/9.0; HTC; 7 Mozart T8698)"',
  '90.221.183.105  - - 26/Dec/2012:00:15:05 +0900  GET /nexrcorp_en/ HTTP/1.1  200 10589 - Mozilla/5.0 (compatible; MSIE 9.0; Windows Phone OS 7.5; Trident/5.0; IEMobile/9.0; HTC; 7 Mozart T8698)"',
  '90.221.183.105  - - 26/Dec/2012:00:15:06 +0900  GET /nexrcorp_en/asset/js/publishing.js HTTP/1.1  200 1553  http://www.nexr.co.kr/nexrcorp_en/  Mozilla/5.0 (compatible; MSIE 9.0; Windows Phone OS 7.5; Trident/5.0; IEMobile/9.0; HTC; 7 Mozart T8698)"',
]

for log_line in log_lines:
  t.learn(log_line)

pattern = re.escape(t.as_text("\001")).replace("\\\001", '(.*)')
print "pattern: %s" % pattern

compiled_pattern = re.compile(pattern)
for log_line in log_lines:
  sub_groups = compiled_pattern.findall(log_line)
  print sub_groups
