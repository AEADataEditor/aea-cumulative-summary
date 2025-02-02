# Getting in-scope articles
# Code derived from another project
# NOTE: THIS REQUIRES R 4.2.0 and newer packages!
#

source(file.path(rprojroot::find_rstudio_root_file(),"pathconfig.R"),echo=FALSE)
source(file.path(basepath,"global-libraries.R"),echo=FALSE)
source(file.path(programs,"libraries.R"), echo=FALSE)
source(file.path(programs,"config.R"), echo=FALSE)


# filenames in config.R


# clean read-back
aeadois <- readRDS(file= doi.file.Rds)
nrow(aeadois)

# subset to the years in-scope: 2019+
aeadois %>%
  mutate(year=substr(published.print,1,4)) %>%
  filter(year >= firstpubyear ) %>%
  filter(published.print >= firstpubday)  %>% 
  mutate(match=TRUE)-> aeadois.subset 


# Match to processed files

jira.manuscript.dois <- readRDS(file=file.path(jiraconf,"manuscript-dois.lookup.Rds"))

nrow(jira.manuscript.dois)

# test: match to complete sample by DOI, should be no missing (complete_rate = 1)

jira.plus.authors <- left_join(jira.manuscript.dois,
                               aeadois.subset,by=c("doi"="doi")) %>%
                     mutate(published = if_else(is.na(match),FALSE,TRUE))

crossref.only <-right_join(jira.manuscript.dois,
                           aeadois.subset,by=c("doi"="doi")) %>% filter(is.na(mc_number_anon))

jira.plus.authors %>%
  group_by(container.title,published) %>%
  summarize(count=n())

## Save files


# Save files
saveRDS(crossref.only,file=file.path(Outputs,"crossref_only.Rds"))
saveRDS(jira.plus.authors,file=file.path(interwrk,"jira_plus_authors.Rds"))


