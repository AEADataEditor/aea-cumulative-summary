
source(file.path(rprojroot::find_rstudio_root_file(),"pathconfig.R"),echo=FALSE)
source(file.path(basepath,"global-libraries.R"),echo=FALSE)
source(file.path(programs,"libraries.R"), echo=FALSE)
source(file.path(programs,"config.R"), echo=FALSE)
source(file.path(basepath,"rmd-libraries.R"),echo=FALSE)

library(rmarkdown)

render(here::here("impacts_of_aea_data_editing.Rmd"), output_format = c("html_document", "word_document"))