library(plumber)
r <- pr("testing.R")
r%>%pr_run(host="0.0.0.0",port=8000)