import nodes
import pocketglow.{type Node, Node}
import types.{
  type Action, type AnsweredQuestion, type Shared, Answer, Decide, Search,
}

fn branch_flow(node: Node(Action, Shared)) -> Node(AnsweredQuestion, Shared) {
  let Node(branch, _shared) = node
  case branch {
    Search -> nodes.search_web(node) |> branch_flow()
    Decide -> nodes.decide_action(node) |> branch_flow()
    Answer -> nodes.answer_question(node)
  }
}

pub fn create_agent_flow(shared: Shared) {
  pocketglow.basic_flow(Node(Decide, shared), fn(node) { branch_flow(node) })
}
