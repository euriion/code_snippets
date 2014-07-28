__author__ = 'aiden.hong'
# -*- coding: utf-8 -*-

import urllib2
import BeautifulSoup
import re

# 데이터 출처: 에너지관리공단
base_url = "http://bpm.kemco.or.kr/transport/grade/new_list.asp?keyword=&select_prod_cd=&select_grade=0&select_fuel_kind=&select_car_group=&select_sort_item=mileage&select_sort_order=desc&select_car_gb=1&page=%s"
pattern_nbsp = re.compile("&nbsp;")

# Column names
# 번호, 모델명, 업체, 유종, 배기량, 공차중량, 변속형식, 연비(㎞/ℓ), 구등급, 신등급, CO2(g/㎞), 예상연료비(원)
# no, model, maker, fueltype, displacement, weight, transmissiontype, mileage, oldgrade, newgrade, co2, oilmoneyperyear
# 예상연료비는 1년간 16,000㎞의 주행조건을 기준으로 산출된 금액입니다.
# (휘발유 1,929.53원/ℓ, 경유 1,754.82원/ℓ, LPG 1,099.26원/ℓ)

tsv_records = []
for page_number in range(1, 125):
    print "Progressing page:%d " % page_number
    url = base_url % page_number
    html_content = urllib2.urlopen(url)
    soup = BeautifulSoup.BeautifulSoup(html_content.read())
    for data_record in soup.findAll('table')[0].findAll('tr')[0].findAll('table')[1].findAll('table')[2].findAll('tr'):
        data_columns = data_record.findAll('td')
        new_columns = []
        for column in data_columns:
            new_columns.append(pattern_nbsp.sub("", column.text).strip())
        tsv_records.append("\t".join(new_columns))

open("./car_fuel_efficiency.tsv", 'w').write("\n".join(tsv_records).encode("utf-8"))
print "Done!"