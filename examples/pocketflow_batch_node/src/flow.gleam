import gleam/dict
import nodes
import pocketflow.{type Flow, type Shared}
import shared_type.{type Values, Statistics, Values}

pub fn run(input_file: String, chunk_size: Int) -> Shared(Values) {
  let statistics = Statistics(0, 0, 0.0)
  let shared =
    dict.new()
    |> dict.insert("prep_res", Values(input_file, chunk_size, statistics))

  let run = process_csv()
  run(shared)
}

fn process_csv() -> Flow(Values) {
  // # Connect nodes in sequence
  // # Create flow starting with csv_processer node
  fn(shared) { nodes.csv_processer(shared) }
}
