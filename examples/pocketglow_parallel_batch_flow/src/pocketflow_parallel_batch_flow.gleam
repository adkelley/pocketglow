import flow
import gleam/io

pub fn main() -> Nil {
  io.println("Hello from pocketflow_batch_flow!")
  flow.run_flow()
  Nil
}
