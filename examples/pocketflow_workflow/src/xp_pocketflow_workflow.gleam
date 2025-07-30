import flow
import gleam/int
import gleam/io
import gleam/result
import gleam/string
import pocketflow

pub fn main() -> Nil {
  io.println("Hello from xp_pocketflow_workflow!")
  run_flow("AI Safety")
  Nil
}

fn run_flow(topic: String) {
  // Print starting message
  io.print("\n=== Starting Article Workflow on Topic: " <> topic <> " ===\n")

  // Run the flow
  let assert Ok(shared) =
    pocketflow.new(["generate_outline", "write_simple_content", "apply_style"])
    |> pocketflow.insert("generate_outline", "topic", topic)
  let run = flow.create_article_flow()
  let shared = run(shared)
  // Output summary
  io.println("\n=== Workflow Completed ===\n")
  let assert Ok(topic) = pocketflow.get(shared, "generate_outline", "topic")
  io.println("Topic: " <> topic)
  let length =
    result.unwrap(
      pocketflow.get(shared, "generate_outline", "formatted_outline"),
      "",
    )
    |> string.length
    |> int.to_string
  io.println("Outline Length: " <> length <> " characters")
  let length =
    result.unwrap(pocketflow.get(shared, "write_simple_content", "draft"), "")
    |> string.length
    |> int.to_string
  io.println("Draft Length: " <> length <> " characters")
  let length =
    result.unwrap(pocketflow.get(shared, "apply_style", "final_article"), "")
    |> string.length
    |> int.to_string
  io.println("Final Article Length: " <> length <> " characters")
}
