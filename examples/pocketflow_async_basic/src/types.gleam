pub type Values {
  Values(recipes: List(String), ingredient: String, suggestion: String)
}

pub type Transitions {
  Fetch
  Suggest
  Approve
  Accept
  Retry
}
