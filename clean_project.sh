#!/bin/bash
if [ "$PWD" != "/home/guglielmo/GithubRepositories/labIV" ]; then
  echo "I think I'm in the wrong directory."
  echo "I'll stop in ordert to not delete important files"
  exit;
fi

find . -type f  ! -path './.git/*' \
                ! -name '*.gitignore' \
                      \
                ! -name 'clean_project.sh' \
                ! -name '*.pdf' \
                ! -name '*.so.*' \
                      \
                ! -name '*.v' \
                ! -name '*.bit' \
                ! -name '*.xise' \
                ! -name '*.ucf' \
                ! -name '*.ngc' \
          -delete

# Delete empty directories
find . -type d -empty ! -path './.git/*' \
          -delete
