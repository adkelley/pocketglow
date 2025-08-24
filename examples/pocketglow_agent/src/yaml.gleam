import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode.{type Decoder}
import gleam/list
import gleam/result
import gleam/string
import types.{type Decision}

// parsed shape: [[#([Int], [Int]), ...]]
pub fn yaml_to_decision(yaml: String) -> Result(Decision, String) {
  use list_dynamic <- result.try(
    yamerl_constr_string(yaml)
    |> decode.run(list_list_decoder())
    |> result.replace_error("Error: failed to parse YAML string"),
  )

  list.flatten(list_dynamic)
  |> list.fold(types.decision_new(), fn(acc, x) {
    let #(k, v) = result.unwrap(decode.run(x, kv_decoder()), #([], []))
    types.kv_strings_to_decision(acc, transform(k), transform(v))
  })
  |> Ok()
}

fn list_list_decoder() -> Decoder(List(List(Dynamic))) {
  decode.list(of: decode.list(decode.dynamic))
}

fn kv_decoder() -> Decoder(#(List(Int), List(Int))) {
  use key <- decode.field(0, decode.list(decode.int))
  use value <- decode.field(1, decode.list(decode.int))
  decode.success(#(key, value))
}

@external(erlang, "yaml_ffi", "yamerl_constr_string")
fn yamerl_constr_string(yaml: String) -> Dynamic

fn transform(codepoints: List(Int)) -> String {
  codepoints
  |> list.map(string.utf_codepoint)
  |> result.values
  |> string.from_utf_codepoints
}
