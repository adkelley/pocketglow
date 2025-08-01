import nodes
import pocketflow.{type Flow, type Shared, Shared}
import types.{type Values, Values}

pub fn run(topic: String) -> Shared(Values) {
  let values =
    Values(
      topic: topic,
      outline_yaml: "",
      formatted_outline: "",
      draft: "",
      final_article: "",
    )
  pocketflow.flow(Shared(values), create_article_flow)
}

/// Create and configure the csv processing workflow
fn create_article_flow() -> Flow(Values) {
  // # Connect nodes in sequence
  // # Create flow starting with outline node
  fn(shared) {
    nodes.generate_outline(shared)
    |> nodes.write_simple_content
    |> nodes.apply_style
  }
}
