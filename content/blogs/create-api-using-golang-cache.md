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

## What is Cache.

Cache is similar to a database, it's a place where we store data. But where a database stores its data in a disk or drive, a cache stores its data in memory. Cache also has a much simpler method of organizing its data. For these reasons, data retrieval using cache is significantly faster.

Storing data in memory has its drawbacks however. First of which is persistance. Memory is volatile in nature, meaning to stay that it will retain its data as long as electricity is running through it. Memory also retains as long as the application using that memory is still running. If the power cuts off or the application is closed then the data is lost.

Second of which is data structure. We know that persistant database comes in various shapes and sizes; relational database, document-based database, and graph database to name a few. And for each of the types of persistant database we can define a schema depending on our needs. But in the case of cache, it's structure is limited to key-value pairs. So imagine a map data structure but for storing data.

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

## Implementing Cache.

We'll be using [Redis](https://redis.io/) for our cache engine and [go-redis](https://github.com/redis/go-redis) for our Golang client. We use Redis because it solves the issue of persistance; Redis can persist data even if its server is off by saving snapshots of the dataset and saving it on the disk.

> :heavy_exclamation_mark: **Disclaimer** :heavy_exclamation_mark:
>
> The entire cache implementation is not included in this article because it would be too long. So if you're following along with this article and run into missing codes, you can check out the [Github repo](https://github.com/ssentinull/create-apis-using-golang).

{{< code language="go" title="internal/model/cache.go" id="3" isCollapsed="false" >}}

    package model

    import "context"

    type CacheRepository interface {
        Get(ctx context.Context, key string) (reply string, err error)
        Set(ctx context.Context, key, val string) (err error)
        Delete(ctx context.Context, keys ...string) (err error)
    }

{{< /code >}}

Our cache implementation will be wrapped inside an interface so that if we want to change our Golang Redis client we only need to change its implementation.

{{< code language="go" title="internal/repository/cache_repository.go" id="4" isCollapsed="false" >}}

    package repository

    import (
        "context"

        "github.com/redis/go-redis/v9"
        "github.com/ssentinull/create-apis-using-golang/internal/model"
    )

    type cacheRepo struct {
        redisClient *redis.Client
    }

    func NewCacheRepository(client *redis.Client) model.CacheRepository {
        return &cacheRepo{redisClient: client}
    }

    func (c *cacheRepo) Get(ctx context.Context, key string) (string, error) {
        val, err := c.redisClient.Get(ctx, key).Result()
        if err != nil && err != redis.Nil {
            return "", err
        }
        return val, nil
    }

    func (c *cacheRepo) Set(ctx context.Context, key, val string) error {
        return c.redisClient.Set(ctx, key, val, 0).Err()
    }

    func (c *cacheRepo) Delete(ctx context.Context, keys ...string) error {
        return c.redisClient.Del(ctx, keys...).Err()
    }

{{< /code >}}

go-redis implementation is pretty straightforward, all we need to do is provide a string key and a string value. The `Set()` and `Delete()` functions only return an `error` while the `Get()` function returns a `string` and an `error`.

{{< code language="go" title="internal/repository/cache_repository.go" id="4" isCollapsed="false" >}}

    package repository

    import (
        "context"
        "encoding/json"
        "fmt"

        "github.com/sirupsen/logrus"
        "github.com/ssentinull/create-apis-using-golang/internal/model"
        "github.com/ssentinull/create-apis-using-golang/internal/utils"
        "gorm.io/gorm"
    )

    type bookRepo struct {
        db        *gorm.DB
        cacheRepo model.CacheRepository
    }

    func NewBookRepository(db *gorm.DB, cacheRepo model.CacheRepository) model.BookRepository {
        return &bookRepo{
            db:        db,
            cacheRepo: cacheRepo,
        }
    }

    func (br *bookRepo) Create(ctx context.Context, book *model.Book) error {
        logger := logrus.WithFields(logrus.Fields{
            "ctx":  utils.Dump(ctx),
            "book": utils.Dump(book),
        })

        ...

        if err := br.cacheRepo.Delete(ctx, br.findAllCacheKey()); err != nil {
            logger.Error(err)
            return err
        }

        return nil
    }

    func (br *bookRepo) DeleteByID(ctx context.Context, ID int64) error {
        logger := logrus.WithFields(logrus.Fields{
            "ctx": utils.Dump(ctx),
            "ID":  ID,
        })

        ...

        cacheKeys := []string{
            br.findByIDCacheKey(ID),
            br.findAllCacheKey(),
        }

        if err := br.cacheRepo.Delete(ctx, cacheKeys...); err != nil {
            logger.Error(err)
            return err
        }

        return nil
    }

    func (br *bookRepo) FindByID(ctx context.Context, ID int64) (*model.Book, error) {
        logger := logrus.WithFields(logrus.Fields{
            "ctx": utils.Dump(ctx),
            "ID":  ID,
        })

        cacheKey := br.findByIDCacheKey(ID)
        reply, err := br.cacheRepo.Get(ctx, cacheKey)
        if err != nil {
            logger.Error(err)
            return nil, err
        }

        if reply != "" {
            book := &model.Book{}
            if err := json.Unmarshal([]byte(reply), &book); err != nil {
                logger.Error(err)
                return nil, err
            }
            return book, nil
        }

        ...

        bytes, err := json.Marshal(book)
        if err != nil {
            logger.Error(err)
            return book, nil
        }

        if err := br.cacheRepo.Set(ctx, cacheKey, string(bytes)); err != nil {
            logger.Error(err)
        }

        return book, nil
    }

    func (br *bookRepo) FindAll(ctx context.Context) ([]*model.Book, error) {
        logger := logrus.WithField("ctx", utils.Dump(ctx))
        cacheKey := br.findAllCacheKey()
        reply, err := br.cacheRepo.Get(ctx, cacheKey)
        if err != nil {
            logger.Error(err)
            return nil, err
        }

        if reply != "" {
            books := []*model.Book{}
            if err := json.Unmarshal([]byte(reply), &books); err != nil {
                logger.Error(err)
                return nil, err
            }
            return books, nil
        }

        ...

        bytes, err := json.Marshal(books)
        if err != nil {
            logger.Error(err)
            return books, nil
        }

        if err := br.cacheRepo.Set(ctx, cacheKey, string(bytes)); err != nil {
            logger.Error(err)
        }

        return books, nil
    }

    func (br *bookRepo) Update(ctx context.Context, book *model.Book) (*model.Book, error) {
        logger := logrus.WithFields(logrus.Fields{
            "ctx":  utils.Dump(ctx),
            "book": utils.Dump(book),
        })

        ...

        cacheKeys := []string{
            br.findByIDCacheKey(book.ID),
            br.findAllCacheKey(),
        }

        if err := br.cacheRepo.Delete(ctx, cacheKeys...); err != nil {
            logger.Error(err)
            return nil, err
        }

        return br.FindByID(ctx, book.ID)
    }

    func (br *bookRepo) findByIDCacheKey(ID int64) string {
        return fmt.Sprintf("book:%d", ID)
    }

    func (br *bookRepo) findAllCacheKey() string {
        return "book:all"
    }

{{< /code >}}

When we fetch data we call our cache before we call our database. If there's a cache hit then we immediately return the value. If there's a cache miss we fetch the data from our database and store the data in our cache afterwards.

When we insert, update, or delete data from our database we need to remember to invalidate our cache to get rid of stale data.
