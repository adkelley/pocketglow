import gleam/io
import gleam/string
import pocketflow.{type Node, Node}
import task
import types.{
  type Branched, type Fetched, type Shared, type Start, type Suggested, Accepted,
  Fetched, Retry, Shared, Start, Suggested,
}
import utils

pub fn fetch_recipes(recipe: Node(Start, Shared)) -> Node(Fetched, Shared) {
  pocketflow.basic_node(
    prep: {
      let handle =
        task.async(fn() { utils.get_user_input("Enter ingredient: ") })
      let Node(Start, shared) = recipe
      #(
        Shared(..shared, ingredient: task.await_forever(handle)),
        pocketflow.default_retries(),
      )
    },
    exec: fn(shared: Shared) {
      let handle = task.async(fn() { utils.fetch_recipes(shared.ingredient) })
      Ok(Shared(..shared, recipes: task.await_forever(handle)))
    },
    post: fn(shared: Result(Shared, String)) {
      let assert Ok(shared_) = shared
      Node(Fetched, shared_)
    },
  )
}

pub fn suggest_recipe(recipe: Node(Fetched, Shared)) -> Node(Suggested, Shared) {
  pocketflow.basic_node(
    prep: {
      let Node(Fetched, shared) = recipe
      #(shared, pocketflow.default_retries())
    },
    exec: fn(shared: Shared) {
      let handle =
        task.async(fn() {
          utils.call_llm_async(string.join(shared.recipes, ", "))
        })
      Ok(Shared(..shared, suggestion: task.await_forever(handle)))
    },
    post: fn(shared: Result(Shared, String)) {
      let assert Ok(shared_) = shared
      Node(Suggested, shared_)
    },
  )
}

pub fn get_approval(recipe: Node(Suggested, Shared)) -> Node(Branched, Shared) {
  pocketflow.basic_node(
    prep: { #(Nil, pocketflow.default_retries()) },
    exec: fn(_) {
      let handle =
        task.async(fn() { utils.get_user_input("\nAccept this recipe? (y/n) ") })
      Ok(task.await_forever(handle))
    },
    post: fn(answer: Result(String, String)) {
      let assert Ok(answer) = answer
      let Node(Suggested, shared) = recipe
      case answer {
        "y" -> {
          io.println("\nGreat choice! Here's your recipe...")
          io.println("Recipe: " <> shared.suggestion)
          io.println("Ingredient: " <> shared.ingredient)
          Node(Accepted, shared)
        }
        _ -> {
          io.println("\nLet's try another recipe...")
          Node(Retry, shared)
        }
      }
    },
  )
}
