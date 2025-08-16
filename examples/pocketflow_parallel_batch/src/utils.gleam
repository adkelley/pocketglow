import chat/completions
import chat/types.{System, User}
import envoy
import gleam/list
import gleam/result

pub fn call_llm(prompt: String) -> Result(String, String) {
  let model = completions.default_model()
  use api_key <- result.try(
    envoy.get("OPENAI_API_KEY")
    |> result.replace_error("Error: get OPENAI_API_KEY"),
  )
  let messages =
    list.new()
    |> completions.add_message(System, "You are a helpful assistant")
    |> completions.add_message(User, prompt)
  Ok(completions.create(client: api_key, model: model, messages: messages))
}
