import gleam/list

pub type Shared(values) {
  Shared(values)
}

// Finite State Machine
pub type Fsm(values, transitions) {
  Fsm(Shared(values), transitions)
}

pub type Flow(a, b) =
  fn(#(Shared(a), b)) -> Shared(a)

pub fn basic_node(prep prep, exec exec, post post) -> Fsm(values, transitions) {
  prep |> exec |> post
}

pub fn batch_node(prep prep, exec exec, post post) -> Fsm(values, transitions) {
  let exec_ = fn(items: List(List(_))) { list.map(items, exec) }
  prep |> exec_ |> post
}

pub fn flow(fsm: Fsm(a, b), flow: fn(Fsm(a, b)) -> Shared(a)) {
  flow(fsm)
}

pub fn batch_flow(fsms: List(Fsm(a, b)), flow_: fn(Fsm(a, b)) -> Shared(a)) {
  list.map(fsms, fn(fsm) { flow(fsm, flow_) })
}
