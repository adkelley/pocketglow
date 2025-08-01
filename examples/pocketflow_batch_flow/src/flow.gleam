import gleam/list
import nodes
import pocketflow.{type Flow, type Shared, Shared}
import types.{type Values, Values}

fn image_batch_flow() {
  let images = ["cat.jpg", "dog.jpg", "bird.jpg"]
  // List of filters to apply
  let filters = ["grayscale", "blur", "sepia"]

  // Generate all combinations
  list.flat_map(images, fn(image) {
    list.flat_map(filters, fn(filter) {
      list.prepend([], Shared(Values(input: image, filter: filter)))
    })
  })
}

pub fn create_base_flow() -> Flow(Values) {
  fn(shared) {
    nodes.load_image(shared) |> nodes.apply_filter |> nodes.save_image
  }
}

pub fn create_flow() -> List(Shared(Values)) {
  let params = image_batch_flow()
  pocketflow.batch_flow(params, create_base_flow)
  // list.map(prep, fn(p) {
  //   let run = create_base_flow()
  //   run(p)
  // })
}
