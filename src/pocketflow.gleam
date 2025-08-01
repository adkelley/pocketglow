import gleam/list

pub type Shared(a) {
  Shared(a)
}

pub type Flow(a) =
  fn(Shared(a)) -> Shared(a)

pub fn node(prep prep, exec exec, post post) -> Shared(a) {
  prep |> exec |> post
}

pub fn batch_node(prep prep, exec exec, post post) -> Shared(a) {
  let exec_ = fn(items: List(List(_))) { list.map(items, exec) }
  prep |> exec_ |> post
}

pub fn flow(shared: Shared(a), flow: fn() -> Flow(a)) {
  let run = flow()
  run(shared)
}

pub fn batch_flow(shareds: List(Shared(a)), flow_: fn() -> Flow(a)) {
  list.map(shareds, fn(shared) { flow(shared, flow_) })
}
