# custom image built from ./Dockerfile via ./build.sh (tag)
repo=aea-cumulative-summary
space=larsvilhuber
dockerrepo=$(echo $space/$repo | tr [A-Z] [a-z] | sed 's/-internal//')
case $USER in
  vilhuber)
  #WORKSPACE=$HOME/Workspace/git/
  WORKSPACE=$PWD
  ;;
  codespace)
  WORKSPACE=/workspaces
  ;;
esac
tag=2026-10-03
