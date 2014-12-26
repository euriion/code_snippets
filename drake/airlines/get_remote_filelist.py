import sys
import BeautifulSoup

def getFilelist(baseUrl, contentFilename):
  content = open(contentFilename).read()
  soup = BeautifulSoup.BeautifulSoup(content)

  elements = soup.body.find('div', attrs={'id':'doc','class':'yui-t4'}).find('div', attrs={'id':'bd'}).find('div', attrs={'id':'yui-main'}).find('div', attrs={'class':'yui-b'}).find('div', attrs={'class':'yui-g'}).findAll('p')[3].findAll('a')
  for element in elements:
    print("%s/%s" % (baseUrl.strip('/'), element['href']))


if __name__ == '__main__':
  if len(sys.argv) == 3:
    baseUrl = sys.argv[1]
    contentFilename = sys.argv[2]
    getFilelist(baseUrl, contentFilename)
  else:
    sys.exit(1)
