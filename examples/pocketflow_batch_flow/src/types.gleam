pub type Values {
  Values(input: String, filter: String)
}

pub type Transitions {
  Load
  Filter
  Save
  Done
}
