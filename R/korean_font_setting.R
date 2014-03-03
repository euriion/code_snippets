# PDF font
pdfFonts(unta2=Type1Font("UnTaza", rep("/usr/share/fonts/un-fonts/test/untaza.afm", 4)))
pdf("/tmp/test11.pdf")
par(family="나눔고딕OTF")
plot(1:10, main="한글 테스트")
dev.off()

# Cairo PDF
cairo_pdf("/tmp/test11.pdf")
par(family="나눔고딕OTF")
plot(1:10, main="한글 테스트")
dev.off()

# Library checking
# ?grDevices
# ?quartzFonts

# QuartzFonts 체킹
names(quartzFonts())
#cairoFonts()
#quartzFonts(bw5=quartzFont(rep("UnPilgi", 4)))
#png("/tmp/1.png")

# X11 체킹
names(X11Fonts())
X11Fonts(mm1=X11Font("-*-UnTaza-*-*-*-*-*-*-*-*-*-*-*-*"))

# Quartz font setting
quartz(family="Bandal")
quartzFonts(bdw=quartzFont("Bandal"))
par(family="Meiryo")
plot(1, main="ありかとこじゃいます。僕わネスアルです")
par(family="KT&G 상상본문OTF M")
plot(1, main="123abcd은 타자 폰트테스트. 伽儺多一")
dev.off()
