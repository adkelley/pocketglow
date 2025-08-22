import flow
import gleam/int
import gleam/io
import gleam/string
import pocketglow.{Node}
import types.{Style}

pub fn main() -> Nil {
  // Print starting message
  let topic = "AI Safety"
  io.print("\n=== Starting Article Workflow on Topic: " <> topic <> " ===\n")
  let Node(Style, shared) = flow.run_flow(topic)

  // Run the flow
  // Output summary
  io.println("\n=== Workflow Completed ===\n")
  io.println("Topic: " <> shared.topic)

  print_statement("Outline Length: ", shared.formatted_outline, " characters")
  print_statement("Draft Length: ", shared.draft, " characters")
  print_statement("Final Article Length: ", shared.final_article, " characters")
}

fn print_statement(prefix: String, subject: String, suffix: String) {
  subject
  |> string.length
  |> int.to_string
  |> fn(length) { io.println(prefix <> length <> suffix) }
}
