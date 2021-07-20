#! /bin/sh

echo -e "\e[1;33m start deploying \e[0m"

# builds the static site to /public
hugo -t hello-friend

# go to /public directory
cd public

# add all the generated files
git add .

# commit the generated files 
message="feat: rebuild site on `date`"
git commit -m "$message"

# push the commit to origin master branch
git push origin master

# move back to root project directory
cd ..

# switch to dev branch
git checkout dev

# add new contents & rebuilt site
git add content/ public/

# commit the changes
git commit -m "$message"

# push the commit to origin dev branch
git push origin dev

echo -e "\e[1;32m finished deploying \e[0m"
