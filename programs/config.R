# ###########################
# CONFIG: define  and filenames for later reference
# ###########################

# environment variables for other APIs

if (file.exists(file.path(basepath,".Renviron"))) {
readRenviron(file.path(basepath,".Renviron"))
}

# AEA DOI prefix

doi_prefix <- "10.1257"

# Crossref-related filenames

issns.file <- file.path(crossrefloc,paste0("issns.Rds"))

doi.file <- file.path(crossrefloc,"crossref_dois")
doi.file.Rds <- paste(doi.file,"Rds",sep=".")
doi.file.csv <- paste(doi.file,"csv",sep=".")

# openAlex related filenames


openalex.file <- file.path(openalexloc,"openalex-aea")
openalex.Rds <- paste0(openalex.file,".Rds")
citations.latest <- file.path(openalexloc,"citations-per-paper.Rds")

openalex.authors     <- file.path(openalexloc,"openalex-aea-authors")
openalex.authors.Rds <- paste0(openalex.authors,".Rds")
openalex.hindex      <- file.path(openalexloc,"openalex-hindex.Rds")


# Jira related stuff


## These control whether the external data is downloaded and processed.
process_raw <- TRUE
download_raw <- TRUE

## This pins the date of the to-be-processed file

extractday <- "2025-02-02"
firstpubday <- "2019-01-01"
firstpubyear <- substr(firstpubday,1,4)

# filenames
issue_history.prefix <- "issue_history_"
manuscript.lookup     <- "mc-lookup"
manuscript.lookup.rds <- file.path(jiraconf,paste0(manuscript.lookup,".RDS"))

assignee.lookup       <- "assignee-lookup"
assignee.lookup.rds   <- file.path(jiraconf,paste0(assignee.lookup,".RDS"))

# this is the augmented confidential file with all the non-confidential variables
jira.conf.plus.base   <- "jira.conf.plus"
jira.conf.plus.rds    <- file.path(jiraconf,paste0(jira.conf.plus.base,".RDS"))

jira.conf.names.csv   <- "jira_conf_names.csv"

# public files
members.txt <- file.path(jiraanon,"replicationlab_members.txt")

jira.anon.base <- "jira.anon"
jira.anon.rds  <- file.path(jiraanon,paste0(jira.anon.base,".RDS"))
jira.anon.csv  <- file.path(jiraanon,paste0(jira.anon.base,".csv"))


