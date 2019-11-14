#!/bin/bash

rm -rf _site

if [ -z "$(git status --porcelain)" ]; then
    echo ">>> Working directory clean"
    TMP_LOC=/tmp/deepu.github.io

    /bin/rm -rf _site || exit
    /bin/rm -rf $TMP_LOC || exit

    echo ">> Building site"
    bundle update listen || exit
    bundle exec jekyll build

    echo ">> Move site to temp folder"
    mkdir --parents $TMP_LOC || exit
    mv _site/* $TMP_LOC || exit

    echo ">> Checkout and clean master"
    git checkout master || exit
    find -mindepth 1 -depth -print0 | grep -vEzZ '(temp(/|$)|vendor(/|$)|\.git(/|$)|/\.gitignore$)' | xargs -0 rm -rvf || exit

    echo ">> Move site form temp & publish to GitHub"
    mv $TMP_LOC/* . || exit
    now=$(date)
    git add --all || exit
    git commit -am "Updated site on $now" || exit
    git push origin master --force || exit

    echo ">> $now: Published changes to GitHub"

    git checkout site_src
else
    echo ">> Working directory is not clean. Commit changes!"
    exit
fi
