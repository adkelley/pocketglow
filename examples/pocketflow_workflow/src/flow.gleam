import nodes
import pocketflow.{type Fsm, type Shared, Fsm, Shared}
import types.{
  type Transitions, type Values, Article, Content, Outline, Style, Values,
}

pub fn run(topic: String) -> Shared(Values) {
  let values =
    Values(
      topic: topic,
      outline_yaml: "",
      formatted_outline: "",
      draft: "",
      final_article: "",
    )
  pocketflow.flow(Fsm(Shared(values), Outline), create_article_flow)
}

/// Create and configure the csv processing workflow
fn create_article_flow(fsm: Fsm(Values, Transitions)) -> Shared(Values) {
  let Fsm(shared, transition) = fsm
  case transition {
    Outline -> create_article_flow(nodes.generate_outline(shared))
    Content -> create_article_flow(nodes.write_simple_content(shared))
    Style -> create_article_flow(nodes.apply_style(shared))
    Article -> shared
  }
}
