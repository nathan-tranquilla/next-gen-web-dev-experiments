module Recipes = {
  @module("./components/Recipes.tsx") @react.component
  external make: unit => React.element = "default"
}

@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()

  switch url.path {
  | list{"recipes"} =>
    <MainLayout>
      <Recipes />
    </MainLayout>
  | _ => <MainLayout> {React.string("You are on the home page")} </MainLayout>
  }
}
