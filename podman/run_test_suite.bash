#!/bin/bash -e

usage() {
  echo "Usage: $0 -r <PR_repo> -b <PR_branch>"
  echo "The default repo and branch are IQSS/dataverse and develop, respectively."
  echo "Command-line arguments will specify a branch/repo to be merged with the IQSS develop branch."
  exit 0
}

while getopts "r:b:" o; do
  case "${o}" in
  r)
    PR_REPO=${OPTARG}
    ;;
  b)
    PR_BRANCH=${OPTARG}
    ;;
  \?)
    usage
    ;;
  esac
done

if [ ! -z "$PR_REPO" ]; then
   PR_REPO_STR="--build-arg PR_REPO=$PR_REPO"
fi

if [ ! -z "$PR_BRANCH" ]; then
   PR_BRANCH_STR="--build-arg PR_BRANCH=$PR_BRANCH"
   CONTAINER="$PR_BRANCH"
else
   CONTAINER="dataverse"
fi

/usr/bin/podman build -t dataverse . $PR_REPO_STR $PR_BRANCH_STR

/usr/bin/podman run --name $CONTAINER dataverse:latest

/bin/mkdir -p ./target
/usr/bin/podman cp $CONTAINER:/dataverse/target/classes ./target/
/usr/bin/podman cp $CONTAINER:/dataverse/target/coverage-it ./target/
/usr/bin/podman cp $CONTAINER:/dataverse/target/jacoco_merged.exec ./target/
/usr/bin/podman cp $CONTAINER:/dataverse/target/site ./target/
/usr/bin/podman cp $CONTAINER:/dataverse/target/surefire-reports ./target/
