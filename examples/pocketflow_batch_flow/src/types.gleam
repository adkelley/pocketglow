import eil.{type Image}

pub type Shared {
  Shared(input: String, image: Image, filter: Filter)
}

pub type Filter {
  Grayscale
  Blur
  Sepia
}

pub type Loaded {
  Loaded
}

pub type Filtered {
  Filtered
}

pub type Saved {
  Saved
}

pub type Start {
  Start
}
