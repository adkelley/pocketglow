import gleam/dict.{type Dict}
import gleam/list

pub type PocketflowError {
  Insert(String)
  Get(String)
}

pub type Data(a) =
  Dict(String, a)

type NodeName =
  String

pub type Shared(a) =
  Dict(NodeName, Data(a))

pub type Flow(a) =
  fn(Shared(a)) -> Shared(a)

fn new_acc(shared: Shared(a), nodes: List(String)) -> Shared(a) {
  case nodes {
    [] -> shared
    [node_name, ..rest] -> {
      shared
      |> dict.insert(node_name, dict.new())
      |> new_acc(rest)
    }
  }
}

pub fn new(nodes: List(String)) -> Shared(a) {
  dict.new()
  |> new_acc(nodes)
}

pub fn insert(
  shared shared: Shared(a),
  node_name node_name: String,
  key key: String,
  value value: a,
) -> Result(Shared(a), PocketflowError) {
  case dict.get(shared, node_name) {
    Ok(data) -> {
      dict.new()
      |> dict.insert(key, value)
      |> dict.merge(data, _)
      |> dict.insert(shared, node_name, _)
      |> dict.merge(shared, _)
      |> Ok()
    }
    Error(Nil) ->
      Error(Insert(
        "Pocketflow Error: Missing " <> key <> "\nCheck the spelling",
      ))
  }
}

pub fn get(
  shared shared: Shared(a),
  node_name node_name: String,
  key key: String,
) -> Result(a, PocketflowError) {
  case dict.get(shared, node_name) {
    Ok(data) -> {
      case dict.get(data, key) {
        Ok(value) -> Ok(value)
        Error(Nil) ->
          Error(Get(
            "Pocketflow Error: Missing " <> key <> "\nCheck the spelling",
          ))
      }
    }
    Error(Nil) ->
      Error(Get(
        "Pocketflow Error: Missing " <> node_name <> "\nCheck the spelling",
      ))
  }
}

pub fn node(prep prep, exec exec, post post) -> Shared(a) {
  prep |> exec |> post
}

pub fn batch_node(prep prep, exec exec, post post) -> Shared(a) {
  let exec_ = fn(items: List(List(xs))) { list.map(items, exec) }
  prep |> exec_ |> post
}
