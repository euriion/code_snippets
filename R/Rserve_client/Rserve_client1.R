install.packages("RSclient")
library(RSclient)
rsc = RS.connect(host="192.168.5.181", port=6311, tls=F)
RS.login(rsc, user="client1", password="password1")
rsc = RS.connect(host="localhost", port=6311, tls=F)

# Remote Rserve
# In order to handle R.serve.
# Checking How to use the Rserv 