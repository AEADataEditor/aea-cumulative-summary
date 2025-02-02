# Get demographics

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

## Running R on Codespaces

```bash
docker run -it --rm -v $(pwd):/project -w /project rocker/verse /bin/bash
```