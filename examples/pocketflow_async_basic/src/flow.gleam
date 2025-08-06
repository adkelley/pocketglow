import nodes
import pocketflow.{type Fsm, type Shared, Fsm, Shared}
import types.{
  type Transitions, type Values, Accept, Approve, Fetch, Retry, Suggest, Values,
}

fn init() -> Shared(Values) {
  Shared(Values(recipes: [], ingredient: "", suggestion: ""))
}

pub fn start() {
  pocketflow.flow(Fsm(init(), Fetch), flow)
}

fn flow(fsm: Fsm(Values, Transitions)) -> Shared(Values) {
  let Fsm(shared, transition) = fsm
  case transition {
    Fetch -> flow(nodes.fetch_recipes(shared))
    Suggest -> flow(nodes.suggest_recipe(shared))
    Approve -> flow(nodes.get_approval(shared))
    Accept -> shared
    Retry -> flow(nodes.fetch_recipes(init()))
  }
}
