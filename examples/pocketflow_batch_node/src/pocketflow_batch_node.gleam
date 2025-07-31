import flow
import gleam/io
import pocketflow.{type Shared}

pub fn main() -> Nil {
  // Print starting message
  io.print("\n=== Starting CSV processor ===\n")

  // Run the flow
  let shared = flow.run("my_csv_file", 1000)
  echo shared
  Nil
}
