#!/bin/bash

# Env vars
access_token="$GITHUB_ACCESS_TOKEN"
if [ -z "$access_token" ]; then
    echo "No access token, cannot authenticate with GitHub. Please set GITHUB_ACCESS_TOKEN environment variable"
    exit 1
fi

target_repo_name="$TARGET_REPO_NAME"
if [ -z "$target_repo_name" ]; then
    echo "No target repo name, please set TARGET_REPO_NAME environment variable"
    exit 1
fi

# Constants
git_email="${TUIST_GIT_EMAIL:-}"
git_user="${GITHUB_REPOSITORY_OWNER:-}"

_get_tag() {
    tags=$(git ls-remote --tags)
    echo "tags $tags"

    tag_list=($(echo "$tags" | grep -o 'refs/tags/[0-9.]\+' | sed 's|refs/tags/||g'))
    echo "tag_list ${tag_list[*]}"

    latest_tag="${tag_list[-1]}"
    if [ -z "$latest_tag" ]; then
        echo "Could not find a tag"
        exit 1
    fi
    echo "$latest_tag"
}

tag=$(_get_tag)

# Cloning ProjectDescription project
target_repo_url="https://$git_user:$access_token@github.com/$target_repo_name"
echo "cloning $target_repo_url"
git clone $target_repo_url
repo_name=$(echo "$target_repo_url" | awk -F'/' '{print $(NF-0)}' | sed 's/.git$//')
cd "$repo_name" || exit

git remote set-url origin target_repo_url
git config --local user.email $git_email
git config --local user.name $git_user

echo "Releasing new version of Project Descriptin with tag=$tag"

./release.sh $tag