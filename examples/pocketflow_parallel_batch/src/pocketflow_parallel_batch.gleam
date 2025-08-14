import gleam/io
import gleam/list
import gleam/string
import pocketflow.{type Node, Node}
import simplifile
import types.{
  type Shared, type Start, type Translated, Shared, Start, Translated,
}
import utils

fn translate_text_node(
  translation: Node(Start, Shared),
) -> Node(Translated, Shared) {
  pocketflow.basic_node(
    prep: {
      let Node(Start, shared) = translation
      let assert Ok(language) = list.first(shared.languages)
      #(shared.text, language)
    },
    exec: fn(exec_res: #(String, String)) {
      let #(text, language) = exec_res

      let prompt = "
Please translate the following markdown file into " <> language <> "." <> "
But keep the original markdown format, links and code blocks.
Directly return the translated text, without any other text or comments.

Original: " <> text <> "Translated:"

      let result = utils.call_llm(prompt)
      io.println("Translated " <> language <> " text")
      io.println("language: " <> language <> " translation: " <> result)
      #(language, result)
    },
    post: fn(result: #(String, String)) {
      let #(language, translation_) = result
      let Node(Start, shared) = translation
      let output_filename =
        shared.output_dir <> "/README_" <> string.uppercase(language)
      let assert Ok(_) =
        simplifile.write(to: output_filename, contents: translation_)
      Node(Translated, shared)
    },
  )
}

fn run_flow(text: String) -> Node(Translated, Shared) {
  let start = new(text)
  pocketflow.basic_flow(start, create_translation_flow())
}

fn new(text: String) -> Node(Start, Shared) {
  let shared =
    Shared(text: text, languages: ["Japanese"], output_dir: "./Translations")
  Node(Start, shared)
}

fn create_translation_flow() -> fn(Node(Start, Shared)) ->
  Node(Translated, Shared) {
  fn(node) { translate_text_node(node) }
}

pub fn main() -> Nil {
  io.println("Hello from pocketflow_parallel_batch!")
  let source_readme_path = "./README.md"
  let assert Ok(text) = simplifile.read(source_readme_path)
  run_flow(text)

  // TODO File Error Handling
  // io.print_error("Error: Could not find the source README file at " <> source_readme_path) ""
  // io.println("Error reading file " <> source_readme_path <> " " <> e)

  Nil
}
