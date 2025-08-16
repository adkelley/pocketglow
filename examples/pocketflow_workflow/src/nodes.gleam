import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/result
import utils/yaml

import gleam/list
import gleam/string
import pocketflow.{type Node, Node, Retry}

import types.{
  type Content, type Outline, type Shared, type Start, type Style, Content,
  Outline, Shared, Start, Style,
}
import utils/call_llm.{call_llm}

pub fn generate_outline(article: Node(Start, Shared)) -> Node(Outline, Shared) {
  pocketflow.basic_node(
    prep: {
      let Node(Start, values) = article
      #(values.topic, pocketflow.default_retries())
    },
    exec: fn(topic: String) {
      let prompt =
        "Create a simple outline for an article about "
        <> topic
        <> "."
        <> "Include at most 3 main sections (no subsections).

      Output the sections in YAML format as shown below:

      ```yaml
      sections:
          - |
              First section
          - |
              Second section
          - |
              Third section
      ```
      "
      let yaml_error = fn(result: Result(a, e)) {
        result.replace_error(result, "Error: YAML string")
      }
      use response <- result.try(call_llm(prompt))
      use yaml_string <- result.try(
        string.split_once(response, on: "```yaml")
        |> yaml_error,
      )
      use yaml_string <- result.try(
        string.split_once(yaml_string.1, "```")
        |> yaml_error,
      )
      use structured_outputs <- result.try(
        string.trim(yaml_string.0)
        |> yaml.yaml_sections
        |> yaml_error,
      )
      list.first(structured_outputs)
      |> yaml_error
    },
    post: fn(exec_res: Result(Dict(String, List(String)), String)) {
      let assert Ok(exec_res) = exec_res
      let assert Ok(headings) = dict.get(exec_res, "sections")
      let outline_yaml = "sections:\n" <> string.join(headings, "")
      io.println("\n===== OUTLINE (YAML) =====\n")
      io.println(outline_yaml)
      io.println("\n===== PARSED OUTLINE =====\n")
      let formatted_outline =
        list.index_fold(headings, "", fn(acc, a, index) {
          acc <> int.to_string(index + 1) <> ". " <> a
        })
      // "1. Introduction to AI Safety\n2. Key Challenges in AI Safety\n3. Strategies for Ensuring AI Safety\n"
      io.println(formatted_outline)
      io.println("\n=========================")
      // Display results
      io.println("\n===== OUTLINE (YAML) =====\n")
      io.println(outline_yaml)
      io.println("\n===== PARSED OUTLINE =====\n")
      io.println(formatted_outline)
      io.println("\n=========================")

      let Node(Start, shared) = article
      Node(
        Outline,
        Shared(
          ..shared,
          outline_yaml: outline_yaml,
          formatted_outline: formatted_outline,
        ),
      )
    },
  )
}

pub fn write_simple_content(
  article: Node(Outline, Shared),
) -> Node(Content, Shared) {
  pocketflow.basic_node(
    prep: {
      let Node(Outline, shared) = article
      // extract each section into a list and pass to exec
      let sections =
        string.split(shared.formatted_outline, "\n")
        |> list.filter(fn(xs) { xs != "" })
      #(sections, pocketflow.default_retries())
    },
    exec: fn(sections: List(String)) {
      let paragraphs =
        list.fold(sections, [], fn(acc, section) {
          let prompt = "
      Write a short paragraph (MAXIMUM 100 WORDS) about this section:" <> section <> "

      Requirements:
      - Explain the idea in simple, easy-to-understand terms
      - Use everyday language, avoiding jargon
      - Keep it very concise (no more than 100 words)
      - Include one brief example or analogy
      "
          let content = call_llm(prompt)
          case content {
            Ok(str) -> list.prepend(acc, Ok(#(section, str)))
            Error(e) -> list.prepend(acc, Error(#(section, e)))
          }
        })
        |> result.partition
      case paragraphs.1 {
        [] -> Ok(paragraphs.0)
        _ -> Error("Error: call_llm")
      }
    },
    post: fn(sections: Result(List(#(String, String)), String)) {
      let assert Ok(sections) = sections
      io.println("\n===== SECTION CONTENTS =====\n")
      let draft =
        list.fold(over: sections, from: "", with: fn(acc, tuple) {
          let section = tuple.0
          let content = tuple.1
          io.println("--- " <> section <> " ---")
          io.println(content <> "\n")
          acc <> section <> "\n" <> content <> "\n"
        })
      io.println("===========================")

      let Node(Outline, shared) = article
      Node(Content, Shared(..shared, draft: draft))
    },
  )
}

pub fn apply_style(article: Node(Content, Shared)) -> Node(Style, Shared) {
  pocketflow.basic_node(
    prep: {
      let Node(Content, shared) = article
      #(shared.draft, pocketflow.default_retries())
    },
    exec: fn(draft: String) {
      // Apply a specific style to the article
      let prompt = "
        Rewrite the following draft into an article that is conversational, with engaging style: " <> draft <> "

        Make it:
        - Conversational and warm in tone
        - Include rhetorical questions that engage the reader
        - Add analogies and metaphors where appropriate
        - Include a strong opening and conclusion

        Your reply should be the article, only

        "
      call_llm(prompt)
    },
    post: fn(exec_res: Result(String, String)) {
      let assert Ok(final_article) = exec_res
      //  Store the final article in shared data
      io.println("\n===== FINAL ARTICLE =====\n")
      io.println(final_article)
      io.println("\n========================")
      let Node(Content, shared) = article
      Node(Style, Shared(..shared, final_article: final_article))
    },
  )
}
