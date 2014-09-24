import sys.process._
import java.net.URL
import java.io.File

System.setProperty("http.agent", "robot"); 
var page_url = "http://www.naver.com"
new URL(page_url) #> new File("output.html") !!