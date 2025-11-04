@react.component
let make = (~children: React.element) => {
  <main>
    <nav>
      <ul>
        <li>
          <a href="/"> {React.string("Home")} </a>
        </li>
        <li>
          <a href="/recipes"> {React.string("Recipes")} </a>
        </li>
      </ul>
    </nav>
    children
  </main>
}
