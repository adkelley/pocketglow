import chat/completions
import envoy

pub fn call_llm(prompt: String) -> String {
  let assert Ok(api_key) = envoy.get("OPENAI_API_KEY")
  completions.create(api_key, "gpt-4.1", prompt)
}
