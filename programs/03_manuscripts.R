# Reconstruct DOI from Manuscript numbers


### Load libraries 
### Requirements: have library *here*
source(file.path(rprojroot::find_root(rprojroot::has_file("pathconfig.R")),"pathconfig.R"),echo=TRUE)
source(file.path(basepath,"global-libraries.R"),echo=TRUE)
source(file.path(programs,"libraries.R"),echo=TRUE)
source(file.path(programs,"config.R"),echo=TRUE)

message("===================================================")

jira.conf.plus <- readRDS(jira.conf.plus.rds)

# Necessary file:
jira.manuscripts <- readRDS(file=manuscript.lookup.rds)
jira.manuscript.dois <- jira.manuscripts %>%
       mutate(first_chars=str_to_lower(substr(mc_number,1,1))) %>%
       filter(first_chars %in% c("a","j","p")) %>%
       # other cleaning
       filter(substr(mc_number,1,6)!="AEAREP") %>%
       filter(str_detect(mc_number,"AEJ Policy")==FALSE) %>%
       # now transform into DOI
       mutate(first_chars=str_to_lower(substr(mc_number,1,4)),
              first_chars5=str_to_lower(substr(mc_number,1,5)),
              doi_article_prefix=case_when(
                    first_chars == "aeja" ~ "app",
                    first_chars == "app" ~ "app",
                    first_chars == "app " ~ "app",
                    first_chars == "aejp" ~ "pol",
                    first_chars == "pol2"  ~ "pol",
                    first_chars5 == "aejma" ~ "mac",
                    first_chars5 == "aejmi" ~ "mic",
                    first_chars == "jel-" ~ "jel",
                    first_chars == "pand" ~ "pandp",
                    first_chars == "aeri" ~ "aeri",
                    first_chars == "aer-" ~ "aer",
                    TRUE                  ~ "")) %>%
       # now construct DOI
       # In general, mc_number = AEJAPP-2017-0453
       #             doi = prefix.20170453
       mutate( doi_suffix = str_extract_all(mc_number,"\\d") %>% 
                 map_chr(~ paste(.x, collapse = "")),
               doi = paste(doi_prefix,
                           paste(doi_article_prefix,doi_suffix,sep="."),
                           sep="/")) %>%
       select(mc_number,mc_number_anon,doi,Journal,doi_article_prefix)

table(jira.manuscript.dois$Journal,jira.manuscript.dois$doi_article_prefix)

saveRDS(jira.manuscript.dois,file=file.path(jiraconf,"manuscript-dois.lookup.Rds"))

