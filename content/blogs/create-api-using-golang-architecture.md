---
title: "Create APIs using Golang | Part 2 : Application Architecture."
date: "2021-11-22"
author: "ssentinull"
cover: "img/blogs/create-api-using-golang-architecture/0.jpg"
description: "Architecture applies just as much in software as it does in buildings."
tags: ["architecture", "api", "golang"]
---

## Introduction.

In the [previous](/blogs/create-api-using-golang-setup/) article, we've set up our workspace that will make our development experience more pleasant. Now it's time to develop the app itself. However, there is one thing I want to discuss before we proceed, and that is Clean Architecture.

## What is Architecture.

Before jumping to Clean Architecture, let's discuss what _architecture_ is. Different experts have different definitions of what architecture exactly is. Some say it's _the fundamental organization of a system_ while others define it as _the way the highest-level components are wired together_. Since I'm nowhere near to being an expert, I'll just have to defer to the definition provided by the experts, which in essence is _how we organize our system_.

## Why bother with Architecture.

The quote below sums up why architecture is important.

> _"Poor architecture is a major contributor to the growth of cruft - elements of the software that impede the ability of developers to understand the software. Software that contains a lot of cruft is much harder to modify, leading to features that arrive more slowly and with more defects."_
>
> -- **Martin Fowler, 2019**

## What is Clean Architecture.

_Clean Architecture_ is a concept forwarded by Robert C. Martin (Uncle Bob) in 2021. It takes a layered approach, where a system is divided into multiple layers, each having its roles and rules it must abide by. If drawn into a diagram, Clean Architecture would look like the cross-section of Earth, where Earth's core would be the innermost circle, and encapsulating it are the numerous layers that make up the Earth's mantle.

{{< figure src="/img/blogs/create-api-using-golang-architecture/1.jpg" position="center" caption="Clean Architecture Diagram" >}}

This layering technique produces a system that's testable, independent of frameworks, independent of UI, independent of database, and independent of any external agency. The rule of this architecture is very straightforward; source code dependencies can only point inwards. In other words, the inner circle can know nothing about the outer circle, while something declared in the outer circle can not be mentioned in the inner circle.

As seen in the diagram above, the architecture comprises four layers:

1. Enterprise Business Rules - objects that correlate to the business at hand.
2. Application Business Rules - manages the flow of data to and from entities.
3. Interface Adapters - converts use cases' data format to a more general data format.
4. Frameworks & Drives - external frameworks and tools.

## Implementing Enterprise Business Rules.

