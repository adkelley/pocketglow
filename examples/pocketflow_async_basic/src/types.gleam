pub type Shared {
  Shared(recipes: List(String), ingredient: String, suggestion: String)
}

pub type Fetched {
  Fetched
}

pub type Start {
  Start
}

pub type Suggested {
  Suggested
}

pub type Branched {
  Accepted
  Retry
}
