
# Windows font 목록확인하기
windowsFonts()
names(pdfFonts())
X11Fonts()  # X11 시스템 폰트 확이
quartzFonts()

# Sys.getlocale() # 환경확인하기

system("fc-list")  # fc-list로 시스템에 설치된 폰트 목록 확인하기


# pdf(file="./korean_plot_exam1.pdf", fonts=c("NanumGothic"))

pdf(file="./korean_plot_exam1.pdf")
hist(faithful$waiting, main="간헐천 유휴시간 히스토그램", xlab="유휴시간", ylab="빈도")
dev.off()

pdf(file="./korean_plot_exam1.pdf")
par(family="NanumGothic")
hist(faithful$waiting, main="간헐천 유휴시간 히스토그램", xlab="유휴시간", ylab="빈도")
dev.off()

Sys.setlocale(locale="C")
library(extrafont)
loadfonts()

Sys.setlocale(locale="ko_kR")

library(extrafont)
pdf(file="./korean_plot_exam1.pdf", family="Korea1")

pdf(file="./korean_plot_exam1.pdf", family="Pilgi2")

par(family="NanumGothic")
par()

hist(faithful$waiting, main="나눔고딕", xlab="유휴시간", ylab="빈도")
dev.off()
warnings()
# pdfFonts 함수를 이용해서 PDF에서 사용할 수 있는 폰트를 확인한다.
names(pdfFonts())

# 폰트가 몇개 없으므로 현재 설치된 TTF폰트들을 AFM으로 변환해서 탑재한다.

# extrafont 패키지를 이용한 PDF용 폰트 다루기
install.packages('extrafont')  # 패키지를 설치한다.
library(extrafont)
font_import()
fonts()
fonttable()
# font_import함수가 TTF를 AFM으로 변환해서 탑재해주지만 작동하지 않을 수 있다.
# 관련된 package들 최신버전으로 설치한다.

install.packages("devtools")
library(devtools)
install_github("Rttf2pt1", "wch", "freetype2")
install_github("extrafont", "wch", "freetype")


# ggplot2에서의 한글 폰트 설정
ggplot2는 par함수에 의한 폰트 설정을 따르지 않는다. 이는 그래픽스를 표현할 때 각 요소별로 폰트를 달리하거나 할 경우가 많은 것을 대비해서
각 요소별로 폰트설정을 용이하게 하도록 별도의 함수를 지원하기 때문이다.
위의 히스토그램은 ggplot2를 이용하면 다음과 같이 표현할 수 있다.

..코드..

names(pdfFonts())

NanumScript <- Type1Font("NanumGothic",
                         c("/Users/euriion/Downloads/nanumscript.afm",
                           "/Users/euriion/Downloads/nanumscript.afm",
                           "/Users/euriion/Downloads/nanumscript.afm",
                           "/Users/euriion/Downloads/nanumscript.afm"))
# postscriptFonts(NanumGothic=NanumGothic)
pdfFonts(NanumScript=NanumScript)

?Type1Font



mdfont <- Type1Font("mdfont",
                    c("/Users/euriion/Downloads/md.afm",
                      "/Users/euriion/Downloads/md.afm",
                      "/Users/euriion/Downloads/md.afm",
                      "/Users/euriion/Downloads/md.afm"),encoding = "PDFDoc.enc")
pdfFonts(mdfont2=mdfont)

?pdfFonts
names(pdfFonts())
list.files(system.file('enc', package="grDevices"))

Sys.setlocale(locale="C")
pdf(file="./korean_plot_exam1.pdf", family="Korea1")
# pdf(file="./korean_plot_exam1.pdf", encoding="UTF-8")
# par(family="mdfont")
pdfFonts()
hist(faithful$waiting, main="ccccccc", xlab="aaa", ylab="bbb")
dev.off()

embedFonts(file="./korean_plot_exam1.pdf", outfile="./korean_plot_exam1.new.pdf")

> Sys.getenv("R_HOME")
[1] "/Library/Frameworks/R.framework/Resources"
# /library/grDevices/afm

# /Library/Frameworks/R.framework/Resources/library/grDevices/afm

library(extrafont)
fonts()
loadfonts()

pdf("font_plot.pdf", family="NanumGothic", width=4, height=4)
plot(mtcars$mpg, mtcars$wt, 
     main = "32종 차량의 연료효율",
     xlab = "Weight (x1000 lb)",
     ylab = "Miles per Gallon")
dev.off()
