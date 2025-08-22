import flow
import gleam/io
import pocketglow.{Node}
import types.{Processed}

pub fn main() -> Nil {
  // Print starting message
  io.print("\n=== Starting CSV processor ===\n")

  // Run the flow
  let Node(Processed, shared) = flow.run_flow("my_csv_file", 1000)
  echo shared
  Nil
}
