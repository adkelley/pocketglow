import gleam/io

import gleam/list
import gleam/string
import pocketflow.{Node}

import types.{
  type Article, type Content, type Outline, type Shared, type Start, type Style,
  Content, Outline, Shared, Start, Style,
}
import utils/call_llm.{call_llm}

pub fn generate_outline(
  article: Article(Start, Shared),
) -> Article(Outline, Shared) {
  pocketflow.basic_node(
    prep: {
      let Node(Start, values) = article
      values.topic
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
      let response = call_llm(prompt)
      let assert Ok(yaml_string) = string.split_once(response, on: "```yaml")
      let assert Ok(yaml_string) = string.split_once(yaml_string.1, "```")
      // TODO: parse the YAML string
      // For now, we'll fake it
      let _yaml_string = string.trim(yaml_string.0)
      let outline_yaml =
        "sections:\n- Introduction to AI Safety\n- Key Challenges in AI Safety\n- Strategies for Ensuring AI Safety"
      // let assert Ok(structured_result) = yaml.load(outline_yaml) |> echo
      outline_yaml
    },
    post: fn(outline_yaml: String) {
      io.println("\n===== OUTLINE (YAML) =====\n")
      io.println(outline_yaml)
      io.println("\n===== PARSED OUTLINE =====\n")
      // TODO: Parse the YAML object to extract the sections
      // For now we'll fake it
      let formatted_outline =
        "1. Introduction to AI Safety\n2. Key Challenges in AI Safety\n3. Strategies for Ensuring AI Safety\n"
      io.println(formatted_outline)
      io.println("=========================")
      // Display results
      io.println("\n===== OUTLINE (YAML) =====\n")
      io.println(outline_yaml)
      io.println("\n===== PARSED OUTLINE =====\n")
      io.println(formatted_outline)
      io.println("=========================")

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
  article: Article(Outline, Shared),
) -> Article(Content, Shared) {
  pocketflow.basic_node(
    prep: {
      let Node(Outline, shared) = article
      let formatted_outline = shared.formatted_outline
      // extract each section into a list and pass to exec
      string.split(formatted_outline, "\n")
      |> list.filter(fn(xs) { xs != "" })
    },
    exec: fn(sections: List(String)) {
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
        list.prepend(acc, #(section, content))
      })
      |> list.reverse
    },
    post: fn(sections: List(#(String, String))) {
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

pub fn apply_style(article: Article(Content, Shared)) -> Article(Style, Shared) {
  pocketflow.basic_node(
    prep: {
      let Node(Content, shared) = article
      shared.draft
    },
    exec: fn(draft: String) {
      // Apply a specific style to the article
      let prompt = "
        Rewrite the following draft in a conversational, engaging style: " <> draft <> "

        Make it:
        - Conversational and warm in tone
        - Include rhetorical questions that engage the reader
        - Add analogies and metaphors where appropriate
        - Include a strong opening and conclusion
        "
      call_llm(prompt)
    },
    post: fn(final_article: String) {
      //  Store the final article in shared data
      io.println("\n===== FINAL ARTICLE =====\n")
      io.println(final_article)
      io.println("\n========================")
      let Node(Content, shared) = article
      Node(Style, Shared(..shared, final_article: final_article))
    },
  )
}
