#!/bin/bash
echo -e "\033[0;32mDeploying updates to GitHub...\033[0m"

msg="rebuilding site `date`"
if [ $# -eq 1 ]
  then msg="$1"
fi

# Push Hugo content 
git add -A
git commit -m "$msg"
git pull origin master
git push origin master

#cd themes/hugo-nuo
# git pull origin master
#cd ../../


# Build the project. 
hugo -t hugo-nuo # if using a theme, replace by `hugo -t <yourtheme>`

# Go To Public folder
cd public/
# Add changes to git.
git add -A

# Commit changes.

git commit -m "$msg"

# Push source and build repos.
git pull origin master
git push origin master
git commit -m "rebuild site" --allow-empty
git push origin master

