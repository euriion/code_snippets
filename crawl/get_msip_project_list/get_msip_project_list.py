# -*- coding: utf-8 -*-

import urllib, urllib2
import BeautifulSoup
import re

url_handle = urllib.urlopen("http://www.msip.go.kr/www/brd/m_210/list.do?page=1&srchFr=&srchTo=&srchWord=&srchTp=&multi_itm_seq=0&itm_seq_1=0&itm_seq_2=0&company_cd=&company_nm=")
content = url_handle.read()
soup = BeautifulSoup.BeautifulSoup(content)
pattern = re.compile(r'( 1 / ([0-9]*) page)')
contents = soup.find('div', {'id':'search'}).find('span').contents
matches = pattern.findall(content)
page_count = 0
if len(matches) > 0 and len(matches[0]) == 2:
	page_count = matches[0][1]
print "Total page: %s" % page_count

# Getting all records
column_count = 0
output_records = []
for page in range(1, int(page_count) + 1):
	print "Scrapping page #%d" % page
	url_handle = urllib.urlopen("http://www.msip.go.kr/www/brd/m_210/list.do?page=%s&srchFr=&srchTo=&srchWord=&srchTp=&multi_itm_seq=0&itm_seq_1=0&itm_seq_2=0&company_cd=&company_nm=" % page)
	content = url_handle.read()
	# print content
	soup = BeautifulSoup.BeautifulSoup(content)
	table_records = soup.find('div', {'id':'contentArea2'}).findAll('tr')
	if page != 1:
		del table_records[0]
	output_records.extend(table_records)
	if page == 1:
		column_count = len(table_records[0].findAll('td'))

# print output_records
# Writing content into file
fd_output = open("./output.html", "w+")
fd_output.write("<table>\n")
idx = 0
for record in output_records:
	idx += 1
	#fd_output.write("\n".join(record.contents) + "\n")
	fd_output.write(str(record) + "\n")
fd_output.write("</table>\n")
fd_output.close()


