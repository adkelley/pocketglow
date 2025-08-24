import gleam/io
import gleam/result
import gleam/string
import pocketglow.{type Node, Node, Params, max_retries, wait}
import types.{
  type Action, type AnsweredQuestion, type Decision, type Shared, Answer,
  AnsweredQuestion, Decide, Search, Shared,
}
import utils
import yaml

pub fn decide_action(node: Node(Action, Shared)) -> Node(Action, Shared) {
  pocketglow.basic_node(
    prep: {
      let Node(_, shared) = node
      Params(#(shared.question, shared.context), max_retries, wait)
    },
    exec: fn(prep_res: #(String, String)) {
      let #(question, context) = prep_res
      let prompt = "
### CONTEXT
You are a research assistant that can search the web.\n
Question: " <> question <> "\nPrevious Research: " <> context <> "\n\n### ACTION SPACE
[1] search
  Description: Look up more information on the web
  Parameters:
    - query (str): What to search for

[2] answer
  Description: Answer the question with current knowledge
  Parameters:
    - answer (str): Final answer to the question

## NEXT ACTION
Decide the next action based on the context and available actions.
Return your response in this format:

```yaml
thinking: |
    <your step-by-step reasoning process>
action: search OR answer
reason: <why you chose this action>
answer: <if action is answer>
search_query: <specific search query if action is search>
```
IMPORTANT: Make sure to:
1. Use proper indentation (4 spaces) for all multi-line fields
2. Use the | character for multi-line text fields
3. Keep single-line fields without the | character
"
      let yaml_error = fn(result: Result(a, e)) {
        result.replace_error(result, "Error: YAML string")
      }
      use response <- result.try(utils.call_llm(prompt))
      use yaml_string <- result.try(
        string.split_once(response, on: "```yaml")
        |> yaml_error,
      )
      use yaml_string <- result.try(
        string.split_once(yaml_string.1, "```")
        |> yaml_error,
      )
      use decision <- result.try(
        string.trim(yaml_string.0)
        |> yaml.yaml_to_decision,
      )

      Ok(decision)
    },
    post: fn(exec_res: Result(Decision, String)) {
      let assert Ok(decision) = exec_res
      let Node(_, shared) = node
      let shared = case decision.action {
        Search -> {
          io.println("🔍 Agent decided to search for: " <> decision.search_query)
          Shared(..shared, search_query: decision.search_query)
        }
        Answer -> {
          io.println("💡 Agent decided to answer the question")
          Shared(..shared, context: decision.answer)
        }
        Decide -> {
          io.print_error("Agent didn't decide properly")
          shared
        }
      }
      Node(decision.action, shared)
    },
  )
}

pub fn search_web(node: Node(Action, Shared)) -> Node(Action, Shared) {
  pocketglow.basic_node(
    prep: {
      let Node(_, shared) = node
      let search_query = string.replace(shared.search_query, " ", "+")
      Params(search_query, max_retries, wait)
    },
    exec: fn(search_query: String) {
      // Call the search utility function
      io.println("🌐 Searching the web for: " <> search_query)
      utils.search_web_brave(search_query)
    },
    post: fn(exec_res: Result(String, String)) {
      let assert Ok(web_results) = exec_res
      let Node(_, shared) = node
      let context =
        shared.context
        <> "\n\nSEARCH: "
        <> shared.search_query
        <> "\nRESULTS: "
        <> web_results
      let shared = Shared(..shared, context: context)
      Node(Decide, shared)
    },
  )
}

pub fn answer_question(
  node: Node(Action, Shared),
) -> Node(AnsweredQuestion, Shared) {
  pocketglow.basic_node(
    prep: {
      let Node(_, shared) = node
      Params(#(shared.question, shared.context), max_retries, wait)
    },
    exec: fn(prep_res: #(String, String)) {
      let #(question, context) = prep_res
      let prompt = "
### CONTEXT
Based on the following information, answer the question.
Question: " <> question <> "Research: " <> context <> "## YOUR ANSWER:\n
Provide a comprehensive answer using the research results.
"
      utils.call_llm(prompt)
    },
    post: fn(exec_res: Result(String, String)) {
      let assert Ok(answer) = exec_res
      let Node(_, shared) = node
      let shared = Shared(..shared, answer: answer)
      io.println("✅ Answer generated successfully")
      Node(AnsweredQuestion, shared)
    },
  )
}
