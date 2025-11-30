# Export lab members worked during the designated period.
# Harry Son, Lars Vilhuber, Takshil Sachdev
# 2021-03-14

## Inputs: jira.conf.plus.RDS
## Outputs: file.path(basepath,"data","replicationlab_members.txt")

### Load libraries 
### Requirements: have library *here*
source(file.path(rprojroot::find_root(rprojroot::has_file("pathconfig.R")),"pathconfig.R"),echo=TRUE)
source(file.path(basepath,"global-libraries.R"),echo=TRUE)
source(file.path(programs,"libraries.R"),echo=TRUE)
source(file.path(programs,"config.R"),echo=TRUE)

exclusions <- c("Lars Vilhuber","Michael Darisse","Sofia Encarnacion", "Linda Wang",
                "Leonel Borja Plaza","User ","Takshil Sachdev","Jenna Kutz Farabaugh",
                "LV (Data Editor)","Ilanith Nizard","Julia Hewitt")

# This contains unmapped IDs that need to be cleaned up

lookup <- read_csv(file.path(jirameta,"assignee-name-lookup.csv"))
removal <- read_csv(file.path(jirameta,"assignee-remove.csv"))

jira.assignees <- readRDS(file=assignee.lookup.rds)

lab.member <- jira.assignees %>%
  #filter(date_created >= firstday, date_created < lastday) %>%
  filter(Assignee != "") %>%
  filter(!Assignee %in% exclusions) %>%
  left_join(lookup) %>%
  anti_join(removal) %>%
  mutate(Assignee = if_else(is.na(Name),Assignee,Name)) %>%
  distinct(Assignee) 

write.table(lab.member, file = file.path(Outputs,"replicationlab_members.txt"), sep = "\t",
            row.names = FALSE)
# Save files: public
saveRDS(lab.member, file=file.path(Outputs,"replicationlab_members.Rds"))


