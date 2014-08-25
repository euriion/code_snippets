# -*- coding:utf-8 -*-
from lxml import etree
# doc = html_response.body_as_unicode()
doc = "<html><head></head><body>한글</body></html>"
parser = etree.HTMLParser(encoding='utf-8')
tree = etree.fromstring(doc, parser)