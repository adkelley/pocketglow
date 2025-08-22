import nodes
import pocketglow.{type Node, Node}
import types.{type Processed, type Shared, type Start, Shared, Start, Statistics}

pub fn run_flow(input_file: String, chunk_size: Int) -> Node(Processed, Shared) {
  let statistics = Statistics(0, 0, 0.0)
  let shared = Shared(input_file, chunk_size, statistics)

  pocketglow.basic_flow(Node(Start, shared), create_flow())
}

fn create_flow() -> fn(Node(Start, Shared)) -> Node(Processed, Shared) {
  fn(node) { nodes.csv_processer(node) }
}
