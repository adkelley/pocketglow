import chat/completions
import chat/types.{System, User}
import envoy
import gleam/list
import gleam/result

pub fn call_llm(prompt: String) -> Result(String, String) {
  use api_key <- result.try(
    envoy.get("OPENAI_API_KEY")
    |> result.replace_error("Error: get OPENAI_API_KEY"),
  )
  let model = completions.default_model()
  let messages =
    list.new()
    |> completions.add_message(System, "You are a helpful assistant")
    |> completions.add_message(User, prompt)
  Ok(completions.create(api_key, model, messages))
}
