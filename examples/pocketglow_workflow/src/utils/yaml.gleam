import gleam/dict.{type Dict}
import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode.{type DecodeError, type Decoder}
import gleam/erlang/charlist.{type Charlist}
import gleam/list
import gleam/result

pub fn yaml_sections(
  yaml: String,
) -> Result(List(Dict(String, List(String))), List(DecodeError)) {
  let decoder = decode.list(decode.list(section_decoder()))
  let constr = yamerl_constr_string(yaml)
  use doc <- result.try(decode.run(constr, decoder))
  list.flatten(doc)
  |> list.map(fn(tuple: #(List(Int), List(List(Int)))) {
    let #(section, headings) = tuple
    let headings = list.map(headings, to_string)
    dict.new() |> dict.insert(to_string(section), headings)
  })
  |> Ok()
}

@external(erlang, "yaml_ffi", "yamerl_constr_string")
fn yamerl_constr_string(yaml: String) -> Dynamic

@external(erlang, "gleam_stdlib", "identity")
fn from_codepoints(c: List(Int)) -> Charlist

fn to_string(codepoints: List(Int)) -> String {
  codepoints
  |> from_codepoints
  |> charlist.to_string
}

fn section_decoder() -> Decoder(#(List(Int), List(List(Int)))) {
  use section <- decode.field(0, decode.list(decode.int))
  use headings <- decode.field(1, decode.list(decode.list(decode.int)))
  decode.success(#(section, headings))
}
