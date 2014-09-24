?expression
length(ex1 <- expression(1 + 0:9))
ex1
eval(ex1)

?eval
evalq(expr, envir, enclos)
?evalq

?quote
substitute(expr, env)
?substitute

?quote
?enquote
?parse
?deparse
?structure
structure(1:6, dim = 2:3)


?quote
#missingness
?bquote # for partial substitution
?sQuote
?dQuote
b<-2
a <- bquote(1 + ..)
a
eval(a)
?bquote


rename
?match
?rename

.aall_aesthetics <- c("adj", "alpha", "angle", "bg", "cex", "col", "color", "colour", "fg", "fill", "group", "hjust", "label", "linetype", "lower", "lty", "lwd", "max", "middle", "min", "order", "pch", "radius", "sample", "shape", "size", "srt", "upper", "vjust", "weight", "width", "x", "xend", "xmax", "xmin", "xintercept", "y", "yend", "ymax", "ymin", "yintercept", "z")


.bbase_to_ggplot <- c(
  "col"   = "colour",
  "color" = "colour",
  "pch"   = "shape",
  "cex"   = "size",
  "lty"   = "linetype",
  "lwd"   = "size",
  "srt"   = "angle",
  "adj"   = "hjust",
  "bg"    = "fill",
  "fg"    = "colour",
  "min"   = "ymin",
  "max"   = "ymax"
)


bbb <- function(x) {
  # Convert prefixes to full names
  print("-------------------")
  print(x)
  full <- match(names(x), .aall_aesthetics)
  print(full)
  names(x)[!is.na(full)] <- .aall_aesthetics[full[!is.na(full)]]
  print("-------------------")
  print(x)
  rename(x, .bbase_to_ggplot, warn_missing = FALSE)
  print(x)
}

?rename

aaa <- function(x, y, ...) {
  aa <- structure(as.list(match.call()[-1]), class="uneval")
  #print(aa)
  #print("-------------------")
  bbb(aa)
}
aaa(x=1, y=..density..)

rename <- function(x, replace, warn_missing) {
  plyr::rename(x, replace)
}


rename
?stat_bin
