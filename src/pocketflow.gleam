import gleam/int
import gleam/io
import gleam/list

import gleam/result

// TODO: create ffi for both Beam & Javascript
import gleam/erlang/process
import task

pub type Node(state, shared) {
  Node(state: state, shared: shared)
}

pub type Params(a) {
  Params(shared: a, max_retries: Int, wait: Int)
}

pub const max_retries = 1

pub const wait = 0

pub type Flow(state, state_, shared) =
  fn(Node(state, shared)) -> Node(state_, shared)

fn retry_exec(
  exec exec,
  params params: Params(a),
  // propogate the error to assist in debugging
  error error: String,
  retry_count count: Int,
) -> Result(c, String) {
  case count < params.max_retries {
    True -> {
      case exec(params.shared) {
        Ok(x) -> Ok(x)
        Error(e) -> {
          // wait 'retry.wait' seconds before the next attempt
          process.sleep(params.wait * 1000)
          retry_exec(exec, params, e, count + 1)
        }
      }
    }
    False -> Error(error <> ", Error: Exceeded max retries")
  }
}

pub fn basic_node(prep prep, exec exec, post post) -> Node(state, shared) {
  let exec_ = fn(params: Params(a)) { retry_exec(exec, params, "", 0) }
  prep |> exec_ |> post
}

// TODO document the short circuit strategy
pub fn batch_node(prep prep, exec exec, post post) -> Node(state, shared) {
  let exec_ = fn(params: Params(List(_))) {
    list.map(params.shared, fn(s) {
      process.sleep(params.wait * 1000)
      retry_exec(exec, Params(..params, shared: s), "", 0)
    })
  }

  prep |> exec_ |> post
}

// TODO: Should I return the result partition, including error processes?
pub fn parallel_node(prep prep, exec exec, post post) -> Node(state, shared) {
  let exec_ = fn(params_: #(Params(List(a)), Int)) {
    let #(params, timeout) = params_
    list.map(params.shared, fn(s) {
      process.sleep(params.wait * 1000)
      task.async(fn() { retry_exec(exec, Params(..params, shared: s), "", 0) })
    })
    |> task.try_await_all(timeout)
    |> result.partition
    |> fn(partition) {
      case partition.1 {
        [] -> partition.0
        _ -> {
          let num_errors = list.length(partition.1) |> int.to_string
          io.print_error(
            "Warning: " <> num_errors <> " processes failed to complete",
          )
          partition.0
        }
      }
    }
  }
  prep |> exec_ |> post
}

pub fn basic_flow(
  start: Node(state, shared),
  flow: Flow(state, state_, shared),
) -> Node(state_, shared) {
  flow(start)
}

pub fn batch_flow(
  flows: List(Node(state, shared)),
  flow: Flow(state, state_, shared),
) -> List(Node(state_, shared)) {
  list.map(flows, fn(node) { flow(node) })
}

pub fn parallel_flow(
  params: #(List(Node(state, shared)), Int),
  flow: Flow(state, state_, shared),
) -> List(Node(state_, shared)) {
  let #(flows, timeout) = params
  list.map(flows, fn(node) { task.async(fn() { flow(node) }) })
  |> task.try_await_all(timeout)
  |> result.partition
  |> fn(partition) {
    case partition.1 {
      [] -> partition.0
      _ -> {
        let num_errors = list.length(partition.1) |> int.to_string
        io.print_error(
          "Warning: " <> num_errors <> " processes failed to complete",
        )
        partition.0
      }
    }
  }
}
