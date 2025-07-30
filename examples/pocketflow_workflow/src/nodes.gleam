import gleam/dict
import gleam/io
import gleam/list
import gleam/string
import pocketflow.{type Shared}
import utils/call_llm.{call_llm}

pub fn generate_outline(shared: Shared(String)) -> Shared(String) {
  pocketflow.node(
    prep: {
      let assert Ok(topic) = pocketflow.get(shared, "generate_outline", "topic")
      topic
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
      let assert Ok(post_res) =
        pocketflow.insert(
          shared,
          "generate_outline",
          "outline_yaml",
          outline_yaml,
        )
      io.println("\n===== OUTLINE (YAML) =====\n")
      io.println(outline_yaml)
      io.println("\n===== PARSED OUTLINE =====\n")
      // TODO: Parse the YAML object to extract the sections
      // For now we'll fake it
      let formatted_outline =
        "1. Introduction to AI Safety\n2. Key Challenges in AI Safety\n3. Strategies for Ensuring AI Safety\n"
      io.println(formatted_outline)
      io.println("=========================")
      let assert Ok(post_res) =
        pocketflow.insert(
          post_res,
          "generate_outline",
          "formatted_outline",
          formatted_outline,
        )
      // Display results
      io.println("\n===== OUTLINE (YAML) =====\n")
      io.println(outline_yaml)
      io.println("\n===== PARSED OUTLINE =====\n")
      io.println(formatted_outline)
      io.println("=========================")
      post_res
    },
  )
}

pub fn write_simple_content(shared: Shared(String)) -> Shared(String) {
  pocketflow.node(
    prep: {
      let assert Ok(formatted_outline) =
        pocketflow.get(shared, "generate_outline", "formatted_outline")
      // extract each section into a list and pass to exec
      string.split(formatted_outline, "\n")
      |> list.filter(fn(xs) { xs != "" })
    },
    exec: fn(sections: List(String)) {
      list.fold(sections, shared, fn(acc, section) {
        let prompt = "
      Write a short paragraph (MAXIMUM 100 WORDS) about this section:" <> section <> "

      Requirements:
      - Explain the idea in simple, easy-to-understand terms
      - Use everyday language, avoiding jargon
      - Keep it very concise (no more than 100 words)
      - Include one brief example or analogy
      "
        let content = call_llm(prompt)
        let assert Ok(acc) =
          pocketflow.insert(acc, "write_simple_content", section, content)
        acc
      })
    },
    post: fn(exec_res: Shared(String)) {
      let assert Ok(sections) = dict.get(exec_res, "write_simple_content")
      let sections = dict.to_list(sections)
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
      let assert Ok(post_res) =
        pocketflow.insert(exec_res, "write_simple_content", "draft", draft)
      post_res
    },
  )
}

pub fn apply_style(shared: Shared(String)) -> Shared(String) {
  pocketflow.node(
    prep: {
      let assert Ok(draft) =
        pocketflow.get(shared, "write_simple_content", "draft")
      draft
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
    post: fn(exec_res: String) {
      //  Store the final article in shared data
      let assert Ok(post_res) =
        pocketflow.insert(shared, "apply_style", "final_article", exec_res)
      io.println("\n===== FINAL ARTICLE =====\n")
      io.println(exec_res)
      io.println("\n========================")
      post_res
    },
  )
}
