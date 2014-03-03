
rhive.rs.install.packages <- function(pkgs, repos=NULL) {
  if (is.null(repos)) {
    stop("should provide values for repos argument")
  }
  
  hive_home <- Sys.getenv("HIVE_HOME")
  ls(pos=grep("^package:RHive$", search()))
  ls(envir= RHive:::.rhiveEnv)
  rhiveHosts <- get("hiveclient", envir=RHive:::.rhiveEnv)[[4]]
  
  resultReport <- t(sapply(rhiveHosts, function(rhost) {
    resultCode <- "init"
    port = 6311
    result <- try(rcon <- RSconnect(rhost, port), silent = TRUE)
    if (class(result)[1] == "try-error") {
      resultCode <- "fail"
    } else {
      # RSeval(rcon, quote(.libPaths()))    
      packageName <- "stringr"
      repository <- "http://cran.nexr.com"
      remoteUser <- RSeval(rcon, quote(Sys.getenv("USER")))
      # remoteLibPaths <- RSeval(rcon, quote(.libPaths()))
      if (remoteUser == "root") {
        evalResult <- RSeval(rcon, sprintf("install.packages('%s', repos='%s')", packageName, repository))
      } else {
        cat("All Rserves should be run by root user\n")
        cat(sprintf("Currently the run-user is '%s'\n",remoteUser))
        resultCode <- "fail"
      }
      resultCode <- "success"
    }
    RSclose(rcon)
    c(rhost, resultCode)
  }))
  
  colnames(resultReport) <- c("hostname", "result")
  
  return (resultReport)
}

rhive.rs.install.packages("stringr","http://cran.nexr.com")