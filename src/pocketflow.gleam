import gleam/list

pub type Node(state, shared) {
  Node(state: state, shared: shared)
}

pub type Flow(state, state_, shared) =
  fn(Node(state, shared)) -> Node(state_, shared)

// pub type Shared(values) {
//   Shared(values)
// }

pub fn basic_node(prep prep, exec exec, post post) -> Node(state, shared) {
  prep |> exec |> post
}

pub fn batch_node(prep prep, exec exec, post post) -> Node(state, shared) {
  let exec_ = fn(items: List(List(_))) { list.map(items, exec) }
  prep |> exec_ |> post
}

pub fn basic_flow(
  start: Node(state, shared),
  flow: Flow(state, state_, shared),
) -> Node(state_, shared) {
  flow(start)
}

pub fn batch_flow(
  flows: List(Node(state, shared)),
  flow: Flow(state, state_, shared),
) {
  list.map(flows, fn(node) { flow(node) })
}
