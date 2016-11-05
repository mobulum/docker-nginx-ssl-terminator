#!/bin/bash

# after merge pull request
tag="$1"
description="$2"

if [ $# -lt 2 ];then
  echo "usage: $0 \$tag \$description"
  exit 1
fi

function gitTag() {
  echo "git tag stage"
  echo
  local tag="$1"
  git-release $tag
}

function packageProperty() {
  local field="$1"
  echo `npm view . $field`
}

function githubRelease() {
  echo "github release stage"
  echo
  local tag="$1"
  local description="$2"
  local repo="docker-nginx-ssl-terminator"

  echo "github release for \"$repo\" in version \"$tag\""
  echo

  github-release release \
    --user "mobulum" \
    --repo "$repo" \
    --tag "$tag" \
    --name "Release $tag" \
    --description "$description"
}

gitTag "$tag"
githubRelease "$tag" "$description"
