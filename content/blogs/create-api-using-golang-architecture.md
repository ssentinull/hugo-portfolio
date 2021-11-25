---
title: "Create APIs using Golang | Part 2 : Application Architecture."
date: "2021-11-22"
author: "ssentinull"
cover: "img/blogs/create-api-using-golang-architecture/0.jpg"
description: "Architecture applies just as much in software as it does in buildings."
---

## Introduction.

In the [previous](/blogs/create-api-using-golang-setup/) article, we've set up our workspace that will our developing experience more pleasant. Now it's time to develop the app itself. However, there is one thing I want to point out before we proceed, and that is Clean Architecture.

## What is Architecture.

Before jumping to Clean Architecture, let's discuss what an 'architecture' actually is. Different experts have different definitions of what architecture exactly is. Some say it's 'the fundamental organization of a system' while others define it as 'the way the highest level components are wired together. Since I'm nowhere near to being an expert, I'll just have to defer to the definition provided by the experts, which in essence is 'how we organize our system'.

## Why bother with Architecture.

The quote below sums up why architecture is important.

> _"A poor architecture is a major contributor to the growth of cruft - elements of the software that impede the ability of developers to understand the software. Software that contains a lot of cruft is much harder to modify, leading to features that arrive more slowly and with more defects."_
>
> -- **Martin Fowler, 2019**

## What is Clean Architecture.

Clean Architecture is a concept forwarded by Robert C. Martin (Uncle Bob) in 2021. It takes a layered approach, where a system is divided into multiple layers, each having its roles and rules it must abide by. If drawn into a diagram, Clean Architecture would look like the cross-section of Earth, where Earth's core would be the innermost circle, and encapsulating it are the numerous layers that make up the Earth's mantle.

{{< figure src="/img/blogs/create-api-using-golang-architecture/1.jpg" position="center" caption="Clean Architecture Diagram" >}}

This layering technique produces a system that's testable, independent of frameworks, independent of UI, independent of database, and independent of any external agency. The rule of this architecture is very straightforward; source code dependencies can only point inwards. In other words, the inner circle can know nothing about the outer circle, while something declared in the outer circle can not be mentioned in the inner circle.

As seen in the diagram above, the architecture comprises of four layers:

1. Entities - business rules in the form of objects with methods, or a set of data structures with functions.
2. Use Cases - manages the flow of data to and from entities.
3. Interface Adapters - converts use cases' or entities' data format to external agency's data format.
4. Frameworks and Drives - consists of external frameworks and tools.

## Implementing Entities.

