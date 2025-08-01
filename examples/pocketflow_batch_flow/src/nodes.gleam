import gleam/io
import pocketflow.{type Shared, Shared}
import types.{type Values, Values}

pub fn load_image(shared: Shared(Values)) -> Shared(Values) {
  pocketflow.node(prep: { 1 }, exec: fn(_i: Int) { 1 }, post: fn(_i: Int) {
    io.println("load_image")
    shared
  })
}

pub fn apply_filter(shared: Shared(Values)) -> Shared(Values) {
  pocketflow.node(prep: { 1 }, exec: fn(_i: Int) { 1 }, post: fn(_i: Int) {
    io.println("apply_filter")
    shared
  })
}

pub fn save_image(shared: Shared(Values)) -> Shared(Values) {
  pocketflow.node(prep: { 1 }, exec: fn(_i: Int) { 1 }, post: fn(_i: Int) {
    io.println("save_image")
    shared
  })
}
