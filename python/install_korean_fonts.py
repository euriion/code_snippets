# -*- coding: utf-8 -*-
import sys
import os

def install_korean_fonts():
  """ Installing Korean fonts (Nanum and others)
  Korean fonts are necessary to plot out graphic using R
  """
  font_repository = {
    "나눔고딕에코TTF":"http://cdn.naver.com/naver/NanumFont/fontfiles/NanumFontSetup_TTF_GOTHICECO.zip",
    "나눔명조에코TTF":"http://cdn.naver.com/naver/NanumFont/fontfiles/NanumFontSetup_TTF_MYUNGJOECO.zip",
    "나눔고딕TTF":"http://cdn.naver.com/naver/NanumFont/fontfiles/NanumFont_TTF_ALL.zip",
    "나눔명조TTF":"http://cdn.naver.com/naver/NanumFont/fontfiles/NanumFont_TTF_ALL.zip",
    "나눔고딕라이트TTF":"http://cdn.naver.com/naver/NanumFont/fontfiles/NanumFontSetup_TTF_GOTHICLIGHT.zip",
    "나눔손글씨TTF":"http://cdn.naver.com/naver/NanumFont/fontfiles/NanumFont_TTF_ALL.zip",
    "나눔고딕에코OTF":"http://cdn.naver.com/naver/NanumFont/fontfiles/NanumFontSetup_OTF_GOTHICECO.zip",
    "나눔명조에코OTF":"http://cdn.naver.com/naver/NanumFont/fontfiles/NanumFontSetup_OTF_MYUNGJOECO.zip",
    "나눔고딕OTF":"http://cdn.naver.com/naver/NanumFont/fontfiles/NanumFont_OTF_ALL.zip",
    "나눔명조OTF":"http://cdn.naver.com/naver/NanumFont/fontfiles/NanumFont_OTF_ALL.zip",
    "나눔고딕라이트OTF":"http://cdn.naver.com/naver/NanumFont/fontfiles/NanumFontSetup_OTF_GOTHICLIGHT.zip",
    "나눔손글씨OTF":"http://cdn.naver.com/naver/NanumFont/fontfiles/NanumFont_OTF_ALL.zip",
    "나눔고딕코딩TTF":"http://dev.naver.com/projects/nanumfont/download/441?filename=NanumGothicCoding-2.0.zip"
  }

  font_base_dir = "/usr/share/fonts"
  if not os.path.exists("/usr/share/fonts"):
    print "/usr/share/fonts does not exist"
    sys.exit(-1)
  os.chdir("/usr/share/fonts")
  if not os.path.exists("./additional"):
    os.mkdir("./additional")
  os.chdir("/usr/share/fonts/additional")
  for fontname, url in font_repository.items():
    os.system("if [ -z ./%s ]; then mkdir -p ./%s" % (fontname, fontname))
    os.system("/usr/bin/wget %s -O ./%s.zip" % (url, fontname))
    os.system("rm -f ./%s/*" % fontname)
    os.system("/usr/bin/unzip ./%s.zip -d %s" % (fontname, fontname))
    os.system("rm -Rf *.zip")
  os.system("fc-cache -fv")

if __name__ == '__main__':
  install_korean_fonts()