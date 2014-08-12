# -*- coding: utf-8 -*-
import sys
from scrapy.spider import BaseSpider
from scrapy.http import FormRequest
from scrapy.http import HtmlResponse, XmlResponse
# from scrapy.http.request.form  import FormRequest
from scrapy.selector import XmlXPathSelector, HtmlXPathSelector
import codecs
from lxml import etree
import re
import json

class OpinetSpider(BaseSpider):
  name = 'opinet'
  user_agent = 'Mozilla/5.0 (compatible; MSIE 8.0; Windows NT 6.1; Trident/4.0; GTB7.4; InfoPath.2; SV1; .NET CLR 3.3.69573; WOW64; en-US)'
  allowed_domains = ["opinet.co.kr"]
  # start_urls = [
  #   "http://www.opinet.co.kr/chart.do?cmd=chart.list3excel"
  # ]
  url = 'http://www.opinet.co.kr/chart.do?cmd=chart.list3'

  def __init__(self):
    self.year_list = [str(x) for x in range(2012, 2013)]  
    
  def start_requests(self):
    requests = []
    for year in self.year_list:
      requests.append(FormRequest(self.url, 
        formdata={
                "start":"%s0101" % year,
                "end":"%s1231" % year,
                "prodDivCd":"B034,B027,D047,C004,C042",
                "chprice":"",
                "term":"d",
                "start_yy":year,
                "start_qq":"1",
                "start_mm":"01",
                "start_ww":"1",
                "start_dd":"01",
                "end_yy":year,
                "end_qq":"1",
                "end_mm":"12",
                "end_ww":"1",
                "end_dd":"31",
                "chkProdCd":"B034",
                "chkProdCd":"B027",
                "chkProdCd":"D047",
                "chkProdCd":"C004",
                "chkProdCd":"C042"
              },
        encoding='cp949',
        callback=self.after_post))
    return requests

  def parse(self, response):
    pass
    # requests = list(super(OpinetSpider, self).start_requests())

    # for year in self.year_list:
      # req = FormRequest.from_response(
      #         response,
      #         formdata={
      #           "start":"%s0101" % year,
      #           "end":"%s1231" % year,
      #           "prodDivCd":"B034,B027,D047,C004,C042",
      #           "chprice":"",
      #           "term":"d",
      #           "start_yy":year,
      #           "start_qq":"1",
      #           "start_mm":"01",
      #           "start_ww":"1",
      #           "start_dd":"01",
      #           "end_yy":year,
      #           "end_qq":"1",
      #           "end_mm":"12",
      #           "end_ww":"1",
      #           "end_dd":"31",
      #           "chkProdCd":"B034",
      #           "chkProdCd":"B027",
      #           "chkProdCd":"D047",
      #           "chkProdCd":"C004",
      #           "chkProdCd":"C042"
      #         }, 
      #         encoding='cp949',
      #         callback=self.after_post)
      # # req.encoding = 'cp949'
      # yield req

  # def parse(self, response):
  #   item = []
  #   xxs = XmlXPathSelector(response)
  #   prices = xxs.select('//')
  #   print(dir(response))
  #   return prices

  def after_post(self, response):
    item = []
    # body = response.body.decode('cp949')

    # html_response = HtmlResponse(url=response.url, body=response.body, encoding='cp949')
    html_response = HtmlResponse(url=response.url, body=response.body, encoding='cp949')
    # xxs = HtmlXPathSelector(html_response)
    # prices = xxs.select('//td[@class="border7_2 text_align1"]/text()').extract()
    doc = html_response.body_as_unicode()
    # parser = etree.HTMLParser(encoding='utf-8')
    # tree = etree.fromstring(doc, parser)
    # xresult = tree.xpath('//td[@class="border7_2 text_align1 dataItem1"]/text()')
    # print len(xresult)
    # for x in xresult:
    #   print x
    # return

    pattern = re.compile(r'var chartData =  ([^;]*);')
    results = pattern.findall(doc)
    a = json.loads(results[0])
    print a
    # print results
