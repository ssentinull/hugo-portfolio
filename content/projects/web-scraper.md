---
title: "Web Scraper."
date: "2020-07-19"
author: "ssentinull"
tags: ["cli-program", "data-scraping", "python", "json"]
description: "A cli-based web scraper that scrapes data from Sinta & Garuda sites."
---

## Description.

This program is used to collect scientific articles' abstracts from journal sites, specifically [SINTA](https://sinta.ristekbrin.go.id/) and [GARUDA](https://garuda.ristekbrin.go.id/journal), through a technique called web-scraping. Web-scraping is the act of collecting information from websites by extracting texts that are embedded in the pages' HTML. It does this by creating an 'agent' that will read and save the texts inside the HTML tags of a page then travel to different pages by accessing the URL that's available on that page.

In the case of this program, a single agent will traverse the table in http://sinta.ristekbrin.go.id/journals and check each row for the `<img>` tag with the class `stat-garuda-small`. If the tag exists, the agent will go deeper by accessing the URL listed in the href property that's anchored to the <a> tag in that specific row. The agent will then traverse the table in said URL, scraping text data from the `<xmp>` tag with the class `abstract-article`. The script will append `"?page=2"` to the URL and increment the page number to continue traversing the following pages. Only after the pages have run out will the agent exit the nested traversal process and continue the main traversal process.

Since the is to collect Indonesian scientific journals and articles, the library [langdetect](https://pypi.org/project/langdetect/) is utilized to make sure that the text data that's scraped is Indonesian. This process is done by extracting the first two sentences of the paragraph and checking the language of both sentences. If the language of one of the two sentences is not Indonesian, then the paragraph would not be scraped.

[Here](https://github.com/ssentinull/scientific-journal-web-scraper) is the link to access the Github repository.

## Background.

This is a sub-project for my Bachelor's thesis. My main thesis project was to build a [Journal Recommender Application](/projects/journal-recommender-application/) using a Softmax Regression model as the classifier. But to create a machine learning model, I need to train the model using some sort of dataset. I tried searching for available dataset online that was relevant to my model, but none existed at the time. So, with the help of [thenewboston](https://www.youtube.com/watch?v=XjNm9bazxn8), I decided to create my own dataset.

## Features.

- Traverses the tables in [SINTA - Science and Technology Index](https://sinta.ristekbrin.go.id/) and [GARUDA - Garda Rujukan Digital](https://garuda.ristekbrin.go.id/journal) sequentially.
- Scrapes journal data from [SINTA - Science and Technology Index](https://sinta.ristekbrin.go.id/).
- Scrapes article abstract data from [GARUDA - Garda Rujukan Digital](https://garuda.ristekbrin.go.id/journal).
- **Only** scrapes Indonesian abstracts by detecting the language of the abstract.

## Data Gathered.

The newly scraped data is saved in `./output/output.csv` directory with the headers `JOURNAL_TITLE`, `ARTICLE_TITLE`, and `ARTICLE_ABSTRACT`. The last time the data is scraped is on April 1st, 2020. The amount of data scraped in total is 157,687 rows, consisting of 2,527 journals, and aggregated in `./data/master/` directory.

## Tools.

- [Python](https://www.python.org/)
- [BeautifulSoup](https://www.crummy.com/software/BeautifulSoup/bs4/doc/)
- [LangDetect](https://pypi.org/project/langdetect/)
- [Requests](https://requests.readthedocs.io/en/master/)

## How to Run in Local Environment.

```shell
$ python3 scrape_web
```

## Demo.

{{< image src="https://media.giphy.com/media/QwyKOyo6te9BsTdAMk/giphy.gif" position="center" >}}
