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

# get the Journal -> MC prefix  back

journal.abbrev <- read_csv(file.path(datapath,"metadata","journal_abbrev.csv")) %>%
                             select(Journal,mc_prefix)

crossref.only <-right_join(jira.manuscript.dois,
                           aeadois.subset,by=c("doi"="doi")) %>% 
                  filter(is.na(mc_number_anon)) %>%
                  # replace full journal name by short name 
                  mutate(Journal = str_replace_all(container.title,
                                                c("American Economic Journal: "="AEJ:",
                                                  "American Economic Review"="AER",
                                                  "Journal of Economic Literature"="JEL",
                                                  "Journal of Economic Perspectives"="JEP",
                                                  "American Economic Review: Insights"="AER:Insights"))) %>%
                  # one last fix
                  mutate(Journal = if_else(Journal=="AER: Insights","AER:Insights",Journal),
                         Journal = if_else(Journal=="AEJ:Macroeconomics","AEJ:Macro",Journal),
                         Journal = if_else(Journal=="AEJ:Microeconomics","AEJ:Micro",Journal)) %>%
                  # merge on the journal.abbrev
                  left_join(journal.abbrev,by=c("Journal"="Journal")) %>%
                  # reconvert to the manuscript number
                  mutate(mc_number = paste0(mc_prefix,"-",
                                    str_sub(doi, start=-8, end=-5),"-",
                                    str_sub(doi, start=-4)))


# Who are these?

jira.plus.authors %>%
  group_by(Journal, published) %>%
  summarize(count = n(), .groups = "drop") %>%
  tidyr::pivot_wider(names_from = published, values_from = count, values_fill = 0, names_prefix = "published_")

## Save files


# Save files
saveRDS(crossref.only,file=file.path(Outputs,"crossref_only.Rds"))
# also export as CSV
write_csv(crossref.only,file=file.path(Outputs,"crossref_only.csv"))
saveRDS(jira.plus.authors,file=file.path(interwrk,"jira_plus_authors.Rds"))


