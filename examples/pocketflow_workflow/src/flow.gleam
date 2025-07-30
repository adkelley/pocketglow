import nodes
import pocketflow.{type Flow}

/// Create and configure the article writing workflow
pub fn create_article_flow() -> Flow(String) {
  // # Connect nodes in sequence
  // # Create flow starting with outline node
  fn(shared) {
    nodes.generate_outline(shared)
    |> nodes.write_simple_content
    |> nodes.apply_style
  }
}
