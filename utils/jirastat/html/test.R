setContentType(type='image/png')
png("/tmp/1.png", width=800, height=500)
obj <- plot(1:100)
dev.off()
t <- "/tmp/1.png"
sendBin(object=readBin(t,'raw',n=file.info(t)$size))
