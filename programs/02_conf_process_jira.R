# Anonymize JIRA process files and construct variables
# Harry Son, Lars Vilhuber, Linda Wang
# 2021-05-20

## Inputs: export_(extractday).csv
## Outputs: file.path(jiraconf,"temp.jira.conf.RDS") file.path(jiraanon,"temp.jira.anon.RDS")

### Load libraries 
### Requirements: have library *here*
source(file.path(rprojroot::find_root(rprojroot::has_file("pathconfig.R")),"pathconfig.R"),echo=TRUE)
source(file.path(basepath,"global-libraries.R"),echo=TRUE)
source(file.path(programs,"libraries.R"),echo=TRUE)
source(file.path(programs,"config.R"),echo=TRUE)

message("===================================================")

if ( file.exists(here::here("programs","confidential-config.R"))) {
  source(here::here("programs","confidential-config.R"))
  warning("Confidential config found.")
  # if not sourced, randomness will ensue
}

exportfile <- paste0(issue_history.prefix,extractday,".csv")

# double-check for existence of issue history file.

if (! file.exists(file.path(jiraconf,exportfile))) {
  process_raw = FALSE
  message("Input file for anonymization not found - setting global parameter to FALSE")
} else {
  message("Input found for confidential data - setting process_raw to TRUE")
}

if ( process_raw == TRUE ) {
  # Read in data extracted from Jira
  warning("===================================================\n    Starting processing ... ")

  jira.conf.raw <- read.csv(file.path(jiraconf,exportfile), stringsAsFactors = FALSE) %>%
    # the first field name can be iffy. It is the Key (sic)...
    rename(ticket=Key) %>%
    mutate(mc_number = sub('\\..*', '', Manuscript.Central.identifier))  %>%
    # Some corrections
    mutate(mc_number = case_when(
      substr(Manuscript.Central.identifier,1,4) == "aer." ~ str_replace(Manuscript.Central.identifier,".","-"),
      substr(Manuscript.Central.identifier,1,4) == "pol." ~ str_replace(Manuscript.Central.identifier,".","-"),
      substr(Manuscript.Central.identifier,1,4) == "app." ~ str_replace(Manuscript.Central.identifier,".","-"),
      TRUE ~  mc_number
    )) %>%
    # Only Tasks
    filter(Issue.Type == "Task") %>%
    # Possibly temporary issue?
    filter(ticket == Key.1) %>%
    select(-Key.1) %>%
    filter(str_detect(ticket,"AEAREP"))
  
  # Write out names as currently captured to TEMP
  names(jira.conf.raw) %>% as.data.frame() -> tmp
  names(tmp) <- c("Name")
  write_excel_csv(tmp,file=file.path(interwrk,jira.conf.names.csv),col_names = TRUE)
  
  
  warning(paste0("If you need to edit the names to be included,\n",
                 "edit the file ",file.path(interwrk,jira.conf.names.csv),"\n",
                 "save it in ",jirameta, "with the same name, ran run again."))
  
  # We need to remove all sub-tasks of AEAREP-1407
placeholders <- jira.conf.raw %>% filter(ticket =="AEAREP-1407") %>%
               select(ticket,Sub.tasks) %>%
               separate_longer_delim(Sub.tasks,delim=",") %>%
               mutate(Sub.tasks = str_trim(Sub.tasks)) %>%
               select(ticket = Sub.tasks) %>%
               distinct() 

  # now do an anti_join
  jira.conf.cleaned <- jira.conf.raw %>%
    anti_join(placeholders) 

  
  # anonymize mc_number. We will use that later only for those not published
  jira.manuscripts <- jira.conf.cleaned %>% 
    select(ticket,mc_number,Journal,As.Of.Date) %>% 
    filter(mc_number!="") %>%
    group_by(ticket) %>%
    arrange(desc(As.Of.Date)) %>%
    filter(row_number() == 1) %>%
    ungroup() %>%
    distinct(mc_number,Journal)   %>%
    mutate(rand = runif(1)) %>%
    arrange(rand) %>%
    mutate(mc_number_anon = row_number()) %>%
    select(-rand) %>%
    arrange(mc_number)

  # Create anonymized Assignee number
  jira.assignees <- jira.conf.cleaned %>%
    select(Assignee) %>%
    filter(Assignee!="") %>%
    filter(Assignee!="Automation for Jira") %>%
    filter(Assignee!="LV (Data Editor)") %>%
    distinct() %>%
    mutate(rand = runif(1),
           rand = if_else(Assignee=="Lars Vilhuber",0,rand)) %>%
    arrange(rand) %>%
    mutate(assignee_anon = row_number()) %>%
    select(-rand) %>%
    arrange(Assignee)
  
  # Now merge the anonymized data on, keep & rename relevant variables
  jira.conf.tmp <- jira.conf.cleaned %>% 
    left_join(jira.manuscripts %>% select(mc_number,mc_number_anon),by="mc_number") %>%
    left_join(jira.assignees,by="Assignee") %>%
    mutate(date_created = as.Date(substr(Created, 1,10), "%Y-%m-%d"),
           date_asof    = as.Date(substr(As.Of.Date, 1,10), "%Y-%m-%d")) %>%
    rename(subtask=Sub.tasks) %>%
    mutate(has_subtask=ifelse(subtask!="","Yes","No")) 
  jira.conf.tmp %>%
    select(ticket, mc_number, mc_number_anon, Manuscript.Central.identifier,
           MCStatus, 
           openICPSR.Project.Number,RepositoryDOI,
           Journal,JournalIssueMonth,JournalIssueYear,  
           Status, Changed.Fields,
           date_created, date_asof, 
           assignee_anon,   Issue.Type, subtask, has_subtask, Update.type) -> jira.conf.plus
  
  # save anonymized and confidential data
  
  # Save files
  saveRDS(jira.manuscripts,file=manuscript.lookup.rds)
  saveRDS(jira.assignees,  file=assignee.lookup.rds)
  saveRDS(jira.conf.plus,
          file=jira.conf.plus.rds)

  
} else { 
  print("Not processing anonymization due to global parameter.")
}
