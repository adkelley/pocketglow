import gleam/list
import nodes
import pocketflow.{type Node, Node}
import types.{type Saved, type Shared, type Start, Shared, Start}

fn image_batch_flow() -> List(Node(Start, Shared)) {
  let images = ["cat.jpg", "dog.jpg", "bird.jpg"]
  // List of filters to apply
  let filters = ["grayscale", "blur", "sepia"]

  // Generate all combinations
  list.flat_map(images, fn(image) {
    list.flat_map(filters, fn(filter) {
      list.prepend([], Node(Start, Shared(input: image, filter: filter)))
    })
  })
}

fn create_flow() -> fn(Node(Start, Shared)) -> Node(Saved, Shared) {
  fn(node) { nodes.load_image(node) |> nodes.apply_filter |> nodes.save_image }
}

pub fn run_flow() -> List(Node(Saved, Shared)) {
  let params = image_batch_flow()
  pocketflow.batch_flow(params, create_flow())
}
