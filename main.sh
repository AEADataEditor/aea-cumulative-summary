#!/bin/bash
#
# Run the full analysis, top to bottom, inside the project's Docker image:
#   1. download Jira issues (programs/01_download_issues.py)
#   2. set extractday in programs/config.R to the extract date
#   3. run the R pipeline (programs/main.sh)
#
# Requires: JIRA_USERNAME and JIRA_API_KEY in the environment (unless -n),
#           and the image built via ./build.sh (tag), see .myconfig.sh.

set -e

usage() {
cat << EOF
Usage: $0 [-n] [-s start] [-e end] [tag]

  -n        skip the Jira download; reuse the existing extract
            (extractday in programs/config.R is then left unchanged)
  -s DATE   start date of the Jira download (default: 2018-01-01)
  -e DATE   end date of the Jira download, also the extract date (default: today)
  tag       Docker image tag (default: tag from .myconfig.sh)
EOF
}

download=yes
start=2018-01-01
end=$(date +%Y-%m-%d)
while getopts "ns:e:h" opt; do
  case $opt in
    n) download=no ;;
    s) start=$OPTARG ;;
    e) end=$OPTARG ;;
    h) usage; exit 0 ;;
    *) usage; exit 1 ;;
  esac
done
shift $((OPTIND - 1))

cd "$(dirname "${BASH_SOURCE[0]}")"
repo=${PWD##*/}
inner=/home/rstudio/$repo/programs

if [[ $download == yes ]]; then
  if [[ -z $JIRA_USERNAME || -z $JIRA_API_KEY ]]; then
    echo "JIRA_USERNAME and JIRA_API_KEY must be set (or use -n)" >&2
    exit 1
  fi
  sed -i -E "s/^extractday <- \"[0-9-]+\"/extractday <- \"$end\"/" programs/config.R
  grep -q "^extractday <- \"$end\"" programs/config.R \
    || { echo "Could not set extractday in programs/config.R" >&2; exit 1; }
  cmd="cd $inner && python 01_download_issues.py -s $start -e $end && bash main.sh"
else
  cmd="cd $inner && bash main.sh"
fi

# run_docker.sh takes the tag as its first argument
tag=${1:-$(. ./.myconfig.sh; echo "$tag")}

# run as the host user so outputs are not owned by root
DOCKEREXTRA="--user $(id -u):$(id -g)" bash run_docker.sh "$tag" -c "$cmd"
