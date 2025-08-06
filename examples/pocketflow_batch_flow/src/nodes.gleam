import gleam/io
import pocketflow.{type Fsm, type Shared, Fsm}
import types.{type Transitions, type Values, Done, Filter, Save}

pub fn load_image(shared: Shared(Values)) -> Fsm(Values, Transitions) {
  pocketflow.basic_node(prep: { 1 }, exec: fn(_i: Int) { 1 }, post: fn(_i: Int) {
    io.println("load_image")
    Fsm(shared, Filter)
  })
}

pub fn apply_filter(shared: Shared(Values)) -> Fsm(Values, Transitions) {
  pocketflow.basic_node(prep: { 1 }, exec: fn(_i: Int) { 1 }, post: fn(_i: Int) {
    io.println("apply_filter")
    Fsm(shared, Save)
  })
}

pub fn save_image(shared: Shared(Values)) -> Fsm(Values, Transitions) {
  pocketflow.basic_node(prep: { 1 }, exec: fn(_i: Int) { 1 }, post: fn(_i: Int) {
    io.println("save_image")
    Fsm(shared, Done)
  })
}
