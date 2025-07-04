# Elm Declarative Router

## Introduction

When I started developing in Elm, coming from the JavaScript community, I was surprised to find no declarative routing solution available. In JavaScript frameworks like React or Vue, libraries such as React Router provide a clear, visual way to define routes, making it easy to understand an application's structure. In Elm, however, routing often requires manual URL parsing and handling, which can be daunting for newcomers and make starting development more difficult than expected.

This library, `elm-router`, aims to fill that gap by providing a simple, declarative routing solution for Elm applications. Inspired by the ease of use in JavaScript routers, it allows developers to define routes in a structured, readable way, improving the developer experience and reducing the friction of setting up navigation in Elm.

## Features

### Declarative Route Definitions

The core feature of `elm-router` is its declarative approach to routing. Routes are defined in a `RouterConfig` that specifies static and dynamic paths, making the application's routing structure visually clear. For example:

```elm
import Home
import RouteConfig exposing (RouterConfig, Path(..))
import Url.Parser as Parser
import Users
import UserDetail

config : RouterConfig model msg
config =
    Router.define ""
        [ { path = Static "", view = Home.view }
        , { path = Static "users", view = Users.view }
        , { path = Dynamic (Parser.s "users" </> Parser.string), view = UserDetail.view }
        ]
```

This configuration supports:

- **Static Routes**: Fixed paths like `/` (home) or `/users`.
- **Dynamic Routes**: Parameterized paths like `/users/:id`, parsed using `elm/url`'s `Parser`.

The `Router.view` function processes a `Url` to render the matched route's view, while internal functions like `matchRoute` and `findRouteConfig` handle path matching and route selection.

### Benefits

- **Visual Clarity**: Developers can see the entire routing structure at a glance, making it easier to onboard new team members or maintain the codebase.
- **Ease of Use**: Simplifies routing setup compared to manual URL parsing, especially for those familiar with JavaScript routers.
- **Type Safety**: Leverages Elm's type system to ensure routes and parsers are correctly defined, reducing runtime errors.

## Goals of the First Iteration

The initial version of `elm-router` focuses on core routing functionality:

- **Static Pages**: Support for fixed paths (e.g., `/`, `/users`) to handle common navigation needs.
- **Dynamic Pages**: Support for parameterized routes (e.g., `/users/:id`) to enable dynamic content, such as user profiles or detailed views.
- **Simplicity**: Provide a minimal API (`Router.define`, `Router.init`, `Router.view`, `Router.update`, `Router.link`) to get started quickly without overwhelming users.

This iteration prioritizes getting the basics right, ensuring developers can define and match routes reliably in a single-page application (SPA).

## Limitations

As a first iteration, the library has some limitations:

- **No Outlet (Nested Views)**: The router does not yet support nested routes or outlets, where child views are rendered within parent views (e.g., a sidebar and main content). Each route corresponds to a single view.
- **Cross-Cutting Concerns**: Features like authentication, route guards, or global error handling are not yet considered. Developers must implement these manually outside the router.
- **Basic Dynamic Parsing**: Dynamic routes rely on `elm/url` parsers, which are powerful but may require manual configuration for complex patterns (e.g., multiple parameters or optional segments).
- **No Route Transitions**: There’s no built-in support for animations or transitions between routes.

These limitations are intentional to keep the initial release focused and usable, with plans to address them in future iterations.

## Roadmap

To evolve `elm-router` into a mature routing solution for the Elm community, the following features are planned:

1. **Outlet (Nested Views)**:

   - Support nested routes, allowing child views to be rendered within parent layouts (e.g., `/dashboard/users/:id` rendering a user detail view inside a dashboard).
   - Introduce an `Outlet` concept, similar to React Router, to compose views hierarchically.

2. **Enhanced Dynamic Routing**:

   - Simplify dynamic route definitions with a higher-level API (e.g., `route "users/:id" UserProfile`).
   - Support optional parameters, query strings, and more complex URL patterns.

3. **Community Feedback Integration**:

   - Actively solicit feedback from the Elm community via forums and GitHub to prioritize features.
   - Ensure compatibility with common Elm SPA patterns and libraries (e.g., `elm-spa`).

## Getting Started

To use `elm-router`, install it via `elm install` (once published) and set up your application with `Browser.application`. Below is an example `Main.elm` that defines routes and integrates the router:

```elm
module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Home
import Html exposing (div, h1, nav, text)
import Html.Attributes exposing (class)
import RouteConfig exposing (RouterConfig, Path(..))
import Router
import Url exposing (Url)
import Url.Parser as Parser
import Users
import UserDetail

type alias Model =
    { router : Router.Model Model Msg
    }

type Msg
    = RouterMsg Router.Msg

main : Program () Model Msg
main =
    let
        routeConfig : RouterConfig Model Msg
        routeConfig =
            Router.define ""
                [ { path = Static "", view = Home.view }
                , { path = Static "users", view = Users.view }
                , { path = Dynamic (Parser.s "users" </> Parser.string), view = UserDetail.view }
                ]
    in
    Browser.application
        { init = init routeConfig
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        , onUrlRequest = RouterMsg << Router.OnUrlRequest
        , onUrlChange = RouterMsg << Router.OnUrlChange
        }

init : RouterConfig Model Msg -> () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init routeConfig _ url key =
    let
        ( routerModel, routerCmd ) = Router.init routeConfig url key
    in
    ( { router = routerModel }
    , Cmd.map RouterMsg routerCmd
    )

view : Model -> Browser.Document Msg
view model =
    { title = "Elm App"
    , body =
        [ div [ class "container" ]
            [ h1 [] [ text "Elm App" ]
            , nav []
                [ Router.link "" model.router.config [ text "Home" ] |> Html.map RouterMsg
                , text " | "
                , Router.link "users" model.router.config [ text "Users" ] |> Html.map RouterMsg
                ]
            , Router.view model.router model
            ]
        ]
    }

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RouterMsg routerMsg ->
            let
                ( newRouter, _, routerCmd ) = Router.update routerMsg model.router model
            in
            ( { model | router = newRouter }
            , Cmd.map RouterMsg routerCmd
            )
```

See the examples directory (TBD) for more details.

## Contributing

This library is in its early stages, and contributions are welcome! Please check the CONTRIBUTING.md (TBD) for guidelines on submitting issues, feature requests, or pull requests. Your feedback will help shape `elm-router` into a robust tool for the Elm community.

## License

This project is licensed under the MIT License. See LICENSE for details.
