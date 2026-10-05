# Custom image for the AEA cumulative summary pipeline
# Adds Python (for the Jira download) and the R packages used by programs/*.R
# Build with: ./build.sh (tag)

FROM rocker/tidyverse:4.4.2

# Python environment for programs/00_get_fields.py and programs/01_download_issues.py
RUN apt-get update \
    && apt-get install -y --no-install-recommends python3-venv python3-pip \
    && rm -rf /var/lib/apt/lists/*

ENV VIRTUAL_ENV=/opt/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
COPY requirements.txt /tmp/requirements.txt
RUN python3 -m venv $VIRTUAL_ENV \
    && pip install --no-cache-dir --default-timeout=120 --retries 5 -r /tmp/requirements.txt

# R packages: run the project's own package initialization
# The CRAN repo is the dated snapshot configured by the rocker base image
COPY global-libraries.R rmd-libraries.R /tmp/rsetup/
COPY programs/libraries.R /tmp/rsetup/programs/
RUN cd /tmp/rsetup \
    && Rscript -e 'source("global-libraries.R"); source("programs/libraries.R"); source("rmd-libraries.R")' \
    && rm -rf /tmp/rsetup /tmp/downloaded_packages
