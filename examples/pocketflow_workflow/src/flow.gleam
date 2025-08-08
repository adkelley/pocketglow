import nodes
import pocketflow.{Node}
import types.{type Article, type Shared, type Start, type Style, Shared, Start}

pub fn run_flow(topic: String) -> Article(Style, Shared) {
  let start = new(topic)
  pocketflow.basic_flow(start, create_article_flow())
}

fn new(topic: String) -> Article(Start, Shared) {
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

fn create_article_flow() -> fn(Article(Start, Shared)) -> Article(Style, Shared) {
  fn(node) {
    nodes.generate_outline(node)
    |> nodes.write_simple_content
    |> nodes.apply_style
  }
}
