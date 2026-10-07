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

# one row per manuscript (some DOIs appear more than once in Jira)
# P&P receive a different, more cursory report, and are counted separately
jira.articles <- jira.plus.authors %>%
  distinct(doi, .keep_all = TRUE) %>%
  mutate(pandp = doi_article_prefix == "pandp" | Journal == "AEA P&P")

# Authors of published articles, and extrapolation to the articles
# that cannot be matched to a published article (JEP, not yet published)
author_stats <- function(articles) {
  authorlist <- articles %>%
    filter(published) %>%
    select(author,doi) %>%
    tidyr::unnest(author)
  unique_authors <- authorlist %>%
    distinct(given,family) %>%
    nrow()
  avg_author_per_article <- authorlist %>%
    count(doi, name = "num_authors") %>%
    pull(num_authors) %>%
    mean()
  articles_jep <- articles %>% filter(!published, Journal == "JEP") %>% nrow()
  articles_not_published <- articles %>% filter(!published, Journal != "JEP") %>% nrow()
  list(articles_published     = articles %>% filter(published) %>% nrow(),
       unique_authors         = unique_authors,
       avg_author_per_article = avg_author_per_article,
       articles_jep           = articles_jep,
       articles_not_published = articles_not_published,
       estimate_authors       = unique_authors +
         round((articles_jep + articles_not_published) * avg_author_per_article, 0))
}

stats.main  <- author_stats(jira.articles %>% filter(!pandp))
stats.pandp <- author_stats(jira.articles %>% filter(pandp))

stats.main
stats.pandp
