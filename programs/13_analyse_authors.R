# Identify author stats
#
source(file.path(rprojroot::find_rstudio_root_file(),"pathconfig.R"),echo=FALSE)
source(file.path(basepath,"global-libraries.R"),echo=FALSE)
source(file.path(programs,"libraries.R"), echo=FALSE)
source(file.path(programs,"config.R"), echo=FALSE)


# filenames in config.R



# Save files
#crossref.only <- readRDS(file=file.path(Outputs,"crossref_only.Rds"))
jira.plus.authors <- readRDS(file=file.path(interwrk,"jira_plus_authors.Rds"))

authorlist.aea.df <- jira.plus.authors %>%
  select(author,doi) %>%
  filter(!is.na(author)) %>%
  tidyr::unnest(author) 

unique_authors <- authorlist.aea.df %>%
  select(given,family) %>%
  distinct(given,family) %>%
  arrange(family,given)

unique_authors_published <- nrow(unique_authors)
articles_published <- jira.plus.authors %>% filter(!is.na(container.title)) %>% nrow()
avg_unique_authors_per_article <- unique_authors_published / articles_published

author_per_article <- authorlist.aea.df %>%
  select(given,family,doi) %>%
  group_by(doi) %>%
  summarize(num_authors=n()) %>%
  ungroup()
  

avg_author_per_article <- author_per_article%>%
  summarize(num_authors=sum(num_authors)/n())


articles_not_published <- jira.plus.authors %>% 
  filter(is.na(container.title)) %>% 
  # remove the JEP and P&P
  filter(doi_article_prefix %in% c("","pandp","jep")) %>%
  nrow()

articles_not_published * avg_unique_authors_per_article
