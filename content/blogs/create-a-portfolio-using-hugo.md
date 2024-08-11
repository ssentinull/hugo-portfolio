---
title: "Craft a Web-Based Portfolio using Hugo."
date: "2021-11-08"
author: "ssentinull"
cover: "img/blogs/create-a-portfolio-using-hugo/0.jpg"
description: "Create a beatiful portfolio website in less than an hour using Hugo."
tags: ["portfolio", "hugo", "markdown", "git"]
---

## Introduction.

In this guide, we'll go through a step-by-step process of crafting a stunning web-based portfolio using the power of Hugo.

> :mega: **Shout-out!** :mega:
>
> Shout-out to [fahmifan](https://github.com/fahmifan) for sharing his knowledge and allowing me to write about it in my blog. Please show some love for his [portfolio repo](https://github.com/fahmifan/fahmifan.github.io).

## Download Hugo.

Begin by visiting Hugo's [installation page](https://gohugo.io/getting-started/installing/) where you'll find instructions tailored to your operating system. If you're an Ubuntu user like myself, you can conveniently install Hugo through the official Hugo Debian package.

```shell
$ sudo apt-get install hugo
```

## Create a Hugo site.

Once Hugo is installed, it's time to initiate our workspace. Create your Hugo site and establish a Git repository within that directory. The [second part](/blogs/auto-deploy-portfolio-to-github-pages/) of this tutorial will delve into automating the deployment of your portfolio to [Github Pages](https://pages.github.com/), so having a Git repository is crucial.

```shell
$ hugo new site hugo-portfolio
$ cd hugo-portfolio
$ git init
```
Run the Hugo server via your CLI. Don't worry if your browser remains blank at this point. The reason is that we haven't selected a theme yet, which is our next step. But before moving on, make sure to commit the newly added files.

```shell
$ hugo serve
```

## Choose a Theme.

Within Hugo's [theme store](https://themes.gohugo.io/) lies a diverse collection of community-crafted themes. Each theme comes with relevant tags, simplifying the hunt for a design that matches your style and personality. Personally, I'm drawn to clean lines and basic colors, which is why I've opted for the [hello-friend](https://themes.gohugo.io/themes/hugo-theme-hello-friend/) theme.

Since we want to tweak the chosen theme, it's essential to fork it to your Github account and treat that fork as a submodule. To achieve this, navigate to the theme's [Github repository](https://github.com/panr/hugo-theme-hello-friend) and fork it into your account. Subsequently, integrate the forked repository into your workspace, specifically within the `themes/theme_name` directory.

```shell
$ git submodule add https://github.com/your_account_name/hugo-theme-hello-friend.git themes/hello-friend
```

As you explore the theme gallery, you'll encounter a plethora of designs, ranging from bold to understated, from vibrant to muted. Although their appearances differ, all these themes share a common configuration file, `config.toml`. The configuration specifics for each theme are accessible on their respective theme pages. For instance, details about the hello-friend theme can be found [here](https://themes.gohugo.io/themes/hugo-theme-hello-friend/#how-to-configure). Copy-paste the values in your local `config.toml` file and your page should look like this.

{{< image src="/img/blogs/create-a-portfolio-using-hugo/1.png" position="center" >}}

This looks great, but there are some things that I want to change about the looks, like the cursor color next to the __> hello friend__ text and the default color scheme for example. We'll do that in the next step after we commit the changes that we've made.

## Customize a Theme.

Let's say that we want to change our color scheme from dark to light. We can do so from the `config.toml` file. To change it, simply change the `defaultTheme` value from `dark` to `light`.

{{< image src="/img/blogs/create-a-portfolio-using-hugo/2.png" position="center" >}}

Changing the cursor color, however, is not as simple. The cursor color is not set to be modifiable through the `config.toml` by the theme's creator, so we need to make changes to the source code. 

Given that the theme operates from a distinct repository than our workspace, adjustments should be made in the theme's repository. To prevent future conflicts with theme updates, implement these changes within a separate feature branch. We'll call this branch `portfolio`. Make sure you also define the branch from which you want to pull the submodules next time you initialize a fresh clone of this repo by adding `branch = portfolio` to `.gitmodules`.

```shell
$ cd themes/hello-friend
$ git checkout -b portfolio master
```

{{< code language="gitmodules" title=".gitmodules" id="1" isCollapsed="false" >}}

    [submodule "themes/hello-friend"]
    path = themes/hello-friend
    url = https://github.com/ssentinull/hugo-theme-hello-friend.git
    branch = portfolio

{{< /code >}}

To safely edit this theme, you need [NodeJs](https://nodejs.org/en/), [NPM](https://www.npmjs.com/), and [Yarn](https://yarnpkg.com/) installed on your machine. I'm not gonna explain how to install those three in this tutorial cause it'll take too long. Once these tools are in place, proceed by installing the required NPM packages.

```shell
$ npm i
$ npm i yarn
$ yarn
```

To change the color of the cursor, go to `/assets/css/logo.css` and change the `background` hexadecimal value of `&__cursor` style. To see the changes, run the theme in development mode to enable automatic reloading upon code changes. If it doesn't change, reload the page and delete the cached data by pressing `CTRL+Shift+R`. 

{{< image src="/img/blogs/create-a-portfolio-using-hugo/3.png" position="center" >}}

Once you've picked a color that you like, rebuild the theme, commit it, and push it to Github.

```shell
$ yarn dev
$ yarn build
$ git push -u origin portfolio
```

Even though we've created a separate repo for our theme and pushed it to its origin, we haven't added it to our workspace's repo. To add it, simply navigate back to our workspace repo, add the theme directory, commit it, then push it to Github.

```shell
$ cd ../../
$ git add themes/
$ git commit -m "feat: adding themes/ directory"
$ git push origin master
```

## Add Contents.

With the visual aspects sorted, let's continue to the main reason why we're making this site in the first place—to showcase yourself and your projects. We'll start with the former. 

While a button linking to the _About_ page is already exist in the navigation bar, clicking it leads to a `404 Page Not Found` error. The reason is because that page doesn't exist yet. Hugo works by reading the contents of `.md` files inside the `/content` directory, then it generates static pages based on the contents. The `config.toml` file dictates how the static pages get routed.

{{< code language="toml" title="config.toml" id="2" isCollapsed="false" >}}

    ...

    [[languages.en.menu.main]]
    identifier = "about"
    name = "About"
    url = "/about"

{{< /code >}}

If you take a look at the snippet above, you'll notice that the `identifier` config is the name of the file inside of `/content`, the `name` config is the label that shows up in the navigation bar, and the `url` config is the endpoint that will be generated for that static page. With that information, create an `about.md` file inside the `/content` directory.

{{< code language="md" title="about.md" id="3" isCollapsed="false" >}}

---

title: "About Me"
date: "2021-07-11"
author: "ssentinull"

---

## Lipsum 2

[Lorem ipsum](https://www.lipsum.com/) **dolor** _sit amet_, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

> _Nam libero tempore, cum soluta nobis est eligendi optio cumque nihil impedit quo minus id quod maxime placeat facere possimus, omnis voluptas assumenda est, omnis dolor repellendus._
>
> **- Lorem Ipsum**

### Lipsum 3

Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?

Lipsum:

- Lorem ipsum dolor sit amet.
- Consectetur adipiscing elit.
  - Lorem ipsum dolor sit amet.
- Sed do eiusmod tempor.
  - Consectetur adipiscing elit.
  - Sed do eiusmod tempor.

### Lispum 4

At vero eos et accusamus et iusto odio dignissimos ducimus qui blanditiis praesentium voluptatum deleniti atque corrupti quos dolores et quas molestias excepturi sint occaecati cupiditate non provident, similique sunt in culpa qui officia deserunt mollitia animi, id est laborum et dolorum fuga. Et harum quidem rerum facilis est et expedita distinctio.

Lipsum:

1. Lorem ipsum dolor sit amet.
2. Consectetur adipiscing elit.
   - Lorem ipsum dolor sit amet.
3. Sed do eiusmod tempor.
   - Consectetur adipiscing elit.
   - Sed do eiusmod tempor.

{{< /code >}}

After you paste the code above and reload the page, the page should exist.

{{< image src="/img/blogs/create-a-portfolio-using-hugo/4.png" position="center" >}}

We're done with our self-introduction page, now let's move on to our projects page. The projects page is similar to the about page, only needing a few modifications. First, we need to change the text in the navigation bar from `showcase` to `projects` by modifying the `config.toml` file.

{{< code language="toml" title="config.toml" id="4" isCollapsed="false" >}}

    ...

    [[languages.en.menu.main]]
    identifier = "projects"
    name = "Projects"
    url = "/projects"

{{< /code >}}

The difference between the about page and the projects page is that the former only consist of a single page and the latter could consist of multiple pages. For this reason we need to create `/projects` inside `/content`. 

The routing for `/projects` endpoint will look like this: `/projects/file-1-name`,`/projects/file-2-name`. So create two files inside `/projects` named `project-one.md` and `project-two.md`.

{{< code language="md" title="project-one.md & project-two.md" id="5" isCollapsed="false" >}}

---

title: "Project One : Web Portfolio"
date: "2021-07-11"
author: "ssentinull"
tags: ["web-app", "hugo", "golang"]
description: "A web-based portfolio to showcase a developer's skill, built using Hugo and Golang."

---

## Description.

Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

## Background.

Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem.

## Features.

- Lorem ipsum dolor sit amet.
- Consectetur adipiscing elit.
- Sed do eiusmod tempor.

## Tools.

- [Hugo](https://gohugo.io/)
- [Golang](https://golang.org/)

## How to Run in Local Environment.

1. Install Hugo

   ```shell
   $ apt-get install hugo
   ```

2. Create a new site

   ```shell
   $ hugo new site hugo-portfolio
   ```

3. Run the app

   ```shell
   $ hugo serve
   ```

## Demo.

- Working app

  {{< image src="https://miro.medium.com/max/384/0*A6EB_Ykks5bPp_rM.gif" position="center" >}}

{{< /code >}}

Finally, because we want our projects page to be our centerpiece, we need to make it so by routing the `/projects` endpoint as our entry point in `config.toml`.

{{< code language="toml" title="config.toml" id="6" isCollapsed="false" >}}

    ...

    [params]

    # dir name of your blog content (default is `content/posts`).
    # the list of set content will show up on your index page (baseurl).
    contentTypeName = "projects"

    ...

    [languages.en.params.logo]
    logoHomeLink = "/projects"
    logoText = "hello friend"

    ...

{{< /code >}}

{{< image src="/img/blogs/create-a-portfolio-using-hugo/5.png" position="center" >}}

{{< image src="/img/blogs/create-a-portfolio-using-hugo/6.png" position="center" style="margin-top: 40px;" >}}

Voila! :tada: :confetti_ball: You have successfully created your very own portfolio! :fire::fire:

In less than an hour you've created yourself a beautiful, customizable portfolio website using Hugo. Now it's up to you to get creative with it by tweaking the themes and adding your contents to it.

I hope this could be beneficial to you. Thank you for taking the time to read this article. :pray:

-- ssentinull
