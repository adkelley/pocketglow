import chat/completions
import chat/types.{System, User}
import envoy
import gleam/list

pub fn call_llm(prompt: String) -> String {
  let assert Ok(api_key) = envoy.get("OPENAI_API_KEY")
  let model = completions.default_model()
  let messages =
    list.new()
    |> completions.add_message(System, "You are a helpful assistant")
    |> completions.add_message(User, prompt)
  completions.create(api_key, model, messages)
}
