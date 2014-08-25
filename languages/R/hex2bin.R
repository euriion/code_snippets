
hex2dec <- function(x) {
  as.numeric(gsub('(.*)H$', '0x\\1', x))
}

dec2hex <- function(x, length=4, fillzero=T) {
  fill <- ""
  if (fillzero == T) {
    fill <- "0"
  }
  sprintf(sprintf("%%%s%sXH",fill, length), x)
}

# example
hex2dec('0506H')
dec2hex(1285)
dec2hex(1072)
dec2hex(1087)
dec2hex(1440) "05A0H"
dec2hex(304) # "0130H"
dec2hex(339) # dec2hex(399)
[1] "018FH"