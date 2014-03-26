#!/usr/bin/env python

import urllib,re

# INTL list
#P1='tw hk kr us uk ca in au nz mye sg ph'
#P2='aa fr cf chfr es e1 mx ar de ch at id'
#P3='vn br cd it chit th dk fi nl ru se no'

INTLS = {
    #'P1':['tw', 'hk', 'kr', 'us', 'uk', 'cd', 'in', 'au', 'nz', 'mye', 'sg', 'ph'],
    #'P2':['aa', 'fr', 'cf', 'chfr', 'es', 'e1', 'mx', 'ar', 'de', 'ch', 'at', 'id'],
    'P3':['vn', 'br', 'cade', 'it', 'chit', 'th', 'dk', 'fi', 'nl', 'ru', 'se', 'no']
    #'P3':['it']
}

target = 'dev.'

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

assists = {'miniassist':'YAHOO.Search.MiniAssist.init', 'assist':'YS.Srp.Assist.init', 'pref_done':'[.]search[.]yahoo[.]com/preferences/preferences[?]pref_done=http%3A%2F%2F'}
page_urls = {'SRP':"http://%s."+target+"news.search.yahoo.com/search?p=ipad", 'SFP':"http://%s."+target+"news.search.yahoo.com"}

print "Checking..."

print "Target: %s" % target_title

for PRI in sorted(INTLS.keys()):
    print "Group: %s" % PRI
    for INTL in INTLS[PRI]:
        print "\t", INTL, "\t",
        for page_key in sorted(page_urls.keys()):
            page = urllib.urlopen(page_urls[page_key] % INTL).read()
            for assist_key in assists.keys():
                print page_key,
                m = re.search(assists[assist_key], page)
                if m and len(m.group()) > 0:
                    print "%s (o)" % assist_key,
                else:
                    print "%s (x)" % assist_key,
        print ""
    break

print "done"
