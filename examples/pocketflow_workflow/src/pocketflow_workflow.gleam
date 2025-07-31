import flow
import gleam/int
import gleam/io
import gleam/string
import pocketflow.{Shared}

pub fn main() -> Nil {
  io.println("Hello from xp_pocketflow_workflow!")
  run_flow("AI Safety")
  Nil
}

fn run_flow(topic: String) {
  // Print starting message
  io.print("\n=== Starting Article Workflow on Topic: " <> topic <> " ===\n")

  // Run the flow
  let shared = flow.run(topic)
  // Output summary
  let Shared(values) = shared
  io.println("\n=== Workflow Completed ===\n")
  io.println("Topic: " <> values.topic)

  print_statement("Outline Length: ", values.formatted_outline, " characters")
  print_statement("Draft Length: ", values.draft, " characters")
  print_statement("Final Article Length: ", values.final_article, " characters")
}

fn print_statement(prefix: String, subject: String, suffix: String) {
  subject
  |> string.length
  |> int.to_string
  |> fn(length) { io.println(prefix <> length <> suffix) }
}
