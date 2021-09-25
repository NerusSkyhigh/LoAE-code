#!/bin/bash
if [ "$PWD" != "/home/guglielmo/Desktop/GithubRepositories/labIV" ]; then
  echo "I think I'm in the wrong directory."
  echo "I'll stop in ordert to not delete important files"
  exit;
fi

find . -type f  ! -name '*.v' \
                ! -name '*.bit' \
                ! -name '*.xise' \
                ! -path './.git/*' \
                ! -name '*.so.*' \
                ! -name '*.ucf' \
                ! -name '*.pdf' \
                ! -name '*.gitignore' \
                ! -name 'clean_project.sh' \
          -delete

# Delete empty directories
find . -type d -empty ! -path './.git/*' \
          -delete
