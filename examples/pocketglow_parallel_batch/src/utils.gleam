import envoy
import gleam/list
import gleam/result
import openai/chat/completions
import openai/chat/types.{System, User}

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

  use res <- result.try(
    completions.create(api_key, model, messages)
    |> result.map_error(with: fn(_) { "openai api error" }),
  )

  use choice <- result.try(
    list.first(res.choices) |> result.map_error(with: fn(_) { "openai error" }),
  )
  Ok(choice.message.content)
}
