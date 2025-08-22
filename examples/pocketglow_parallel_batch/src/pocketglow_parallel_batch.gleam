import gleam/io
import gleam/list
import gleam/result
import gleam/string
import pocketglow.{type Node, Node, Params, max_retries, wait}
import simplifile.{Eexist}

import types.{
  type Shared, type Start, type Translated, Shared, Start, Translated,
}
import utils

fn translate_text_node(
  translation: Node(Start, Shared),
) -> Node(Translated, Shared) {
  let Node(Start, shared) = translation
  pocketglow.parallel_node(
    prep: {
      #(
        Params(
          shared.languages,
          max_retries,
          // Try changing wait to see difference in wait times in seconds
          wait,
        ),
        100_000,
      )
    },
    exec: fn(language: String) {
      let text = shared.text
      let prompt = "
Please translate the following markdown file into " <> language <> "." <> "
But keep the original markdown format, links and code blocks.
Directly return the translated text, without any other text or comments.

Original: " <> text <> "Translated:"

      use result <- result.try(utils.call_llm(prompt))
      io.println("Translated " <> language <> " text")
      io.println("language: " <> language <> " translation: " <> result)
      Ok(#(language, result))
    },
    post: fn(results: List(Result(#(String, String), String))) {
      list.map(results, fn(result) {
        let assert Ok(#(language, translation)) = result
        let output_filename =
          shared.output_dir <> "/README_" <> string.uppercase(language) <> ".md"
        let assert Ok(_) =
          simplifile.write(to: output_filename, contents: translation)
      })
      Node(Translated, shared)
    },
  )
}

fn run_flow(text: String) -> Node(Translated, Shared) {
  pocketglow.basic_flow(new(text), create_translation_flow())
}

fn new(text: String) -> Node(Start, Shared) {
  let output_dir_path = "./translations"
  // TODO: Allow directory to already exist
  let assert Ok(_) = case simplifile.create_directory(output_dir_path) {
    Ok(Nil) -> Ok(output_dir_path)
    Error(Eexist) -> {
      io.print_error("Error: " <> output_dir_path <> " already exists.")
      Error(Eexist)
    }
    Error(e) -> Error(e)
  }

  let shared =
    Shared(
      text: text,
      languages: ["Japanese", "German", "Chinese", "Korean"],
      output_dir: output_dir_path,
    )
  Node(Start, shared)
}

fn create_translation_flow() -> fn(Node(Start, Shared)) ->
  Node(Translated, Shared) {
  fn(node) { translate_text_node(node) }
}

pub fn main() -> Nil {
  io.println("Hello from pocketglow_parallel_batch!")
  let source_readme_path = "./README.md"
  let assert Ok(text) = simplifile.read(source_readme_path)
  run_flow(text)
  Nil
}
