import nodes
import pocketglow.{type Node, Node}
import types.{type Shared, type Start, type Style, Shared, Start}

pub fn run_flow(topic: String) -> Node(Style, Shared) {
  let start = new(topic)
  pocketglow.basic_flow(start, create_article_flow())
}

fn new(topic: String) -> Node(Start, Shared) {
  let shared =
    Shared(
      topic: topic,
      outline_yaml: "",
      formatted_outline: "",
      draft: "",
      final_article: "",
    )
  Node(Start, shared)
}

fn create_article_flow() -> fn(Node(Start, Shared)) -> Node(Style, Shared) {
  fn(node) {
    nodes.generate_outline(node)
    |> nodes.write_simple_content
    |> nodes.apply_style
  }
}
