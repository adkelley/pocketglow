import pocketglow.{type Node}

pub type Shared {
  Shared(
    topic: String,
    outline_yaml: String,
    formatted_outline: String,
    draft: String,
    final_article: String,
  )
}

pub type Article(state, shared) =
  Node(state, shared)

pub type Outline {
  Outline
}

pub type Style {
  Style
}

pub type Content {
  Content
}

pub type Start {
  Start
}
