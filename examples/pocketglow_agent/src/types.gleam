pub type Shared {
  Shared(
    context: String,
    question: String,
    answer: String,
    search_query: String,
  )
}

pub type Decision {
  Decision(
    thinking: String,
    action: Action,
    reason: String,
    answer: String,
    search_query: String,
  )
}

pub fn decision_new() -> Decision {
  Decision("", Decide, "", "", "")
}

// LLM server should never return anything more than service or answer.
// If it does, then make the LLM redo nodes.decide_action, by assiging
// the Decide action.
pub fn action_string_to_enum(action: String) -> Action {
  case action {
    "search" -> Search
    "answer" -> Answer
    _ -> Decide
  }
}

// LLM server should never return anything more than the Decision fields.
// There are two exceptions: answer and search_query, which are optional
// see the prompt in nodes.decide_action for details
// In these two cases, then ignore and return the decision state.
pub fn kv_strings_to_decision(
  decision: Decision,
  k: String,
  v: String,
) -> Decision {
  case k {
    "thinking" -> Decision(..decision, thinking: v)
    "action" -> Decision(..decision, action: action_string_to_enum(v))

    "reason" -> Decision(..decision, reason: v)
    "answer" -> Decision(..decision, answer: v)
    "search_query" -> Decision(..decision, search_query: v)
    _ -> decision
  }
}

// Nodes
pub type Action {
  Decide
  Search
  Answer
}

pub type AnsweredQuestion {
  AnsweredQuestion
}
