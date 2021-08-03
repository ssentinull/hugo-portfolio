---
title: "Chi-Square Feature Selection."
date: "2020-07-19"
author: "ssentinull"
tags: ["cli-program", "data-processing", "node-js", "javascript", "json"]
description: "A cli-based feature selection using the Chi-Square method."
---

## Description.

This is a Chi-Square feature selection module based on the research done by Wang, D., Liang, Y., Xu, D., Feng, X., & Guan, R. [[1]](#reference) that processes scientific journal abstract data, written in NodeJs. This module will determine the most dependent set of words to a given set of journals. The more dependent a word is on a journal, the more representative that word is to the journal. This module uses a version of the Chi-Square equation from [[1]](#reference) to calculate the dependence of a word to a journal based on the following formula :

{{< image src="/img/chi-square-formula.svg" position="center" >}}

Where :

- **_A_** is the number of documents including word **_t_**, which belongs to journal **_c_**.
- **_B_** is the number of documents including word **_t_**, which does not belong to journal **_c_**.
- **_C_** is the number of documents in journal **_c_**, which does not include the word **_t_**.
- **_D_** is the number of documents in journals other than journal **_c_**, which does not include the word **_t_**.

[Here](https://github.com/ssentinull/chi-square-module) is the link to access the Github repository.

## Background.

This is a sub-project for my Bachelor's thesis. My main thesis project was to build a [Journal Recommender Application](/projects/journal-recommender-application/) using a Softmax Regression model as the classifier. I already gathered textual data online using my [Web Scraper](/projects/web-scraper), but the text is still in the form of complete paragraphs. So to turn the paragraphs into features that can be learned by the model, I created this sub-project.

## Features.

- Aggregates 150 words with the highest Chi-Square value for each journal and remove any duplicate words.
- Groups 150 words with the highest Chi-Square value for each journal by their respective journals.
- Logs the **_A_**, **_B_**, **_C_**, **_D_** variables for each word to each journal as well as their Chi-Square values.

## Input.

The input file can be found in the `./data/input/` directory, which stores a list of JSON objects with the following structure :

{{< code language="json" title="Input Data." id="1" isCollapsed="true" >}}
[
{
"JOURNAL_ID": 0,
"JOURNAL_TITLE": "Jurnal Hortikultura",
"ARTICLE_ID": 0,
"ARTICLE_TITLE": "SISTEM TANAM TUMPANG SARI CABAI MERAH DENGAN ... DAN BUNCIS TEGAK ",
"ARTICLE_ABSTRACT": "Pola tanam tumpang sari merupakan salah satu cara untuk meningkatkan efisiensi ... tumpang sari cabai dengan kentang dan bawang merah merupakan usahatani yang paling menguntungkan terutama apabila dibandingkan dengan monokultur.",
"TOKENS": [ "pola", "tanam", "tumpang", "sari", "rupa", "salah", "tingkat", "efisiensi", ... , "tumpang", "sari", "usahatani", "tumpang", "sari", "cabai", "kentang", "bawang", "merah", "rupa", "usahatani", "untung", "utama", "banding", "monokultur" ],
"TOKENS_DUPLICATE_REMOVED": [ "pola", "tanam", "tumpang", "sari", "rupa", "salah", ... , "tumbuh", "vegetatif", "beda", "nyata", "tara", "untung", "bersih", "usahatani", "utama", "banding" ]
},
... ,
{
"JOURNAL_ID": Number,
"JOURNAL_TITLE": String,
"ARTICLE_ID": Number,
"ARTICLE_TITLE": String,
"ARTICLE_ABSTRACT": String,
"TOKENS": Array,
"TOKENS_DUPLICATE_REMOVED": Array
}
]
{{< /code >}}

## Output.

This module produces three different files with differing outputs:

1. The file in the `./data/output/fv-tokens.json` directory is used to save the 150 aggregated words with the highest Chi-Square value for each journals and removes any duplicate words.

   {{< code language="json" title="Aggregated words with the highest Chi-Square values from every journals." id="2" isCollapsed="true" >}}
   [
   "tanam",
   "balai",
   "varietas",
   "ulang",
   "sayur",
   ... ,
   "kawat",
   "struktur",
   "superplasticizer",
   "wulung"
   ]
   {{< /code >}}

2. The file in the `./data/output/fv-tokens-by-journal.json` directory is used to save the 150 words with the highest Chi-Square values, grouped by their respectives journal IDs.

   {{< code language="json" title="Words with the highest Chi-Square values for each journals." id="3" isCollapsed="true" >}}
   {
   "0": [
   "tanam",
   "balai",
   "varietas",
   "ulang",
   "sayur",
   ... ,
   "hasil",
   "manggis",
   "patogen"
   ],
   ... ,
   "n_journals" : [
   String,
   String,
   String,
   ... ,
   String,
   String
   ]
   }
   {{< /code >}}

3. The file in the `./data/output/chi-square-feature-vectors.json` directory is used to log the **_A_**, **_B_**, **_C_**, **_D_**, journal ID, and Chi-Square values for each word.

   {{< code language="json" title="Chi-Square value & variables for every words from each journals." id="4" isCollapsed="true" >}}
   [
   {
   "JOURNAL_ID": 0,
   "TOKEN": "tanam",
   "A_VALUE": 626,
   "B_VALUE": 501,
   "C_VALUE": 137,
   "D_VALUE": 6633,
   "CHI_SQUARE": 2185638.198645179
   },
   ... ,
   {
   "JOURNAL_ID": Number,
   "TOKEN": String,
   "A_VALUE": Number,
   "B_VALUE": Number,
   "C_VALUE": Number,
   "D_VALUE": Number,
   "CHI_SQUARE": Number
   }
   ]
   {{< /code >}}

## Tools.

- [CSV-Writer](https://www.npmjs.com/package/csv-writer)
- [Lodash.GroupBy](https://www.npmjs.com/package/lodash.groupby)
- [Lodash.MapValues](https://www.npmjs.com/package/lodash.mapvalues)
- [Lodash.UniqBy](https://www.npmjs.com/package/lodash.uniqby)
- [Neat-CSV](https://www.npmjs.com/package/neat-csv)

## How To Run in Local Environment.

```shell
$ node src/index.js
```

## Demo.

![](https://media.giphy.com/media/Rf4xdYQHIW4vLBS66p/giphy.gif)

## Reference. {#reference}

- [1] Wang, D., Liang, Y., Xu, D., Feng, X., & Guan, R. (2018).
  A content-based recommender system for computer science publications.Knowledge-Based Systems, 157, 1-9.
