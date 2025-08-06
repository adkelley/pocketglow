pub type Values {
  Values(
    topic: String,
    outline_yaml: String,
    formatted_outline: String,
    draft: String,
    final_article: String,
  )
}

pub type Transitions {
  Article
  Outline
  Content
  Style
}
