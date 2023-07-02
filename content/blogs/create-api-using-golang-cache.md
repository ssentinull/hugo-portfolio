---
title: "Create APIs using Golang | Part 4 : Implementing Cache."
date: "2023-06-23"
author: "ssentinull"
cover: "img/blogs/create-api-using-golang-cache/0.jpg"
description: "*Cache* is King."
tags: ["cache", "api", "golang"]
---

## Introduction.

Database is handy for storing data, but its performance can take a hit if it's handling massive amounts of transactions. To aleviate some load off the database, also to introduce a faster method of data retreival, caching is required.

## What is a Cache.

Cache is similar to a database, it's a place where we store data. But where a database stores its data in a disk or drive, a cache stores its data in memory. Cache also has a much simpler method of organizing its data. For these reasons, data retrieval using cache is significantly faster.

Storing data in memory has its drawbacks however. First of which is persistance. Memory is volatile in nature, meaning to stay that it will retain its data as long as electricity is running through it. Memory also retains as long as the application using that memory is still running. If the power cuts off or the application is closed then the data is lost.

Second of which is data structure. We know that persistant database comes in various shapes and sizes; relational database, document-based database, and graph database to name a few. And for each of the types of persistant database we can define a schema depending on our needs. But in the case of cache, it's structure is limited to key-value pairs. So imagine a map data structure but for storing data.

In this tutorial, we'll be using Redis.

## Performance Metrics.

To measure the improvement in performance cache brings us, we need some kind of metrics to compare the storage methods by. I don't plan on making article very scientfic, so we'll just use an API's response time as the metrics.

Currently our service has two endpoints to retrieve data:

1. `/books/:id`: fetch a book by its `id`.
2. `/books`: fetch multiple books.

We'll be using `/books` to compare the metrics because fetching multple data would be a more demanding task for our storage methods.

## Creating a Database Seeder.

To make the retrieval process even more demanding, we need to fetch a lot of data, up to the hundreds. Creating hundreds of data manually through our API or database client is a chore, so instead of doing it manually we can make a database seeder to automatically create rows of fake data.

We'll be using a library called [gofakeit](https://github.com/brianvoe/gofakeit) to generate fake data. This library can generate fake data from a wide range of domains, including `person`, `address`, `game`, `car`, and of course `book`.

{{< code language="go" title="/cmd/seeder/main.go" id="3" isCollapsed="false" >}}

    package main

    import (
        "context"
        "flag"
        "os"

        "github.com/brianvoe/gofakeit/v6"
        "github.com/sirupsen/logrus"
        "github.com/ssentinull/create-apis-using-golang/internal/config"
        "github.com/ssentinull/create-apis-using-golang/internal/db"
        "github.com/ssentinull/create-apis-using-golang/internal/model"
        "github.com/ssentinull/create-apis-using-golang/internal/repository"
        "github.com/ssentinull/create-apis-using-golang/internal/utils"
    )

    // initialize logger configurations
    func initLogger() {
        logLevel := logrus.ErrorLevel
        switch config.Env() {
        case "dev", "development":
            logLevel = logrus.InfoLevel
        }

        logrus.SetFormatter(&logrus.TextFormatter{
            ForceColors:     true,
            DisableSorting:  true,
            DisableColors:   false,
            FullTimestamp:   true,
            TimestampFormat: "15:04:05 02-01-2006",
        })

        logrus.SetOutput(os.Stdout)
        logrus.SetReportCaller(true)
        logrus.SetLevel(logLevel)
    }

    func init() {
        config.GetConf()
        initLogger()
    }

    func main() {
        seed := flag.Int("seed", 1, "number of seed")
        flag.Parse()

        db.InitializePostgresConn()
        db.InitializeRedisConn()

        cacheRepo := repository.NewCacheRepository(db.RedisClient)
        bookRepo := repository.NewBookRepository(db.PostgresDB, cacheRepo)

        logrus.Infof("Running %d seeds!", *seed)

        for i := 0; i < *seed; i++ {
            book := &model.Book{
                ID:            utils.GenerateID(),
                Title:         gofakeit.BookTitle(),
                Author:        gofakeit.BookAuthor(),
                Description:   gofakeit.Paragraph(1, 3, 10, "."),
                PublishedDate: gofakeit.Date().Format("2006-01-02"),
            }

            if err := bookRepo.Create(context.TODO(), book); err != nil {
                logrus.WithField("book", utils.Dump(book)).Error(err)
            }
        }

        logrus.Info("Finished running seeder!")

}

{{< /code >}}

{{< code language="Makefile" title="Makefile" id="2" isCollapsed="false" >}}

    # command to run db seeder based on number of $(seed)
    # eg: make seed-db seed=10
    seed-db:
        go run internal/cmd/seeder/main.go -seed=$(seed)

{{< /code >}}

```shell
$ make seed-db seed=100
```

If we run the above command and check on our database client, we'll see that our `books` table have been filled with 100 rows of data.

<!-- insert screenshot of postico -->

## References.

1. [7 Database Paradigms](https://www.youtube.com/watch?v=W2Z7fbCLSTw&t=19s)
2. [What is a Relational Database?](https://cloud.google.com/learn/what-is-a-relational-database)
3. [What is an ORM – The Meaning of Object Relational Mapping Database Tools](https://www.freecodecamp.org/news/what-is-an-orm-the-meaning-of-object-relational-mapping-database-tools/)
