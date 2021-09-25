#!/bin/bash
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
