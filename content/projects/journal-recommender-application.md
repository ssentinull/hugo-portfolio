---
title: "Journal Recommender Application."
date: "2020-08-01"
author: "ssentinull"
tags: ["web-app", "machine-learning", "flask", "python", "heroku"]
description: "A web-based application that recommends Indonesian scientific journals."
---

## Description.

This web app recommends Indonesian scientific journals that best fit the user's scientific paper. The premise is quite simple: the user inputs the abstract for their scientific article, and the application outputs a list of journals ordered descendingly by how similar they are to the article in terms of percentages. It's able to do this because it utilizes a previously trained Softmax Regression model that's deployed to the web app.

Softmax Regression is a version of Logistic Regression the switches the Sigmoid function in the output layer with a Softmax function. To put it simply, while a Logistic Regression model classifies the input data dichotomously (yes or no; cat or dog) with a 100% certainty, a Softmax Regression model classifies the input data multinomially (yes, no, or maybe; cat, dog, mouse, or bird) with differing percentages for each class. The model is trained on a dataset that was scraped from [SINTA](https://sinta.ristekbrin.go.id/) and [Garuda](https://garuda.ristekbrin.go.id/journal) using a [web scraper](/projects/web-scraper) that I built in conjunction with this web app, and the features of the dataset were selected using a Chi-Square feature selection program that I also built.

[Here](https://github.com/ssentinull/journal-recommender-system-website) is the link for the Github repository and [here](https://sistem-rekomendasi-jurnal.herokuapp.com/) is the link for the demo of the app. The demo could be slow to start because I deployed it to the free version of Heroku and it takes time for the dyno to spin up if it hasn't been used in a while.

## Background.

This is a project for my Bachelor's thesis. The idea came up when I was casually browsing the internet to find journals that I could use as inspiration for my thesis. I came across a [feature](https://journalfinder.elsevier.com/) from [Elsevier](https://www.elsevier.com/en-xs) that allows researchers to find the best journals that fit their scientific papers. After searching whether or not there was an Indonesian counterpart available online (which there wasn't at that time), and knowing that my major's specialization was Artificial Intelligence, I ended up doing this project.

## Features.

- Utilizes a trained Softmax Regression model and Chi-Square feature selection.
- Outputs journal recommendations in the form of probabilities.
- Recommends journal with the highest probability as the main recommendation and outputs a summary and a link for said recommended journal.
- Works properly only with **Indonesian** abstracts.
- Only allows abstracts that consist of 100 - 350 words as input.
- Recommends 12 different journals:

| No. |                                                     Name                                                      | Scope of Knowledge  |
| :-: | :-----------------------------------------------------------------------------------------------------------: | :-----------------: |
| 1.  |                 [Jurnal Hortikultura](http://ejurnal.litbang.pertanian.go.id/index.php/jhort)                 |    Horticulture     |
| 2.  |          [Jurnal Penelitian Perikanan Indonesia](http://ejournal-balitbang.kkp.go.id/index.php/jppi)          |      Fisheries      |
| 3.  |                 [Jurnal Riset Akuakultur](http://ejournal-balitbang.kkp.go.id/index.php/jra)                  |     Aquaculture     |
| 4.  |            [Jurnal Jalan-Jembatan](http://jurnal.pusjatan.pu.go.id/index.php/jurnaljalanjembatan)             |  Road Construction  |
| 5.  |     [Jurnal Penelitian Hasil Hutan](http://ejournal.forda-mof.org/ejournal-litbang/index.php/JPHH/index)      |     Forestries      |
| 6.  | [Jurnal Penelitian Hutan dan Konservasi Alam](http://ejournal.forda-mof.org/ejournal-litbang/index.php/JPHKA) | Forest Conservation |
| 7.  |                        [E-Jurnal Medika Udayana](https://ojs.unud.ac.id/index.php/eum)                        |  Medical Sciences   |
| 8.  |                          [Jurnal Simetris](https://jurnal.umk.ac.id/index.php/simet)                          |     Technology      |
| 9.  |                        [Jurnal Teknik ITS](http://ejurnal.its.ac.id/index.php/teknik)                         |     Technology      |
| 10. |                         [Berita Kedokteran Masyarakat](https://jurnal.ugm.ac.id/bkm)                          |    Public Health    |
| 12. |                   [Indonesia Medicus Veterinus](https://ojs.unud.ac.id/index.php/imv/index)                   |     Veterinary      |
| 13. |                           [Matriks Teknik Sipil](https://jurnal.uns.ac.id/matriks)                            |  Civil Engineering  |

## Tools.

- [Python](https://www.python.org/)
- [Flask v.1.1.x](https://flask.palletsprojects.com/en/1.1.x/)
- [Flash-Bootstrap](https://pythonhosted.org/Flask-Bootstrap/)
- [Jinja v.2.11.x](https://jinja.palletsprojects.com/en/2.11.x/)
- [NumPy](https://numpy.org/)
- [Sastrawi](https://pypi.org/project/Sastrawi/)
- [WTForms v.2.3.x](https://wtforms.readthedocs.io/en/2.3.x/)
- [Heroku](https://www.heroku.com/)

## How to Configure in Local Environment.

After cloning the [repository](https://github.com/ssentinull/journal-recommender-system-website), do the following steps:

1. Create a virtual environment in the cloned dir.

   ```shell
   $ python3 -m venv venv
   ```

2. Activate the virtual environment/.

   ```shell
   $ source venv/bin/activate
   ```

3. Install all the dependencies listed in `requirements.txt`.

   ```shell
   $ pip install -r requirements.txt
   ```

4. Setup the flask environment variable in `.env`.

   ```env
   SECRET_KEY=your_secret_key
   ABSTRACT_TOKEN_SAVE_DIR=./data/output/abstract-token-list.json
   TF_IDF_SAVE_DIR=./data/output/tf-idf.csv
   FV_TOKENS_OPEN_DIR=./data/fv-tokens
   JOURNAL_DATA_OPEN_DIR=./static/journal_info
   ```

5. Deactivate and reactivate the virtual environment.

   ```shell
   $ deactivate
   $ source venv/bin/activate
   ```

## How to Run in Local Environment.

After configuring it locally, do the following steps every time you want to run the app:

1. Activate the virtual environment.

   ```shell
   $ source venv/bin/activate
   ```

2. Export the shell environment variables.

   ```shell
   $ export FLASK_APP=server.py
   $ export FLASK_ENV=development
   ```

3. Run the app.

   ```shell
   $ flask run
   ```

## Demo.

- Input validation

  ![](https://media.giphy.com/media/J3SLW8RvR55zMea4h1/giphy.gif)

- Recommendation result

  ![](https://media.giphy.com/media/daJ6Z7uG5e8Four7Mj/giphy.gif)
