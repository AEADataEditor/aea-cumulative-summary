# Get demographics

## TL;DR

In order to run this top to bottom, do this:

```
bash ./main.sh
```


## Step 0: Prep

- needs API key for Jira and possibly Box (to store confidential data)
- run `00_get_fields.py` if no `data/metadata/jira-fields.xlsx` file exits. Edit the file to include the desired fields, and re-upload. This will be used by the Python scripts for Jira.

## Step 1: get list of published articles

- Pull from Jira (confidential) data on all reproducibility checks.
- Pull from CrossRef all the articles published in the AEA journals

## Step 2: Combine the two

- Construct the AEA DOI from the Manuscript number. This will NOT work for JEP articles.
- Combine the two lists. This is primarily to construct the same statistics for both all manuscripts handled, and the subset of manuscripts that are published.

## Step 2: Get author information, citations, institutional citations

Pull from OpenAlex, but also map to Carnegie classification (will be fuzzy match)


## Supplementary: get filenames, software

Using Krantz data, relate the software, and complexity/size of the repository, to the characteristics collected earlier.

# NOTES

## Running in Docker

The `Dockerfile` extends `rocker/tidyverse` with Python (for the Jira download) and runs the project's own package initialization (`global-libraries.R`, `programs/libraries.R`, `rmd-libraries.R`). The image and tag are set in `.myconfig.sh`.

```bash
bash build.sh 2026-10-03       # build larsvilhuber/aea-cumulative-summary:2026-10-03
# JIRA_USERNAME and JIRA_API_KEY must be set in the host environment
DOCKEREXTRA="--user $(id -u):$(id -g)" bash run_docker.sh 2026-10-03 -c \
  'cd /home/rstudio/aea-cumulative-summary/programs && python 01_download_issues.py -s 2018-01-01 -e YYYY-MM-DD'
# then set extractday in programs/config.R to the date of the extract, and run
DOCKEREXTRA="--user $(id -u):$(id -g)" bash run_docker.sh 2026-10-03 -c \
  'cd /home/rstudio/aea-cumulative-summary/programs && bash main.sh'
```