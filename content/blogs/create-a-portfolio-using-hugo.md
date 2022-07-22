---
title: "Create a Portfolio using Hugo."
date: "2021-11-08"
author: "ssentinull"
cover: "img/blogs/create-a-portfolio-using-hugo/0.jpg"
description: "Create a beatiful portfolio in less than an hour using Hugo."
tags: ["portfolio", "hugo", "markdown", "git"]
---

## Introduction.

This article will give you a step-by-step tutorial on how to create a beautiful web-based portfolio using Hugo.

> :mega: **Shout-out!** :mega:
>
> Shout-out to [fahmifan](https://github.com/fahmifan) for sharing his knowledge and allowing me to write about it in my blog. Please show some love for his [portfolio repo](https://github.com/fahmifan/fahmifan.github.io).

## Download Hugo.

Head over to Hugo's [installation page](https://gohugo.io/getting-started/installing/) and install it based on your machine's OS. If you're using Ubuntu like me, you can install it through the official Hugo Debian package.

```shell
$ sudo apt-get install hugo
```

## Create a Hugo site.

After installation would be the initialization of our workspace. Create a Hugo site and initialize a Git repository in that directory. Part two of this tutorial will include an automation process to deploy your portfolio to [Github static pages](https://pages.github.com/), so a Git repository is necessary.

```shell
$ hugo new site hugo-portfolio
$ cd hugo-portfolio
$ git init
```

Run the Hugo server in your CLI. If you don't see anything in your browser, don't panic. It's still blank because we haven't picked out a theme yet, and that's exactly what we're gonna do next. But before that, make sure you commit the newly added files.

```shell
$ hugo serve
```

## Choose a Theme.

Hugo provides a wide range of community-built themes in their [theme store](https://themes.gohugo.io/). Each theme is tagged which makes it easier to find the right theme that matches your preference and personality. I personally like simplicity and basic colors, so I use the [hello-friend](https://themes.gohugo.io/themes/hugo-theme-hello-friend/) theme.

Because we want to have the option of modifying the theme, we would need to fork it to our own Github account and use that fork as a submodule. To do that, head over to the theme's [Github repository](https://github.com/panr/hugo-theme-hello-friend) and fork it to your account. After doing so, add the forked repo to your workspace, specifically to the `themes/theme_name` directory.

```shell
$ git submodule add https://github.com/your_account_name/hugo-theme-hello-friend.git themes/hello-friend
```

When you browse the theme page you'll see a diverse set of themes, from the flamboyant to the plain, from the colorful to the pale. Even though they all may look different, all of them are configured using the same file, `config.toml`. The configurations for each theme can be found on their respective theme page. As for the hello-friend theme, you can find it right [here](https://themes.gohugo.io/themes/hugo-theme-hello-friend/#how-to-configure). Copy-paste the values to our local `config.toml` and your page should look like this.

{{< image src="/img/blogs/create-a-portfolio-using-hugo/1.png" position="center" >}}

This looks great, but there are some things that I want to change about the looks, like the cursor color next to the "> hello friend" text and the default color scheme for example. We'll do that in the next step after we commit the changes that we've made.

## Customize a Theme.

Let's say that we want to change our color scheme from dark to light. We can do so from the `config.toml` file. To change it, simply change the `defaultTheme` value from `dark` to `light`.

{{< image src="/img/blogs/create-a-portfolio-using-hugo/2.png" position="center" >}}

However, changing the cursor color won't be as simple as that. The cursor color is not set to be modifiable through the `config.toml` by the theme's creator, so we need to make changes to the source code. Because the theme is a separate repository from our workspace, we need to make the changes from the theme's repository, not from our workspace. To make sure our changes don't conflict with future updates to the theme, we make our changes in a separate feature branch, so that if there were updates we could simply rebase our feature branch. We'll call this branch `portfolio`. Make sure you also define the branch from which you want to pull the submodules next time you initialize a fresh clone of this repo by adding `branch = portfolio` to `.gitmodules`.

```shell
$ cd themes/hello-friend
$ git checkout -b portfolio master
```

{{< code language="gitmodules" title=".gitmodules" id="1" isCollapsed="true" >}}

    [submodule "themes/hello-friend"]
    path = themes/hello-friend
    url = https://github.com/ssentinull/hugo-theme-hello-friend.git
    branch = custom

{{< /code >}}

To safely edit this theme, you need [NodeJs](https://nodejs.org/en/), [NPM](https://www.npmjs.com/), and [Yarn](https://yarnpkg.com/) installed on your machine. I'm not gonna explain how to install those three in this tutorial cause it'll take too long. After installing NodeJs, NPM, and Yarn, install the necessary NPM packages before proceeding.

```shell
$ npm i
$ npm i yarn
$ yarn
```

To change the color of the cursor, go to `/assets/css/logo.css` and change the `background` hexadecimal value of `&__cursor` style. To see the changes, run the theme in dev mode so that it auto reloads on changes to the source code. If it doesn't change, reload the page and delete the cached data by pressing `CTRL+Shift+R`. Once you've picked a color that you like, rebuild the theme, commit it, and push it to Github.

```shell
$ yarn dev
$ yarn build
$ git push -u origin portfolio
```

{{< image src="/img/blogs/create-a-portfolio-using-hugo/3.png" position="center" >}}

Even though we've created a separate repo for our theme and pushed it to its origin, we haven't added it to our workspace's repo. We need to change directory back to our workspace repo, add the theme directory, commit it, then push it to Github.

```shell
$ cd ../../
$ git add themes/
$ git commit -m "feat: adding themes/ directory"
$ git push origin master
```

## Add Contents.

Now that we got the appearance out of the way, let's continue to the main reason why we're making this site in the first place; to showcase yourself and your projects. We'll start with the former. In the navigation bar, there already exists a button that redirects you to the 'About' page. But if you click on it, Hugo will redirect you to a `404 Page Not Found` page. The reason is because that page doesn't exist yet.

Hugo works by reading the contents of `.md` files inside the `/content` directory, then it generates static pages based on the texts. How the static pages get routed is dictated in the `config.toml` file.

{{< code language="toml" title="config.toml" id="2" isCollapsed="true" >}}

    ...

    [[languages.en.menu.main]]
    identifier = "about"
    name = "About"
    url = "/about"

{{< /code >}}

If we take a closer look at the snippet above, you'll notice that the `identifier` config is the name of the file inside of `/content`, the `name` config is the text that shows up in the navigation bar, and the `url` config is the endpoint that will be generated for that static page. By that information, we create an `about.md` file inside the `/content` directory.

{{< code language="md" title="about.md" id="3" isCollapsed="true" >}}

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

We're done with our self-introduction page, now let's move on to our projects page. The concept of the projects page is similar to the about page with minor differences and few modifications. First, we need to change the text in the navigation bar from `showcase` to `projects` by modifying the `config.toml` file.

{{< code language="toml" title="config.toml" id="4" isCollapsed="true" >}}

    ...

    [[languages.en.menu.main]]
    identifier = "projects"
    name = "Projects"
    url = "/projects"

{{< /code >}}

After that, we need to make a `/projects` directory inside of `/contents`. The difference between `/about` and `/projects` is that the former only consist of a single page and the latter could consist of multiple pages. Because of this, we need to create `/projects`. The routing for `/projects` endpoint will look like this: `/projects/file-1-name`,`/projects/file-2-name`. So create two files inside `/projects` named `project-one.md` and `project-two.md`.

{{< code language="md" title="project-one.md & project-two.md" id="5" isCollapsed="true" >}}

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

{{< code language="toml" title="config.toml" id="6" isCollapsed="true" >}}

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
