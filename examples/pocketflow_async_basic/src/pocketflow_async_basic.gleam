import flow
import gleam/io

pub fn main() {
  io.println("Hello from pocketflow_async_basic!")
  io.println("\nWelcome to Recipe Finder!")
  io.println("------------------------")
  let _ = flow.start()
  io.println("\nThanks for using Recipe Finder!")
}
