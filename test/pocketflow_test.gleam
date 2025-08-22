import gleam/io
import gleam/list
import gleam/result
import gleam/string
import pocketglow.{type Node, Node, Params, max_retries, wait}

type Shared =
  String

// Nodes
type Start {
  Start
}

type Middle {
  Middle
}

type End {
  End
}

import gleeunit

pub fn main() -> Nil {
  gleeunit.main()
}

// gleeunit test functions end in `_test`
pub fn basic_nodes_test() {
  let start = fn(greeting: Node(Start, Shared)) -> Node(Middle, Shared) {
    pocketglow.basic_node(
      prep: {
        let Node(Start, name) = greeting
        Params(name, max_retries, wait)
      },
      exec: fn(name: Shared) { Ok(string.capitalise(name)) },
      post: fn(exec_res: Result(Shared, String)) {
        let assert Ok(name) = exec_res
        io.println("Hello " <> name <> "!")
        Node(Middle, name)
      },
    )
  }
  let middle = fn(greeting: Node(Middle, Shared)) -> Node(End, Shared) {
    pocketglow.basic_node(
      prep: {
        let Node(Middle, name) = greeting
        Params(name, max_retries, wait)
      },
      exec: fn(name: Shared) { Ok(string.append(name, " Armstrong")) },
      post: fn(exec_res: Result(Shared, String)) {
        let assert Ok(name) = exec_res
        io.println("Hello " <> name <> "!")
        Node(End, name)
      },
    )
  }

  let flow_test = fn(joe: String) -> Node(End, Shared) {
    pocketglow.basic_flow(Node(Start, joe), fn(node) { start(node) |> middle })
  }

  io.println("\n*********************")
  io.println("basic_nodes_test()")
  assert Node(End, "Joe Armstrong") == flow_test("joe")
  io.println("*********************")
}

pub fn batch_node_test() {
  let start = fn(node: Node(Start, Shared)) -> Node(End, Shared) {
    pocketglow.batch_node(
      prep: {
        let Node(Start, name) = node
        Params([name, "armstrong"], max_retries, wait)
      },
      exec: fn(name: String) { Ok(string.capitalise(name)) },
      post: fn(exec_res: List(Result(Shared, String))) {
        let assert Ok(full_name) = result.all(exec_res)
        let full_name_ =
          list.fold(full_name, "", fn(acc, name) { acc <> name <> " " })
          |> string.trim_end()
        io.println("Hello " <> full_name_ <> "!")
        Node(End, full_name_)
      },
    )
  }

  let flow_test = fn(joe: String) -> Node(End, Shared) {
    let name = Node(Start, joe)
    pocketglow.basic_flow(name, fn(node) { start(node) })
  }

  io.println("\n*********************")
  io.println("batch_node_test()")
  assert Node(End, "Joe Armstrong") == flow_test("joe")
  io.println("*********************")
}
