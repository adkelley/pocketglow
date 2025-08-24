import argv
import flow
import gleam/io
import pocketglow.{Node}
import types.{Shared}

pub fn main() -> Nil {
  let shared =
    Shared(
      context: "previous context",
      question: "Who won the Nobel Prize in Physics in 2024?",
      answer: "",
      search_query: "",
    )
  // User question?
  let shared = case argv.load().arguments {
    ["-q", question] -> Shared(..shared, question: question)
    _ -> shared
  }
  // Process the question
  io.println("🤔 Processing question: " <> shared.question)
  let Node(_, shared) = flow.create_agent_flow(shared)
  io.println("Processed Question: " <> shared.question)
  io.println("Final Answer: " <> shared.answer)
  Nil
}
