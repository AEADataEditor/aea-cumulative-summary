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

# This maps Jira assignees to names, and records each person's role:
# undergraduate, graduate, pre-doc, staff, other (non-person accounts).
# Assignees not listed are treated as undergraduates.
# Graduate students not in Jira can be added with Assignee = Name.

roles <- c("undergraduate","graduate","pre-doc","staff","other")

lookup <- read_csv(file.path(jirameta,"assignee-name-lookup.csv"),
                   col_types = cols(.default = col_character()),
                   trim_ws = FALSE)
removal <- read_csv(file.path(jirameta,"assignee-remove.csv"))

bad.roles <- lookup %>% filter(is.na(Role) | !Role %in% roles)
if (nrow(bad.roles) > 0) {
  stop(paste0("Missing or invalid Role in assignee-name-lookup.csv for: ",
              paste(bad.roles$Name, collapse = ", "),
              "\nValid roles: ", paste(roles, collapse = ", ")))
}

jira.assignees <- readRDS(file=assignee.lookup.rds)

# Undergraduates come from Jira (unlisted assignees default to undergraduate),
# everybody else from the lookup. Non-person accounts (Role "other") are dropped.
lab.undergrads <- jira.assignees %>%
  #filter(date_created >= firstday, date_created < lastday) %>%
  filter(Assignee != "") %>%
  left_join(lookup) %>%
  filter(is.na(Role) | Role == "undergraduate") %>%
  anti_join(removal) %>%
  mutate(Name = if_else(is.na(Name),Assignee,Name),
         Role = "undergraduate") %>%
  distinct(Name,Role)

lab.member <- lookup %>%
  filter(!Role %in% c("undergraduate","other")) %>%
  distinct(Name,Role) %>%
  bind_rows(lab.undergrads,.)

write.table(lab.member, file = file.path(Outputs,"replicationlab_members.txt"), sep = "\t",
            row.names = FALSE)
# Save files: public
saveRDS(lab.member, file=file.path(Outputs,"replicationlab_members.Rds"))


