#!/bin/bash

#pip install -r ../requirements.txt

# ./01_download_issues.py -s 2018-01-01 -e 2024-12-31 
R CMD BATCH 02_conf_process_jira.R
R CMD BATCH 03_manuscripts.R
R CMD BATCH 04_lab_members.R
R CMD BATCH 11_get_crossref.R
R CMD BATCH 12_combine_crossref_jira.R
R CMD BATCH 13_analyse_authors.R
#R CMD BATCH 90_push_box.R
R CMD BATCH 99_render_markdown.R