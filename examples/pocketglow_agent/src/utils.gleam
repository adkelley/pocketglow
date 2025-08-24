import chat/completions
import chat/types.{Model, System, User}
import envoy
import gleam/dynamic/decode
import gleam/http
import gleam/http/request
import gleam/httpc
import gleam/int
import gleam/json
import gleam/list
import gleam/result
import gleam/string

pub type WebResult {
  WebResult(title: String, url: String, description: String)
}

fn web_results_to_context(results: List(WebResult)) -> String {
  list.fold(results, "", fn(acc, result) {
    acc
    <> "title: "
    <> result.title
    <> "url: "
    <> result.url
    <> "description: "
    <> result.description
  })
}

fn web_results_decoder() {
  use title <- decode.field("title", decode.string)
  use url <- decode.field("url", decode.string)
  use description <- decode.field("description", decode.string)
  decode.success(WebResult(title: title, url: url, description: description))
}

fn brave_response_decoder() {
  decode.at(["web", "results"], decode.list(web_results_decoder()))
}

pub fn search_web_brave(query: String) -> Result(String, String) {
  let search_query = string.replace(query, " ", "+")

  let url = "https://api.search.brave.com/res/v1/web/search?q=" <> search_query
  let assert Ok(base_req) = request.to(url)
  let assert Ok(api_key) = envoy.get("BRAVE_API_KEY")

  let req =
    base_req
    |> request.prepend_header("accept", "application/json")
    |> request.prepend_header("Accept-Encoding", "qzip")
    |> request.prepend_header("X-Subscription-Token", api_key)
    |> request.set_method(http.Get)

  use resp <- result.try(
    httpc.send(req) |> result.replace_error("Error: Bad API response"),
  )
  case resp.status == 200 {
    True -> {
      use web_results <- result.try(
        json.parse(resp.body, brave_response_decoder())
        |> result.replace_error("Error: bad JSON response"),
      )
      web_results_to_context(web_results) |> Ok()
      // Ok(web_results)
    }

    False ->
      Error(
        "Error: Bad Brave API response code: " <> int.to_string(resp.status),
      )
  }
}

// \"web\":{\"type\":\"search\",\"results\":[{\"title\":\"Quantum computing - Wikipedia\",\"url\":\"https://en.wikipedia.org/wiki/Quantum_computing\",\"is_source_local\":false,\"is_source_both\":false,\"description\":\"A <strong>quantum</strong> <strong>computer</strong> is a (real or theoretical) <strong>computer</strong> that uses <strong>quantum</strong> mechanical phenomena in an essential way: a <strong>quantum</strong> <strong>computer</strong> exploits superposed and entangled states and the (non-deterministic) outcomes of <strong>quantum</strong> measurements as features of its <strong>computation</strong>.\",\"page_age\":\"2025-08-21T03:38:57\",\"profile\":{\"name\":\"Wikipedia\",\"url\":\"https://en.wikipedia.org/wiki/Quantum_computing\",\"long_name\":\"en.wikipedia.org\",\"img\":\"https://imgs.search.brave.com/m6XxME4ek8DGIUcEPCqjRoDjf2e54EwL9pQzyzogLYk/rs:fit:32:32:1:0/g:ce/aHR0cDovL2Zhdmlj/b25zLnNlYXJjaC5i/cmF2ZS5jb20vaWNv/bnMvNjQwNGZhZWY0/ZTQ1YWUzYzQ3MDUw/MmMzMGY3NTQ0ZjNj/NDUwMDk5ZTI3MWRk/NWYyNTM4N2UwOTE0/NTI3ZDQzNy9lbi53/aWtpcGVkaWEub3Jn/Lw\"},\"language\":\"en\",\"family_friendly\":true,\"type\":\"search_result\",\"subtype\":\"generic\",\"is_live\":false,\"meta_url\":{\"scheme\":\"https\",\"netloc\":\"en.wikipedia.org\",\"hostname\":\"en.wikipedia.org\",\"favicon\":\"https://imgs.search.brave.com/m6XxME4ek8DGIUcEPCqjRoDjf2e54EwL9pQzyzogLYk/rs:fit:32:32:1:0/g:ce/aHR0cDovL2Zhdmlj/b25zLnNlYXJjaC5i/cmF2ZS5jb20vaWNv/bnMvNjQwNGZhZWY0/ZTQ1YWUzYzQ3MDUw/MmMzMGY3NTQ0ZjNj/NDUwMDk5ZTI3MWRk/NWYyNTM4N2UwOTE0/NTI3ZDQzNy9lbi53/aWtpcGVkaWEub3Jn/Lw\",\"path\":\"› wiki  › Quantum_computing\"},\"age\":\"2 days ago\"},{

pub fn call_llm(prompt: String) -> Result(String, String) {
  use api_key <- result.try(
    envoy.get("OPENAI_API_KEY")
    |> result.replace_error("Error: get OPENAI_API_KEY"),
  )
  let model = completions.default_model()
  let model = Model(..model, name: "gpt-4.1")
  let messages =
    list.new()
    |> completions.add_message(System, "You are a helpful assistant")
    |> completions.add_message(User, prompt)

  completions.create(api_key, model, messages)
  |> result.map_error(with: fn(_) { "openai api error" })
}
