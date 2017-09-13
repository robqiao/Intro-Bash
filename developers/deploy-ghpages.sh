#!/bin/bash
set -e # Exit with non zero exit code if anything fails

# Get the deploy key by using Travis's stored variables to decrypt deploy_key.enc 
#ENCRYPTED_KEY_VAR="encrypted_${ENCRYPTION_LABEL}_key"
#ENCRYPTED_IV_VAR="encrypted_${ENCRYPTION_LABEL}_iv"
#ENCRYPTED_KEY=${!ENCRYPTED_KEY_VAR}
#ENCRYPTED_IV=${!ENCRYPTED_IV_VAR}
chmod 600 deploy_key
eval `ssh-agent -s`
ssh-add deploy_key

SOURCE_BRANCH="master"

# Configure git and clone the repo
git config --global user.email "$COMMIT_AUTHOR_EMAIL"
git config --global user.name "travis-ci"

SSH_REPO='git@${GH_REF}'

git clone --quiet --branch=gh-pages $SSH_REPO gh-pages > /dev/null 2>&1

#Using GH_TOKEN
#git clone --quiet --branch=gh-pages https://${GH_TOKEN}@${GH_REF} gh-pages > /dev/null 2>&1

# Only commit on changed commit 
#if git diff --quiet; then 
#   echo "No changes to the output on this push; exiting."
#   exit 0
#fi 

# Commit and Push the Changes
cd gh-pages
mkdir -p pdfs-latest
rm -f pdfs-latest/*.pdf
cp -Rf ../*.pdf ./pdfs-latest
git add -f .
git commit -m "Lastest PDFs on successful travis build $TRAVIS_BUILD_NUMBER auto-pushed to gh-pages"

# Auto push the Change
git push $SSH_REPO $TARGET_BRANCH

# Push using Deploy Key 
#git push -fq "https://${DEPLOY_KEY}@${GH_REF}" ${TARGET_BRANCH}  > /dev/null 2>&1
