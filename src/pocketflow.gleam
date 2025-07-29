import gleam/dict.{type Dict}

pub type PocketflowError {
  Insert(String)
  Get(String)
}

pub type Data =
  Dict(String, String)

type NodeName =
  String

pub type Shared =
  Dict(NodeName, Data)

pub type Flow =
  fn(Shared) -> Shared

fn new_acc(shared: Shared, nodes: List(String)) -> Shared {
  case nodes {
    [] -> shared
    [node_name, ..rest] -> {
      shared
      |> dict.insert(node_name, dict.new())
      |> new_acc(rest)
    }
  }
}

pub fn new(nodes: List(String)) -> Shared {
  dict.new()
  |> new_acc(nodes)
}

pub fn insert(
  shared shared: Shared,
  node_name node_name: String,
  key key: String,
  value value: String,
) -> Result(Shared, PocketflowError) {
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
  shared shared: Shared,
  node_name node_name: String,
  key key: String,
) -> Result(String, PocketflowError) {
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

pub fn node(prep prep, exec exec, post post) -> Shared {
  prep |> exec |> post
}
