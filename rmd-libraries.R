# These are libraries only used in the Rmd and Quarto files

libraries <- c("knitr","rmarkdown")


results <- sapply(as.list(libraries), pkgTest)
cbind(libraries,results)