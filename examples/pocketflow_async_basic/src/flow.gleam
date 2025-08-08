import nodes
import pocketflow.{type Node, Node}
import types.{
  type Branched, type Shared, type Start, Accepted, Retry, Shared, Start,
}

fn new() -> Node(Start, Shared) {
  Node(Start, Shared(recipes: [], ingredient: "", suggestion: ""))
}

pub fn run_flow() -> Node(Branched, Shared) {
  let start = new()
  let Node(branch, shared) = pocketflow.basic_flow(start, create_flow())

  case branch {
    Retry -> run_flow()
    Accepted -> Node(Accepted, shared)
  }
}

fn create_flow() -> fn(Node(Start, Shared)) -> Node(Branched, Shared) {
  fn(node) {
    nodes.fetch_recipes(node) |> nodes.suggest_recipe |> nodes.get_approval
  }
}
