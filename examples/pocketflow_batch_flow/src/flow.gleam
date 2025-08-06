import gleam/list
import nodes
import pocketflow.{type Fsm, type Shared, Fsm, Shared}
import types.{type Transitions, type Values, Done, Filter, Load, Save, Values}

fn image_batch_flow() -> List(Fsm(Values, Transitions)) {
  let images = ["cat.jpg", "dog.jpg", "bird.jpg"]
  // List of filters to apply
  let filters = ["grayscale", "blur", "sepia"]

  // Generate all combinations
  list.flat_map(images, fn(image) {
    list.flat_map(filters, fn(filter) {
      list.prepend([], Fsm(Shared(Values(input: image, filter: filter)), Load))
    })
  })
}

pub fn flow(fsm: Fsm(Values, Transitions)) -> Shared(Values) {
  let Fsm(shared, transition) = fsm
  case transition {
    Load -> flow(nodes.load_image(shared))
    Filter -> flow(nodes.apply_filter(shared))
    Save -> flow(nodes.save_image(shared))
    Done -> shared
  }
}

pub fn create_flow() -> List(Shared(Values)) {
  let params = image_batch_flow()
  pocketflow.batch_flow(params, flow)
}
