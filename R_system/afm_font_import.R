
# /Library/Fonts/
# /Library/Frameworks/R.framework/Versions/3.0/Resources/library/extrafontdb/metrics/
# /Library/Frameworks/R.framework/Versions/3.0/Resources/library/extrafontdb/fontmap
# /Library/Frameworks/R.framework/Versions/3.0/Resources/library/extrafontdb/fontmap/fonttable.csv

# /Users/euriion/Documents/NanumGothic.afm
# /usr/local/texlive/2014/texmf-dist/fonts/afm/public/nanumtype1

CMitalic <- Type1Font("ComputerModern2",
                      c("CM_regular_10.afm", "CM_boldx_10.afm",
                        "cmti10.afm", "cmbxti10.afm",
                         "CM_symbol_10.afm"),
                      encoding = "TeXtext.enc")

NanumGothic <- Type1Font("NanumGothic",
                      c("/Users/euriion/Documents/NanumGothic.afm",
                        "/Users/euriion/Documents/NanumGothic.afm",
                        "/Users/euriion/Documents/NanumGothic.afm",
                        "/Users/euriion/Documents/NanumGothic.afm"))

NanumGothic <- postscriptFont("NanumGothic",
                      c("/Users/euriion/Documents/NanumGothic.afm",
                        "/Users/euriion/Documents/NanumGothic.afm",
                        "/Users/euriion/Documents/NanumGothic.afm",
                        "/Users/euriion/Documents/NanumGothic.afm"))

postscriptFonts(NanumGothic=NanumGothic)

pdf(file="./korean_plot_exam1.pdf"), family="NanumGothic")
par(family="NanumGothic")
hist(faithful$waiting, main="간헐천 유휴시간 히스토그램", xlab="유휴시간", ylab="빈도")
dev.off()

postscriptFonts()
CMitalic <- postscriptFont("ComputerModern",
                           c("CM_regular_10.afm", "CM_boldx_10.afm",
                             "cmti10.afm", "cmbxti10.afm",
                             "CM_symbol_10.afm"))
postscriptFonts(CMitalic=CMitalic)

postscriptFonts(CMitalic = CMitalic)
# ---------------------------------------------------------

library(extrafont)
ttf_files <- normalizePath(list.files(c("/Library/Fonts/"), pattern = "\\.ttf$",
                                      full.names=TRUE, recursive = TRUE,
                                      ignore.case = TRUE))

# /Library/Fonts/NanumGothic.ttc
ttf_files <- c("/Library/Fonts/NanumGothic.ttc")
fontmap <- extrafont:::ttf_extract(ttf_files)
fontmap <- fontmap[!is.na(fontmap$FontName), ]
afmdata <- extrafont:::afm_scan_files()
afmfiles <- c("/Library/Frameworks/R.framework/Versions/3.0/Resources/library/extrafontdb/metrics/NanumGothic.afm.gz")
# afmdata <- lapply(afmfiles, extrafont:::afm_get_info)
afmdata <- lapply(afmfiles, custom_afm_get_info)
fontmap <- merge(afmdata, fontmap)
# extrafont:::afm_get_info(afmfiles[1])
# extrafont:::fonttable_file()
extrafont:::fonttable_add(fontmap)

extrafont:::font_import
extrafont:::ttf_import
extrafont:::afm_scan_files
extrafont:::afm_get_info

fd <- gzfile(afmfiles[1])
text <- readLines(fd, 30)
close(fd)

Sys.setlocale(locale="C")
fd <- gzfile("/Library/Frameworks/R.framework/Versions/3.0/Resources/library/extrafontdb/metrics/NanumGothic.afm.gz", "r", encoding=getOption("encoding"))
text <- readLines(fd, 30, encoding=getOption("encoding"))
close(fd)
FamilyName <- sub("^FamilyName ", "", text[grepl("^FamilyName", text)])
FontName <- sub("^FontName ", "", text[grepl("^FontName", text)])
FullName <- sub("^FullName ", "", text[grepl("^FullName", text)])
weight <- sub("^Weight ", "", text[grepl("^Weight", text)])
text

if (grepl("Bold", weight)) {
    Bold <- TRUE
} else {
    Bold <- FALSE
}



readLines(gzfile("/Library/Frameworks/R.framework/Versions/3.0/Resources/library/extrafontdb/metrics/NanumGothic.afm.gz"))

readLines(gzfile("/Users/euriion/Documents/test.txt.gz"))[1:30]



Sys.setlocale(locale="C")
custom_afm_get_info <- function(filename) {

    if (grepl("\\.gz", filename)) {
        fd <- gzfile(filename, "r")
    }
    else {
        fd <- file(filename, "r")
    }
    text <- readLines(fd, 30)
    close(fd)
    print(text)
    FamilyName <- sub("^FamilyName ", "", text[grepl("^FamilyName", text)])
    FontName <- sub("^FontName ", "", text[grepl("^FontName", text)])
    FullName <- sub("^FullName ", "", text[grepl("^FullName", text)])
    weight <- sub("^Weight ", "", text[grepl("^Weight", text)])

    if (grepl("Bold", weight)) {
        Bold <- TRUE
    }
    else {
        Bold <- FALSE
    }
    if (grepl("Italic", weight) || grepl("Oblique", weight) || grepl("Italic", FontName) || grepl("Slanted", FontName)) {
        Italic <- TRUE
    }
    else {
        Italic <- FALSE
    }
    if (grepl("Symbol", FamilyName))
        Symbol <- TRUE
    else Symbol <- FALSE

    if (length(FullName) == 0) {
        FullName <- FamilyName
        if (Bold) {
            FullName <- paste(FullName, "Bold")
        }
        if (Italic) {
			FullName <- paste(FullName, "Italic")
        }
    }
    data.frame(FamilyName, FontName, FullName, afmfile = basename(filename), Bold, Italic, Symbol, afmsymfile = NA, stringsAsFactors = FALSE)
}

afmdata <- lapply(afmfiles, custom_afm_get_info)


# FontForge를 이용한 폰트 변환
Quartz가 필요함
http://xquartz.macosforge.org/landing/

FontForge의 Mac 버전
http://fontforge.github.io/en-US/downloads/mac/

http://luc.devroye.org/tt2ps.html
http://dev.naver.com/projects/nanumfont/issue/2841




http://www.files-conversion.com/converted.php?nom=nanumgothic.afm

