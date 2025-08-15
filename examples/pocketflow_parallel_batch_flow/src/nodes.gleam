import gleam/io
import pocketflow.{type Node, Node}
import types.{
  type Filtered, type Loaded, type Saved, type Shared, type Start, Filtered,
  Loaded, Saved, Start,
}

pub fn load_image(node: Node(Start, Shared)) -> Node(Loaded, Shared) {
  pocketflow.basic_node(prep: { 1 }, exec: fn(_i: Int) { 1 }, post: fn(_i: Int) {
    io.println("load_image")
    let Node(Start, shared) = node
    Node(Loaded, shared)
  })
}

pub fn apply_filter(node: Node(Loaded, Shared)) -> Node(Filtered, Shared) {
  pocketflow.basic_node(prep: { 1 }, exec: fn(_i: Int) { 1 }, post: fn(_i: Int) {
    io.println("apply_filter")
    let Node(Loaded, shared) = node
    Node(Filtered, shared)
  })
}

pub fn save_image(node: Node(Filtered, Shared)) -> Node(Saved, Shared) {
  pocketflow.basic_node(prep: { 1 }, exec: fn(_i: Int) { 1 }, post: fn(_i: Int) {
    io.println("save_image")
    let Node(Filtered, shared) = node
    Node(Saved, shared)
  })
}
