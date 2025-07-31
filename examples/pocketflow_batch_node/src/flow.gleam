import nodes
import pocketflow.{type Flow, type Shared, Shared}
import types.{type Values, Statistics, Values}

pub fn run(input_file: String, chunk_size: Int) -> Shared(Values) {
  let statistics = Statistics(0, 0, 0.0)
  let values = Values(input_file, chunk_size, statistics)

  let run = process_csv()
  run(Shared(values))
}

fn process_csv() -> Flow(Values) {
  // # Connect nodes in sequence
  // # Create flow starting with csv_processer node
  fn(shared) { nodes.csv_processer(shared) }
}
