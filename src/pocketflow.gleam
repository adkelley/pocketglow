import gleam/list

// TODO: Consider option for passing the retries structure
// import gleam/option.{type Option, None, Some}
import gleam/result

// TODO: remove task, and create ffi for Beam & Javascript
import task

pub type Node(state, shared) {
  Node(state: state, shared: shared)
}

pub type Retry {
  Retry(max_retries: Int, wait: Int)
}

pub type Flow(state, state_, shared) =
  fn(Node(state, shared)) -> Node(state_, shared)

pub fn default_retries() -> Retry {
  Retry(max_retries: 1, wait: 0)
}

fn retry_exec(
  exec exec,
  params params: #(a, Retry),
  // propogate the error to assist in debugging
  error error: String,
  retry_count count: Int,
) -> Result(c, String) {
  let #(a, retry) = params
  case count < retry.max_retries {
    True ->
      case exec(a) {
        Ok(x) -> Ok(x)
        Error(e) -> retry_exec(exec, params, e, count + 1)
      }
    False -> Error(error <> ", Error: Exceeded max retries")
  }
}

pub fn basic_node(prep prep, exec exec, post post) -> Node(state, shared) {
  let exec_ = fn(params: #(_, Retry)) { retry_exec(exec, params, "", 0) }
  prep |> exec_ |> post
}

pub fn batch_node(prep prep, exec exec, post post) -> Node(state, shared) {
  let exec_ = fn(params: #(List(_), Retry)) {
    let #(items, retry) = params
    // TODO: Should this short circuit upon error?
    list.map(items, fn(x) { retry_exec(exec, #(x, retry), "", 0) })
  }

  prep |> exec_ |> post
}

pub fn parallel_node(prep prep, exec exec, post post) -> Node(state, shared) {
  let exec_ = fn(params: #(List(a), Int)) {
    let #(tasks, timeout) = params
    list.map(tasks, fn(t) { task.async(fn() { exec(t) }) })
    |> task.try_await_all(timeout)
    |> result.all
    |> fn(res) {
      case res {
        Ok(results) -> results
        // TODO: Alternative to panic?
        Error(_) -> panic
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
  |> result.all
  |> fn(res) {
    case res {
      Ok(results) -> results
      // TODO: Alternative to panic
      Error(_) -> panic
    }
  }
}