In our project, we'll refer to _Enterprise Business Rules_ as _Models_. Since we're making a library app, we'll be dealing with books, so a _book_ is our entity. For the _book_ entity, let's just use the most basic property that a book has, plus a couple of necessary attributes for our database; ID, Title, Author, Description, Published At, Created At, Updated At, Deleted At. Referring back to the [Golang Standard Layout](https://github.com/golang-standards/project-layout), all modules that are meant to be exported must be placed in the `/internal` dir. So, we create a `/internal/model`, a place where all future entities will reside, and place `book.go` there.

{{< code language="go" title="book.go" id="1" >}}

    package model

    import (
        "context"
        "time"
    )

    type Book struct {
        ID            int64     `json:"id"`
        Title         string    `json:"title"`
        Author        string    `json:"author"`
        Description   string    `json:"description"`
        PublishedDate string    `json:"published_date"`
        CreatedAt     time.Time `json:"created_at"`
        UpdatedAt     time.Time `json:"updated_at"`
        DeletedAt     time.Time `json:"deleted_at"`
    }

    type CreateBookInput struct {
        Title         string `json:"title"`
        Author        string `json:"author"`
        Description   string `json:"description"`
        PublishedDate string `json:"published_date"`
    }

    func (i CreateBookInput) ToModel() *Book {
        return &Book{
            ID:            int64(1),
            Title:         i.Title,
            Author:        i.Author,
            Description:   i.Description,
            PublishedDate: i.PublishedDate,
            CreatedAt:     time.Now(),
        }
    }

    type UpdateBookInput struct {
        ID            int64  `json:"id"`
        Title         string `json:"title"`
        Author        string `json:"author"`
        Description   string `json:"description"`
        PublishedDate string `json:"published_date"`
    }

    func (i UpdateBookInput) ToModel() *Book {
        return &Book{
            ID:            i.ID,
            Title:         i.Title,
            Author:        i.Author,
            Description:   i.Description,
            PublishedDate: i.PublishedDate,
            UpdatedAt:     time.Now(),
        }
    }

{{< /code >}}

## Implementing Application Business Rules.

_Application Business Rules_ are also known as _Use Cases_. The _use cases_ in our app will be divided into two parts; _usecase_ (I know it's redundant but it explains itself as we proceed) and _repository_. _Usecase_ will only include business logic while _repository_ will only include transactions to our data store. One can not happen within the other, eg: a business logic can not happen in a repository and a usecase can not make calls directly to our data store.

### Implementing Repository.

We'll start with _repository_. Since we need a place to store our books, we need a database. _Repository_ comes into play when we want to interact with our database. Fetch, create, update, and delete data from and to our database happens exclusively in our _repository_. Since we won't cover database connections in this part of the series, we'll use dummy data in the meantime.

Before we create the _repository_, make sure to define a book _repository interface_ in our book model. The _interface_ is used as a means of contract and communication between the layers.

{{< code language="go" title="book.go" id="2" >}}

    ...

    type BookRepository interface {
        Create(ctx context.Context, input *Book) (err error)
        DeleteByID(ctx context.Context, ID int64) (err error)
        FindByID(ctx context.Context, ID int64) (book *Book, err error)
        FindAll(ctx context.Context) (books []*Book, err error)
        Update(ctx context.Context, input *Book) (book *Book, err error)
    }

{{< /code >}}

Differing from the intention of `/internal/model` directory, we'll create a `/interal/repository` directory to signify that all the codes within it are _repository_ codes.

{{< code language="go" title="book_repository.go" id="3" >}}

    package postgres

    import (
        "context"
        "time"

        "github.com/ssentinull/create-apis-using-golang/internal/model"
    )

    type bookRepo struct{}

    func NewBookRepository() model.BookRepository {
        return &bookRepo{}
    }

    func (br *bookRepo) Create(ctx context.Context, book *model.Book) error {
        return nil
    }

    func (br *bookRepo) DeleteByID(ctx context.Context, ID int64) error {
        return nil
    }

    func (br *bookRepo) FindByID(ctx context.Context, ID int64) (*model.Book, error) {
        book := &model.Book{
            ID:            ID,
            Title:         "Harry Potter",
            Author:        "J. K. Rowling",
            Description:   "A book about wizards",
            PublishedDate: "10-12-2022",
            CreatedAt:     time.Now(),
        }

        return book, nil
    }

    func (br *bookRepo) FindAll(ctx context.Context) ([]*model.Book, error) {
        books := []*model.Book{
            {
                ID:            1,
                Title:         "Harry Potter",
                Author:        "J. K. Rowling",
                Description:   "A book about wizards",
                PublishedDate: "10-12-2022",
                CreatedAt:     time.Now(),
            },
            {
                ID:            2,
                Title:         "The Hobbit",
                Author:        "J. R. R. Tolkien",
                Description:   "A book about hobbits",
                PublishedDate: "11-11-2022",
                CreatedAt:     time.Now(),
            },
        }

        return books, nil
    }

    func (br *bookRepo) Update(ctx context.Context, input *model.Book) (*model.Book, error) {
        book := &model.Book{
            ID:            int64(1),
            Title:         "Harry Potter",
            Author:        "J. K. Rowling",
            Description:   "A book about wizards",
            PublishedDate: "10-12-2022",
            CreatedAt:     time.Now(),
        }

        return book, nil
    }

{{< /code >}}

### Implementing Usecases.

The _usecase_ layer should only involve business logic and calls to the repository layer. Just like the _repository_ layer, we have to define a book _usecase interface_ in the book model.

{{< code language="go" title="book.go" id="4" >}}

    ...

    type BookUsecase interface {
        Create(ctx context.Context, input *CreateBookInput) (book *Book, err error)
        DeleteByID(ctx context.Context, ID int64) (err error)
        FindByID(ctx context.Context, ID int64) (book *Book, err error)
        FindAll(ctx context.Context) (books []*Book, err error)
        Update(ctx context.Context, input *UpdateBookInput) (book *Book, err error)
    }

{{< /code >}}

Create a `/internal/usecase` dir and place a `book_usecase.go` in it. This example might be barren because we only implement simple logics. In production-level applications, this layer could include much more complicated logic that involves _repositories_ from multiple domains.

{{< code language="go" title="book_usecase.go" id="5" >}}

    package usecase

    import (
        "context"

        "github.com/sirupsen/logrus"
        "github.com/ssentinull/create-apis-using-golang/internal/model"
        "github.com/ssentinull/create-apis-using-golang/internal/utils"
    )

    type bookUsecase struct {
        bookRepo model.BookRepository
    }

    func NewBookUsecase(br model.BookRepository) model.BookUsecase {
        return &bookUsecase{bookRepo: br}
    }

    func (bu *bookUsecase) Create(ctx context.Context, input *model.CreateBookInput) (*model.Book, error) {
        book := input.ToModel()
        if err := bu.bookRepo.Create(ctx, book); err != nil {
            logrus.WithFields(logrus.Fields{
                "ctx":   utils.Dump(ctx),
                "input": utils.Dump(input),
            }).Error(err)
            return nil, err
        }

        return book, nil
    }

    func (bu *bookUsecase) DeleteByID(ctx context.Context, ID int64) error {
        if err := bu.bookRepo.DeleteByID(ctx, ID); err != nil {
            logrus.WithFields(logrus.Fields{
                "ctx": utils.Dump(ctx),
                "ID":  ID,
            }).Error(err)
            return err
        }

        return nil
    }

    func (bu *bookUsecase) FindByID(ctx context.Context, ID int64) (*model.Book, error) {
        book, err := bu.bookRepo.FindByID(ctx, ID)
        if err != nil {
            logrus.WithFields(logrus.Fields{
                "ctx": utils.Dump(ctx),
                "ID":  ID,
            }).Error(err)
            return nil, err
        }

        return book, nil
    }

    func (bu *bookUsecase) FindAll(ctx context.Context) ([]*model.Book, error) {
        books, err := bu.bookRepo.FindAll(ctx)
        if err != nil {
            logrus.WithField("ctx", utils.Dump(ctx)).Error(err)
            return nil, err
        }

        return books, nil
    }

    func (bu *bookUsecase) Update(ctx context.Context, input *model.UpdateBookInput) (*model.Book, error) {
        book, err := bu.bookRepo.Update(ctx, input.ToModel())
        if err != nil {
            logrus.WithFields(logrus.Fields{
                "ctx":   utils.Dump(ctx),
                "input": utils.Dump(input),
            }).Error(err)
            return nil, err
        }

        return book, nil
    }

{{< /code >}}

## Implementing Interface Adapters.

_Interface Adapters_ are commonly known as _Handlers_, _Presenters_, or _Deliveries_, in this project we refer to them as _Deliveries_. The delivery's role is to format data to and from our application. We'll format our data to JSON because we're creating REST APIs. The data to be formatted is retrieved from the previous layer, the _usecase_ layer. In a similar fashion to our _repository_ layer, we'll create a `/internal/delivery/http` dir as a means of separation. If in the future we'd want to use a different method of presenting data, such as through GraphQL or RPC, we can create separate directories.

{{< code language="go" title="book_handler_http.go" id="6" >}}

    package http

    import (
        "net/http"
        "strconv"

        "github.com/labstack/echo/v4"
        "github.com/sirupsen/logrus"
        "github.com/ssentinull/create-apis-using-golang/internal/model"
        "github.com/ssentinull/create-apis-using-golang/internal/utils"
    )

    type BookHTTPHandler struct {
        BookUsecase model.BookUsecase
    }

    func NewBookHTTPHandler(e *echo.Echo, bu model.BookUsecase) {
        handler := BookHTTPHandler{BookUsecase: bu}

        g := e.Group("/v1")
        g.POST("/books", handler.CreateBook)
        g.GET("/books", handler.FetchBooks)
        g.GET("/books/:ID", handler.FetchBookByID)
        g.PUT("/books", handler.UpdateBook)
        g.DELETE("/books/:ID", handler.DeleteBookByID)
    }

    func (bh *BookHTTPHandler) CreateBook(c echo.Context) error {
        input := new(model.CreateBookInput)
        if err := c.Bind(input); err != nil {
            logrus.Error(err)
            return c.JSON(http.StatusBadRequest, err.Error())
        }

        book, err := bh.BookUsecase.Create(c.Request().Context(), input)
        if err != nil {
            logrus.Error(err)
            return c.JSON(utils.ParseHTTPErrorStatusCode(err), err.Error())
        }

        return c.JSON(http.StatusCreated, book)
    }

    func (bh *BookHTTPHandler) DeleteBookByID(c echo.Context) error {
        ID, err := strconv.ParseInt(c.Param("ID"), 10, 64)
        if err != nil {
            logrus.Error(err)
            return c.JSON(http.StatusBadRequest, "ID param is invalid")
        }

        err = bh.BookUsecase.DeleteByID(c.Request().Context(), ID)
        if err != nil {
            logrus.Error(err)
            return c.JSON(utils.ParseHTTPErrorStatusCode(err), err.Error())
        }

        return c.NoContent(http.StatusNoContent)
    }

    func (bh *BookHTTPHandler) FetchBooks(c echo.Context) error {
        books, err := bh.BookUsecase.FindAll(c.Request().Context())
        if err != nil {
            logrus.Error(err)
            return c.JSON(utils.ParseHTTPErrorStatusCode(err), err.Error())
        }

        return c.JSON(http.StatusOK, books)
    }

    func (bh *BookHTTPHandler) FetchBookByID(c echo.Context) error {
        ID, err := strconv.ParseInt(c.Param("ID"), 10, 64)
        if err != nil {
            logrus.Error(err)
            return c.JSON(http.StatusBadRequest, "ID param is invalid")
        }

        book, err := bh.BookUsecase.FindByID(c.Request().Context(), ID)
        if err != nil {
            logrus.Error(err)
            return c.JSON(utils.ParseHTTPErrorStatusCode(err), err.Error())
        }

        return c.JSON(http.StatusOK, book)
    }

    func (bh *BookHTTPHandler) UpdateBook(c echo.Context) error {
        input := new(model.UpdateBookInput)
        if err := c.Bind(input); err != nil {
            logrus.Error(err)
            return c.JSON(http.StatusBadRequest, err.Error())
        }

        book, err := bh.BookUsecase.Update(c.Request().Context(), input)
        if err != nil {
            logrus.Error(err)
            return c.JSON(utils.ParseHTTPErrorStatusCode(err), err.Error())
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
        "github.com/ssentinull/create-apis-using-golang/internal/config"
        _bookHTTPHndlr "github.com/ssentinull/create-apis-using-golang/internal/delivery/http"
        _bookRepo "github.com/ssentinull/create-apis-using-golang/internal/repository"
        _bookUcase "github.com/ssentinull/create-apis-using-golang/internal/usecase"
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
        config.GetConf()
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

Don't forget to add the helper functions in the `/internal/utils` directory.

{{< code language="go" title="dump.go" id="8" >}}

    package utils

    import (
        "encoding/json"
        "github.com/sirupsen/logrus"
    )

    // Dump dump i to json
    func Dump(i interface{}) string {
        bt, err := json.Marshal(i)
        if err != nil {
            logrus.Error(err)
        }

        return string(bt)
    }

{{< /code >}}

{{< code language="go" title="error.go" id="9" >}}

    package utils

    import "net/http"

    func ParseHTTPErrorStatusCode(err error) int {
        switch err {
        default:
            return http.StatusInternalServerError
        }
    }

{{< /code >}}

You're all set. Now run your server, open Postman, and try hitting `localhost:8080/v1/books` and `localhost:8080/v1/books/1` using `GET` method.

{{< figure src="/img/blogs/create-api-using-golang-architecture/2.png" position="center" caption="" >}}

{{< figure src="/img/blogs/create-api-using-golang-architecture/3.png" position="center" caption="" >}}

Congrats!! :partying_face: You've created APIs using Golang and implemented Clean Architecture!! :clap: The next step would be to connect a database to our application.

The Github repository for this step of this series can be found [here](https://github.com/ssentinull/create-apis-using-golang/tree/2c0fba5724f7e6d1352c9e34aa9f9c09a1303df5).

I hope this could be beneficial to you. Thank you for taking the time to read this article. :pray:

-- ssentinull

## References.

1. [Software Architecture Guide](https://martinfowler.com/architecture/)
2. [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
3. [Go Clean Arch Repo](https://github.com/bxcodec/go-clean-arch)
