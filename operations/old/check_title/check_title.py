#!/usr/bin/env python
# -*- coding: utf-8 -*-

import urllib2,re
from pprint import *

# INTL list
#P1='tw hk kr us uk ca in au nz mye sg ph'
#P2='aa fr cf chfr es e1 mx ar de ch at id'
#P3='vn br cd it chit th dk fi nl ru se no'

INTLS = {
    'P1':['us', 'tw', 'hk', 'kr', 'uk', 'ca', 'in', 'au', 'nz', 'malaysia', 'sg', 'ph'],
    'P2':['asia', 'fr', 'qc', 'chfr', 'es', 'espanol', 'mx', 'ar', 'de', 'ch', 'at', 'id'],
    'P3':['vn', 'br', 'cade', 'it', 'chit', 'th', 'dk', 'fi', 'nl', 'ru', 'se', 'no']
    #'P3':['th']
}

#target = '' # product
target = 'dev.'
#vertical = '' # web
vertical = 'news.'

if target == 'dev.':
    target_title = 'DEV'
elif target == 'qa.':
    target_title = 'QA'
elif target == 'stage.':
    target_title = 'STAGE'
elif target == '':
    target_title = 'PRODUCT'
else:
    target_title = 'Unknown'

#assists = {'miniassist':'YAHOO.Search.MiniAssist.init', 'assist':'YS.Srp.Assist.init', 'pref_done':'[.]search[.]yahoo[.]com/preferences/preferences[?]pref_done=http%3A%2F%2F'}
#page_urls = {'SRP':"http://%s."+target+"news.search.yahoo.com/search?p=ipad", 'SFP':"http://%s."+target+"news.search.yahoo.com"}
#page_urls = {'SRP':"http://%s."+target+"news.search.yahoo.com/search?p=car"}
find_patterns = {'title':'<title>(.*)</title>'}
page_urls = {'SRP title: ':"http://%(intl)s"+target+vertical+"search.yahoo.com/search?p=car"}

print "Checking..."

print "Target: %s" % target_title

pp = PrettyPrinter(indent=4)

fd = open("./output.txt", "w")

#useragent = 'Mozilla/4.0 (compatible; MSIE 5.5; Windows NT)'

# Firefox on Ubuntu
useragent = 'Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.2.3) Gecko/20100401 Firefox/3.6.3 '
accept_charset  = 'ISO-8859-1,utf-8;q=0.7,*;q=0.7'

# IE6 on winXP
useragent = 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; .NET CLR 1.1.4322; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)'
accept_charset = ''

# Firefox on WinXP
accept_charset = 'ISO-8859-1,utf-8;q=0.7,*;q=0.7'
useragent = 'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.0.8) Gecko/2009032609 Firefox/3.0.8 (.NET CLR 3.5.30729)'


#Firefox on Macintosh accept_charset = 'ISO-8859-1,utf-8;q=0.7,*;q=0.7'
useragent = 'Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.2.8) Gecko/20100722 YFF35 Firefox/3.6.8'

#Safari on Macintosh
accept_charset = ''
useragent = 'Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_4; en-us) AppleWebKit/533.17.8 (KHTML, like Gecko) Version/5.0.1 Safari/533.17.8'

headers = { 'User-Agent' : useragent , 'Accept-charset' : accept_charset}

for PRI in sorted(INTLS.keys()):
    print "Group: %s" % PRI
    for INTL in INTLS[PRI]:
        print "\t" + INTL + "\t",
        fd.write("\t" + INTL + "\t")
        for page_key in sorted(page_urls.keys()):
            if INTL == "us":
                request_url = (page_urls[page_key]) % {'intl':''}
            else: 
                request_url = (page_urls[page_key]) % {'intl':(INTL + ".")}

            print "page: " + request_url
            req = urllib2.Request(request_url,  '', headers)
            response = urllib2.urlopen(req)
            print 'Content-type: ' + response.headers['Content-type'],
            page = response.read()

            #print urlfd.headers['content-type']
            #fd.write(page)

            for find_pattern_key in find_patterns.keys():
                print page_key,
                fd.write(page_key)
                m = re.search(find_patterns[find_pattern_key], page, re.U)
                print "["+m.group(1)+"]".encode("UTF-8"),
                fd.write( "["+m.group(1)+"]".encode("UTF-8"))
                #if m and len(m.group()) > 0:
                #    print "%s " % find_pattern_key,
                #else:
                #    print "%s " % find_pattern_key,
                break
        print ""
        fd.write("\n")

fd.close()
print "done"