In our project, we'll refer to 'entities' as 'models'. Since we're making a library app, we'll be dealing with books, so a book is our entity. For the book entity, let's just use the most basic property that a book has, plus a couple of necessary attributes for our database; ID, Title, Author, Description, Published At, Created At, Updated At, Deleted At. Referring back to the [Golang Standard Layout](https://github.com/golang-standards/project-layout), all modules that are meant to be exported must be placed in the `/pkg` dir. So, we create a `/pkg/model`, a place where all future entities will reside, and place `book.go` there.

{{< code language="go" title="book.go" id="1" >}}

    package model

    import "time"

    type Book struct {
        ID          int64     `json:"id"`
        Title       string    `json:"title"`
        Author      string    `json:"author"`
        Description string    `json:"description"`
        PublishedAt time.Time `json:"published_at"`
        CreatedAt   time.Time `json:"created_at"`
        UpdatedAt   time.Time `json:"updated_at"`
        DeletedAt   time.Time `json:"deleted_at"`
    }

{{< /code >}}

## Implementing Repositories.

Indeed, repository is not stated in Uncle Bob's diagram, but we need this as a layer that connects to our database. If we're to draw this layer on the diagram, it would be between entities and use case layer, hence making it accessible to use cases and adapters while making it only dependent on entities.

Before we create the repository, make sure to define a book repository interface in our book model. The interface is used as a means of contract and communication between the layers.

{{< code language="go" title="book.go" id="2" >}}

    package model

    import (
        "context"
        "time"
    )

    type Book struct {
        ID          int64     `json:"id"`
        Title       string    `json:"title"`
        Author      string    `json:"author"`
        Description string    `json:"description"`
        PublishedAt time.Time `json:"published_at"`
        CreatedAt   time.Time `json:"created_at"`
        UpdatedAt   time.Time `json:"updated_at"`
        DeletedAt   time.Time `json:"deleted_at"`
    }

    type BookRepository interface {
        ReadBookByID(context.Context, int64) (Book, error)
        ReadBooks(context.Context) ([]Book, error)
    }

{{< /code >}}

Differing from the intention of `/pkg/model` directory, we'll create a `/pkg/book` directory to signify that all the codes within it are of the 'book' domain. If there are new entities, we'll create separate domains for them.

Inside `/pkg/book` dir, create another dir called `/repository/postgres`. We create a `/postgres` dir as a means of separation. If in the future we would like to use another database for the 'book' domain, let's say MongoDB, then we'll create a `/mongodb` inside the `/repository` dir. Create `book_repository_postgres.go` inside this dir.

{{< code language="go" title="book_repository_postgres.go" id="3" >}}

    package postgres

    import (
        "context"
        "time"

        "github.com/ssentinull/create-apis-using-golang/pkg/model"
    )

    type bookRepo struct{}

    func NewBookRepository() model.BookRepository {
        return &bookRepo{}
    }

    func (br *bookRepo) ReadBookByID(ctx context.Context, ID int64) (model.Book, error) {
        book := model.Book{
            ID:          ID,
            Title:       "Harry Potter",
            Author:      "J. K. Rowling",
            Description: "A book about wizards",
            PublishedAt: time.Now(),
            CreatedAt:   time.Now(),
        }

        return book, nil
    }

    func (br *bookRepo) ReadBooks(ctx context.Context) ([]model.Book, error) {
        books := []model.Book{
            {
                ID:          1,
                Title:       "Harry Potter",
                Author:      "J. K. Rowling",
                Description: "A book about wizards",
                PublishedAt: time.Now(),
                CreatedAt:   time.Now(),
            },
            {
                ID:          2,
                Title:       "The Hobbit",
                Author:      "J. R. R. Tolkien",
                Description: "A book about hobbits",
                PublishedAt: time.Now(),
                CreatedAt:   time.Now(),
            },
        }

        return books, nil
    }

{{< /code >}}

Since we haven't established a database connection, we'll use dummy data in our repository as an example. Ideally, this layer will only be filled with CRUD queries to our database.

## Implementing Usecases.

The use case layer should only involve data flow logic and calls to the repository layer. Just like the repository layer, we have to define a book use case interface in the book model.

{{< code language="go" title="book.go" id="4" >}}

    package model

    import (
        "context"
        "time"
    )

    type Book struct {
        ID          int64     `json:"id"`
        Title       string    `json:"title"`
        Author      string    `json:"author"`
        Description string    `json:"description"`
        PublishedAt time.Time `json:"published_at"`
        CreatedAt   time.Time `json:"created_at"`
        UpdatedAt   time.Time `json:"updated_at"`
        DeletedAt   time.Time `json:"deleted_at"`
    }

    type BookUsecase interface {
        GetBookByID(context.Context, int64) (Book, error)
        GetBooks(context.Context) ([]Book, error)
    }

    type BookRepository interface {
        ReadBookByID(context.Context, int64) (Book, error)
        ReadBooks(context.Context) ([]Book, error)
    }

{{< /code >}}

Create a `/pkg/book/usecase` dir and place a `book_usecase.go` in it. This example might be barren because we only implement simple retrieval functions. In production-level applications, this layer could include much more complicated logic that involves repositories from multiple domains.

{{< code language="go" title="book_usecase.go" id="5" >}}

    package usecase

    import (
        "context"
        "encoding/json"

        "github.com/sirupsen/logrus"
        "github.com/ssentinull/create-apis-using-golang/pkg/model"
    )

    type bookUsecase struct {
        bookRepo model.BookRepository
    }

    func NewBookUsecase(br model.BookRepository) model.BookUsecase {
        return &bookUsecase{bookRepo: br}
    }

    func (bu *bookUsecase) GetBookByID(ctx context.Context, ID int64) (model.Book, error) {
        book, err := bu.bookRepo.ReadBookByID(ctx, ID)
        if err != nil {
            c, err := json.Marshal(ctx)
            if err != nil {
                logrus.Error(err)
            }

            logrus.WithFields(logrus.Fields{
                "ctx": c,
                "ID":  ID,
            }).Error(err)

            return model.Book{}, err
        }

        return book, nil
    }

    func (bu *bookUsecase) GetBooks(ctx context.Context) ([]model.Book, error) {
        books, err := bu.bookRepo.ReadBooks(ctx)
        if err != nil {
            c, err := json.Marshal(ctx)
            if err != nil {
                logrus.Error(err)
            }

            logrus.WithField("ctx", c).Error(err)

            return nil, err
        }

        return books, nil
    }

{{< /code >}}

## Implementing Presenters.

The presenters' role is to format data to and from our application. Since we're creating REST APIs, we'll format our data to JSON. The data to be formatted is retrieved from the previous layer, the use case layer. In a similar fashion to our repository layer, we'll create a `/pkg/book/handler/http` dir as a means of separation, if in the future we'd want to use a different method of presenting data, such as through CLI or RPC.

{{< code language="go" title="book_handler_http.go" id="6" >}}

    package http

    import (
        "net/http"
        "strconv"

        "github.com/labstack/echo/v4"
        "github.com/sirupsen/logrus"
        "github.com/ssentinull/create-apis-using-golang/pkg/model"
    )

    type BookHTTPHandler struct {
        BookUsecase model.BookUsecase
    }

    func NewBookHTTPHandler(e *echo.Echo, bu model.BookUsecase) {
        handler := BookHTTPHandler{BookUsecase: bu}

        g := e.Group("/v1")
        g.GET("/books", handler.FetchBooks)
        g.GET("/books/:ID", handler.FetchBookByID)
    }

    func (bh *BookHTTPHandler) FetchBooks(c echo.Context) error {
        books, err := bh.BookUsecase.GetBooks(c.Request().Context())
        if err != nil {
            logrus.Error(err)

            return c.JSON(http.StatusInternalServerError, err.Error())
        }

        return c.JSON(http.StatusOK, books)
    }

    func (bh *BookHTTPHandler) FetchBookByID(c echo.Context) error {
        ID, err := strconv.ParseInt(c.Param("ID"), 10, 64)
        if err != nil {
            logrus.Error(err)

            return c.JSON(http.StatusBadRequest, "url param is faulty")
        }

        book, err := bh.BookUsecase.GetBookByID(c.Request().Context(), ID)
        if err != nil {
            logrus.Error(err)

            return c.JSON(http.StatusInternalServerError, err.Error())
        }

        return c.JSON(http.StatusOK, book)
    }

{{< /code >}}

We use a `/v1` endpoint prefix as a safety net where our API consumers can quickly roll back if ever our new version has a critical bug. The final step would be to import our modules to the main app.

{{< code language="go" title="main.go" id="7" >}}

    package main

    import (
        "net/http"
        "os"
        "time"

        "github.com/labstack/echo/v4"
        "github.com/sirupsen/logrus"
        "github.com/ssentinull/create-apis-using-golang/config"
        _bookHTTPHndlr "github.com/ssentinull/create-apis-using-golang/pkg/book/handler/http"
        _bookRepo "github.com/ssentinull/create-apis-using-golang/pkg/book/repository/postgres"
        _bookUcase "github.com/ssentinull/create-apis-using-golang/pkg/book/usecase"
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

    // run initLogger() before running main()
    func init() {
        initLogger()
    }

    func main() {
        e := echo.New()

        bookRepo := _bookRepo.NewBookRepository()
        bookUsecase := _bookUcase.NewBookUsecase(bookRepo)
        _bookHTTPHndlr.NewBookHTTPHandler(e, bookUsecase)

        s := &http.Server{
            Addr:         ":" + config.ServerPort(),
            ReadTimeout:  2 * time.Minute,
            WriteTimeout: 2 * time.Minute,
        }

        logrus.Fatal(e.StartServer(s))
    }

{{< /code >}}

You're all set. Now run your server, open Postman, and try hitting `localhost:8080/v1/books` and `localhost:8080/v1/books/1`.

{{< figure src="/img/blogs/create-api-using-golang-architecture/2.png" position="center" caption="" >}}

{{< figure src="/img/blogs/create-api-using-golang-architecture/3.png" position="center" caption="" >}}

By this step, your directory should look like this.

{{< image src="/img/blogs/create-api-using-golang-architecture/4.png" position="center" >}}

Congrats!! :partying_face: You've created APIs using Golang and implemented Clean Architecture!! :clap: The next step would be to connect a database to our application.

I hope this could be beneficial to you. Thank you for taking the time to read this article. :pray:

-- ssentinull

## References.

1. [Software Architecture Guide](https://martinfowler.com/architecture/)
2. [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
3. [Go Clean Arch Repo](https://github.com/bxcodec/go-clean-arch)