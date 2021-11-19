---
title: "Deploy your Hugo Portfolio to Github Pages."
date: "2021-11-09"
author: "ssentinull"
cover: "img/blogs/auto-deploy-portfolio-to-github-pages/0.jpg"
description: "Effortlessly deploy static content to Github Pages."
---

## Introduction.

In the [previous article](/blogs/create-a-portfolio-using-hugo), we've covered how to create a beautiful portfolio using Hugo in less than an hour. But what good is it to have an awesome portfolio if no one can see it? So in this article, I'll be showing you how to set up an automatic deployment flow that will deploy to Github Pages using shell scripts.

> :mega: **Shout-out** :mega:
>
> Shout-out to [fahmifan](https://github.com/fahmifan) for sharing his knowledge and allowing me to write about it in my blog. Please show some love for his [portfolio repo](https://github.com/fahmifan/hugo-blog).

## What is Github Pages.

Github Pages is a feature in Github that allows you to host the content of a repository. You don't have to set up any servers nor domain names, Github does that automatically for you. All you have to do is provide the content, let Github takes care of the rest.

However, this ease of use comes with a couple of rules that you must follow. By default, every user is granted a single domain tied to their account, `username.github.io`. And by default, that domain will also be tied to the master branch of the repository with the same name. Since my username is `ssentinull`, my domain will be `ssentinull.github.io`, and this domain will refer to the master branch of `ssentinull.github.io` repository in my account.

With that said, it doesn't mean that Github allows you to host only one repo. No no. If you want to host additional repo, the domain will still be `username.github.io`, but that domain will have an additional endpoint with the value being the project name. So to access your additional hosted repo, the URL will look like something this `username.github.io/project-name`.

Since I'm already using Github Pages for my blog in my Github account, I'll use a different account, so please don't mind the difference in username.

## Set up SSH for Github account.

For the automatic deployment to work, we need to configure SSH on our machine as well as our Github account.

```shell
$ ssh-keygen -t ed25519 -C "your_email@example.com"
$ ssh-add ~/.ssh/id_ed25519
$ cat ~/.ssh/id_ed25519.pub
# copy-paste the output value to Github -> Settings -> SSH & GPG Keys -> New SSH Key
```

If the commands above aren't clear enough, [this](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent) guide shows you how to generate an SSH key and [this](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account) guide shows you how to add the SSH key to your Github account.

## Change Remote Host to SSH.

If your repo's remote origin is HTTPS, make sure to change it to SSH. We need to do this because we'll be using SSH to automatically push our changes to our remote, which we'll cover later in this tutorial.

```shell
# checks whether our remote is HTTPS or SSH
$ git remote -v

# changes the remote host from HTTPS to SSH
$ git remote set-url origin git@github.com:IbnuAhsani/hugo-portfolio-article.git
```

## Create a Repo based on your Username.

This step is pretty self-explanatory, you just need to create a repo called `your_username.github.io` in your account and add a single commit to it.

## Use /public directory as a Submodule.

If you are not aware before, Hugo works by running a webserver and generating static HTML files based on the contents that you write and the theme that you choose. When you run `hugo serve`, Hugo will spin up a web server so that you can view your current work directly in your browser. And when you want to publish your work, you simply run `hugo`, and all the HTML files will be generated in the `/public` directory. These are the files that are gonna be hosted on Github Pages.

In the previous article, we briefly touched on the concept of Git Submodules when we themed our blog. The same concept is gonna be used here as well. We'll use the `/public` directory as a submodule to our `username.github.io` repo. After setting `/public` as our submodule, we generate the files and push them to our `username.github.io` repo as well as our portfolio repo.

```shell
# make sure /public doesn't exist before running git submodule
# use SSH URL instead of HTTPS URL
$ git submodule add git@github.com:IbnuAhsani/ibnuahsani.github.io.git public/
$ hugo

# pushing to username.github.io repo
$ cd public
$ git add .
$ git commit -m "feat: new portfolio"
$ git push origin main # default branch could be main / master

# pushing to portfolio repo
$ cd ..
$ git add .
$ git commit -m "feat: set /public as submodule"
$ git push origin master # default branch could be main / master
```

## Enable Github Pages.

If your repo name is `username.github.io` then Github should automatically enable Github Pages for that repo. But if it isn't, then you can go to Settings -> Pages and enable it there.

{{< image src="/img/blogs/auto-deploy-portfolio-to-github-pages/1.png" position="center" >}}

We've successfully deployed our portfolio to Github Pages!! :tada: :confetti_ball: It wasn't that difficult, right? But then again, if we have to push to multiple repos to deploy our portfolio everytime we make a change could be rather cumbersome. Thankfully, there's a way to automate it.

## Automate the deployment process.

This is where the benefit of using SSH comes in. Notice how when we push our repos to origin we didn't have to input our email and access token. This is possible because we've set up the SSH agent in our machine and registered the corresponding key to our Github account, so now our machine is on their trusted list. To automate the process, we can simply create a Makefile and a shell script that runs all of the commands necessary to deploy our portfolio without having to input a single credential.

{{< code language="makefile" title="Makefile" id="2" isCollapsed="true" >}}

    # run hugo server locally
    run:
        @hugo server

    # build static pages, commit to github, & deploy to github.io
    deploy:
        @bash deploy.sh

{{< /code >}}

{{< code language="shell" title="deploy.sh" id="1" isCollapsed="true" >}}

    #! /bin/sh
    echo -e "\e[1;33m start deploying \e[0m"

    # push to username.github.io repo
    hugo -t hello-friend                    # builds the static site to /public
    cd public                               # go to /public directory
    git checkout main                       # switch to main branch
    git add .                               # add all the generated files
    message="feat: rebuild site on `date`"  # commit the generated files
    git commit -m "$message"
    git push origin main                    # push the commit to origin main branch

    # push to portfolio repo
    cd ..                                   # move back to root project directory
    git checkout master                     # switch to master branch
    git add content/ public/                # add new contents & rebuilt site
    git commit -m "$message"                # commit the changes
    git push origin master                  # push the commit to origin master branch

    echo -e "\e[1;32m finished deploying \e[0m"

{{< /code >}}

```shell
$ make run      # run hugo server
$ make deploy   # run deployment shell
```

Awesome!! :fire::fire: Creating articles and deploying to Github has never been easier!! :grin: :beers:

I hope this could be beneficial to you. Thank you for taking the time to read this article. :pray:

-- ssentinull
