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
      Shared(..shared, ingredient: task.await_forever(handle))
    },
    exec: fn(shared: Shared) {
      let handle = task.async(fn() { utils.fetch_recipes(shared.ingredient) })
      Shared(..shared, recipes: task.await_forever(handle))
    },
    post: fn(shared: Shared) { Node(Fetched, shared) },
  )
}

pub fn suggest_recipe(recipe: Node(Fetched, Shared)) -> Node(Suggested, Shared) {
  pocketflow.basic_node(
    prep: {
      let Node(Fetched, shared) = recipe
      shared
    },
    exec: fn(shared: Shared) {
      let handle =
        task.async(fn() {
          utils.call_llm_async(string.join(shared.recipes, ", "))
        })
      Shared(..shared, suggestion: task.await_forever(handle))
    },
    post: fn(shared: Shared) { Node(Suggested, shared) },
  )
}

pub fn get_approval(recipe: Node(Suggested, Shared)) -> Node(Branched, Shared) {
  pocketflow.basic_node(
    prep: { Nil },
    exec: fn(_) {
      let handle =
        task.async(fn() { utils.get_user_input("\nAccept this recipe? (y/n) ") })
      task.await_forever(handle)
    },
    post: fn(answer: String) {
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
